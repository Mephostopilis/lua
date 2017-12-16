#include "config.h"
#include "csv.h"

#include <cstdlib>
#include <cstdio>
#include <map>
#include <cstring>
#include <new>
#include <assert.h>

#ifdef __cplusplus
extern "C" {
#endif // 
#include <lua.h>
#include <lauxlib.h>

bool is_integer(std::string str) {
	bool res = false;
	if (str.length() <= 0) {
		return res;
	}
	for (auto iter = str.begin(); iter != str.end(); iter++) {
		if (*iter <= 57 && *iter >= 48) {
		} else {
			return res;
		}
	}
	res = true;
	return res;
}

bool is_float(std::string str) {
	return true;
}

struct sharedata {
	strhtable                    strt;
};

static struct sharedata *inst;

static int
lalloc(lua_State *L) {
	if (inst == NULL) {
		inst = (struct sharedata *)lua_newuserdata(L, sizeof(*inst));
		memset(inst, 0, sizeof(*inst));
		strhtable *strh = new (inst) strhtable(111);
		lua_newtable(L);
		lua_setuservalue(L, -2);
		lua_pushvalue(L, lua_upvalueindex(1));
		lua_setmetatable(L, -2);
		lua_geti(L, LUA_REGISTRYINDEX, LUA_RIDX_GLOBALS);
		lua_pushvalue(L, -2);
		lua_rawsetp(L, -2, (const void *)inst);
		lua_pop(L, 1);
		return 1;
	} else {
		lua_geti(L, LUA_REGISTRYINDEX, LUA_RIDX_GLOBALS);
		lua_getfield(L, -1, (const char *)inst);
		luaL_checktype(L, -1, LUA_TUSERDATA);
		return 1;
	}
}

static int
lfree(lua_State *L) {
	luaL_checktype(L, 1, LUA_TUSERDATA);
	struct sharedata *sd = (struct sharedata *) lua_touserdata(L, 1);
	lua_getuservalue(L, 1);
	lua_pushnil(L);
	while (lua_next(L, -2) != 0) {
		lua_getfield(L, -1, "value");
		luaL_checktype(L, 1, LUA_TUSERDATA);
		void *ptr = lua_touserdata(L, -1);
		if (ptr != nullptr) {
			delete ptr;
		}
		lua_pop(L, 1);
	}
	return 0;
}

static int
linit(lua_State *L) {
	struct sharedata *sd = (struct sharedata *)lua_touserdata(L, 1);
	luaL_checktype(L, 2, LUA_TTABLE);
	lua_pushnil(L);
	while (lua_next(L, 2) != 0) {
		luaL_checktype(L, -1, LUA_TTABLE);
		lua_getfield(L, -1, "mkt");
		if (lua_tointeger(L, -1) == value_t::UINT32_T) {
			lua_pop(L, 1);
			lua_getfield(L, -1, "path");
			size_t sz = 0;
			const char *ptr = lua_tolstring(L, -1, &sz);
			char path[128] = { 0 };
			strncpy(path, ptr, sz);
			lua_pop(L, 1);
			lua_getfield(L, -1, "headline");
			int headline = lua_tointeger(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "typeline");
			int typeline = lua_tointeger(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "dataline");
			int dataline = lua_tointeger(L, -1);
			lua_pop(L, 1);

			csv<uint32_t, 1, nullptr_t> *f = new csv<uint32_t, 1, nullptr_t>(&sd->strt, path, headline, typeline, dataline);
			lua_pushlightuserdata(L, f);
			lua_setfield(L, -2, "value");

			lua_getfield(L, -1, "key");
			ptr = lua_tolstring(L, -1, &sz);
			char key[128] = { 0 };
			strncpy(key, ptr, sz);
			lua_pop(L, 1);
			
			lua_getuservalue(L, 1);
			lua_pushvalue(L, -2);
			luaL_checktype(L, -1, LUA_TTABLE);
			lua_setfield(L, -2, key);
			lua_pop(L, 1);
		}
		lua_pop(L, 1);
	}
	return 0;
}

static int
lget(lua_State *L) {
	struct sharedata *sd = (struct sharedata *)lua_touserdata(L, 1);
	std::string key = lua_tostring(L, 2);
	assert(lua_gettop(L) == 2);
	size_t _1 = key.find(':');
	size_t _2 = key.find("@");
	std::string tname = key.substr(0, _1);
	std::string mk = key.substr(_1 + 1, _2 - _1 -1);
	std::string col_name = key.substr(_2 + 1, key.length() - _2 - 1);
	//lua_pop(L, 1);
	lua_getuservalue(L, 1);
	lua_getfield(L, -1, tname.c_str());
	lua_getfield(L, -1, "mkt");
	if (lua_tointeger(L, -1) == value_t::UINT32_T) {
		lua_pop(L, 1);
		lua_getfield(L, -1, "value");
		csv<uint32_t, 1, nullptr_t> *ptr = reinterpret_cast<csv<uint32_t, 1, nullptr_t>*>(lua_touserdata(L, -1));
		if (is_integer(mk)) {
			uint32_t ui = std::atoi(mk.c_str());
			const value_t &v = ptr->search(ui, col_name);
			if (v.tt == value_t::UINT32_T) {
				lua_pushinteger(L, v.v.ui);
				return 1;
			} else if (v.tt == value_t::NONE) {
				return 0;
			}
		}
	}
}

static int
ltest(lua_State *L) {
	printf("test");
	return 0;
}

CONFIG_API int
luaopen_config(lua_State *L) {
	luaL_checkversion(L);
	lua_createtable(L, 0, 2); // met
	luaL_Reg l[] = {
		{"init", linit},
		{"get", lget },
		{"test", ltest},
		{NULL, NULL}
	};
	luaL_newlib(L, l);
	lua_setfield(L, -2, "__index");
	lua_pushcfunction(L, lfree);
	lua_setfield(L, -2, "__gc");
	lua_pushcclosure(L, lalloc, 1);
	return 1;
}
#ifdef __cplusplus
}
#endif // __cplusplus