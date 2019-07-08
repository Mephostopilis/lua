﻿#if !defined(LUA_LIB)
#define LUA_LIB
#endif // !ANDROID

#include "xluaconf.h"
#include "ringbuf.h"
#include "message_queue.h"
#include "socket_server.h"
#include "skynet_timer.h"
#include "simplethread.h"
#include "array.h"
#include "protoc.h"

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

#define XLUASOCKET_TYPE_DATA 1
#define XLUASOCKET_TYPE_CONNECT 2
#define XLUASOCKET_TYPE_CLOSE 3
#define XLUASOCKET_TYPE_ACCEPT 4
#define XLUASOCKET_TYPE_ERROR 5
#define XLUASOCKET_TYPE_UDP 6
#define XLUASOCKET_TYPE_WARNING 7

#define MAX_SENDPACK_NUM  (10)
#define MAX_RECVPACK_NUM  (4)
#define MAX_SLICEPACK_NUM (20)

#define RINGBUF_CAP (256)

#define THREADS 1
static bool inited = false;
static struct socket_server *ss;
static struct message_queue *q;
struct args {
	int n;
	struct thread_event *wait;
	struct thread_event *trigger;
};
static struct thread t[THREADS];
struct thread_event ev[THREADS];
static struct args args[THREADS];

static void *
soi_buffer(void *ptr) {
	return NULL;
}

static int
soi_size(void *ptr) {
	return 0;
}

static void
soi_free(void *ptr) {}

static int
lhandle_error(lua_State *L) {
	return 0;
}

static void
on_handle_msg(lua_State *L, struct xluasocket_message *msg) {
	switch (msg->type) {
	case XLUASOCKET_TYPE_DATA:
	{
		lua_getglobal(L, "xluasocket");
		lua_getfield(L, -1, "unpack");
		assert(lua_istable(L, -1));
		lua_geti(L, -1, msg->id);
		if (lua_isnoneornil(L, -1)) {
			lua_getglobal(L, "xluasocket");
			lua_rawgetp(L, -1, ss);
			luaL_checktype(L, -1, LUA_TFUNCTION);
			lua_pushinteger(L, msg->type);
			lua_pushinteger(L, msg->id);
			lua_pushinteger(L, msg->ud);
			lua_pushlstring(L, msg->buffer, msg->ud);
			lua_pcall(L, 4, 0, 0);
			goto handle_data_error;
		}
		lua_Integer t = lua_tointeger(L, -1);
		lua_pop(L, 2);
		lua_getfield(L, -1, "unpackrb");
		if (lua_isnoneornil(L, -1)) {
			lua_pop(L, 1);
			lua_newtable(L);
			lua_setfield(L, -2, "unpackrb");
			lua_getfield(L, -1, "unpackrb");
		}
		lua_geti(L, -1, msg->id);
		if (lua_isnoneornil(L, -1)) {
			lua_pop(L, 1);
			ringbuf_t *rb = ringbuf_new(256);
			lua_pushlightuserdata(L, rb);
			lua_seti(L, -2, msg->id);
			lua_geti(L, -1, msg->id);
		}
		ringbuf_t *rb = lua_touserdata(L, -1);
		lua_pop(L, 3);

		if (ringbuf_memcpy_buffer(rb, msg->buffer, msg->ud)) {
			fprintf(stderr, "ringbuf memcpy buffer err.\n");
			goto handle_data_error;
		}
		for (size_t i = 0; i < MAX_SLICEPACK_NUM; i++) {
			if (ringbuf_is_empty(rb)) {
				break;
			}
			char *buffer = NULL;
			int sz = 0;
			if (t == HEADER_TYPE_LINE) {
				if (ringbuf_get_line(&buffer, &sz, rb)) {
					fprintf(stderr, "ringbuf get line err.\n");
					goto handle_data_error;
				}
			} else if (t == HEADER_TYPE_PG) {
				if (ringbuf_get_string(&buffer, &sz, rb)) {
					fprintf(stderr, "ringbuf get string err.\n");
					goto handle_data_error;
				}
				// test
				/*ringbuf_statics(rb);
				ARRAY(char, testm, sz + 1);
				memset(testm, 0, sz + 1);
				memcpy(testm, buffer, sz);
				fprintf(stderr, "ringbuf [%s][%d]\n", testm, sz);*/
			}
			if (buffer != NULL && sz > 0) {
				lua_getglobal(L, "xluasocket");
				lua_rawgetp(L, -1, ss);
				luaL_checktype(L, -1, LUA_TFUNCTION);
				lua_pushinteger(L, msg->type);
				lua_pushinteger(L, msg->id);
				lua_pushinteger(L, msg->ud);
				lua_pushlstring(L, buffer, sz);
				if (lua_pcall(L, 4, 0, 0) == 0) {
				}
			}
		}
	handle_data_error:
		FREE(msg->buffer);
		break;
	}
	case XLUASOCKET_TYPE_ERROR:
	case XLUASOCKET_TYPE_CONNECT:
	case XLUASOCKET_TYPE_ACCEPT:
	{
		lua_getglobal(L, "xluasocket");
		lua_rawgetp(L, -1, ss);
		luaL_checktype(L, -1, LUA_TFUNCTION);
		lua_pushinteger(L, msg->type);
		lua_pushinteger(L, msg->id);
		lua_pushinteger(L, msg->ud);
		lua_pushlstring(L, msg + 1, msg->sz - sizeof(*msg));
		lua_pcall(L, 4, 0, 0);
		break;
	}
	default:
		lua_getglobal(L, "xluasocket");
		lua_rawgetp(L, -1, ss);
		luaL_checktype(L, -1, LUA_TFUNCTION);
		lua_pushinteger(L, msg->type);
		lua_pushinteger(L, msg->id);
		lua_pushinteger(L, msg->ud);
		lua_pcall(L, 3, 0, 0);
		break;
	}
}

