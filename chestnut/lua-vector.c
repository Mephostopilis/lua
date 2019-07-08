#ifndef ANDROID
#define LUA_LIB
#endif // !ANDROID

#include <lua.h>
#include <lauxlib.h>
#include <stdio.h>
#include <string.h>

/*
** @breif
** @param #1 table
** @param #2 index
** @return 1 (element)
*/
static int
lat(lua_State *L) {
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

	lua_rawgeti(L, 1, idx);
	return 1;
}

/*
** @breif
** @param #1 table
** @return 0
*/
static int
lclear(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_rawgeti(L, 1, 0);
	lua_Integer sparselen = luaL_checkinteger(L, -1);
	for (lua_Integer i = 1; i <= sparselen; ++i) {
		lua_pushnil(L);
		lua_rawseti(L, 1, i);
	}
	lua_pushinteger(L, 0);
	lua_rawseti(L, 1, 0);
	return 0;
}

/*
** @breif
** @param #1 table
** @param #2 index
** @param #3 element
** @return 0
*/
static int
linsert(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_Integer idx = luaL_checkinteger(L, 2);
	if (idx <= 0) {
		return luaL_error(L, "The index should be positive (%d)", (int)idx);
	}
	int n = lua_gettop(L);
	if (n < 3) {
		return luaL_error(L, "The param more than 3");
	}
	if (lua_isnil(L, 3)) {
		return luaL_error(L, "The param #3 is nil");
	}
	lua_rawgeti(L, 1, 0);
	lua_Integer sparselen = luaL_checkinteger(L, -1);
	if (idx == sparselen + 1) {
		lua_pushvalue(L, 3);
		lua_rawseti(L, 1, idx);
		lua_pushinteger(L, sparselen + 1);
		lua_rawseti(L, 1, 0);
		return 0;
	}
	if (idx > sparselen + 1) {
		return luaL_error(L, "The index should be less then (%d)", (int)sparselen);
	}
	lua_Integer pos = sparselen;
	for (; pos >= idx; pos--) {
		lua_rawgeti(L, 1, pos);
		lua_rawseti(L, 1, pos + 1);
	}
	lua_rawseti(L, 1, idx);
	lua_pushinteger(L, sparselen + 1);
	lua_rawseti(L, 1, 0);
	return 0;
}

/*
** @breif
** @param #1 table
** @param #2 element
** @return 0
*/
static int
lerase(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	if (lua_isnil(L, 2)) {
		return luaL_error(L, "The param #3 is nil");
	}
	
	lua_rawgeti(L, 1, 0);
	lua_Integer sparselen = luaL_checkinteger(L, -1);
	for (size_t i = 1; i <= sparselen; i++) {
		lua_rawgeti(L, 1, i);
		lua_pushvalue(L, 2);
		// check equil
	}
	return 0;
}

/*
** @breif
** @param #1 table
** @param #2 index
** @return 0
*/
static int
leraseat(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_Integer idx = luaL_checkinteger(L, 2);
	if (idx <= 0) {
		return luaL_error(L, "The index should be positive (%d)", (int)idx);
	}
	lua_rawgeti(L, 1, 0);
	lua_Integer sparselen = luaL_checkinteger(L, -1);
	if (idx >= sparselen) {
		return luaL_error(L, "The index should be less then (%d)", (int)sparselen);
	}
	if (idx < sparselen) {
		lua_Integer pos = idx + 1;
		for (; pos <= sparselen; ++pos) {
			lua_rawgeti(L, 1, pos);
			lua_rawseti(L, 1, pos - 1);
		}
	} else {
		lua_pushnil(L);
		lua_rawseti(L, 1, idx);
	}
	lua_pushinteger(L, sparselen - 1);
	lua_rawseti(L, 1, 0);
	return 0;
}

/*
** @breif
** @param #1 table
** @param #2 element
** @return 1 (index)
*/
static int
lpush_back(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	if (lua_type(L, 2) == LUA_TNIL) {
		luaL_error(L, "not push back nil.");
		return 0;
	}
	lua_rawgeti(L, 1, 0);
	lua_Integer sparselen = luaL_checkinteger(L, -1);
	lua_settop(L, 2);
	lua_rawseti(L, 1, sparselen + 1);
	lua_pushinteger(L, sparselen + 1);
	lua_rawseti(L, 1, 0);
	lua_pushinteger(L, sparselen + 1);
	return 1;
}

/*
** @breif
** @param #1 table
** @param #2 element
** @return 0
*/
static int
lpop_back(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_rawgeti(L, 1, 0);
	lua_Integer sparselen = luaL_checkinteger(L, -1);
	if (sparselen > 0) {
		lua_pushinteger(L, sparselen - 1);
		lua_rawseti(L, 1, 0);
	}
	return 0;
}

