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

struct ltable {};

class lb3QueryListener : b3QueryListener {
public:
	lb3QueryListener() : b3QueryListener() {}
	virtual ~lb3QueryListener() {}
	int Register(lua_State *L) {
		this->L = L;
		if (!lua_istable(L, 2)) {
			lua_error(L);
		} else {
			lua_settop(L, 2);
			lua_setglobal(L, "");
		}
		return 0;
	}
	virtual bool ReportShape(b3Shape* shape) {
		lua_getglobal(L, "");
	}
private:
	lua_State * L;
};

class lb3RayCastListener {
public:
	// The user must return the new ray cast fraction.
	// If fraction == zero then the ray cast query will be canceled.
	virtual ~lb3RayCastListener() {}
	virtual r32 ReportShape(b3Shape* shape, const b3Vec3& point, const b3Vec3& normal, r32 fraction) {

	}
};

class lb3ContactListener {
public:
	// Inherit from this class and set it in the world to listen for collision events.	
	// Call the functions below to inspect when a shape start/end colliding with another shape.
	/// @warning You cannot create/destroy Bounc3 objects inside these callbacks.
	virtual void BeginContact(b3Contact* contact) = 0;
	virtual void EndContact(b3Contact* contact) = 0;
	virtual void Persisting(b3Contact* contact) = 0;
};

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
	struct Stack <b3Quaternion> {
		static void push(lua_State* L, b3Quaternion const& quat) {
			lua_createtable(L, 0, 4);
			Stack<b3R32>::push(L, quat.a);
			lua_setfield(L, -2, "a");
			Stack<b3R32>::push(L, quat.b);
			lua_setfield(L, -2, "b");
			Stack<b3R32>::push(L, quat.c);
			lua_setfield(L, -2, "c");
			Stack<b3R32>::push(L, quat.d);
			lua_setfield(L, -2, "d");

			// create meta bable
		}

		static b3Quaternion get(lua_State* L, int index) {
			if (!lua_istable(L, index)) {
				luaL_error(L, "#%d argments must be table", index);
			}
			b3Quaternion quat;
			lua_pushvalue(L, index);
			lua_getfield(L, -1, "a");
			quat.a = Stack<b3R32>::get(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "b");
			quat.b = Stack<b3R32>::get(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "c");
			quat.c = Stack<b3R32>::get(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "d");
			quat.d = Stack<b3R32>::get(L, -1);
			lua_pop(L, 2);
			return quat;
		}
	};

	template <>
	struct Stack <b3Quaternion const&> : Stack <b3Quaternion > {};

	template <>
	struct Stack <b3Mat33> {
		static void push(lua_State* L, b3Mat33 const& mat) {
			lua_createtable(L, 0, 3);
			Stack<b3Vec3>::push(L, mat.x);
			lua_setfield(L, -2, "x");
			Stack<b3Vec3>::push(L, mat.y);
			lua_setfield(L, -2, "y");
			Stack<b3Vec3>::push(L, mat.z);
			lua_setfield(L, -2, "z");


			// create meta bable
		}

		static b3Mat33 get(lua_State* L, int index) {
			if (!lua_istable(L, index)) {
				luaL_error(L, "#%d argments must be table", index);
			}
			b3Mat33 mat;
			lua_pushvalue(L, index);
			lua_getfield(L, -1, "x");
			mat.x = Stack<b3Vec3>::get(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "y");
			mat.y = Stack<b3Vec3>::get(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "z");
			mat.z = Stack<b3Vec3>::get(L, -1);
			lua_pop(L, 2);
			return mat;
		}
	};

	template <>
	struct Stack <b3Mat33 const&> : Stack <b3Mat33 > {};

	template <>
	struct Stack <b3Transform> {
		static void push(lua_State* L, b3Transform const& trans) {
			lua_createtable(L, 0, 4);
			Stack<b3Vec3>::push(L, trans.translation);
			lua_setfield(L, -2, "translation");
			Stack<b3Mat33>::push(L, trans.rotation);
			lua_setfield(L, -2, "rotation");

			// create meta bable
		}

		static b3Transform get(lua_State* L, int index) {
			if (!lua_istable(L, index)) {
				luaL_error(L, "#%d argments must be table", index);
			}
			b3Transform trans;
			lua_pushvalue(L, index);
			lua_getfield(L, -1, "translation");
			trans.translation = Stack<b3Vec3>::get(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "rotation");
			trans.rotation = Stack<b3Mat33>::get(L, -1);
			lua_pop(L, 2);
			return trans;
		}
	};

	template <>
	struct Stack <b3Transform const&> : Stack <b3Transform > {};

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

	template <>
	struct Stack <b3BodyDef> {
		static void push(lua_State* L, b3BodyDef const& def) {
			lua_createtable(L, 0, 8);
			lua_pushinteger(L, (lua_Integer)def.type);
			lua_setfield(L, -2, "type");
			lua_pushboolean(L, def.awake);
			lua_setfield(L, -2, "awake");
			lua_pushlightuserdata(L, def.userData);
			lua_setfield(L, -2, "userData");
			Stack<b3Vec3>::push(L, def.position);
			lua_setfield(L, -2, "position");
			Stack<b3Quaternion>::push(L, def.orientation);
			lua_setfield(L, -2, "orientation");
			Stack<b3Vec3>::push(L, def.linearVelocity);
			lua_setfield(L, -2, "linearVelocity");
			Stack<b3Vec3>::push(L, def.angularVelocity);
			lua_setfield(L, -2, "angularVelocity");
			Stack<r32>::push(L, def.gravityScale);
			lua_setfield(L, -2, "gravityScale");
		}

		static b3BodyDef get(lua_State* L, int index) {
			if (!lua_istable(L, index)) {
				luaL_error(L, "#%d argments must be table", index);
			}

			b3BodyDef def;
			lua_pushvalue(L, index);
			lua_getfield(L, -1, "type");
			def.type = (b3BodyType)luaL_checkinteger(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "awake");
			def.awake = lua_toboolean(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "userData");
			def.userData = lua_touserdata(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "position");
			def.position = Stack<b3Vec3>::get(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "orientation");
			def.orientation = Stack<b3Quaternion>::get(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "linearVelocity");
			def.linearVelocity = Stack<b3Vec3>::get(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "angularVelocity");
			def.angularVelocity = Stack<b3Vec3>::get(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "angularVelocity");
			def.angularVelocity = Stack<b3Vec3>::get(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "gravityScale");
			def.gravityScale = Stack<r32>::get(L, -1);
			lua_pop(L, 2);
			return def;
		}
	};

	template <>
	struct Stack <b3BodyDef const&> : Stack <b3BodyDef > {};

	template <>
	struct Stack <b3SphericalJointDef> {
		static void push(lua_State* L, b3SphericalJointDef const& def) {
			lua_createtable(L, 0, 3);
			lua_pushlightuserdata(L, def.bodyA);
			lua_setfield(L, -2, "bodyA");
			lua_pushlightuserdata(L, def.bodyB);
			lua_setfield(L, -2, "bodyB");
			lua_pushlightuserdata(L, def.userData);
			lua_setfield(L, -2, "userData");
		}

		static b3SphericalJointDef get(lua_State* L, int index) {
			if (!lua_istable(L, index)) {
				luaL_error(L, "#%d argments must be table", index);
			}

			b3SphericalJointDef def;
			lua_pushvalue(L, index);
			lua_getfield(L, -1, "bodyA");
			def.bodyA = static_cast<b3Body*>(lua_touserdata(L, -1));
			lua_pop(L, 1);
			lua_getfield(L, -1, "bodyB");
			def.bodyB = static_cast<b3Body*>(lua_touserdata(L, -1));
			lua_pop(L, 1);
			lua_getfield(L, -1, "userData");
			def.userData = lua_touserdata(L, -1);
			lua_pop(L, 2);
			return def;
		}
	};

	template <>
	struct Stack <b3SphericalJointDef const&> : Stack <b3SphericalJointDef > {};

	template <>
	struct Stack <b3ShapeDef> {
		static void push(lua_State* L, b3ShapeDef const& def) {
			lua_createtable(L, 0, 8);
			Stack<const b3Shape*>::push(L, def.shape);
			lua_setfield(L, -2, "shape");
			lua_pushlightuserdata(L, def.userData);
			lua_setfield(L, -2, "userData");
			lua_pushboolean(L, def.sensor);
			lua_setfield(L, -2, "sensor");
			Stack<b3R32>::push(L, def.density);
			lua_setfield(L, -2, "density");
			Stack<b3R32>::push(L, def.friction);
			lua_setfield(L, -2, "friction");
			Stack<b3R32>::push(L, def.restitution);
			lua_setfield(L, -2, "restitution");
			Stack<b3Transform>::push(L, def.local);
			lua_setfield(L, -2, "local");
		}

		static b3ShapeDef get(lua_State* L, int index) {
			if (!lua_istable(L, index)) {
				luaL_error(L, "#%d argments must be table", index);
			}

			b3ShapeDef def;
			lua_pushvalue(L, index);
			lua_getfield(L, -1, "shape");
			int idx = lua_absindex(L, -1);
			const b3Shape *shape = Stack<b3Polyhedron *>::get(L, idx);
			if (shape == NULL) {
				luaL_error(L, "shape must be");
			}
			def.shape = shape;
			lua_pop(L, 1);
			lua_getfield(L, -1, "sensor");
			if (!lua_isnil(L, -1)) {
				def.sensor = lua_toboolean(L, -1);
			}
			lua_pop(L, 1);
			lua_getfield(L, -1, "density");
			if (!lua_isnil(L, -1)) {
				def.density = Stack<r32>::get(L, -1);
			}
			lua_pop(L, 1);
			lua_getfield(L, -1, "friction");
			if (!lua_isnil(L, -1)) {
				def.friction = Stack<r32>::get(L, -1);
			}
			lua_pop(L, 1);
			lua_getfield(L, -1, "restitution");
			if (!lua_isnil(L, -1)) {
				def.restitution = Stack<r32>::get(L, -1);
			}
			lua_pop(L, 1);
			lua_getfield(L, -1, "local");
			if (!lua_isnil(L, -1)) {
				def.local = Stack<b3Transform>::get(L, -1);
			}
			lua_pop(L, 2);
			return def;
		}
	};

	template <>
	struct Stack <b3ShapeDef const&> : Stack <b3ShapeDef > {};

} // namespace luabridge

