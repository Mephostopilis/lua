﻿#ifndef ANDROID
#define LUA_LIB
#endif // !ANDROID

#include "xluaconf.h"
#include "ringbuf.h"
#include "write_buffer.h"

#include <lua.h>
#include <lauxlib.h>

#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include <time.h>
#include <assert.h>

#define SOCKET_DATA 0
#define SOCKET_CLOSE 1
#define SOCKET_OPEN 2
#define SOCKET_ACCEPT 3
#define SOCKET_ERROR 4
#define SOCKET_EXIT 5
#define SOCKET_UDP 6

#define SOCKET_TYPE_INVALID 0
#define SOCKET_TYPE_RESERVE 1
#define SOCKET_TYPE_PLISTEN 2
#define SOCKET_TYPE_LISTEN 3
#define SOCKET_TYPE_CONNECTING 4
#define SOCKET_TYPE_CONNECTED 5
#define SOCKET_TYPE_HALFCLOSE 6
#define SOCKET_TYPE_PACCEPT 7
#define SOCKET_TYPE_BIND 8
#define SOCKET_TYPE_CLOSE 9

#define PROTOCOL_TCP 0
#define PROTOCOL_UDP 1
#define PROTOCOL_UDPv6 2

#define UDP_ADDRESS_SIZE 19	// ipv6 128bit + port 16bit + 1 byte type

#define MAX_SOCKET_NUM (4)

static void
init_lib(lua_State *L) {
#if defined(_WIN32)
	WSADATA wsaData;
	int iResult = WSAStartup(MAKEWORD(2, 2), &wsaData);
	if (iResult != 0) {
		luaL_error(L, "init win32 failture.");
	}
#endif // WIN32
}

static void
close_lib(lua_State *L) {
#if defined(_WIN32)
	WSACleanup();
#endif // WIN32
}

typedef struct lua_socket {
	struct lua_socket *next;
	struct lua_socket *listen;    // 所有监听的socket并且有客户来链接
	struct lua_socket *accept;    // 所有接受的
	int             id;
	int             fd;
	uint8_t         protocol;
	uint8_t         type;
	uint8_t         header;
	struct sockaddr local;
	struct sockaddr remote;
	struct wb_list *wl;
	ringbuf_t      *rb;
} lua_socket;

typedef struct lua_gate {
	int                 count;        // 使用了多少
	fd_set              rfds;
	fd_set              wfds;
	struct lua_socket  *head;         // 遍历所有socket
	struct lua_socket  *error;        // 从head删除，加入错误
	struct lua_socket  *disconn;      // 从head删除，加入断连
	struct lua_socket  *accept;       // 加入accept，单独处理
	struct lua_socket  *freelist;     // 用来查找下一个分配的socket
	struct lua_socket   socks[0];     // 分配的所有socket
} lua_gate;

///////////////////////////////////////////////////////////////////// 处理poll
static void
gate_add(struct lua_gate *g, struct lua_socket *so) {
	assert(g != NULL && so != NULL);
	if (g->head == NULL) {
		g->head = so;
	} else {
		struct lua_socket *ptr = g->head;
		while (ptr->next && ptr != so) {
			ptr = ptr->next;
		}
		assert(ptr != so);
		ptr->next = so;
	}
	so->next = NULL;
}

static struct lua_socket *
gate_del(struct lua_gate *g, struct lua_socket *so) {
	assert(g != NULL && so != NULL);
	if (g->head == NULL) {
		return NULL;
	} else if (g->head == so) {
		assert(so->type != SOCKET_TYPE_INVALID);
		g->head = g->head->next;
		g->count--;
		so->type = SOCKET_TYPE_INVALID;
		return so;
	} else {
		struct lua_socket *ptr = g->head;
		while (ptr != NULL && ptr->next != NULL) {
			if (ptr->next == so) {
				ptr->next = so->next;
				so->next = NULL;
				so->type = SOCKET_TYPE_INVALID;
				g->freelist = so;
				return so;
			}
			ptr = ptr->next;
		}
	}
	return NULL;
}
///////////////////////////////////////////////////////////////////// 结束poll


