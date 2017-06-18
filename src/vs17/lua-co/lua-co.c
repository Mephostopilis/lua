#include <lua.h>
#include <lauxlib.h>

int k(lua_State *L, int status, lua_KContext *ctx) {

}

static int
func1(lua_State *L) {
	if (lua_isfunction(L, 1)) {
	}
	//return k(L, lua_pcallk(L, 0, 0, 0,  ))
	//lua_pcall(L, )
	lua_call(L, 0, 0);
	return 0;
}

static int 
func2(lua_State *L) {
	luaL_checktype(L, 1, LUA_TFUNCTION);
	lua_State *co = lua_newthread(L);
	lua_pushvalue(L, 1);
	lua_xmove(L, co, 1);
	lua_resume(co, L, 0);
	printf("hello world.");
}

LUAMOD_API int
luaopen_cotest(lua_State *L) {
	luaL_checkversion(L);
	const luaL_Reg l[] = {

		{ "func1", func1 },
		{ "func2", func2 },
		{ NULL, NULL }
	};
	luaL_newlib(L, l);
	return 1;
}