// socket thread
static void
forward_message(int type, bool padding, struct socket_message * result) {
	struct xluasocket_message *sm;
	size_t sz = sizeof(*sm);
	if (padding) {
		if (result->data) {
			size_t msg_sz = strlen(result->data);
			if (msg_sz > 128) {
				msg_sz = 128;
			}
			sz += msg_sz;
		} else {
			result->data = "";
		}
	}
	sm = (struct xluasocket_message *)MALLOC(sz);
	memset(sm, 0, sz);
	sm->type = type;
	sm->id = result->id;
	sm->ud = result->ud;
	sm->sz = sz;
	if (padding) {
		sm->buffer = NULL;
		memcpy(sm + 1, result->data, sz - sizeof(*sm));
	} else {
		sm->buffer = result->data;
	}
	mq_push(q, sm);
}

static int
xluasocket_poll() {
	assert(ss);
	struct socket_message result;
	int more = 1;
	int type = socket_server_poll(ss, &result, &more);
	switch (type) {
	case SOCKET_EXIT:
		return 0;
	case SOCKET_DATA:
		forward_message(XLUASOCKET_TYPE_DATA, false, &result);
		break;
	case SOCKET_CLOSE:
		forward_message(XLUASOCKET_TYPE_CLOSE, false, &result);
		break;
	case SOCKET_OPEN:
		forward_message(XLUASOCKET_TYPE_CONNECT, true, &result);
		break;
	case SOCKET_ERR:
		forward_message(XLUASOCKET_TYPE_ERROR, true, &result);
		break;
	case SOCKET_ACCEPT:
		forward_message(XLUASOCKET_TYPE_ACCEPT, true, &result);
		break;
	case SOCKET_UDP:
		forward_message(XLUASOCKET_TYPE_UDP, false, &result);
		break;
	case SOCKET_WARNING:
		forward_message(XLUASOCKET_TYPE_WARNING, false, &result);
		break;
	default:
		fprintf(stderr, "Unknown socket message type %d.\n", type);
		return -1;
	}
	if (more) {
		return -1;
	}
	return 1;
}

static void
co(void *p) {
	struct args * arg = p;
	while (1) {
		// 时间
		skynet_updatetime();
		socket_server_updatetime(ss, skynet_now());

		int r = xluasocket_poll();
		if (r == 0) {
			fprintf(stderr, "scoket server EXIT\n");
			break;
		}
		if (r < 0) {
			// 出错了
		}
		// 有消息
	}
}

