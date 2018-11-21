#define LUA_LIB

#ifdef __cplusplus
extern "C" {
#endif
#include <lua.h>
#include <lauxlib.h>

LUAMOD_API int luaopen_fixmath_bounce(lua_State *L);

#ifdef __cplusplus
}
#endif

#include <LuaBridge\LuaBridge.h>
#include "Bounce.h"

int
luaopen_fixmath_bounce(lua_State *L) {
	luabridge::getGlobalNamespace(L)
		.beginNamespace("bounce")
		.beginClass<b3Time>("b3Time")
		.addStaticFunction("GetRealTime", &b3Time::GetRealTime)
		.addConstructor<void(*) (luabridge::LuaRef)>()
		.addFunction("SetResolution", &b3Time::SetResolution)
		.addFunction("GetCurMicros", &b3Time::GetCurMicros)
		.addFunction("GetDeltaMicros", &b3Time::GetDeltaMicros)
		.addFunction("GetCurSecs", &b3Time::GetCurSecs)
		.addFunction("GetDeltaSecs", &b3Time::GetDeltaSecs)
		.endClass()
		.beginClass<b3World>("b3World")
		.addFunction("CreateBody", &b3World::CreateBody)
		.endClass()
		.beginClass<b3Body>("b3Body")
		.addFunction("CreateShape", &b3Body::CreateShape)
		.endClass()
		.beginClass<b3Shape>("b3Shape")
		.endClass()
		.endNamespace();
		//.beginClass<Chestnut::EntitasPP::ISystem>("ISystem")
		//.endClass()
		//.beginClass<Chestnut::EntitasPP::ISetRefPoolSystem>("ISetRefPoolSystem")
		//.addFunction("SetPool", &Chestnut::EntitasPP::ISetPoolSystem::SetPool)
		//.endClass()
		//.beginClass<Chestnut::EntitasPP::IInitializeSystem>("IInitializeSystem")
		//.addFunction("Initialize", &Chestnut::EntitasPP::IInitializeSystem::Initialize)
		//.endClass()
		//.beginClass<Chestnut::EntitasPP::IExecuteSystem>("IExecuteSystem")
		//.addFunction("Execute", &Chestnut::EntitasPP::IExecuteSystem::Execute)
		//.endClass()
		//.beginClass<Chestnut::EntitasPP::IFixedExecuteSystem>("IFixedExecuteSystem")
		//.addFunction("FixedExecute", &Chestnut::EntitasPP::IFixedExecuteSystem::FixedExecute)
		//.endClass()
		//.endNamespace()
		//.beginNamespace("Ball")
		//.beginClass<Chestnut::Ball::Systems>("Systems")
		////.addFunction("GetIndexSystem", &Chestnut::Ball::Systems::GetIndexSystem)
		//.endClass()
		//.deriveClass<Chestnut::Ball::MoveSystem, Chestnut::EntitasPP::ISystem>("MoveSystem")
		//.addFunction("SetPool", &Chestnut::Ball::MoveSystem::SetPool)
		//.addFunction("FixedExecute", &Chestnut::Ball::MoveSystem::FixedExecute)
		//.endClass()
		//.deriveClass<Chestnut::Ball::JoinSystem, Chestnut::EntitasPP::ISystem>("JoinSystem")

		//.addFunction("SetPool", &Chestnut::Ball::JoinSystem::SetPool)
		//.addFunction("Join", &Chestnut::Ball::JoinSystem::Join)
		//.addFunction("Leave", &Chestnut::Ball::JoinSystem::Leave)
		//.endClass()
		//.deriveClass<Chestnut::Ball::IndexSystem, Chestnut::EntitasPP::ISystem>("IndexSystem")
		//.addFunction("SetPool", &Chestnut::Ball::IndexSystem::SetPool)
		//.addFunction("Initialize", &Chestnut::Ball::IndexSystem::Initialize)
		//.addFunction("FixedExecute", &Chestnut::Ball::IndexSystem::FixedExecute)
		//.endClass()
		//.deriveClass<Chestnut::Ball::MapSystem, Chestnut::EntitasPP::ISystem>("MapSystem")
		//.addFunction("SetPool", &Chestnut::Ball::MapSystem::SetPool)
		//.addFunction("Initialize", &Chestnut::Ball::MapSystem::Initialize)
		//.addFunction("FixedExecute", &Chestnut::Ball::MapSystem::FixedExecute)
		//.endClass()
		//.endNamespace()
		//.endNamespace();

	return 0;
}
