#define LUA_LIB

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

#define PROTOCOL_TCP 0
#define PROTOCOL_UDP 1
#define PROTOCOL_UDPv6 2

#define UDP_ADDRESS_SIZE 19	// ipv6 128bit + port 16bit + 1 byte type

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
	struct lua_socket *extra;
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
	fd_set              rfds;
	fd_set              wfds;
	int                 id;
	struct lua_socket  *head;
	struct lua_socket  *error;
	struct lua_socket  *disconn;
	struct lua_socket  *freelist;
} lua_gate;

static struct lua_socket *
gate_find(struct lua_gate *g, int id) {
	if (g->head == NULL) {
		return NULL;
	}
	struct lua_socket *so = g->head;
	while (so != NULL) {
		if (so->id == id) {
			return so;
		}
		so = so->next;
	}
	return NULL;
}

static struct lua_socket *
gate_add(struct lua_gate *g, struct lua_socket *so) {
	if (g->head == NULL) {
		g->head = so;
	} else {
		struct lua_socket *ptr = g->head;
		while (ptr->next) {
			ptr = ptr->next;
		}
		ptr->next = so;
	}
	so->next = NULL;
	return so;
}

static struct lua_socket *
gate_del(struct lua_gate *g, struct lua_socket *so) {
	if (so == NULL) {
		return NULL;
	}
	if (g->head == NULL) {
		return NULL;
	} else if (g->head == so) {
		g->head = g->head->next;
	} else {
		struct lua_socket *ptr = g->head;
		while (ptr->next) {
			if (ptr->next == so) {
				ptr->next = so->next;
				so->next = g->freelist;
				g->freelist = so;
				return so;
			}
			ptr = ptr->next;
		}
	}
	return NULL;
}

static struct lua_socket *
gate_add_error(struct lua_gate *g, struct lua_socket *so) {
	struct lua_socket *ptr = g->error;
	while (ptr) {
		if (ptr == so) {
			return so;
		}
		ptr = ptr->next;
	}
	assert(so->extra == NULL);
	so->extra = g->error;
	g->error = so;
	return so;
}

static struct lua_socket *
gate_add_disconn(struct lua_gate *g, struct lua_socket *so) {
	struct lua_socket *ptr = g->disconn;
	while (ptr) {
		if (ptr == so) {
			return so;
		}
		ptr = ptr->next;
	}
	assert(so->extra == NULL);
	so->extra = g->disconn;
	g->disconn = so;
	return so;
}

static int
on_disconnected(lua_State *L, struct lua_gate *g, struct lua_socket *so) {
	lua_getglobal(L, "xluasocket");
	lua_rawgetp(L, -1, so);
	luaL_checktype(L, -1, LUA_TFUNCTION);

	lua_pushinteger(L, SOCKET_CLOSE);
	lua_pcall(L, 1, 0, 0);
	return 0;
}

static int
on_data(lua_State *L, struct lua_gate *g, struct lua_socket *so, char *buffer, int len) {
	(void)g;
	lua_getglobal(L, "xluasocket");
	lua_rawgetp(L, -1, so);
	luaL_checktype(L, -1, LUA_TFUNCTION);

	lua_pushinteger(L, SOCKET_DATA);
	lua_pushlstring(L, buffer, len);
	lua_pcall(L, 2, 0, 0);
	return 0;
}

static int
on_error(lua_State *L, struct lua_gate *g, struct lua_socket *so, int err) {
	lua_getglobal(L, "xluasocket");
	lua_rawgetp(L, -1, so);
	luaL_checktype(L, -1, LUA_TFUNCTION);

	lua_pushinteger(L, SOCKET_ERROR);
	lua_pushinteger(L, err);
	lua_pcall(L, 2, 0, 0);
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
	init_lib(L);
	struct lua_gate *g = (struct lua_gate *)MALLOC(sizeof(*g));
	memset(g, 0, sizeof(*g));
	g->head = NULL;
	g->freelist = NULL;
	lua_pushlightuserdata(L, g);
	return 1;
}

static int
lsocket(lua_State *L) {
	struct lua_gate *g = (struct lua_gate *)lua_touserdata(L, 1);
	g->id++;
	struct lua_socket *so = NULL;
	if (g->freelist != NULL) {
		so = g->freelist;
		g->freelist = g->freelist->next;
	} else {
		so = (struct lua_socket*)MALLOC(sizeof(*so));
		so->wl = wb_list_new(WRITE_BUFFER_SIZE);
		so->rb = ringbuf_new(RINGBUF_SIZE);
	}
	so->next = NULL;
	so->extra = NULL;
	so->id = g->id;
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

	lua_getglobal(L, "xluasocket");
	if (!lua_istable(L, -1)) {
		lua_newtable(L);
		lua_setglobal(L, "xluasocket");
		lua_getglobal(L, "xluasocket");
	}

	luaL_checktype(L, 4, LUA_TFUNCTION);
	lua_pushvalue(L, 4);
	lua_rawsetp(L, -2, so);

	gate_add(g, so);
	lua_pushinteger(L, so->id);
	return 1;
}