static void
gate_add_disconected(struct lua_gate *g, struct lua_socket *so) {
	assert(g != NULL && so != NULL);
	if (g->disconn == NULL) {
		g->disconn = so;
		so->next = NULL;
	} else {
		struct lua_socket *pp = g->disconn;
		while (pp != NULL && pp->next != NULL) {
			pp = pp->next;
		}
		pp->next = so;
		so->next = NULL;
	}
}

static int
on_disconnected(lua_State *L, struct lua_gate *g) {
	struct lua_socket *so = g->disconn;
	g->disconn = NULL;
	while (so) {
		lua_getglobal(L, "xluasocket");
		lua_rawgetp(L, -1, g);
		luaL_checktype(L, -1, LUA_TFUNCTION);
		lua_pushinteger(L, so->id);
		lua_pushinteger(L, SOCKET_CLOSE);
		lua_pushinteger(L, 0);
		lua_pcall(L, 3, 0, 0);
		lua_pop(L, 1);

		so = so->next;
	}
	return 0;
}

static int
on_data(lua_State *L, struct lua_gate *g, struct lua_socket *so, char *buffer, int len) {
	(void)g;
	lua_getglobal(L, "xluasocket");
	lua_rawgetp(L, -1, g);
	luaL_checktype(L, -1, LUA_TFUNCTION);

	lua_pushinteger(L, so->id);
	lua_pushinteger(L, SOCKET_DATA);
	lua_pushlstring(L, buffer, len);
	lua_pcall(L, 3, 0, 0);
	lua_pop(L, 1);
	return 0;
}

static int
on_error(lua_State *L, struct lua_gate *g) {
	struct lua_socket *so = g->error;
	g->error = NULL;
	while (so) {
		lua_getglobal(L, "xluasocket");
		lua_rawgetp(L, -1, g);
		luaL_checktype(L, -1, LUA_TFUNCTION);
		lua_pushinteger(L, so->id);
		lua_pushinteger(L, SOCKET_ERROR);
		lua_pushinteger(L, 0);
		lua_pcall(L, 3, 0, 0);
		lua_pop(L, 1);
		so = so->next;
	}
	return 0;
}

static int
on_accept(lua_State *L, struct lua_gate *g) {
	struct lua_socket *l = g->accept;
	g->accept = NULL;
	while (l) {
		assert(l->type == SOCKET_TYPE_LISTEN);
		struct lua_socket *so = l->accept;
		l->accept = NULL;
		while (so) {
			assert(so->type == SOCKET_TYPE_CONNECTED);
			lua_getglobal(L, "xluasocket");
			lua_rawgetp(L, -1, g);
			luaL_checktype(L, -1, LUA_TFUNCTION);
			lua_pushinteger(L, l->id);
			lua_pushinteger(L, SOCKET_ACCEPT);
			lua_pushinteger(L, so->id);
			lua_pcall(L, 3, 0, 0);
			lua_pop(L, 1);

			so = so->next;
		}
		l = l->listen;
	}
	return 0;
}

static int
close_sock(lua_State *L, struct lua_gate *g, struct lua_socket *so) {
#if defined(_WIN32)
	closesocket(so->fd);
#else
	close(so->fd);
#endif // WIN32
	gate_del(g, so);
	return 0;
}

static int
lnew(lua_State *L) {
	luaL_checktype(L, 1, LUA_TFUNCTION);

	init_lib(L);
	struct lua_gate *g = (struct lua_gate *)lua_newuserdata(L, sizeof(*g) + ((MAX_SOCKET_NUM + 1) * sizeof(struct lua_socket)));
	memset(g, 0, sizeof(*g) + ((MAX_SOCKET_NUM + 1) * sizeof(struct lua_socket)));          // 分配了1024个，0作为一个标记
	g->freelist = &g->socks[MAX_SOCKET_NUM];
	for (size_t i = 1; i <= MAX_SOCKET_NUM; i++) {
		g->socks[i].id = i;
		g->socks[i].wl = wb_list_new(WRITE_BUFFER_SIZE);
		g->socks[i].rb = ringbuf_new(RINGBUF_SIZE);
	}

	lua_getglobal(L, "xluasocket");
	if (!lua_istable(L, -1)) {
		lua_pop(L, 1);
		lua_newtable(L);
		lua_setglobal(L, "xluasocket");
		lua_getglobal(L, "xluasocket");
	}
	lua_pushvalue(L, 1);
	lua_rawsetp(L, -2, g);
	lua_pop(L, 1);

	return 1;
}

