#if !defined(LUA_LIB)
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


#define XLUASOCKET_ERROR_OVERFLOW 1
#define XLUASOCKET_ERROR_SOCKET 2

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

#define MAX_SENDPACK_NUM (10)
#define MAX_RECVPACK_NUM (1)
#define MAX_SLICEPACK_NUM (20)
#define MAX_SOCKET_NUM (1 << 3)
#define SOCKET_ID_MASK (1 << 3)

static void
init_lib(lua_State *L) {
#if defined(_WIN32) || defined(_WIN64)
	WSADATA wsaData;
	int iResult = WSAStartup(MAKEWORD(2, 2), &wsaData);
	if (iResult != 0) {
		luaL_error(L, "init win32 failture.");
	}
#endif // WIN32
}

static void
close_lib(lua_State *L) {
#if defined(_WIN32) || defined(_WIN64)
	WSACleanup();
#endif // WIN32
}

typedef struct lua_socket {
	struct lua_socket *prev;        // 双向链表
	struct lua_socket *next;
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
	struct lua_socket   head[1];      // 遍历所有socket
	struct lua_socket  *freelist;     // 用来查找下一个分配的socket
	struct lua_socket   socks[0];     // 分配的所有socket
} lua_gate;

///////////////////////////////////////////////////////////////////// 处理poll
static int
gate_add(struct lua_gate *g, struct lua_socket *so) {
	assert(g != NULL && so != NULL);
	so->next = g->head->next;
	if (g->head->next != NULL) {
		g->head->next->prev = so;
	}
	g->head->next = so;
	so->prev = g->head;
	return 0;
}

static struct lua_socket *
gate_del(struct lua_gate *g, struct lua_socket *so) {
	assert(g != NULL && so != NULL);
	struct lua_socket *ptr = g->head->next;
	while (ptr != NULL) {
		if (ptr == so) {
			ptr->prev->next = ptr->next;
			ptr->next->prev = ptr->prev;
			return 0;
		}
	}
	return -1;
}
///////////////////////////////////////////////////////////////////// 结束poll


static int
on_connected(lua_State *L, struct lua_gate *g, struct lua_socket *so) {
	lua_getglobal(L, "xluasocket");
	lua_rawgetp(L, -1, g);
	luaL_checktype(L, -1, LUA_TFUNCTION);
	lua_pushinteger(L, so->id);
	lua_pushinteger(L, SOCKET_OPEN);
	lua_pushinteger(L, 0);
	lua_pcall(L, 3, 0, 0);
	lua_pop(L, 1);
	return 0;
}

static int
on_disconnected(lua_State *L, struct lua_gate *g, struct lua_socket *so) {
	lua_getglobal(L, "xluasocket");
	lua_rawgetp(L, -1, g);
	luaL_checktype(L, -1, LUA_TFUNCTION);
	lua_pushinteger(L, so->id | SOCKET_ID_MASK);
	lua_pushinteger(L, SOCKET_CLOSE);
	lua_pushinteger(L, 0);
	lua_pcall(L, 3, 0, 0);
	lua_pop(L, 1);
	return 0;
}

static int
on_data(lua_State *L, struct lua_gate *g, struct lua_socket *so, char *buffer, int len) {
	(void)g;
	lua_getglobal(L, "xluasocket");
	lua_rawgetp(L, -1, g);
	luaL_checktype(L, -1, LUA_TFUNCTION);
	lua_pushinteger(L, so->id | SOCKET_ID_MASK);
	lua_pushinteger(L, SOCKET_DATA);
	lua_pushlstring(L, buffer, len);
	lua_pcall(L, 3, 0, 0);
	lua_pop(L, 1);
	return 0;
}

static int
on_error(lua_State *L, struct lua_gate *g, struct lua_socket *so, int errorcode, const char *msg) {
	lua_getglobal(L, "xluasocket");
	lua_rawgetp(L, -1, g);
	luaL_checktype(L, -1, LUA_TFUNCTION);
	lua_pushinteger(L, so->id | SOCKET_ID_MASK);
	lua_pushinteger(L, SOCKET_ERROR);
	lua_pushinteger(L, errorcode);
	lua_pushstring(L, msg);
	lua_pcall(L, 5, 0, 0);
	lua_pop(L, 1);
	return 0;
}