/*
 * @return 0 success
		   1 not find socket
		   2 connect error
*/
static int
lconnect(lua_State *L) {
	struct lua_gate *g = (struct lua_gate *)lua_touserdata(L, 1);
	lua_Integer id = luaL_checkinteger(L, 2);
	lua_socket *so = gate_find(g, id);
	if (so == NULL) {
		lua_pushinteger(L, 1);
		return 1;
	}
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
			lua_pushinteger(L, res);
#if defined(_MSC_VER)
			int err = WSAGetLastError();
			lua_pushinteger(L, err);
			closesocket(so->fd);
#else
			close(so->fd);
#endif
			gate_del(g, so);
			return 2;
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

/*
** @return -1 1
		   -1 2  socket not connectd
		   -1 3  send socket socket error.
*/
static int
lsend(lua_State *L) {
	struct lua_gate *g = (struct lua_gate *)lua_touserdata(L, 1);
	lua_Integer id = luaL_checkinteger(L, 2);
	struct lua_socket * so = gate_find(g, id);
	if (so == NULL) {
		lua_pushinteger(L, -1);
		lua_pushinteger(L, 1);
		return 2;
	}

	if (so->type != SOCKET_TYPE_CONNECTED) {
		lua_pushinteger(L, -1);
		lua_pushinteger(L, 2);
		return 2;
	}

	size_t sz;
	const char *buffer = luaL_checklstring(L, 3, &sz);
	if (sz <= 0) {
		lua_pushinteger(L, -1);
		lua_pushinteger(L, 3);
		return 2;
	}
	assert(so->protocol == PROTOCOL_TCP);
	wb_list_push(so->wl, so->header, buffer, sz);
	lua_pushinteger(L, sz);
	return 1;
}

static int
lsendto(lua_State *L) {
	struct lua_gate *g = (struct lua_gate *)lua_touserdata(L, 1);
	struct lua_socket * so = (struct lua_socket*)lua_touserdata(L, 2);
	size_t len = 0;
	const char *buffer = lua_tolstring(L, 3, &len);
	int tolen = sizeof(so->remote);
	sendto(so->fd, buffer, len, 0, &so->remote, tolen);
	return 0;
}

static int
lpoll(lua_State *L) {
	struct lua_gate *g = (struct lua_gate *)lua_touserdata(L, 1);
	if (g->head == NULL) {
		return 0;
	}
	uint32_t max = 0;
	FD_ZERO(&g->rfds);
	FD_ZERO(&g->wfds);
	struct lua_socket *ptr = g->head;
	while (ptr) {
		if (ptr->type == SOCKET_TYPE_CONNECTED) {
			max = (max > ptr->fd) ? max : ptr->fd;
			FD_SET(ptr->fd, &g->rfds);
			FD_SET(ptr->fd, &g->wfds);
			ptr = ptr->next;
		} else {
			ptr = ptr->next;
		}
	}
	if (max == 0) {
		return 0;
	}
	struct timeval timeout;
	timeout.tv_sec = 0;
	timeout.tv_usec = 0;
	int r = select(max + 1, &g->rfds, &g->wfds, NULL, &timeout);
	if (r <= 0) {
		return 0;
	}
	ptr = g->head;
	while (ptr != NULL) {
		if (ptr->type != SOCKET_TYPE_CONNECTED) {
			continue;
		}
		if (FD_ISSET(ptr->fd, &g->wfds)) {
			struct write_buffer* wb = wb_list_pop(ptr->wl);
			while (wb != NULL) {
				int n = wb_write_fd(wb, ptr->fd);
				if (n == -1) {
#if defined(_MSC_VER)
					int e = WSAGetLastError();
					if (e == WSAEINTR || e == WSAEINPROGRESS) {
						break;
					} else {
						gate_add_error(g, ptr);
						on_error(L, g, ptr, e);
						break;
					}
#else
					if (errno == EINTR) {
						break;
					} else {
						gate_add_error(g, ptr);
						on_error(L, g, ptr, e);
						break;
					}
#endif
				} else if (n == 0) {
					gate_add_disconn(g, ptr);
					on_disconnected(L, g, ptr);
					break;
				}
				if (wb_is_empty(wb)) {
					wb_list_free_wb(ptr->wl, wb);
				}
				wb = wb_list_pop(ptr->wl);
			}
		}
		if (FD_ISSET(ptr->fd, &g->rfds)) {
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
						break;
					} else {
						gate_add_error(g, ptr);
						on_error(L, g, ptr, res);
						break;
					}
		} else if (res == 0) {
			gate_add_disconn(g, ptr);
			break;
		}

		if (ptr->header == HEADER_TYPE_PG) {
			while (true) {
				if (ringbuf_bytes_used(ptr->rb) >= 2) {
					int16_t len = 0;
					ringbuf_read_int16(ptr->rb, &len);
					if (ringbuf_bytes_used(ptr->rb) >= len) {
						void *buf = NULL;
						int sz = ringbuf_read(ptr->rb, len, &buf);
						on_data(L, g, ptr, buf, sz);
				} else {
						break;
					}
			} else {
					break;
				}
		}

	} else {
			if (ringbuf_bytes_used(ptr->rb) > 0) {
				int n = ringbuf_findchr(ptr->rb, '\n', 0);
				while (n < ringbuf_bytes_used(ptr->rb)) {
					void *out = NULL;
					n = ringbuf_read(ptr->rb, n + 1, &out);
					on_data(L, g, ptr, out, n - 1);
					n = ringbuf_findchr(ptr->rb, '\n', 0);
				}
			}
		}
} else if (ptr->protocol == PROTOCOL_UDP) {
} else if (ptr->protocol == PROTOCOL_UDPv6) {
}
}
		ptr = ptr->next;
	}

	ptr = g->error;
	g->error = NULL;
	while (ptr) {
		gate_del(g, ptr);
		on_error(L, g, ptr, 0);
		ptr = ptr->next;
	}
	ptr = g->disconn;
	g->disconn = NULL;
	while (ptr) {
		gate_del(g, ptr);
		on_disconnected(L, g, ptr);
		ptr = ptr->next;
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
	struct lua_socket * so = gate_find(g, id);
	if (so) {
		return close_sock(L, g, so);
	}
	return 0;
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
		{ "connect", lconnect },
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