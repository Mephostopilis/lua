#ifndef ANDROID
#define LUA_LIB
#endif // !ANDROID

#include <lua.h>
#include <lauxlib.h>
#include <stdio.h>

static int
lclear(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_pushinteger(L, 0);
	lua_rawseti(L, 1, 0);
	return 0;
}

static int
linsert(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_Integer idx = luaL_checkinteger(L, 2);

	if (idx <= 0) {
		return luaL_error(L, "The index should be positive (%d)", (int)idx);
	}
	lua_rawgeti(L, 1, 0);
	lua_Integer sparselen = luaL_checkinteger(L, -1);
	if (idx == sparselen + 1) {
		lua_pop(L, 1);
		lua_settop(L, 3);
		lua_rawseti(L, 1, idx);
		lua_pushinteger(L, idx);
		return 1;
	}
	if (idx > sparselen + 1) {
		return luaL_error(L, "The index should be less then (%d)", (int)sparselen);
	}

	lua_pop(L, 1);
	lua_Integer pos = sparselen;
	for (; pos >= idx; pos--) {
		lua_rawgeti(L, 1, pos);
		lua_rawseti(L, 1, pos + 1);
	}

	lua_settop(L, 3);
	lua_rawseti(L, 1, idx);
	lua_pushinteger(L, idx);
	return 1;
}

static int
lpush_back(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_rawgeti(L, 1, 0);
	lua_Integer sparselen = luaL_checkinteger(L, -1);
	lua_pop(L, 1);
	lua_settop(L, 2);
	lua_rawseti(L, 1, sparselen + 1);
	lua_pushinteger(L, sparselen + 1);
	lua_rawseti(L, 1, 0);
	return 0;
}

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

static int
quick_sort(lua_State *L, lua_Integer l, lua_Integer r) {
	if (l >= r) {
		return 0;
	}
	lua_settop(L, 2);
	lua_Integer i, j;
	i = l;
	j = r;
	lua_rawgeti(L, 1, l);  // 3

	while (i < j) {
		while (i < j) {
			lua_pushvalue(L, 2);
			lua_rawgeti(L, 1, j);
			lua_pushvalue(L, 3);
			lua_pcall(L, 2, 1, 0);
			lua_Integer r = luaL_checkinteger(L, -1);
			lua_pop(L, 1);
			if (r > 0) {
				j--;
			} else {
				lua_rawgeti(L, 1, j);
				lua_rawseti(L, 1, i);
				i++;
				break;
			}
		}
		while (i < j) {
			lua_pushvalue(L, 2);
			lua_rawgeti(L, 1, j);
			lua_pushvalue(L, 3);
			lua_pcall(L, 2, 1, 0);
			lua_Integer r = luaL_checkinteger(L, -1);
			lua_pop(L, 1);
			if (r < 0) {
				i++;
			} else {
				lua_rawgeti(L, 1, i);
				lua_rawseti(L, 1, j);
				j++;
				break;
			}
		}
	}
	lua_pushvalue(L, 3);
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

	if (sparselen <= 512) {
		return quick_sort(L, 1, sparselen);
	} else {
		return quick_sort(L, 1, sparselen);
	}
}

static int
lindex(lua_State *L) {
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
	lua_pop(L, 1);

	lua_rawgeti(L, 1, idx);
	return 1;
}

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
	lua_pop(L, 1);

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

	if (lua_rawgeti(L, 1, idx) != LUA_TNIL) {
		lua_pushinteger(L, idx);
		lua_pushvalue(L, -2);
		return 2;
	}

	size_t rawlen = lua_rawlen(L, 1);
	if (rawlen >= idx) {
		size_t i;
		for (i = idx + 1; i <= rawlen; i++) {
			if (lua_rawgeti(L, 1, i) != LUA_TNIL) {
				lua_pushinteger(L, i);
				lua_pushvalue(L, -2);
				return 2;
			}
			lua_pop(L, 1);
		}
		return luaL_error(L, "Invalid index %d", (int)idx);
	}

	if (lua_rawgeti(L, 1, 0) != LUA_TNUMBER)
		return luaL_error(L, "Invalid array");
	lua_Integer sparselen = lua_tointeger(L, -1);
	lua_pop(L, 1);
	if (sparselen == 0)
		return 0;
	if (sparselen > 0) {
		lua_pushcfunction(L, lsort);
		lua_pushvalue(L, 1);
		lua_pushinteger(L, sparselen);
		lua_call(L, 2, 1);	// resort sparse array
		sparselen = lua_tointeger(L, -1);
		lua_pop(L, 1);
	} else {
		sparselen = -sparselen;
	}

	// binary search
	lua_Integer begin = 0, end = sparselen;
	while (begin < end) {
		lua_Integer mid = (begin + end) / 2;
		lua_rawgeti(L, 1, -mid - 1);
		lua_Integer v = luaL_checkinteger(L, -1);
		lua_pop(L, 1);
		if (v > idx) {
			end = mid;
		} else if (v < idx) {
			begin = mid + 1;
		} else {
			begin = mid;
			break;
		}
	}
	if (begin >= sparselen)
		return 0;
	lua_rawgeti(L, 1, -begin - 1);
	idx = luaL_checkinteger(L, -1);
	lua_rawgeti(L, 1, idx);

	return 2;
}

static int
lpairs(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_rawgeti(L, 1, 0);
	lua_Integer sparselen = luaL_checkinteger(L, -1);
	if (sparselen <= 0) {
		return 0;
	}

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
	lua_createtable(L, n, 5);
	lua_pushvalue(L, lua_upvalueindex(1));
	lua_setmetatable(L, -2);

	int i;
	for (i = 1; i <= n; i++) {
		lua_pushvalue(L, i);
		lua_rawseti(L, -2, i);
	}
	lua_pushinteger(L, n);
	lua_rawseti(L, -2, 0);

	luaL_Reg l[] = {
		{ "clear", lclear },
		{ "insert", linsert },
		{ "push_back", lpush_back },
		{ "pop_back", lpop_back },
		{ "sort", lsort },
		{ NULL, NULL },
	};
	for (size_t i = 0; i < sizeof(l) / sizeof(luaL_Reg); i++) {
		if (l[i].name) {
			lua_pushstring(L, l[i].name);
			lua_pushcfunction(L, l[i].func);
			lua_rawset(L, -3);
		}
	}
	return 1;
}

LUAMOD_API int
luaopen_chestnut_vector(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg metatable[] = {
		{ "__index", lindex },
		{ "__newindex", lnewindex },
		{ "__pairs", lpairs },
		{ "__len", llen },
		{ NULL, NULL },
	};
	luaL_newlib(L, metatable);
	lua_pushcclosure(L, lnewvector, 1);

	return 1;
}