/*
** @return 0 resiv
		   [1, MAX_SOCKET_NUM]
*/
static int
lsocket(lua_State *L) {
	struct lua_gate *g = (struct lua_gate *)lua_touserdata(L, 1);
	if (g->count > MAX_SOCKET_NUM) {
		lua_pushinteger(L, 0);
		return 1;
	}
	struct lua_socket *so = g->freelist;
	if (++g->count > MAX_SOCKET_NUM) {
		g->freelist = &g->socks[0];
	} else {
		for (size_t i = (so->id - 1); i != so->id; ) {
			if (g->socks[i].type == SOCKET_TYPE_INVALID) {
				g->freelist = &g->socks[i];
				break;
			}
			--i;
			i = (i < 1) ? (MAX_SOCKET_NUM) : i;
		}
	}

	so->next = NULL;
	//so->extra = NULL;
	so->type = SOCKET_TYPE_RESERVE;
	so->protocol = luaL_checkinteger(L, 2);
	so->header = luaL_checkinteger(L, 3);
	if (so->protocol == PROTOCOL_TCP) {
		so->fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	} else if (so->protocol == PROTOCOL_UDP) {
		so->fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	} else if (so->protocol == PROTOCOL_UDPv6) {
		so->fd = socket(AF_INET6, SOCK_DGRAM, 0);
	}

	lua_pushinteger(L, so->id);
	return 1;
}

static int
llisten(lua_State *L) {
	struct lua_gate *g = (struct lua_gate *)lua_touserdata(L, 1);
	lua_Integer id = luaL_checkinteger(L, 2);
	lua_socket *so = &g->socks[id];
	if (so->type != SOCKET_TYPE_RESERVE) {
		return 0;
	}
	size_t sz;
	const char *addr = luaL_checklstring(L, 3, &sz);
	uint16_t port = luaL_checkinteger(L, 4);
	struct sockaddr_in *local = (struct sockaddr_in *)&so->local;
	local->sin_family = AF_INET;
	local->sin_port = htons(port);
	inet_pton(AF_INET, addr, &local->sin_addr);
	bind(so->fd, (const struct sockaddr*)local, sizeof(*local));
	so->type = SOCKET_TYPE_PLISTEN;
	listen(so->fd, 0);
	lua_pushinteger(L, 0);
	return 1;
}

/*
 * @return 0 success
		   1 not find socket
		   2 connect error
		   3 overflow
*/
static int
lconnect(lua_State *L) {
	struct lua_gate *g = (struct lua_gate *)lua_touserdata(L, 1);
	lua_Integer id = luaL_checkinteger(L, 2);
	if (id < 1 && id >= MAX_SOCKET_NUM) {
		lua_pushinteger(L, 3);
		return 1;
	}
	lua_socket *so = &g->socks[id];
	size_t sz;
	const char *addr = luaL_checklstring(L, 3, &sz);
	uint16_t port = luaL_checkinteger(L, 4);
	struct sockaddr_in * remote = (struct sockaddr_in *)&so->remote;
	remote->sin_family = AF_INET;
	remote->sin_port = htons(port);
	inet_pton(AF_INET, addr, &remote->sin_addr);
	if (so->protocol == PROTOCOL_TCP) {
		int res = connect(so->fd, (const struct sockaddr*)&so->remote, sizeof(so->remote));
		if (res == -1) {
#if defined(_MSC_VER)
			int err = WSAGetLastError();
			(void)err;
			closesocket(so->fd);
#else
			close(so->fd);
#endif
			assert(so->next == NULL);
			lua_pushinteger(L, 2);
			return 1;
		} else {
			so->type = SOCKET_TYPE_CONNECTED;
			lua_pushinteger(L, 0);
			return 1;
		}
	} else if (so->protocol == PROTOCOL_UDP) {
		so->type = SOCKET_TYPE_CONNECTED;
		lua_pushinteger(L, 0);
		return 1;
	} else if (so->protocol == PROTOCOL_UDPv6) {
		so->type = SOCKET_TYPE_CONNECTED;
		lua_pushinteger(L, 0);
		return 1;
	}
	return 0;
}

