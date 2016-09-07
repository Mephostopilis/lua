// test.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"
extern "C" {
#include <lua.h>
#include <lauxlib.h>
#include <lgc.h>
#include <lstate.h>
#include <lstring.h>
}

static int 
test1(lua_State *L) {
	int a = lua_tointeger(L, 1);
	int b = lua_tointeger(L, 2);
	int c = a + b;
	global_State *g = G(L);
	int ow = otherwhite(g);
	TString *ts = luaS_new(L, "abcedf");
	if (isdead(g, ts)) {
		lua_error(L);
	}
	if (luaC_white(g) == 2) {
		int a = luaC_white(g);
	} else {
		int a = luaC_white(g);
	}
	lua_pushinteger(L, c);
	return 1;
}

int main() {
	lua_State *L = luaL_newstate();
	if (L == NULL) {
		return 1;
	}
	lua_pushcfunction(L, &test1);
	lua_pushinteger(L, 2);
	lua_pushinteger(L, 3);
	int status = lua_pcall(L, 2, 1, 0);

	return 0;
}