/*
** @breif 加入一个元素，
** @param #1 table
** @param #2 element
** @return 1 (index)
*/
static int
lindexof(lua_State *L) {
    return 0;
}

static int
quick_sort(lua_State *L, lua_Integer l, lua_Integer r) {
	if (l >= r) {
		return 0;
	}
	lua_Integer i = 0, j = 0, t = 0;
	i = l;
	j = r;
	lua_rawgeti(L, 1, l);  // 3

	while (i < j) {
		while (i < j) {
			lua_pushvalue(L, 2);
			lua_pushvalue(L, -2);        // l
			lua_rawgeti(L, 1, j);       // r
			lua_call(L, 2, 1);
			lua_Integer r = luaL_checkinteger(L, -1);
			lua_pop(L, 1);
			if (r < 0) {
				--j;
			} else {
				lua_rawgeti(L, 1, j); 
				lua_rawseti(L, 1, i);
				++i;
				break;
			}
		}
		while (i < j) {
			lua_pushvalue(L, 2);
			lua_rawgeti(L, 1, i);
			lua_pushvalue(L, -3);
			lua_call(L, 2, 1);
			lua_Integer r = luaL_checkinteger(L, -1);
			lua_pop(L, 1);
			if (r < 0) {
				++i;
			} else {
				lua_rawgeti(L, 1, i);
				lua_rawseti(L, 1, j);
				--j;
				break;
			}
		}
	}
	lua_rawseti(L, 1, i);

	quick_sort(L, l, i - 1);
	quick_sort(L, i + 1, r);
	return 0;
}

static int
lsort(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	luaL_checktype(L, 2, LUA_TFUNCTION);
	lua_rawgeti(L, 1, 0);
	lua_Integer sparselen = luaL_checkinteger(L, -1);
	lua_settop(L, 2);
	if (sparselen <= 512) {
		return quick_sort(L, 1, sparselen);
	} else {
		return quick_sort(L, 1, sparselen);
	}
}

static int
lnewindex(lua_State *L) {
	/*luaL_checktype(L, 1, LUA_TTABLE);
	lua_Integer idx = luaL_checkinteger(L, 2);
	if (idx <= 0) {
		return luaL_error(L, "The index should be positive (%d)", (int)idx);
	}
	lua_rawgeti(L, 1, 0);
	lua_Integer sparselen = luaL_checkinteger(L, -1);
	if (idx > sparselen) {
		return luaL_error(L, "The index should be less then (%d)", (int)sparselen);
	}
	lua_pop(L, 1);

	lua_settop(L, 3);
	lua_rawseti(L, 1, idx);*/
	luaL_error(L, "newindex met method not supported.");
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
	lua_rawgeti(L, 1, 0);
	lua_Integer sparselen = luaL_checkinteger(L, -1);
	if (idx <= sparselen ) {
		lua_pushinteger(L, idx);
		lua_rawgeti(L, 1, idx);
		return 2;
	}
	return 0;
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
lnewvector(lua_State *L) {
	int n = lua_gettop(L);
	lua_createtable(L, n, 1);
	lua_pushvalue(L, lua_upvalueindex(1));
	lua_setmetatable(L, -2);

	for (int i = 1; i <= n; ++i) {
		lua_pushvalue(L, i);
		lua_rawseti(L, -2, i);
	}
	lua_pushinteger(L, n);
	lua_rawseti(L, -2, 0);

	return 1;
}

LUAMOD_API int
luaopen_chestnut_vector(lua_State *L) {
	luaL_checkversion(L);

	luaL_Reg metatable[] = {
		{ "__newindex", lnewindex },
		{ "__pairs", lpairs },
		{ "__len", llen },
		{ NULL, NULL },
	};
	luaL_newlib(L, metatable);

	lua_pushstring(L, "__index");
	luaL_Reg l[] = {
		{ "at", lat },
		{ "clear", lclear },
		{ "insert", linsert },
		{ "erase", lerase },
		{ "eraseat", leraseat },
		{ "push_back", lpush_back },
		{ "pop_back", lpop_back },
		{ "sort", lsort },
		{ "indexof", lindexof },
		{ NULL, NULL },
	};
	lua_createtable(L, 0, 9);
	for (size_t i = 0; i < sizeof(l) / sizeof(luaL_Reg); i++) {
		if (l[i].name) {
			lua_pushstring(L, l[i].name);
			lua_pushcfunction(L, l[i].func);
			lua_rawset(L, -3);
		}
	}
	lua_rawset(L, -3);
	lua_pushcclosure(L, lnewvector, 1);

	return 1;
}