/*
** @breif 创建这个模块
** @param  [1] callback function 回调函数
** @return [1] 0 成功
**             -1 失败
*/
static int
lnew(lua_State *L) {
	luaL_checktype(L, 1, LUA_TFUNCTION);
	lua_getglobal(L, "xluasocket");
	if (!lua_istable(L, -1)) {
		lua_pop(L, 1);
		lua_newtable(L);
		lua_setglobal(L, "xluasocket");
		lua_getglobal(L, "xluasocket");
	}
#if defined(_DEBUG)
	assert(lua_gettop(L) == 2);
#endif
	if (!inited) {

		skynet_timer_init();  // 初始timer
		q = mq_create();      // 初始消息队列
		if (q == NULL) {
			luaL_error(L, "q is null");
		}
		ss = socket_server_create(skynet_now());  // 初始socket
		if (ss == NULL) {
			luaL_error(L, "ss is null");
		}
		struct socket_object_interface soi;
		soi.buffer = soi_buffer;
		soi.size = soi_size;
		soi.free = soi_free;
		socket_server_userobject(ss, &soi);

		lua_pushvalue(L, 1);
		lua_rawsetp(L, -2, ss);
		lua_pop(L, 1);
#if defined(USE_PTHREAD) && defined(_MSC_VER) || defined(__MINGW32__) || defined(__MINGW64__)
		thread_init();
#endif
		int i = 0;
		for (i = 0; i < THREADS; i++) {
			t[i].func = co;
			t[i].ud = &args[i];
			args[i].n = i;
		}
		thread_create(t, THREADS);
		inited = 1;
	}

	lua_pushinteger(L, 0);
	return 1;
}

static int
lfree(lua_State *L) {
	if (!inited) {
		socket_server_release(ss);
		// release mq
		mq_release(q);
		// release rb
		lua_getglobal(L, "xluasocket");
		lua_getfield(L, -1, "unpackrb");
		if (lua_istable(L, -1)) {
			lua_pushnil(L);  // key
			while (lua_next(L, -2)) {
				int t = lua_type(L, -1);
				if (t == LUA_TLIGHTUSERDATA) {
					ringbuf_t *rb = lua_touserdata(L, -1);
					ringbuf_free(rb);
				}
				lua_pop(L, 1);
			}
		}
	} else {
		fprintf(stderr, "first call exit.");
	}
	return 0;
}

static int
lpoll(lua_State *L) {
	for (size_t i = 0; i < MAX_RECVPACK_NUM; i++) {
		struct xluasocket_message *msg = mq_pop(q);
		if (msg != NULL) {
			on_handle_msg(L, msg);
			FREE(msg);
		}
	}
	return 0;
}

static int
lexit(lua_State *L) {
	socket_server_exit(ss);
	// 等待完成

	thread_join(t, THREADS);
	inited = false;
	return 0;
}

/*
** @return [1] integer -1  错误
**                     >0 id
*/
static int
llisten(lua_State *L) {
	size_t sz;
	const char *addr = luaL_checklstring(L, 1, &sz);
	uint16_t port = luaL_checkinteger(L, 2);
	int id = socket_server_listen(ss, L, addr, port, 0);
	lua_pushinteger(L, id);
	return 1;
}

/*
** @return [1] 0 success
**		      -1 failture
*/
static int
lconnect(lua_State *L) {
	size_t sz;
	const char *addr = luaL_checklstring(L, 1, &sz);
	uint16_t port = luaL_checkinteger(L, 2);
	int id = socket_server_connect(ss, L, addr, port);
	lua_pushinteger(L, id);
	return 1;
}

static int
lbind(lua_State *L) {
	lua_Integer fd = luaL_checkinteger(L, 1);
	int id = socket_server_bind(ss, L, fd);
	lua_pushinteger(L, id);
	return 1;
}

static int
lclosesocket(lua_State *L) {
	lua_Integer id = luaL_checkinteger(L, 1);
	socket_server_close(ss, L, id);
	return 0;
}

static int
lshutdown(lua_State *L) {
	lua_Integer id = luaL_checkinteger(L, 1);
	socket_server_shutdown(ss, L, id);
	return 0;
}

static int
lstart(lua_State *L) {
	lua_Integer id = luaL_checkinteger(L, 1);
	socket_server_start(ss, L, id);
	return 0;
}

static int
lpack(lua_State *L) {
	lua_Integer id = luaL_checkinteger(L, 1);
	lua_Integer t = luaL_checkinteger(L, 2);

	lua_getglobal(L, "xluasocket");
	lua_getfield(L, -1, "pack");
	if (lua_type(L, -1) != LUA_TTABLE) {
		lua_pop(L, 1);
		lua_newtable(L);
		lua_setfield(L, -2, "pack");
		lua_getfield(L, -1, "pack");
	}

	lua_pushvalue(L, 2);
	lua_seti(L, -2, id);

	return 0;
}