int
luaopen_fixmath_bounce(lua_State *L) {
	luabridge::getGlobalNamespace(L)
		.beginNamespace("bounce")
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
		//.addFunction("CreateJoint", &b3World::CreateJoint)
		.addFunction("DestroyJoint", &b3World::DestroyJoint)
		.addFunction("QueryAABB", &b3World::QueryAABB)
		.addFunction("RayCast", &b3World::RayCast)
		.addFunction("Step", &b3World::Step)
		.endClass()
		.beginClass<b3Body>("b3Body")
		.addFunction("CreateShape", &b3Body::CreateShape)
		.addFunction("DestroyShape", &b3Body::DestroyShape)
		//.addFunction("DestroyContacts", &b3Body::DestroyContacts)
		.addFunction("DestroyJoints", &b3Body::DestroyJoints)
		.addFunction("DestroyShapes", &b3Body::DestroyShapes)
		.addFunction("GetTransform", &b3Body::GetTransform)
		.addFunction("ApplyForce", &b3Body::ApplyForce)
		.addFunction("ApplyForceToCenter", &b3Body::ApplyForceToCenter)
		.addFunction("ApplyTorque", &b3Body::ApplyTorque)
		.addFunction("ApplyLinearImpulse", &b3Body::ApplyLinearImpulse)
		.addFunction("ApplyAngularImpulse", &b3Body::ApplyLinearImpulse)
		.addFunction("SetLinearVelocity", &b3Body::SetLinearVelocity)
		.addFunction("SetAngularVelocity", &b3Body::SetAngularVelocity)
		.endClass()
		.beginClass<b3Shape>("b3Shape")
		//.addConstructor<void(*)()>()
		.endClass()
		.deriveClass<b3Polyhedron, b3Shape>("b3Polyhedron")
		.addConstructor<void(*) ()>()
		.addFunction("GetHull", &b3Polyhedron::GetHull)
		.addFunction("SetHull", &b3Polyhedron::SetHull)
		.endClass()
		.beginClass<b3Hull>("b3Hull")
		.addConstructor<void(*) ()>()
		.addFunction("SetFromFaces", &b3Hull::SetFromFaces)
		.addFunction("CreateFacesPlanes", &b3Hull::CreateFacesPlanes)
		.addFunction("SetAsBox", &b3Hull::SetAsBox)
		.endClass()
		.beginClass<lb3QueryListener>("lb3QueryListener")
		.addCFunction("Register", &lb3QueryListener::Register)
		.endClass()
		.endNamespace();
	return 0;
}
