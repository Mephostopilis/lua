#define LUA_LIB

#include <lua.h>
#include <lauxlib.h>

#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>


static int
lpush(lua_State *L) {
	lua_settop(L, 2);
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_rawgeti(L, 1, 0);
	lua_Integer top = luaL_checkinteger(L, -1);
	if (lua_type(L, 2) == LUA_TNIL) {
		luaL_error(L, "args #2 must not be nil.");
		return 0;
	}
	lua_pushvalue(L, 2); // forbit more args.
	lua_rawseti(L, 1, ++top);
	lua_pushinteger(L, top);
	lua_rawseti(L, 1, 0);
	return 0;
}

static int
lpop(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_rawgeti(L, 1, 0);
	lua_Integer top = luaL_checkinteger(L, -1);
	if (top <= 0) {
		return 0;
	}
	lua_rawgeti(L, 1, top--);
	lua_pushinteger(L, top);
	lua_rawseti(L, 1, 0);
	return 1;
}

static int
lpeek(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_rawgeti(L, 1, 0);
	lua_Integer top = luaL_checkinteger(L, -1);
	if (top <= 0) {
		return 0;
	}
	lua_rawgeti(L, 1, top);
	return 1;
}

static int
llen(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_rawgeti(L, 1, 0);
	return 1;
}

static int
lnext(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);

	lua_Integer idx;
	if (lua_isnoneornil(L, 2)) {
		lua_rawgeti(L, 1, 0);
		idx = luaL_checkinteger(L, -1);		
	} else {
		idx = lua_tointeger(L, 2);
		idx--;
	}
	if (idx <= 0) {
		return 0;
	}
	lua_pushinteger(L, idx);
	lua_rawgeti(L, 1, idx);
	return 2;
}

static int
lpairs(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_pushcfunction(L, lnext);
	lua_pushvalue(L, 1);
	lua_pushnil(L);
	return 3;
}

static int
lfree(lua_State *L) {
	return 0;
}

static int
lalloc(lua_State *L) {
	int n = lua_gettop(L);
	lua_createtable(L, n, 3);

	lua_pushvalue(L, lua_upvalueindex(1));
	lua_setmetatable(L, -2);

	for (int i = 1; i <= n; i++) {
		lua_pushvalue(L, i);
		lua_rawseti(L, -2, i);
	}

	lua_pushinteger(L, n);
	lua_rawseti(L, -2, 0);

	return 1;
}

LUAMOD_API int
luaopen_chestnut_stack(lua_State *L) {
	luaL_checkversion(L);

	luaL_Reg l[] = {
		{ "__pairs", lpairs },
		{ "__len", llen },
		{ "__gc", lfree },
		{ NULL, NULL },
	};
	luaL_newlib(L, l); // met

	luaL_Reg il[] = {
		{ "push", lpush },
		{ "pop", lpop },
		{ "peek", lpeek },
		{ NULL, NULL },
	};
	luaL_newlib(L, il);

	lua_setfield(L, -2, "__index");
	lua_pushcclosure(L, lalloc, 1);
	return 1;
}