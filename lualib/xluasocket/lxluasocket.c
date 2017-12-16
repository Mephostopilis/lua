#if defined(_WIN32)
#include <Winsock2.h>
#include <Wininet.h>
#include <ws2tcpip.h>
#include <Windows.h>
#pragma comment (lib, "Ws2_32.lib")
#else
#include <sys/stat.h>
#include <netinet/in.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/timeb.h>
#include <netdb.h>
#include <sys/select.h>
#endif

#include "ringbuf.h"

#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include <time.h>
#include <assert.h>

#include <lua.h>
#include <lauxlib.h>

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

#define HEADER_TYPE_LINE 0
#define HEADER_TYPE_PG 1

#define UDP_ADDRESS_SIZE 19	// ipv6 128bit + port 16bit + 1 byte type
#define WRITE_BUFFER_SIZE 2048
#define RINGBUF_SIZE 4096

#define MALLOC malloc
#define FREE   free

#define COMPAT_LUA

static uint8_t c2s_req_tag = 1 << 0;
static uint8_t c2s_rsp_rag = 1 << 1;
static uint8_t s2c_req_tag = 1 << 2;
static uint8_t s2c_rsp_tag = 1 << 3;

static int int22bytes_bd(int32_t src, char *bufer, int idx, int len) {
	int i = idx + len - 1;
	for (; i >= idx; --i) {
		bufer[i] = (char)((src >> (len - 1 - i) * 8) & 0xff);
	}
	return 1;
}

static int bytes2int_bd(char *src, int len, int32_t *dst) {
	assert(len == 4);
	int i = 0;
	for (; i < len; i++) {
		*dst |= (src[i] << ((3 - i) * 8)) & 0xffffffff;
	}
	return 1;
}

static int unpackbH(char *src, int len, uint16_t *dst) {
	assert(len == 2);
	int i = 0;
	for (; i < 2; i++) {
		*dst |= (src[i] << ((1 - i) * 8)) & 0xffffffff;
	}
	return 1;
}

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

struct write_buffer {
	struct write_buffer * next;
	char *ptr;
	int sz;
	char buffer[0];
};

struct wb_list {
	struct write_buffer * head;
	struct write_buffer * tail;
	struct write_buffer * freelist;
};

static inline struct wb_list*
wb_list_new() {
	struct wb_list* list = MALLOC(sizeof(*list));
	list->head = NULL;
	list->tail = NULL;
	list->freelist = NULL;
	return list;
}

static inline void
wb_list_free(struct wb_list* list) {
	struct write_buffer *first = list->head;
	while (first) {
		struct write_buffer *tmp = first;
		first = first->next;
		FREE(tmp->buffer);
		FREE(tmp);
	}
}

static inline void
wb_list_push(struct wb_list* list, char *buffer, int sz) {
	assert(list != NULL);
	assert(sz <= WRITE_BUFFER_SIZE);
	struct write_buffer *ptr = NULL;
	if (list->freelist != NULL) {
		ptr = list->freelist;
		list->freelist = list->freelist->next;
	} else {
		ptr = MALLOC(sizeof(*ptr) + WRITE_BUFFER_SIZE);
	}
	ptr->next = NULL;
	ptr->ptr = ptr->buffer;
	memcpy(ptr->buffer, buffer, sz);
	ptr->sz = sz;

	if (list->head == NULL) {
		list->head = ptr;
		list->tail = ptr;
	} else {
		list->tail->next = ptr;
		list->tail = ptr;
	}
	list->tail->next = NULL;
}

static inline void
wb_list_push_wb(struct wb_list* list, struct write_buffer *wb) {
	if (list->head == NULL) {
		list->head = wb;
		list->tail = wb;
	} else {
		list->tail->next = wb;
		list->tail = wb;
	}
	list->tail->next = NULL;
}

static inline void
wb_list_push_to_freelist(struct wb_list* list, struct write_buffer *wb) {
	if (list->freelist == NULL) {
		list->freelist = wb;
	} else {
		struct write_buffer *ptr = list->freelist;
		while (ptr->next != NULL) {
			ptr = ptr->next;
		}
		ptr->next = wb;
	}
	wb->next = NULL;
}

static inline struct write_buffer*
wb_list_pop(struct wb_list* list) {
	if (list->head == NULL) {
		return NULL;
	} else if (list->head == list->tail) {
		struct	write_buffer* ptr = list->head;
		list->head = list->tail = NULL;
		return ptr;
	} else {
		struct	write_buffer* ptr = list->head;
		list->head = list->head->next;
		return ptr;
	}
}

static inline struct write_buffer*
wb_list_pop_freelist(struct wb_list* list) {
	struct write_buffer *ptr = NULL;
	if (list->freelist != NULL) {
		ptr = list->freelist;
		list->freelist = list->freelist->next;
	} else {
		ptr = MALLOC(sizeof(*ptr) + WRITE_BUFFER_SIZE);
	}
	ptr->next = NULL;
	ptr->ptr = ptr->buffer;
	ptr->sz = 0;
	return ptr;
}


