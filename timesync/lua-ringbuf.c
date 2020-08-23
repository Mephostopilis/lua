#define LUA_LIB

#include "array.h"
#include "ringbuf.h"

#include <lauxlib.h>
#include <lua.h>

#include <assert.h>
#include <string.h>

#define MAX_BUF_LEN (1024)

static int
lcapacity(lua_State* L)
{
    ringbuf_t* aux = (ringbuf_t*)lua_touserdata(L, 1);
    size_t b = ringbuf_capacity(aux);
    lua_pushinteger(L, b);
    return 1;
}

static int
lmemcpy_buffer(lua_State* L)
{
    ringbuf_t* aux = (ringbuf_t*)lua_touserdata(L, 1);
    size_t sz = 0;
    const char* buf = luaL_checklstring(L, 2, &sz);
    int err = ringbuf_memcpy_buffer(aux, buf, sz);
    lua_pushinteger(L, err);
    return 1;
}

static int
lget_string(lua_State* L)
{
    ringbuf_t* aux = (ringbuf_t*)lua_touserdata(L, 1);
    size_t sz = MAX_BUF_LEN;
    ARRAY(char, buf, sz);
    memset(buf, 0, sz);
    int err = ringbuf_get_string(&buf, &sz, aux);
    if (err == RINGBUF_OK) {
        lua_pushinteger(L, err);
        lua_pushlstring(L, buf, sz);
        return 2;
    }
    lua_pushinteger(L, err);
    return 1;
}

static int
lget_line(lua_State* L)
{
    ringbuf_t* aux = (ringbuf_t*)lua_touserdata(L, 1);
    size_t sz = MAX_BUF_LEN;
    ARRAY(char, buf, sz);
    memset(buf, 0, sz);
    int err = ringbuf_get_line(&buf, &sz, aux);
    if (err == RINGBUF_OK) {
        lua_pushinteger(L, err);
        lua_pushlstring(L, buf, sz);
        return 2;
    }
    lua_pushinteger(L, err);
    return 1;
}

static int
lfree(lua_State* L)
{
    ringbuf_t* aux = (ringbuf_t*)lua_touserdata(L, 1);
    ringbuf_free(aux);
    return 0;
}

static int
lalloc(lua_State* L)
{
    ringbuf_t* aux = (ringbuf_t*)lua_newuserdata(L, sizeof(*aux));
    if (aux == NULL) {
        luaL_error(L, "new udata failture.");
        return 0;
    }
    memset(aux, 0, sizeof(*aux));
    ringbuf_init(aux, 256);
    lua_pushvalue(L, lua_upvalueindex(1));
    lua_setmetatable(L, -2);
    return 1;
}

LUAMOD_API int
luaopen_timesync_ringbuf(lua_State* L)
{
    luaL_checkversion(L);
    lua_newtable(L); // met
    luaL_Reg l[] = {
        { "capacity", lcapacity },
        { "memcpy_buffer", lmemcpy_buffer },
        { "get_string", lget_string },
        { "get_line", lget_line },
        { NULL, NULL },
    };
    luaL_newlib(L, l);
    lua_setfield(L, -2, "__index");
    lua_pushcclosure(L, lfree, 0);
    lua_setfield(L, -2, "__gc");
    lua_pushcclosure(L, lalloc, 1);
    return 1;
}