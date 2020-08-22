#define LUA_LIB

#include "xluaconf.h"

#include "array.h"
#include "message_queue.h"
#include "simplethread.h"
#include "skynet_timer.h"
#include "socket_server.h"

#include <lauxlib.h>
#include <lua.h>

#include <assert.h>
#include <netinet/in.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define XLUASOCKET_ERROR_OVERFLOW 1
#define XLUASOCKET_ERROR_SOCKET 2

#define XLUASOCKET_TYPE_DATA 1
#define XLUASOCKET_TYPE_CONNECT 2
#define XLUASOCKET_TYPE_CLOSE 3
#define XLUASOCKET_TYPE_ACCEPT 4
#define XLUASOCKET_TYPE_ERROR 5
#define XLUASOCKET_TYPE_UDP 6
#define XLUASOCKET_TYPE_WARNING 7

#define MAX_SENDPACK_NUM (10)
#define MAX_RECVPACK_NUM (4)
#define MAX_SLICEPACK_NUM (20)

#define RINGBUF_CAP (256)

#define THREADS 1
static bool inited = false;
static struct socket_server* ss;
static struct message_queue* q;
struct args {
    int n;
    struct thread_event* wait;
    struct thread_event* trigger;
};
static struct thread t[THREADS];
struct thread_event ev[THREADS];
static struct args args[THREADS];

static void*
soi_buffer(void* ptr)
{
    return NULL;
}

static int
soi_size(void* ptr)
{
    return 0;
}

static void
soi_free(void* ptr) {}

static void
on_handle_msg(lua_State* L, struct xluasocket_message* msg)
{
    switch (msg->type) {
    case XLUASOCKET_TYPE_DATA: {
        lua_getglobal(L, "xluasocket");
        luaL_checktype(L, -1, LUA_TFUNCTION);
        lua_pushinteger(L, msg->type);
        lua_pushinteger(L, msg->id);
        lua_pushinteger(L, msg->ud);
        lua_pushlstring(L, msg->buffer, msg->ud);
        if (lua_pcall(L, 4, 0, 0) == 0) {
        }
        FREE(msg->buffer);
        break;
    }
    case XLUASOCKET_TYPE_ERROR:
    case XLUASOCKET_TYPE_CONNECT:
    case XLUASOCKET_TYPE_ACCEPT: {
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
forward_message(int type, bool padding, struct socket_message* result)
{
    struct xluasocket_message* sm;
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
    sm = (struct xluasocket_message*)MALLOC(sz);
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
xluasocket_poll()
{
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
co(void* p)
{
    struct args* arg = p;
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
lnew(lua_State* L)
{
    if (inited) {
        luaL_error(L, "inited succsss.");
        return 0;
    }
    luaL_checktype(L, 1, LUA_TFUNCTION);
    lua_settop(L, 1);
    lua_setglobal(L, "xluasocket");

    skynet_timer_init(); // 初始timer
    q = mq_create(); // 初始消息队列
    if (q == NULL) {
        luaL_error(L, "q is null");
    }
    ss = socket_server_create(skynet_now()); // 初始socket
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

    int i = 0;
    for (i = 0; i < THREADS; i++) {
        t[i].func = co;
        t[i].ud = &args[i];
        args[i].n = i;
    }
    thread_create(t, THREADS);
    inited = true;

    lua_pushinteger(L, 0);
    return 1;
}

static int
lfree(lua_State* L)
{
    if (!inited) {
        luaL_error(L, "not inited.");
        return 0;
    }
    socket_server_release(ss);
    // release mq
    mq_release(q);
    // release rb

    return 0;
}

static int
lpoll(lua_State* L)
{
    for (size_t i = 0; i < MAX_RECVPACK_NUM; i++) {
        struct xluasocket_message* msg = mq_pop(q);
        if (msg != NULL) {
            on_handle_msg(L, msg);
            FREE(msg);
        }
    }
    return 0;
}

static int
lexit(lua_State* L)
{
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
llisten(lua_State* L)
{
    size_t sz;
    const char* addr = luaL_checklstring(L, 1, &sz);
    lua_Integer port = luaL_checkinteger(L, 2);
    int id = socket_server_listen(ss, L, addr, port, 0);
    lua_pushinteger(L, id);
    return 1;
}

/*
** @return [1] 0 success
**		      -1 failture
*/
static int
lconnect(lua_State* L)
{
    size_t sz;
    const char* addr = luaL_checklstring(L, 1, &sz);
    uint16_t port = luaL_checkinteger(L, 2);
    int id = socket_server_connect(ss, L, addr, port);
    lua_pushinteger(L, id);
    return 1;
}

static int
lbind(lua_State* L)
{
    lua_Integer fd = luaL_checkinteger(L, 1);
    int id = socket_server_bind(ss, L, fd);
    lua_pushinteger(L, id);
    return 1;
}

static int
lclosesocket(lua_State* L)
{
    lua_Integer id = luaL_checkinteger(L, 1);
    socket_server_close(ss, L, id);
    return 0;
}

static int
lshutdown(lua_State* L)
{
    lua_Integer id = luaL_checkinteger(L, 1);
    socket_server_shutdown(ss, L, id);
    return 0;
}

static int
lstart(lua_State* L)
{
    lua_Integer id = luaL_checkinteger(L, 1);
    socket_server_start(ss, L, id);
    return 0;
}

/*
** @return [1] 0    success
**		      -1    failture
*/
static int
lsend(lua_State* L)
{
    int err = -1;
    lua_Integer id = luaL_checkinteger(L, 1);
    size_t sz;
    const char* buffer = luaL_checklstring(L, 2, &sz);
    char* pack = MALLOC(sz);
    memcpy(pack, buffer, sz);
    err = socket_server_send(ss, id, pack, sz);
    lua_pushinteger(L, err);
    return 1;
}

static int
lkeepalive(lua_State* L)
{
    luaL_error(L, "error.");
    lua_Integer id = luaL_checkinteger(L, 1);
    // struct lua_gate *g = (struct lua_gate *)lua_touserdata(L, 1);
    // struct lua_socket * so = (struct lua_socket*)lua_touserdata(L, 2);
    //setsockopt(so->so)
    return 0;
}

LUAMOD_API int
luaopen_xluasocket(lua_State* L)
{
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
        { "shutdown", lshutdown },
        { "closesocket", lclosesocket },
        { "keepalive", lkeepalive },

        { "send", lsend },

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

    return 1;
}