static int
lunpack(lua_State *L) {
	lua_Integer id = luaL_checkinteger(L, 1);
	lua_Integer t = luaL_checkinteger(L, 2);
	lua_getglobal(L, "xluasocket");
	lua_getfield(L, -1, "unpack");
	if (lua_type(L, -1) != LUA_TTABLE) {
		lua_pop(L, 1);
		lua_newtable(L);
		lua_setfield(L, -2, "unpack");
		lua_getfield(L, -1, "unpack");
	}
	lua_pushinteger(L, t);
	lua_rawseti(L, -2, id);
	lua_pop(L, 1);  // pop unpack
	lua_getfield(L, -1, "unpackrb");
	if (lua_isnoneornil(L, -1)) {
		lua_pop(L, 1);
		lua_newtable(L);
		lua_setfield(L, -2, "unpackrb");
		lua_getfield(L, -1, "unpackrb");
	}
	lua_geti(L, -1, id);
	if (lua_isnoneornil(L, -1)) {
		lua_pop(L, 1);
		ringbuf_t *rb = ringbuf_new(RINGBUF_CAP);
		lua_pushlightuserdata(L, rb);
		lua_seti(L, -2, id);

	} else {
		ringbuf_t *rb = lua_touserdata(L, -1);
		ringbuf_reset(rb);
	}
	return 0;
}

/*
** @return [1] 0    success
**		      -1    failture
*/
static int
lsend(lua_State *L) {
	int err = -1;
	lua_Integer id = luaL_checkinteger(L, 1);
	size_t sz;
	const char *buffer = luaL_checklstring(L, 2, &sz);
	lua_getglobal(L, "xluasocket");
	lua_getfield(L, -1, "pack");
	lua_geti(L, -1, id);
	lua_Integer t = lua_tointeger(L, -1);
	if (t == HEADER_TYPE_LINE) {
		char *pack = MALLOC(sz + 1);
		memcpy(pack, buffer, sz);
		pack[sz] = '\n';
		err = socket_server_send(ss, id, pack, sz + 1);
	} else if (t == HEADER_TYPE_PG) {
		char *pack = MALLOC(sz + 2);
		WriteInt16(pack, 0, sz);
		memcpy(pack + 2, buffer, sz);
		err = socket_server_send(ss, id, pack, sz + 2);
	} else {
		luaL_error(L, "not supoort other pack");
	}
	lua_pushinteger(L, err);
	return 1;
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
llog(lua_State *L) {
	luaL_checkstring(L, 1);
	size_t l;
	const char *buf = lua_tolstring(L, 1, &l);
	fprintf(stderr, buf);
	return 0;
}

LUAMOD_API int
luaopen_xluasocket(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "new", lnew },
		{ "close", lfree },
		{ "poll", lpoll },
		{ "exit", lexit },

		{ "listen", llisten },
		{ "connect", lconnect },
		{ "bind", lbind },

		{ "start", lstart },
		{ "pack", lpack },
		{ "unpack", lunpack },

		{ "shutdown", lshutdown },
		{ "closesocket", lclosesocket },
		{ "keepalive", lkeepalive },

		{ "send", lsend },

		{ "log",  llog },

		{ NULL, NULL },
	};
#if LUA_VERSION_NUM < 503
	luaL_openlib(L, "xluasocket", l, 0);
#else
	luaL_newlib(L, l);
#endif
	lua_pushstring(L, "SOCKET_DATA");
	lua_pushinteger(L, XLUASOCKET_TYPE_DATA);
	lua_rawset(L, -3);

	lua_pushstring(L, "SOCKET_CLOSE");
	lua_pushinteger(L, XLUASOCKET_TYPE_CLOSE);
	lua_rawset(L, -3);

	lua_pushstring(L, "SOCKET_OPEN");
	lua_pushinteger(L, XLUASOCKET_TYPE_CONNECT);
	lua_rawset(L, -3);

	lua_pushstring(L, "SOCKET_ACCEPT");
	lua_pushinteger(L, XLUASOCKET_TYPE_ACCEPT);
	lua_rawset(L, -3);

	lua_pushstring(L, "SOCKET_ERROR");
	lua_pushinteger(L, XLUASOCKET_TYPE_ERROR);
	lua_rawset(L, -3);

	lua_pushstring(L, "SOCKET_UDP");
	lua_pushinteger(L, XLUASOCKET_TYPE_UDP);
	lua_rawset(L, -3);

	lua_pushstring(L, "SOCKET_WARNING");
	lua_pushinteger(L, XLUASOCKET_TYPE_WARNING);
	lua_rawset(L, -3);

	lua_pushstring(L, "HEADER_TYPE_LINE");
	lua_pushinteger(L, HEADER_TYPE_LINE);
	lua_rawset(L, -3);
	lua_pushstring(L, "HEADER_TYPE_PG");
	lua_pushinteger(L, HEADER_TYPE_PG);
	lua_rawset(L, -3);

	return 1;
}