typedef struct lua_socket {
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
	fd_set              rfds;
	fd_set              wfds;
	int                 id;
	struct lua_socket  *head;
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


static int
on_disconnected(lua_State *L, struct lua_socket *so) {
	lua_getglobal(L, "xluasocket");
	lua_rawgetp(L, -1, so);
	//luaL_checktype(L, -1, )

	lua_pushinteger(L, so->id);
	lua_pushinteger(L, SOCKET_CLOSE);
	lua_pcall(L, 2, 0, 0);
	return 0;
}

static int
on_data(lua_State *L, struct lua_socket *so, void *buffer, int len) {
	lua_getglobal(L, "xluasocket");
	lua_rawgetp(L, -1, so);
	//luaL_checktype(L, -1, )

	lua_pushinteger(L, so->id);
	lua_pushinteger(L, SOCKET_DATA);
	lua_pushlstring(L, buffer, len);
	lua_pcall(L, 3, 0, 0);
	return 0;
}

static void
close_sock(lua_State *L, struct lua_gate *g, struct lua_socket *so) {
	struct lua_socket *ptr = g->head;
	if (ptr == so) {
		g->head = ptr->next;
	} else {
		while (ptr->next) {
			if (ptr->next == so) {
				ptr->next = so->next;
				break;
			}
			ptr = ptr->next;
		}
	}
	if (ptr == NULL) {
		luaL_error(L, "ptr is NULL.");
	} else {
#if defined(_WIN32)
		closesocket(so->fd);
#else
		close(so->fd);
#endif // WIN32
		so->next = g->freelist;
		g->freelist = so;
	}
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
		so->next = NULL;
		so->id = g->id;
	} else {
		so = (struct lua_socket*)MALLOC(sizeof(*so));
		so->next = NULL;
		so->id = g->id;
		so->type = SOCKET_TYPE_RESERVE;
		so->wl = wb_list_new();
		so->rb = ringbuf_new(RINGBUF_SIZE);
	}
	so->protocol = luaL_checkinteger(L, 2);
	so->header = luaL_checkinteger(L, 3);
	if (so->protocol == PROTOCOL_TCP) {
		so->fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	} else if (so->protocol == PROTOCOL_UDP) {
		so->fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	} else if (so->protocol == PROTOCOL_UDPv6) {
		so->fd = socket(AF_INET6, SOCK_DGRAM, 0);
	}

	if (g->head == NULL) {
		g->head = so;
	} else {
		struct lua_socket *ptr = g->head;
		while (ptr->next) {
			ptr = ptr->next;
		}
		ptr->next = so;
	}
	lua_getglobal(L, "xluasocket");
	if (!lua_checktype(L, LUA_TTABLE)) {
		lua_newtable(L);
		lua_setglobal(L, "xluasocket");
		lua_getglobal(L, "xluasocket");
	}

	luaL_checktype(L, 4, LUA_TFUNCTION);
	lua_pushvalue(L, 4);
	lua_rawsetp(L, -1, so);

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
}

static int
send_buffer(lua_State *L, struct lua_socket *so, struct	write_buffer* ptr) {
	assert(ptr != NULL);
	if (so->protocol == PROTOCOL_TCP) {
		int n = send(so->fd, ptr->ptr, ptr->buffer + ptr->sz - ptr->ptr, 0);
		if (n == -1) {
#if defined(_WIN32 )
			int e = WSAGetLastError();
			if (e == WSAEINTR || e == WSAEINPROGRESS) {
				return 0;
			} else {
				return -1;
			}
#else
			if (errno == EINTR) {
				return 0;
			} else {
				return -1;
			}
#endif
		} else {
			return n;
		}
	} else if (so->protocol == PROTOCOL_UDP || so->protocol == PROTOCOL_UDPv6) {
		int n = sendto(so->fd, ptr->ptr, ptr->buffer + ptr->sz - ptr->ptr, 0, &so->remote, sizeof(so->remote));
		if (n == -1) {
#if defined( _WIN32)
			int e = WSAGetLastError();
			if (e == WSAEINTR || e == WSAEINPROGRESS) {
				return 0;
			} else {
				return -1;
			}
#else
			if (errno == EINTR) {
				return 0;
			} else {
				return -1;
			}
#endif
		} else {
			return n;
		}
	} else {
		return 0;
	}
}