static int
lstart(lua_State *L) {
	struct lua_gate *g = (struct lua_gate *)lua_touserdata(L, 1);
	lua_Integer id = luaL_checkinteger(L, 2);
	gate_add(g, &g->socks[id]);
	if (g->socks[id].type == SOCKET_TYPE_PLISTEN) {
		g->socks[id].type = SOCKET_TYPE_LISTEN;
	}
	lua_pushinteger(L, 0);
	return 1;
}

/*
** @return -1 0  success
		   -1 1  socet type is wrong.
		   -1 2  socket not connectd
		   -1 3  send socket socket error.
			  4  send buffer less than 0.
			  5  header type is wrong.
*/
static int
lsend(lua_State *L) {
	struct lua_gate *g = (struct lua_gate *)lua_touserdata(L, 1);
	lua_Integer id = luaL_checkinteger(L, 2);
	if (id <= 0 && id > MAX_SOCKET_NUM) {
		lua_pushinteger(L, 2);
		return 1;
	}
	struct lua_socket * so = &g->socks[id];
	if (so->type != SOCKET_TYPE_CONNECTED) {
		lua_pushinteger(L, 1);
		return 1;
	}

	size_t sz;
	const char *buffer = luaL_checklstring(L, 3, &sz);
	if (sz <= 0) {
		lua_pushinteger(L, 4);
		return 1;
	}
	assert(so->protocol == PROTOCOL_TCP);
	if (so->header == HEADER_TYPE_LINE) {
		wb_list_push_line(so->wl, (char *)buffer, sz);
	} else if (so->header == HEADER_TYPE_PG) {
		wb_list_push_string(so->wl, (char *)buffer, sz);
	} else {
		lua_pushinteger(L, 5);
		return 1;
	}
	lua_pushinteger(L, 0);
	lua_pushinteger(L, sz);
	return 2;
}

static int
lsendto(lua_State *L) {
	struct lua_gate *g = (struct lua_gate *)lua_touserdata(L, 1);
	struct lua_socket * so = (struct lua_socket*)lua_touserdata(L, 2);
	size_t len = 0;
	const char *buffer = lua_tolstring(L, 3, &len);
	sendto(so->fd, buffer, len, 0, &so->remote, sizeof(so->remote));
	return 0;
}

