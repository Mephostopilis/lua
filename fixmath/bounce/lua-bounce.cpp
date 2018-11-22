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

#include "Bounce.h"
#include "Common/Math/b3r32.h"
#include <LuaBridge\LuaBridge.h>

namespace luabridge {

	template <>
	struct Stack <b3R32> {
		static void push(lua_State* L, b3R32 const& step) {
			int32_t i = step;
			lua_pushinteger(L, i);
		}

		static b3R32 get(lua_State* L, int index) {
			if (lua_isnumber(L, index)) {
				lua_Number i = lua_tonumber(L, index);
				return b3R32(i);
			} else if (lua_isinteger(L, index)) {
				lua_Integer i = lua_tointeger(L, index);
				return b3R32(i);
			} else {
				luaL_error(L, "#%d argments must be table", index);
			}
			return b3R32::zero;
		}
	};

	template <>
	struct Stack <b3R32 const&> : Stack <b3R32 > {};

	template <>
	struct Stack <b3Vec3> {
		static void push(lua_State* L, b3Vec3 const& vec3) {
			lua_createtable(L, 0, 3);
			Stack<b3R32>::push(L, vec3.x);
			lua_setfield(L, -2, "x");
			Stack<b3R32>::push(L, vec3.y);
			lua_setfield(L, -2, "y");
			Stack<b3R32>::push(L, vec3.z);
			lua_setfield(L, -2, "z");

			// create meta bable
		}

		static b3Vec3 get(lua_State* L, int index) {
			if (!lua_istable(L, index)) {
				luaL_error(L, "#%d argments must be table", index);
			}
			b3Vec3 vec3;
			lua_pushvalue(L, index);
			lua_getfield(L, -1, "x");
			vec3.x = Stack<b3R32>::get(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "y");
			vec3.y = Stack<b3R32>::get(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "z");
			vec3.z = Stack<b3R32>::get(L, -1);
			lua_pop(L, 2);
			return vec3;
		}
	};

	template <>
	struct Stack <b3Vec3 const&> : Stack <b3Vec3 > {};

	template <>
	struct Stack <b3TimeStep> {
		static void push(lua_State* L, b3TimeStep const& step) {
			lua_createtable(L, 0, 3);
			Stack<b3R32>::push(L, step.dt);
			lua_setfield(L, -2, "dt");
			lua_pushinteger(L, step.velocityIterations);
			lua_setfield(L, -2, "velocityIterations");
			lua_pushboolean(L, step.sleeping);
			lua_setfield(L, -2, "velocityIterations");
		}

		static b3TimeStep get(lua_State* L, int index) {
			if (!lua_istable(L, index)) {
				luaL_error(L, "#%d argments must be table", index);
			}

			b3TimeStep step;
			lua_pushvalue(L, index);
			lua_getfield(L, -1, "dt");
			step.dt = Stack<b3R32>::get(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "velocityIterations");
			step.velocityIterations = static_cast<u32>(lua_tointeger(L, -1));
			lua_pop(L, 1);
			lua_getfield(L, -1, "sleeping");
			step.sleeping = lua_toboolean(L, -1);
			lua_pop(L, 2);
			return step;
		}
	};

	template <>
	struct Stack <b3TimeStep const&> : Stack <b3TimeStep > {};


	template <>
	struct Stack <b3Velocity> {
		static void push(lua_State* L, b3Velocity const& vel) {
			lua_createtable(L, 0, 2);
			Stack<b3Vec3>::push(L, vel.v);
			lua_setfield(L, -2, "v");
			Stack<b3Vec3>::push(L, vel.w);
			lua_setfield(L, -2, "w");
		}

		static b3Velocity get(lua_State* L, int index) {
			if (!lua_istable(L, index)) {
				luaL_error(L, "#%d argments must be table", index);
			}

			b3Velocity vel;
			lua_pushvalue(L, index);
			lua_getfield(L, -1, "v");
			vel.v = Stack<b3Vec3>::get(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "w");
			vel.w = Stack<b3Vec3>::get(L, -1);
			lua_pop(L, 2);
			return vel;
		}
	};

	template <>
	struct Stack <b3Velocity const&> : Stack <b3Velocity > {};
} // namespace luabridge

int
luaopen_fixmath_bounce(lua_State *L) {
	luabridge::getGlobalNamespace(L)
		.beginNamespace("bounce")
		.beginClass<b3Velocity>("b3Velocity")
		.addData("v", &b3Velocity::v, true)
		.addData("w", &b3Velocity::w, true)
		.endClass()

		.beginClass<b3Time>("b3Time")
		.addStaticFunction("GetRealTime", &b3Time::GetRealTime)
		.addConstructor<void(*) ()>()
		.addFunction("SetResolution", &b3Time::SetResolution)
		.addFunction("GetCurMicros", &b3Time::GetCurMicros)
		.addFunction("GetDeltaMicros", &b3Time::GetDeltaMicros)
		.addFunction("GetCurSecs", &b3Time::GetCurSecs)
		.addFunction("GetDeltaSecs", &b3Time::GetDeltaSecs)
		.endClass()
		.beginClass<b3World>("b3World")
		.addConstructor<void(*) ()>()
		.addFunction("CreateBody", &b3World::CreateBody)
		.addFunction("DestroyBody", &b3World::DestroyBody)
		.addFunction("Step", &b3World::Step)
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