static void
send_list(lua_State *L, struct lua_socket *so) {
	while (so->wl->head != NULL) {
		struct write_buffer *tmp = so->wl->head;
		int n = send_buffer(L, so, tmp);
		if (n == -1) {
			return;
		} else if (tmp->buffer + tmp->sz == tmp->ptr + n) {
			if (so->wl->head == so->wl->tail) {
				so->wl->head = so->wl->tail = NULL;
			} else {
				so->wl->head = so->wl->head->next;
			}
			wb_list_push_to_freelist(so->wl, tmp);
		} else {
			tmp->ptr += n;
		}
	}
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
	if (so->header == HEADER_TYPE_PG) {
		struct write_buffer *wb = wb_list_pop_freelist(so->wl);
		int22bytes_bd(sz, wb->buffer, 0, 2);
		int csz = (sz > (WRITE_BUFFER_SIZE - 2)) ? (WRITE_BUFFER_SIZE - 2) : sz;
		memcpy(wb->buffer + 2, buffer, csz);
		int n = csz;
		wb->sz = csz;
		wb_list_push_wb(so->wl, wb);
		while (n < sz) {
			wb = wb_list_pop_freelist(so->wl);
			csz = (sz > (WRITE_BUFFER_SIZE)) ? (WRITE_BUFFER_SIZE) : sz;
			memcpy(wb->buffer, buffer + n, csz);
			n += csz;
			wb->sz = csz;
			wb_list_push_wb(so->wl, wb);
		}
	} else if (so->header == HEADER_TYPE_LINE) {
		struct write_buffer *wb = NULL;
		int n = 0;
		while (n < sz) {
			wb = wb_list_pop_freelist(so->wl);
			int csz = ((sz) > (WRITE_BUFFER_SIZE)) ? (WRITE_BUFFER_SIZE) : sz;
			memcpy(wb->buffer, buffer, csz);
			n += csz;
			wb->sz = csz;
			wb_list_push_wb(so->wl, wb);
		}
		wb = wb_list_pop(so->wl);
		if (wb->sz < WRITE_BUFFER_SIZE) {
			wb->buffer[wb->sz] = '\n';
			wb->sz = wb->sz + 1;
		} else {
			wb = wb_list_pop_freelist(so->wl);
			wb->buffer[0] = '\n';
			wb->sz = 1;
			wb_list_push_wb(so->wl, wb);
		}
	}

	struct	write_buffer* ptr = wb_list_pop(so->wl);
	if (ptr == NULL) {
		luaL_error(L, "write buffer ptr is NULL.");
	} else {
		int n = send_buffer(L, so, ptr);
		if (n == -1) {
			lua_pushinteger(L, -1);
			lua_pushinteger(L, 4);
			return 3;
		} else {
			ptr->ptr = ptr->ptr + n;
			if (ptr->ptr == ptr->buffer + ptr->sz) {
				wb_list_push_to_freelist(so->wl, ptr);
			} else {
				wb_list_push_wb(so->wl, ptr);
			}
			lua_pushinteger(L, n);
			return 1;
		}
	}
	return 0;
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
			send_list(L, ptr, ptr->wl);
		}
		if (FD_ISSET(ptr->fd, &g->rfds)) {
			if (ptr->protocol == PROTOCOL_TCP) {
				for (; ;) {
					int res = ringbuf_read(ptr->fd, ptr->rb, RINGBUF_SIZE);
					if (res == -1) {
#if defined(_WIN32)
						int e = WSAGetLastError();
						if (e == WSAEINTR || e == WSAEINPROGRESS) {
							// 当前so不处理
						}
#else
						if (errno == EINTR || errno == EWOULDBLOCK || errno == EAGAIN) {
						} else {
							ptr->disc(ptr);
							close_sock(L, g, ptr);
						}
#endif
						break;
					} else if (res == 0) {
						break;
					}
				}
				if (ptr->header == HEADER_TYPE_PG) {
					if (ringbuf_bytes_used(ptr->rb) >= 2) {
						int32_t sz = 0;
						const char *head = (const char *)ringbuf_head(ptr->rb);
						bytes2int_bd(head, 2, &sz);
						if (ringbuf_bytes_used(ptr->rb) >= (2 + sz)) {
							char *buf = NULL;
							buf = ringbuf_read_offset(ptr->rb, 2);
							buf = ringbuf_read_offset(ptr->rb, sz);
							on_data(L, ptr, buf, sz);
						}
					}
				} else {

				}
			} else if (ptr->protocol == PROTOCOL_UDP) {
			} else if (ptr->protocol == PROTOCOL_UDPv6) {
			}
		}
		ptr = ptr->next;
	}
	return 0;
}

static int
lkeepalive(lua_State *L) {
	// struct lua_gate *g = (struct lua_gate *)lua_touserdata(L, 1);
	// struct lua_socket * so = (struct lua_socket*)lua_touserdata(L, 2);
	//setsockopt(so->so)
	return 0;
}

static int
lclosesocket(lua_State *L) {
	struct lua_gate *g = (struct lua_gate *)lua_touserdata(L, 1);
	struct lua_socket * so = (struct lua_socket*)lua_touserdata(L, 2);
	//so->disc(so);
	close_sock(L, g, so);
	return 0;
}

static int
lclose(lua_State *L) {
	close_lib(L);
	lua_pushinteger(L, SOCKET_EXIT);
	return 1;
}

int
luaopen_packagesocket(lua_State *L) {
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

	lua_pushstring(L, "HEADER_LINE");
	lua_pushinteger(L, HEADER_LINE);
	lua_rawset(L, -3);
	lua_pushstring(L, "HEADER_PG");
	lua_pushinteger(L, HEADER_PG);
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