#ifndef ANDROID
#define LUA_LIB
#endif // !ANDROID

#include <lua.h>
#include <lauxlib.h>
#include <stdio.h>
#include <math.h>

static int
lnewindex(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_Integer idx = luaL_checkinteger(L, 2);
	if (idx <= 0) {
		return luaL_error(L, "The index should be positive (%d)", (int)idx);
	}

	lua_rawgeti(L, 1, 0);
	lua_Integer sparselen = luaL_checkinteger(L, -1);
	if (idx > sparselen) {
		return luaL_error(L, "The index should be less then (%d)", (int)sparselen);
	}

	lua_settop(L, 3);
	lua_rawseti(L, 1, idx);
	return 0;
}

static int
lnext(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_Integer idx;
	if (lua_isnoneornil(L, 2)) {
		idx = 1;
	} else {
		if (!lua_isinteger(L, 2)) {
			return luaL_error(L, "last index should be integer");
		}
		idx = lua_tointeger(L, 2) + 1;
	}
	if (lua_rawgeti(L, 1, 0) != LUA_TNUMBER)
		return luaL_error(L, "Invalid array");
	lua_Integer sparselen = lua_tointeger(L, -1);

	if (idx > sparselen) {
		return 0;
	}
	lua_rawgeti(L, 1, idx);
	lua_pushinteger(L, idx);
	lua_pushvalue(L, -2);
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
llen(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_rawgeti(L, 1, 0);
	return 1;
}

static int
lnewarrayinit(lua_State *L) {
	int n = lua_gettop(L);
	lua_pushvalue(L, lua_upvalueindex(1));
	lua_Integer size = luaL_checkinteger(L, -1);
	lua_createtable(L, size, 0);
	lua_pushvalue(L, lua_upvalueindex(2));
	lua_setmetatable(L, -2);
	luaL_checktype(L, -1, LUA_TTABLE);
	int i;
	for (i = 1; i <= n && i <= size; i++) {
		lua_pushvalue(L, i);
		lua_rawseti(L, -2, i);
	}
	lua_pushinteger(L, size);
	lua_rawseti(L, -2, 0);
	return 1;
}

static int
lnewarray(lua_State *L) {
	lua_Integer size = luaL_checkinteger(L, 1);
	size = (size < 0) ? 0 : size;
	lua_pushinteger(L, size);
	lua_pushvalue(L, lua_upvalueindex(1));
	lua_pushcclosure(L, lnewarrayinit, 2);
	return 1;
}

LUAMOD_API int
luaopen_chestnut_array(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg metatable[] = {
		{ "__newindex", lnewindex },
		{ "__pairs", lpairs },
		{ "__len", llen },
		{ NULL, NULL },
	};
	luaL_newlib(L, metatable);
	lua_pushcclosure(L, lnewarray, 1);

	return 1;
}
