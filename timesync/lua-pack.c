#include <lua.h>
#include <lauxlib.h>

static int
lpack(lua_State* L)
{
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
lunpack(lua_State* L)
{
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
    lua_pop(L, 1); // pop unpack
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
        ringbuf_t* rb = ringbuf_new(RINGBUF_CAP);
        lua_pushlightuserdata(L, rb);
        lua_seti(L, -2, id);
    } else {
        ringbuf_t* rb = lua_touserdata(L, -1);
        ringbuf_reset(rb);
    }
    return 0;
}

static int 
test() {
    if (t == HEADER_TYPE_LINE) {
        char* pack = MALLOC(sz + 1);
        memcpy(pack, buffer, sz);
        pack[sz] = '\n';
        err = socket_server_send(ss, id, pack, sz + 1);
    } else if (t == HEADER_TYPE_PG) {
        char* pack = MALLOC(sz + 2);
        WriteInt16(pack, 0, sz);
        memcpy(pack + 2, buffer, sz);
        err = socket_server_send(ss, id, pack, sz + 2);
    } else {
        luaL_error(L, "not supoort other pack");
    }
}

