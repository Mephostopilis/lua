#define LUA_LIB

#ifdef __cplusplus
extern "C" {
#endif
#include <lua.h>
#include <lauxlib.h>

LUAMOD_API int luaopen_ball(lua_State *L);

#ifdef __cplusplus
}
#endif

#include <LuaBridge\LuaBridge.h>
#include "EntitasPP/SystemContainer.h"
#include "systems/JoinSystem.h"
#include "systems/JoinSystem.h"
#include "systems/MoveSystem.h"
#include "systems/MapSystem.h"
#include "systems/IndexSystem.h"
#include "Systems.h"

struct ball_aux {
	int dummy;
};

static int
lalloc(lua_State *L) {
	luabridge::getGlobalNamespace(L)
		.beginNamespace("Chestnut")
		.beginNamespace("EntitasPP")
		.beginClass<Chestnut::EntitasPP::Pool>("Pool")
		.addStaticFunction("Create", &Chestnut::EntitasPP::Pool::Create)
		.addFunction("Test", &Chestnut::EntitasPP::Pool::Test)
		.addFunction("CreateSystemPtr", &Chestnut::EntitasPP::Pool::CreateSystemRef)
		.endClass()
		.beginClass<Chestnut::EntitasPP::ISystem>("ISystem")
		.endClass()
		.beginClass<Chestnut::EntitasPP::ISetRefPoolSystem>("ISetRefPoolSystem")
		.addFunction("SetPool", &Chestnut::EntitasPP::ISetPoolSystem::SetPool)
		.endClass()
		.beginClass<Chestnut::EntitasPP::IInitializeSystem>("IInitializeSystem")
		.addFunction("Initialize", &Chestnut::EntitasPP::IInitializeSystem::Initialize)
		.endClass()
		.beginClass<Chestnut::EntitasPP::IExecuteSystem>("IExecuteSystem")
		.addFunction("Execute", &Chestnut::EntitasPP::IExecuteSystem::Execute)
		.endClass()
		.beginClass<Chestnut::EntitasPP::IFixedExecuteSystem>("IFixedExecuteSystem")
		.addFunction("FixedExecute", &Chestnut::EntitasPP::IFixedExecuteSystem::FixedExecute)
		.endClass()
		.endNamespace()
		.beginNamespace("Ball")
		.beginClass<Chestnut::Ball::Systems>("Systems")
		//.addFunction("GetIndexSystem", &Chestnut::Ball::Systems::GetIndexSystem)
		.endClass()
		.deriveClass<Chestnut::Ball::MoveSystem, Chestnut::EntitasPP::ISystem>("MoveSystem")
		.addFunction("SetPool", &Chestnut::Ball::MoveSystem::SetPool)
		.addFunction("FixedExecute", &Chestnut::Ball::MoveSystem::FixedExecute)
		.endClass()
		.deriveClass<Chestnut::Ball::JoinSystem, Chestnut::EntitasPP::ISystem>("JoinSystem")
		
		.addFunction("SetPool", &Chestnut::Ball::JoinSystem::SetPool)
		.addFunction("Join", &Chestnut::Ball::JoinSystem::Join)
		.addFunction("Leave", &Chestnut::Ball::JoinSystem::Leave)
		.endClass()
		.deriveClass<Chestnut::Ball::IndexSystem, Chestnut::EntitasPP::ISystem>("IndexSystem")
		.addFunction("SetPool", &Chestnut::Ball::IndexSystem::SetPool)
		.addFunction("Initialize", &Chestnut::Ball::IndexSystem::Initialize)
		.addFunction("FixedExecute", &Chestnut::Ball::IndexSystem::FixedExecute)
		.endClass()
		.deriveClass<Chestnut::Ball::MapSystem, Chestnut::EntitasPP::ISystem>("MapSystem")
		.addFunction("SetPool", &Chestnut::Ball::MapSystem::SetPool)
		.addFunction("Initialize", &Chestnut::Ball::MapSystem::Initialize)
		.addFunction("FixedExecute", &Chestnut::Ball::MapSystem::FixedExecute)
		.endClass()
		.endNamespace()
		.endNamespace();

	return 1;
}

static int
lrelease(lua_State *L) {
	return 0;
}

int
luaopen_ball(lua_State *L) {
	luaL_Reg l[] = {
		{ NULL, NULL },
	};
	// create metatable
	int n = 0;
	while (l[n].name)
		++n;
	lua_newtable(L);
	lua_createtable(L, 0, n);
	int i = 0;
	for (; i < n; ++i) {
		lua_pushcfunction(L, l[i].func);
		lua_setfield(L, -2, l[i].name);
	}
	lua_setfield(L, -2, "__index");
	lua_pushstring(L, "ball");
	lua_setfield(L, -2, "__metatable");
	lua_pushcfunction(L, lrelease);
	lua_setfield(L, -2, "__gc");

	lua_pushcclosure(L, lalloc, 1);

	return 1;
}