static int
lpoll(lua_State *L) {
	struct lua_gate *g = (struct lua_gate *)lua_touserdata(L, 1);
	if (g->head == NULL) {
		return 0;
	}
	int max = 0;
	FD_ZERO(&g->rfds);
	FD_ZERO(&g->wfds);
	struct lua_socket *ptr = g->head;
	while (ptr) {
		max = (max > ptr->fd) ? max : ptr->fd;
		FD_SET(ptr->fd, &g->rfds);
		FD_SET(ptr->fd, &g->wfds);
		//ptr->extra = NULL;
		ptr = ptr->next;
	}
	if (max <= 0) {
		return 0;
	}
	struct timeval timeout;
	timeout.tv_sec = 0;
	timeout.tv_usec = 0;
	int res = select(max + 1, &g->rfds, &g->wfds, NULL, &timeout);
	if (res <= 0) {
		return 0;
	}
	
	struct lua_socket *next = NULL, *prev = NULL;
	prev = g->head;
	ptr = g->head;
	while (ptr != NULL) {
		if (ptr->next != NULL)
			next = ptr->next;
		else
			next = NULL;

		if (FD_ISSET(ptr->fd, &g->rfds)) {
			if (ptr->type == SOCKET_TYPE_LISTEN) {
				if (g->count > MAX_SOCKET_NUM) {
					continue;
				}
				int fd = accept(ptr->fd, NULL, NULL);
				if (fd < 0) {
					continue;
				}
				struct lua_socket *so = g->freelist;
				if (++g->count > (MAX_SOCKET_NUM)) {
					g->freelist = &g->socks[0];
				} else {
					for (size_t i = (so->id - 1); i != so->id; ) {
						if (g->socks[i].type == SOCKET_TYPE_INVALID) {
							g->freelist = &g->socks[i];
							break;
						}
						--i;
						i = (i < 1) ? (MAX_SOCKET_NUM) : i;
					}
				}
				so->type = SOCKET_TYPE_CONNECTED;
				int addlen;
				so->fd = fd;
				
				if (ptr->accept == NULL) {
					ptr->accept = so;
					if (g->accept == NULL) {
						g->accept = ptr;
					} else {
						struct lua_socket *pp = g->accept;
						while (pp != NULL && pp->listen != NULL) {
							pp = pp->listen;
						}
						pp->listen = ptr;
						ptr->listen = NULL;
					}
				} else {
					struct lua_socket *pp = ptr->accept;
					while (pp != NULL && pp->accept != NULL) {
						pp = pp->accept;
					}
					pp->next = so;
					so->next = NULL;
				}
			} else if (ptr->type == SOCKET_TYPE_CONNECTED) {
				if (ptr->protocol == PROTOCOL_TCP) {
					int res = ringbuf_read_fd(ptr->rb, ptr->fd, RINGBUF_SIZE);
					if (res == -1) {
#if defined(_WIN32)
						int e = WSAGetLastError();
						if (e == WSAEINTR || e == WSAEINPROGRESS) {
#else
						if (errno == EINTR || errno == EWOULDBLOCK || errno == EAGAIN) {
#endif
							// 当前so不处理
							prev = ptr;
							ptr = next;
							continue;
#if defined(_WIN32)
						} else if (e == WSAECONNRESET) {
							closesocket(ptr->fd);
#else
						} else if (errno == ECONNRESET) {
							close(ptr->fd);
#endif
							ptr->type = SOCKET_TYPE_CLOSE;
							prev->next = next;
							ptr->next = NULL;
							gate_add_disconected(g, ptr);
							ptr = next;
							continue;
						} else {
#if defined(_WIN32)
							closesocket(ptr->fd);
#else
							close(ptr->fd);
#endif
							ptr->type = SOCKET_TYPE_CLOSE;
							prev->next = next;
							ptr->next = NULL;
							gate_add_disconected(g, ptr);
							ptr = next;
							continue;
						}
					} else if (res == 0) {
#if defined(_WIN32)
						closesocket(ptr->fd);
#else
						close(ptr->fd);
#endif
						ptr->type = SOCKET_TYPE_CLOSE;
						prev->next = next;
						ptr->next = NULL;
						gate_add_disconected(g, ptr);
						ptr = next;
						continue;
					}

					if (ptr->header == HEADER_TYPE_PG) {
						int count = 0;
						int size = 0;
						uint8_t *buf = NULL;
						while (ringbuf_read_string(ptr->rb, &buf, &size) > 0 && count <= 50) {
							on_data(L, g, ptr, (char *)buf, size);
							count++;
						}
					} else {
						int count = 0;
						int size = 0;
						uint8_t *buf = NULL;
						while (ringbuf_read_line(ptr->rb, &buf, &size) > 0 && count <= 50) {
							on_data(L, g, ptr, (char *)buf, size);
							count++;
						}
					}
				} else if (ptr->protocol == PROTOCOL_UDP) {
				} else if (ptr->protocol == PROTOCOL_UDPv6) {
				}
			}
		}

		if (FD_ISSET(ptr->fd, &g->wfds)) {
			if (ptr->type == SOCKET_TYPE_CONNECTED) {
				struct write_buffer* wb = wb_list_pop(ptr->wl);
				while (wb != NULL) {
					res = wb_write_fd(wb, ptr->fd);
					if (res == -1) {
#if defined(_MSC_VER)
						int e = WSAGetLastError();
						if (e == WSAEINTR || e == WSAEINPROGRESS) {
#else 
						if (errno == EINTR || errno == EWOULDBLOCK || errno == EAGAIN) {

#endif
							break;
						} else {
#if defined(_WIN32)
							closesocket(ptr->fd);
#else
							close(ptr->fd);
#endif
							ptr->type = SOCKET_TYPE_CLOSE;
							prev->next = next;
							ptr->next = NULL;
							gate_add_disconected(g, ptr);
							ptr = next;
							continue;
						}
					} else if (res == 0) {
#if defined(_WIN32)
						closesocket(ptr->fd);
#else
						close(ptr->fd);
#endif
						ptr->type = SOCKET_TYPE_CLOSE;
						prev->next = next;
						ptr->next = NULL;
						gate_add_disconected(g, ptr);
						ptr = next;
						continue;
					}
					if (wb_is_empty(wb)) {
						wb_list_free_wb(ptr->wl, wb);
					}
					wb = wb_list_pop(ptr->wl);
				}
			}
		}
		prev = ptr;
		ptr = next;
	}

	on_accept(L, g);
	on_disconnected(L, g);
	on_error(L, g);

	return 0;
}

static int
lkeepalive(lua_State *L) {
	luaL_error(L, "error.");
	// struct lua_gate *g = (struct lua_gate *)lua_touserdata(L, 1);
	// struct lua_socket * so = (struct lua_socket*)lua_touserdata(L, 2);
	//setsockopt(so->so)
	return 0;
}

static int
lclosesocket(lua_State *L) {
	struct lua_gate *g = (struct lua_gate *)lua_touserdata(L, 1);
	lua_Integer id = luaL_checkinteger(L, 2);
	if (id < 1 || id > MAX_SOCKET_NUM) {
		return 0;
	}
	struct lua_socket * so = &g->socks[id];
	return close_sock(L, g, so);
}

static int
lclose(lua_State *L) {
	close_lib(L);
	return 0;
}

LUAMOD_API int
luaopen_xluasocket(lua_State *L) {
	//luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "new", lnew },
		{ "socket", lsocket },
		{ "listen", llisten },
		{ "connect", lconnect },
		{ "start", lstart },
		{ "send", lsend },
		{ "sendto", lsendto },
		{ "poll", lpoll },
		{ "keepalive", lkeepalive },
		{ "closesocket", lclosesocket },
		{ "close", lclose },
		{ NULL, NULL },
	};
#if LUA_VERSION_NUM < 503
	luaL_openlib(L, "packagesocket", l, 0);
#else
	luaL_newlib(L, l);
#endif
	lua_pushstring(L, "SOCKET_DATA");
	lua_pushinteger(L, SOCKET_DATA);
	lua_rawset(L, -3);
	lua_pushstring(L, "SOCKET_CLOSE");
	lua_pushinteger(L, SOCKET_CLOSE);
	lua_rawset(L, -3);

	lua_pushstring(L, "SOCKET_OPEN");
	lua_pushinteger(L, SOCKET_OPEN);
	lua_rawset(L, -3);

	lua_pushstring(L, "SOCKET_ACCEPT");
	lua_pushinteger(L, SOCKET_ACCEPT);
	lua_rawset(L, -3);

	lua_pushstring(L, "SOCKET_ERROR");
	lua_pushinteger(L, SOCKET_ERROR);
	lua_rawset(L, -3);

	lua_pushstring(L, "SOCKET_EXIT");
	lua_pushinteger(L, SOCKET_EXIT);
	lua_rawset(L, -3);

	lua_pushstring(L, "SOCKET_UDP");
	lua_pushinteger(L, SOCKET_UDP);
	lua_rawset(L, -3);

	lua_pushstring(L, "HEADER_TYPE_LINE");
	lua_pushinteger(L, HEADER_TYPE_LINE);
	lua_rawset(L, -3);
	lua_pushstring(L, "HEADER_TYPE_PG");
	lua_pushinteger(L, HEADER_TYPE_PG);
	lua_rawset(L, -3);

	lua_pushstring(L, "PROTOCOL_TCP");
	lua_pushinteger(L, PROTOCOL_TCP);
	lua_rawset(L, -3);
	lua_pushstring(L, "PROTOCOL_UDP");
	lua_pushinteger(L, PROTOCOL_UDP);
	lua_rawset(L, -3);
	lua_pushstring(L, "PROTOCOL_UDPv6");
	lua_pushinteger(L, PROTOCOL_UDPv6);
	lua_rawset(L, -3);
	return 1;
}