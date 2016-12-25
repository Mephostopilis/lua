#include "csv.h"

#ifdef __cplusplus
extern "C" {
#endif // 
#include <lua.h>
#include <lauxlib.h>
#ifdef __cplusplus
}
#endif // __cplusplus

#include <cstdlib>
#include <map>

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
	csv<uint32_t, 1, nullptr_t> *sysmail;
	csv<uint32_t, 1, nullptr_t> *task;
};

static struct sharedata *inst;

static int
lalloc(lua_State *L) {
	if (inst == NULL) {
		inst = (struct sharedata *)malloc(sizeof(*inst));
	}
	lua_pushlightuserdata(L, inst);
	return 1;
}

static int
lfree(lua_State *L) {
	struct sharedata *sd = (struct sharedata *)lua_touserdata(L, 1);
	if (sd != NULL) {
		free(sd);
		sd = NULL;
	}
	return 0;
}

static int
linit(lua_State *L) {
	struct sharedata *sd = (struct sharedata *)lua_touserdata(L, 1);
	csv<uint32_t, 1, nullptr_t> *sysmail = new csv<uint32_t, 1, nullptr_t>(&sd->strt, "D:\\Ember\\Documents\\github\\crazy\\module\\host\\config\\sysmail.xlsx", 1, 3, 4);
	csv<uint32_t, 1, nullptr_t> *task = new csv<uint32_t, 1, nullptr_t>(&sd->strt, "D:\\Ember\\Documents\\github\\crazy\\module\\host\\config\\task.xlsx", 1, 3, 4);
	sd->sysmail = sysmail;
	sd->task = task;

	return 0;
}

static int
lget(lua_State *L) {
	struct sharedata *sd = (struct sharedata *)lua_touserdata(L, 1);
	std::string key = lua_tostring(L, 2);
	size_t _1 = key.find(':');
	size_t _2 = key.find("@");
	std::string tname = key.substr(0, _1);
	std::string mk = key.substr(_1 + 1, _2 - _1);
	std::string col_name = key.substr(_2 + 1, key.length() - _2);
	if (tname == "sysmail") {
		if (is_integer(mk)) {
			uint32_t ui = std::atoi(mk.c_str());
			const value_t &v = sd->sysmail->search(ui, col_name);
			if (v.tt == value_t::UINT32_T) {
				lua_pushinteger(L, v.v.ui);
				return 1;
			}
		}
	}
}


#ifdef __cplusplus
extern "C" {
#endif // 
int
luaopen_sharedata(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{"alloc", lalloc},
		{"free", lfree},
		{"get", lget },
		{NULL, NULL}
	};

	luaL_newlib(L, l);
	return 1;
}
#ifdef __cplusplus
}
#endif // __cplusplus