static int
on_handle_error(lua_State *L, struct lua_gate *g, struct lua_socket *so) {
#if defined(_WIN32)
	int e = WSAGetLastError();
	if (e == WSAEINTR || e == WSAEINPROGRESS) {
#else
	if (errno == EINTR || errno == EWOULDBLOCK || errno == EAGAIN) {
#endif
		// 不做处理
		return 0;
#if defined(_WIN32)
	} else if (e == WSAECONNRESET) {
		closesocket(so->fd);
#else
	} else if (errno == ECONNRESET) {
		close(so->fd);
#endif
		// 断联处理
		so->type = SOCKET_TYPE_CLOSE;
		so->prev->next = so->next;
		if (so->next != NULL) {
			so->next->prev = so->prev;
		}
		on_error(L, g, so, XLUASOCKET_ERROR_SOCKET, "server socket error");
		on_disconnected(L, g, so);
		return 0;
	} else {
		// 错误处理
#if defined(_WIN32)
		closesocket(so->fd);
#else
		close(so->fd);
#endif
		so->type = SOCKET_TYPE_CLOSE;
		so->prev->next = so->next;
		if (so->next != NULL) {
			so->next->prev = so->prev;
		}
		on_error(L, g, so, XLUASOCKET_ERROR_SOCKET, "client socket error");
		on_disconnected(L, g, so);
	}
	return 0;
}

static int
on_accept(lua_State *L, struct lua_gate *g, struct lua_socket *l, struct lua_socket *so) {
	assert(so->type == SOCKET_TYPE_CONNECTED);
	lua_getglobal(L, "xluasocket");
	lua_rawgetp(L, -1, g);
	luaL_checktype(L, -1, LUA_TFUNCTION);
	lua_pushinteger(L, l->id | SOCKET_ID_MASK);
	lua_pushinteger(L, SOCKET_ACCEPT);
	lua_pushinteger(L, so->id | SOCKET_ID_MASK);
	lua_pcall(L, 3, 0, 0);
	lua_pop(L, 1);
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
	for (size_t i = 0; i < MAX_SOCKET_NUM; i++) {
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
** @return -1 error
		   [1, MAX_SOCKET_NUM]
*/
static int
lsocket(lua_State *L) {
	struct lua_gate *g = (struct lua_gate *)lua_touserdata(L, 1);
	if (g->count > MAX_SOCKET_NUM) {
		lua_pushinteger(L, -1);
		return 1;
	}
	struct lua_socket *so = g->freelist;
	for (size_t i = 0; i < MAX_SOCKET_NUM; i++) {
		so = &g->socks[((so->id + i + 1) / MAX_SOCKET_NUM)];
		if (so->type == SOCKET_TYPE_INVALID) {
			g->freelist = so;
			break;
		}
	}

	so->prev = NULL;
	so->next = NULL;
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

	lua_pushinteger(L, (so->id | SOCKET_ID_MASK));
	return 1;
}

static int
llisten(lua_State *L) {
	struct lua_gate *g = (struct lua_gate *)lua_touserdata(L, 1);
	lua_Integer id = luaL_checkinteger(L, 2);
	lua_Integer realid = id & ~SOCKET_ID_MASK;
	if (realid < 0 || realid >= MAX_SOCKET_NUM) {
		lua_pushinteger(L, 3);
		return 1;
	}
	lua_socket *so = &g->socks[realid];
	if (so->type != SOCKET_TYPE_RESERVE) {
		lua_pushinteger(L, -1);
		return 1;
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
	if (listen(so->fd, 0) == -1) {
		on_handle_error(L, g, so);
		lua_pushinteger(L, -1);
		return 1;
	}
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
	lua_Integer realid = id & ~SOCKET_ID_MASK;
	if (realid < 0 || realid >= MAX_SOCKET_NUM) {
		lua_pushinteger(L, 3);
		return 1;
	}
	lua_socket *so = &g->socks[realid];
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
	lua_Integer realid = id & ~SOCKET_ID_MASK;
	if (realid < 0 || realid >= MAX_SOCKET_NUM) {
		lua_pushinteger(L, -1);
		lua_pushinteger(L, XLUASOCKET_ERROR_OVERFLOW);
		return 2;
	}
	lua_socket *so = &g->socks[realid];
	gate_add(g, so);
	if (so->type == SOCKET_TYPE_PLISTEN) {
		so->type = SOCKET_TYPE_LISTEN;
	}
	lua_pushinteger(L, 0);
	return 1;
}

/*
** @return  0    success
		   -1    failture
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
	lua_Integer realid = id & ~SOCKET_ID_MASK;
	if (realid < 0 || realid >= MAX_SOCKET_NUM) {
		lua_pushinteger(L, -1);
		return 1;
	}
	struct lua_socket * so = &g->socks[realid];
	if (so->type != SOCKET_TYPE_CONNECTED) {
		lua_pushinteger(L, -1);
		return 1;
	}

	size_t sz;
	const char *buffer = luaL_checklstring(L, 3, &sz);
	if (sz <= 0) {
		lua_pushinteger(L, -1);
		return 1;
	}

	assert(so->protocol == PROTOCOL_TCP);
	if (so->header == HEADER_TYPE_LINE) {
		wb_list_push_line(so->wl, (char *)buffer, sz);
	} else if (so->header == HEADER_TYPE_PG) {
		wb_list_push_string(so->wl, (char *)buffer, sz);
	} else {
		lua_pushinteger(L, -1);
		lua_pushinteger(L, 5);
		return 2;
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
	int max = 0;
	FD_ZERO(&g->rfds);
	FD_ZERO(&g->wfds);
	struct lua_socket *ptr = g->head->next;
	while (ptr) {
		max = (max > ptr->fd) ? max : ptr->fd;
		FD_SET(ptr->fd, &g->rfds);
		FD_SET(ptr->fd, &g->wfds);
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

	for (ptr = g->head->next; ptr != NULL; ptr = ptr->next) {
		// read
		if (FD_ISSET(ptr->fd, &g->rfds)) {
			if (ptr->protocol == PROTOCOL_TCP && ptr->type == SOCKET_TYPE_LISTEN) {
				if (g->count > MAX_SOCKET_NUM) {
					//on_error(L, g, ptr);
					continue;
				}
				int fd = accept(ptr->fd, NULL, NULL);
				if (fd < 0) {
					continue;
				}
				// find free
				struct lua_socket *so = g->freelist;
				for (size_t i = 0; i < MAX_SOCKET_NUM; i++) {
					so = &g->socks[g->freelist->id + i + 1 % MAX_SOCKET_NUM];
					if (so->type == SOCKET_TYPE_INVALID) {
						g->freelist = so;
						break;
					}
				}
				so->type = SOCKET_TYPE_CONNECTED;
				int addlen;
				so->fd = fd;
				on_accept(L, g, ptr, so);
			} else if (ptr->protocol == PROTOCOL_TCP && ptr->type == SOCKET_TYPE_CONNECTED) {
				// must call 1th
				for (size_t i = 0; i < MAX_RECVPACK_NUM; i++) {
					int res = ringbuf_read_fd(ptr->rb, ptr->fd, RINGBUF_SIZE);
					if (res == -1) {
						on_handle_error(L, g, ptr);
						break;
					} else if (res == 0) {
#if defined(_WIN32)
						closesocket(ptr->fd);
#else
						close(ptr->fd);
#endif
						ptr->type = SOCKET_TYPE_CLOSE;
						ptr->prev->next = ptr->next;
						if (ptr->next != NULL) {
							ptr->next->prev = ptr->prev;
						}
						on_disconnected(L, g, ptr);
						break;
					}
					if (ptr->header == HEADER_TYPE_PG) {
						int size = 0;
						uint8_t *buf = NULL;
						for (size_t j = 0; ringbuf_read_string(ptr->rb, &buf, &size) > 0 && j < MAX_SLICEPACK_NUM; j++) {
							on_data(L, g, ptr, (char *)buf, size);
						}
					} else if (ptr->header == HEADER_TYPE_LINE) {
						int size = 0;
						uint8_t *buf = NULL;
						for (size_t j = 0; ringbuf_read_line(ptr->rb, &buf, &size) > 0 && j < MAX_SLICEPACK_NUM; j++) {
							on_data(L, g, ptr, (char *)buf, size);
						}
					} else {
						assert(0);
					}

				}
			} else if (ptr->protocol == PROTOCOL_UDP || ptr->protocol == PROTOCOL_UDPv6) {
			}
			// read over
		}
		// write
		if (FD_ISSET(ptr->fd, &g->wfds)) {
			if (ptr->protocol == PROTOCOL_TCP && ptr->type == SOCKET_TYPE_CONNECTED) {
				struct write_buffer* wb = wb_list_pop(ptr->wl);
				for (size_t i = 0; i < MAX_SENDPACK_NUM && wb != NULL;) {
					res = wb_write_fd(wb, ptr->fd);
					if (res == -1) {
						on_handle_error(L, g, ptr);
						break;
					} else if (res == 0) {
#if defined(_WIN32) || defined(_WIN64)
						closesocket(ptr->fd);
#else
						close(ptr->fd);
#endif
						ptr->type = SOCKET_TYPE_CLOSE;
						ptr->prev->next = ptr->next;
						if (ptr->next != NULL) {
							ptr->next->prev = ptr->prev;
						}
						on_disconnected(L, g, ptr);
						break;
					}
					if (wb_is_empty(wb)) {
						wb_list_free_wb(ptr->wl, wb);
						wb = wb_list_pop(ptr->wl);
						i++;
					}
				}
			} else if (ptr->protocol == PROTOCOL_UDP || ptr->protocol == PROTOCOL_UDPv6) {
			}
			// write over
		}
	}
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
	lua_Integer realid = id & ~SOCKET_ID_MASK;
	if (realid < 0 || id >= MAX_SOCKET_NUM) {
		lua_pushinteger(L, -1);
		return 1;
	}
	struct lua_socket * so = &g->socks[realid];
	return close_sock(L, g, so);
}

static int
lclose(lua_State *L) {
	close_lib(L);
	return 0;
}

LUAMOD_API int
luaopen_xluasocket(lua_State *L) {
	luaL_checkversion(L);
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