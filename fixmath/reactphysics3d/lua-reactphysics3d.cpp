#define LUA_LIB

#ifdef __cplusplus
extern "C" {
#endif
#include <lua.h>
#include <lauxlib.h>

	LUAMOD_API int luaopen_fixmath_reactphysics3d(lua_State *L);

#ifdef __cplusplus
}
#endif

#include "reactphysics3d.h"
#include "b3r32.h"
#include "decimal.h"
#include <LuaBridge\LuaBridge.h>
#include <fix16.h>

struct ltable {};

class lEventListener : public reactphysics3d::EventListener {
public:
	lEventListener() : EventListener() { L = NULL; }
	virtual ~lEventListener() {}
	int lregister(lua_State *L) {
		this->L = L;
		auto l = luabridge::Stack<lEventListener*>::get(L, 1);
		lua_settop(L, 2);
		if (lua_isfunction(L, 2)) {
			lua_getglobal(L, "rp3d");
			if (lua_isnil(L, -1)) {
				lua_createtable(L, 0, 2);
				lua_setglobal(L, "rp3d");
				lua_getglobal(L, "rp3d");
			}
			lua_pushvalue(L, 2);
			lua_rawsetp(L, -2, l);
		} else {
			luaL_error(L, "2th arg must be function.");
		}
		return 0;
	}
	virtual void newContact(const reactphysics3d::CollisionCallback::CollisionCallbackInfo& collisionInfo) {
		assert(L != NULL);
		lua_getglobal(L, "rp3d");
		lua_rawgetp(L, -1, this);
		lua_createtable(L, 0, 4);
		luabridge::Stack<reactphysics3d::CollisionBody *>::push(L, collisionInfo.body1);
		lua_setfield(L, -2, "body1");
		luabridge::Stack<reactphysics3d::CollisionBody *>::push(L, collisionInfo.body2);
		lua_setfield(L, -2, "body2");
		luabridge::Stack<const reactphysics3d::ProxyShape *>::push(L, collisionInfo.proxyShape1);
		lua_setfield(L, -2, "proxyShape1");
		luabridge::Stack<const reactphysics3d::ProxyShape *>::push(L, collisionInfo.proxyShape2);
		lua_setfield(L, -2, "proxyShape2");
		lua_pcall(L, 1, 0, -2);
	}
private:
	lua_State * L;
};

class lCollisionCallback : public reactphysics3d::CollisionCallback {
public:
	lCollisionCallback() : reactphysics3d::CollisionCallback() {}
	virtual ~lCollisionCallback() {}
	int lregister(lua_State *L) {
		this->L = L;
		auto l = luabridge::Stack<lCollisionCallback*>::get(L, 1);
		lua_settop(L, 2);
		if (lua_isfunction(L, 2)) {
			lua_getglobal(L, "rp3d");
			if (lua_isnil(L, -1)) {
				lua_createtable(L, 0, 2);
				lua_setglobal(L, "rp3d");
				lua_getglobal(L, "rp3d");
			}
			lua_pushvalue(L, 2);
			lua_rawsetp(L, -2, l);
		} else {
			luaL_error(L, "2th arg must be function.");
		}
		return 0;
	}
	virtual void notifyContact(const reactphysics3d::CollisionCallback::CollisionCallbackInfo& collisionInfo) {
		assert(L != NULL);
		lua_getglobal(L, "rp3d");
		lua_rawgetp(L, -1, this);
		lua_createtable(L, 0, 4);
		luabridge::Stack<reactphysics3d::CollisionBody *>::push(L, collisionInfo.body1);
		lua_setfield(L, -2, "body1");
		luabridge::Stack<reactphysics3d::CollisionBody *>::push(L, collisionInfo.body2);
		lua_setfield(L, -2, "body2");
		luabridge::Stack<const reactphysics3d::ProxyShape *>::push(L, collisionInfo.proxyShape1);
		lua_setfield(L, -2, "proxyShape1");
		luabridge::Stack<const reactphysics3d::ProxyShape *>::push(L, collisionInfo.proxyShape2);
		lua_setfield(L, -2, "proxyShape2");
		lua_pcall(L, 1, 0, -2);
	}
private:
	lua_State * L;
};

static int 
lr32add(lua_State *L) {
	lua_settop(L, 2);
	lua_getfield(L, 1, "__i__");
	lua_Integer a = luaL_checkinteger(L, -1);
	lua_getfield(L, 2, "__i__");
	lua_Integer b = luaL_checkinteger(L, -1);
	fix16_t v = fix16_sadd((fix16_t)a, (fix16_t)b);
	lua_createtable(L, 0, 1);
	lua_pushinteger(L, v);
	lua_setfield(L, -2, "__i__");
	lua_getmetatable(L, 1);
	lua_setmetatable(L, -2);
	return 1;
}

static int
lr32sub(lua_State *L) {
	lua_settop(L, 2);
	lua_getfield(L, 1, "__i__");
	lua_Integer a = luaL_checkinteger(L, -1);
	lua_getfield(L, 2, "__i__");
	lua_Integer b = luaL_checkinteger(L, -1);
	fix16_t v = fix16_ssub((fix16_t)a, (fix16_t)b);
	lua_createtable(L, 0, 1);
	lua_pushinteger(L, v);
	lua_setfield(L, -2, "__i__");
	lua_getmetatable(L, 1);
	lua_setmetatable(L, -2);
	return 1;
}

static int
lr32mul(lua_State *L) {
	lua_settop(L, 2);
	lua_getfield(L, 1, "__i__");
	lua_Integer a = luaL_checkinteger(L, -1);
	lua_getfield(L, 2, "__i__");
	lua_Integer b = luaL_checkinteger(L, -1);
	fix16_t v = fix16_smul((fix16_t)a, (fix16_t)b);
	lua_createtable(L, 0, 1);
	lua_pushinteger(L, v);
	lua_setfield(L, -2, "__i__");
	lua_getmetatable(L, 1);
	lua_setmetatable(L, -2);
	return 1;
}

static int
lr32div(lua_State *L) {
	lua_settop(L, 2);
	lua_getfield(L, 1, "__i__");
	lua_Integer a = luaL_checkinteger(L, -1);
	lua_getfield(L, 2, "__i__");
	lua_Integer b = luaL_checkinteger(L, -1);
	fix16_t v = fix16_sdiv((fix16_t)a, (fix16_t)b);
	lua_createtable(L, 0, 1);
	lua_pushinteger(L, v);
	lua_setfield(L, -2, "__i__");
	lua_getmetatable(L, 1);
	lua_setmetatable(L, -2);
	return 1;
}

static int
lr32tostring(lua_State *L) {
	lua_settop(L, 1);
	lua_getfield(L, 1, "__i__");
	lua_Integer a = luaL_checkinteger(L, -1);
	float f = fix16_to_float(a);
	char buffer[128] = { 0 };
	snprintf(buffer, 128, "fp: %f", f);
	lua_pushstring(L, buffer);
	return 1;
}

static int 
printTable(lua_State *L) {
	lua_pushnil(L);  /* first key */
	while (lua_next(L, -2) != 0) {
		/* uses 'key' (at index -2) and 'value' (at index -1) */
		printf("%s - %s\n",
			lua_typename(L, lua_type(L, -2)),
			lua_typename(L, lua_type(L, -1)));
		/* removes 'value'; keeps 'key' for next iteration */
		printf("%s - %s\n",
			lua_tostring(L, -2),
			"h");
		lua_pop(L, 1);
	}
}

namespace luabridge {

	// math
	template <>
	struct Stack <b3R32> {
		static void push(lua_State* L, b3R32 const& r) {
			// 跟多是查看数据
			lua_createtable(L, 0, 1);
			lua_pushinteger(L, r._i);
			lua_setfield(L, -2, "__i__");
			// meta
			luaL_Reg l[] = {
				{ "__add", lr32add },
				{ "__sub", lr32sub },
				{ "__mul", lr32mul },
				{ "__div", lr32div },
				{ "__tostring",  lr32tostring},
				{ NULL, NULL },
			};
			luaL_newlib(L, l);
			lua_setmetatable(L, -2);
			lua_getfield(L, -1, "__i__");
			assert(luaL_checkinteger(L, -1) == r._i);
			lua_pop(L, 1);
		}

		static b3R32 get(lua_State* L, int index) {
			if (lua_isnumber(L, index)) {
				lua_Number i = lua_tonumber(L, index);
				return b3R32(i);
			} else if (lua_isinteger(L, index)) {
				lua_Integer i = lua_tointeger(L, index);
				return b3R32(i);
			} else if (lua_istable(L, index)) {
				lua_pushvalue(L, index);
				lua_getfield(L, -1, "__i__");
				lua_Integer i = luaL_checkinteger(L, -1);
				lua_pop(L, 2);
				b3R32 r;
				r._i = i;
				return r;
			} else {
				luaL_error(L, "#%d argments must be table, type is %s", index, lua_typename(L, index));
			}
			return b3R32::zero();
		}
	};

	template <>
	struct Stack <b3R32 const&> : Stack <b3R32> {};

	template <>
	struct Stack <reactphysics3d::Vector2> {
		static void push(lua_State* L, reactphysics3d::Vector2 const& vec2) {
			lua_createtable(L, 0, 2);
			Stack<reactphysics3d::decimal>::push(L, vec2.x);
			lua_setfield(L, -2, "x");
			Stack<reactphysics3d::decimal>::push(L, vec2.y);
			lua_setfield(L, -2, "y");

			// create meta bable
		}

		static reactphysics3d::Vector2 get(lua_State* L, int index) {
			if (!lua_istable(L, index)) {
				luaL_error(L, "#%d argments must be table", index);
			}
			reactphysics3d::Vector2 vec2;
			lua_pushvalue(L, index);
			lua_getfield(L, -1, "x");
			vec2.x = Stack<reactphysics3d::decimal>::get(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "y");
			vec2.y = Stack<reactphysics3d::decimal>::get(L, -1);
			lua_pop(L, 2);
			return vec2;
		}
	};

	template <>
	struct Stack <reactphysics3d::Vector2 const&> : Stack <reactphysics3d::Vector2> {};

	template <>
	struct Stack <reactphysics3d::Vector3> {
		static void push(lua_State* L, reactphysics3d::Vector3 const& vec3) {
			lua_createtable(L, 0, 3);
			Stack<reactphysics3d::decimal>::push(L, vec3.x);
			lua_setfield(L, -2, "x");
			Stack<reactphysics3d::decimal>::push(L, vec3.y);
			lua_setfield(L, -2, "y");
			Stack<reactphysics3d::decimal>::push(L, vec3.z);
			lua_setfield(L, -2, "z");

			// create meta bable
		}

		static reactphysics3d::Vector3 get(lua_State* L, int index) {
			if (!lua_istable(L, index)) {
				luaL_error(L, "#%d argments must be table", index);
			}
			reactphysics3d::Vector3 vec3;
			lua_pushvalue(L, index);
			lua_getfield(L, -1, "x");
			vec3.x = Stack<reactphysics3d::decimal>::get(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "y");
			vec3.y = Stack<reactphysics3d::decimal>::get(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "z");
			vec3.z = Stack<reactphysics3d::decimal>::get(L, -1);
			lua_pop(L, 2);
			return vec3;
		}
	};

	template <>
	struct Stack <reactphysics3d::Vector3 const&> : Stack <reactphysics3d::Vector3> {};

	template <>
	struct Stack <reactphysics3d::Quaternion> {
		static void push(lua_State* L, reactphysics3d::Quaternion const& quat) {
			lua_createtable(L, 0, 4);
			Stack<reactphysics3d::decimal>::push(L, quat.x);
			lua_setfield(L, -2, "x");
			Stack<reactphysics3d::decimal>::push(L, quat.y);
			lua_setfield(L, -2, "y");
			Stack<reactphysics3d::decimal>::push(L, quat.z);
			lua_setfield(L, -2, "z");
			Stack<reactphysics3d::decimal>::push(L, quat.w);
			lua_setfield(L, -2, "w");

			// create meta bable
		}

		static reactphysics3d::Quaternion get(lua_State* L, int index) {
			if (!lua_istable(L, index)) {
				luaL_error(L, "#%d argments must be table", index);
			}
			reactphysics3d::Quaternion quat;
			lua_pushvalue(L, index);
			lua_getfield(L, -1, "x");
			quat.x = Stack<reactphysics3d::decimal>::get(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "y");
			quat.y = Stack<reactphysics3d::decimal>::get(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "z");
			quat.z = Stack<reactphysics3d::decimal>::get(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "w");
			quat.w = Stack<reactphysics3d::decimal>::get(L, -1);
			lua_pop(L, 2);
			return quat;
		}
	};

	template <>
	struct Stack <reactphysics3d::Quaternion const&> : Stack <reactphysics3d::Quaternion> {};

	template <>
	struct Stack <reactphysics3d::Matrix3x3> {
		static void push(lua_State* L, reactphysics3d::Matrix3x3 const& mat) {
			lua_createtable(L, 3, 0);
			Stack<reactphysics3d::Vector3>::push(L, mat.mRows[0]);
			lua_rawseti(L, -2, 1);
			Stack<reactphysics3d::Vector3>::push(L, mat.mRows[1]);
			lua_rawseti(L, -2, 2);
			Stack<reactphysics3d::Vector3>::push(L, mat.mRows[2]);
			lua_rawseti(L, -2, 3);

			// create meta bable
		}

		static reactphysics3d::Matrix3x3 get(lua_State* L, int index) {
			if (!lua_istable(L, index)) {
				luaL_error(L, "#%d argments must be table", index);
			}
			reactphysics3d::Matrix3x3 mat;
			lua_pushvalue(L, index);
			lua_rawgeti(L, -1, 1);
			mat.mRows[0] = Stack<reactphysics3d::Vector3>::get(L, -1);
			lua_pop(L, 1);
			lua_rawgeti(L, -1, 2);
			mat.mRows[1] = Stack<reactphysics3d::Vector3>::get(L, -1);
			lua_pop(L, 1);
			lua_rawgeti(L, -1, 3);
			mat.mRows[2] = Stack<reactphysics3d::Vector3>::get(L, -1);
			lua_pop(L, 2);
			return mat;
		}
	};

	template <>
	struct Stack <reactphysics3d::Matrix3x3 const&> : Stack <reactphysics3d::Matrix3x3> {};

	template <>
	struct Stack <reactphysics3d::Transform> {
		static void push(lua_State* L, reactphysics3d::Transform const& trans) {
			lua_createtable(L, 0, 2);
			Stack<reactphysics3d::Vector3>::push(L, trans.getPosition());
			lua_setfield(L, -2, "position");
			Stack<reactphysics3d::Quaternion>::push(L, trans.getOrientation());
			lua_setfield(L, -2, "rotation");

			// create meta bable
		}

		static reactphysics3d::Transform get(lua_State* L, int index) {
			if (!lua_istable(L, index)) {
				luaL_error(L, "#%d argments must be table", index);
			}
			reactphysics3d::Transform trans;
			lua_pushvalue(L, index);
			lua_getfield(L, -1, "position");
			reactphysics3d::Vector3 position = Stack<reactphysics3d::Vector3>::get(L, -1);
			trans.setPosition(position);
			lua_pop(L, 1);
			lua_getfield(L, -1, "rotation");
			reactphysics3d::Quaternion quat = Stack<reactphysics3d::Quaternion>::get(L, -1);
			trans.setOrientation(quat);
			lua_pop(L, 2);
			return trans;
		}
	};

	template <>
	struct Stack <reactphysics3d::Transform const&> : Stack <reactphysics3d::Transform> {};

	// body
	template <>
	struct Stack <reactphysics3d::BodyType> {
		static void push(lua_State* L, reactphysics3d::BodyType const& r) {
			lua_pushinteger(L, (lua_Integer)r);
		}

		static reactphysics3d::BodyType get(lua_State* L, int index) {
			lua_Integer i = luaL_checkinteger(L, index);
			return (reactphysics3d::BodyType)i;
		}
	};

	template <>
	struct Stack <reactphysics3d::BodyType const&> : Stack <reactphysics3d::BodyType> {};

	// shape
	template <>
	struct Stack <reactphysics3d::AABB> {
		static void push(lua_State* L, reactphysics3d::AABB const& aabb) {
			lua_createtable(L, 0, 3);
			luaL_error(L, "aabb not imp");
			/*Stack<b3R32>::push(L, step.dt);
			lua_setfield(L, -2, "dt");
			lua_pushinteger(L, step.velocityIterations);
			lua_setfield(L, -2, "velocityIterations");
			lua_pushboolean(L, step.sleeping);
			lua_setfield(L, -2, "velocityIterations");*/
		}

		static reactphysics3d::AABB get(lua_State* L, int index) {
			if (!lua_istable(L, index)) {
				luaL_error(L, "#%d argments must be table", index);
			}

			reactphysics3d::AABB aabb;
			/*lua_pushvalue(L, index);
			lua_getfield(L, -1, "dt");
			step.dt = Stack<b3R32>::get(L, -1);
			lua_pop(L, 1);
			lua_getfield(L, -1, "velocityIterations");
			step.velocityIterations = static_cast<u32>(lua_tointeger(L, -1));
			lua_pop(L, 1);
			lua_getfield(L, -1, "sleeping");
			step.sleeping = lua_toboolean(L, -1);
			lua_pop(L, 2);*/
			return aabb;
		}
	};

	template <>
	struct Stack <reactphysics3d::AABB const&> : Stack <reactphysics3d::AABB> {};

	template <>
	struct Stack <reactphysics3d::WorldSettings> {
		static void push(lua_State* L, reactphysics3d::WorldSettings const& settings) {
			lua_createtable(L, 0, 8);
			Stack<b3R32>::push(L, settings.persistentContactDistanceThreshold);
			lua_setfield(L, -2, "persistentContactDistanceThreshold");
			/*lua_pushlightuserdata(L, def.userData);
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
			lua_setfield(L, -2, "local");*/
		}

		static reactphysics3d::WorldSettings get(lua_State* L, int index) {
			if (!lua_istable(L, index)) {
				luaL_error(L, "#%d argments must be table", index);
			}

			reactphysics3d::WorldSettings settings;
			lua_pushvalue(L, index);
			/*lua_getfield(L, -1, "shape");
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
			lua_pop(L, 2);*/
			return settings;
		}
	};

	template <>
	struct Stack <reactphysics3d::WorldSettings const&> : Stack <reactphysics3d::WorldSettings> {};

} // namespace luabridge

int
luaopen_fixmath_reactphysics3d(lua_State *L) {
	typedef void(reactphysics3d::CollisionWorld::*TestCollisionArg3T)(reactphysics3d::CollisionBody*, reactphysics3d::CollisionBody*, reactphysics3d::CollisionCallback*);
	TestCollisionArg3T testCollisionArg3 = &reactphysics3d::CollisionWorld::testCollision;
	typedef void(reactphysics3d::CollisionWorld::*TestCollisionArg2T)(reactphysics3d::CollisionBody*, reactphysics3d::CollisionCallback*, unsigned short categoryMaskBits);
	TestCollisionArg2T testCollisionArg2 = &reactphysics3d::CollisionWorld::testCollision;
	typedef void(reactphysics3d::CollisionWorld::*TestCollisionArg1T)(reactphysics3d::CollisionCallback*);
	TestCollisionArg1T testCollisionArg1 = &reactphysics3d::CollisionWorld::testCollision;


	luabridge::getGlobalNamespace(L)
		.beginNamespace("rp3d")
		// body
		.beginClass<reactphysics3d::Body>("Body>")
		.addFunction("isAllowedToSleep", &reactphysics3d::Body::isAllowedToSleep)
		.addFunction("setIsAllowedToSleep", &reactphysics3d::Body::setIsAllowedToSleep)
		.addFunction("setIsSleeping", &reactphysics3d::Body::setIsSleeping)
		.addFunction("isSleeping", &reactphysics3d::Body::isSleeping)
		.addFunction("isActive", &reactphysics3d::Body::isActive)
		.endClass()
		.deriveClass<reactphysics3d::CollisionBody, reactphysics3d::Body>("CollisionBody")
		.addFunction("getType", &reactphysics3d::CollisionBody::getType)
		.addFunction("setType", &reactphysics3d::CollisionBody::setType)
		.addFunction("getTransform", &reactphysics3d::CollisionBody::getTransform)
		.addFunction("setTransform", &reactphysics3d::CollisionBody::setTransform)
		.addFunction("addCollisionShape", &reactphysics3d::CollisionBody::addCollisionShape)
		.addFunction("removeCollisionShape", &reactphysics3d::CollisionBody::removeCollisionShape)
		.endClass()
		.deriveClass<reactphysics3d::RigidBody, reactphysics3d::CollisionBody>("RigidBody")
		.addFunction("getMass", &reactphysics3d::RigidBody::getMass)
		.addFunction("getLinearVelocity", &reactphysics3d::RigidBody::getLinearVelocity)
		.addFunction("setMass", &reactphysics3d::RigidBody::setMass)
		.endClass()
		// shape
		.beginClass<reactphysics3d::CollisionShape>("CollisionShape")
		.endClass()
		.deriveClass<reactphysics3d::ConvexShape, reactphysics3d::CollisionShape>("ConvexShape")
		.endClass()
		.deriveClass<reactphysics3d::CapsuleShape, reactphysics3d::ConvexShape>("CapsuleShape")
		.addConstructor<void(*)(reactphysics3d::decimal, reactphysics3d::decimal)>()
		.endClass()
		.deriveClass<reactphysics3d::SphereShape, reactphysics3d::ConvexShape>("SphereShape")
		.addConstructor<void(*)(reactphysics3d::decimal)>()
		.endClass()
		.deriveClass<reactphysics3d::ConvexPolyhedronShape, reactphysics3d::ConvexShape>("ConvexPolyhedronShape")
		.endClass()
		.deriveClass<reactphysics3d::BoxShape, reactphysics3d::ConvexPolyhedronShape>("BoxShape")
		.addConstructor<void(*)(const reactphysics3d::Vector3&)>()
		.endClass()
		.deriveClass<reactphysics3d::TriangleShape, reactphysics3d::ConvexPolyhedronShape>("TriangleShape")
		.endClass()
		/*.deriveClass<reactphysics3d::ConvexMeshShape, reactphysics3d::ConvexPolyhedronShape>("ConvexMeshShape")
		.endClass()*/
		.deriveClass<reactphysics3d::ConcaveShape, reactphysics3d::CollisionShape>("ConcaveShape")
		.endClass()
		/*.deriveClass<reactphysics3d::ConcaveMeshShape, reactphysics3d::ConcaveShape>("ConcaveMeshShape")
		.endClass()*/
		/*.deriveClass<reactphysics3d::HeightFieldShape, reactphysics3d::ConcaveShape>("HeightFieldShape")
		.endClass()*/
		.beginClass<reactphysics3d::ProxyShape>("ProxyShape")
		.addFunction("getMass", &reactphysics3d::ProxyShape::getMass)
		//.addFunction("getLocalToWorldTransform", &reactphysics3d::ProxyShape::getLocalToWorldTransform)
		.addFunction("setLocalToBodyTransform", &reactphysics3d::ProxyShape::setLocalToBodyTransform)
		//.addFunction("getWorldAABB", &reactphysics3d::ProxyShape::getWorldAABB)
		.endClass()
		// engine
		.beginClass<reactphysics3d::CollisionWorld>("CollisionWorld")
		.addConstructor<void(*)()>()
		.addFunction("createCollisionBody", &reactphysics3d::CollisionWorld::createCollisionBody)
		.addFunction("destroyCollisionBody", &reactphysics3d::CollisionWorld::destroyCollisionBody)
		.addFunction("setCollisionDispatch", &reactphysics3d::CollisionWorld::setCollisionDispatch)
		.addFunction("raycast", &reactphysics3d::CollisionWorld::raycast)
		//.addFunction("testAABBOverlap", &reactphysics3d::CollisionWorld::testAABBOverlap)
		.addFunction("testCollision3", testCollisionArg3)
		.addFunction("testCollision2", testCollisionArg2)
		.addFunction("testCollision1", testCollisionArg1)
		.endClass()
		.deriveClass<reactphysics3d::DynamicsWorld, reactphysics3d::CollisionWorld>("DynamicsWorld")
		.addConstructor<void(*)(const reactphysics3d::Vector3 &)>()
		.addFunction("update", &reactphysics3d::DynamicsWorld::update)
		.addFunction("getNbIterationsVelocitySolver", &reactphysics3d::DynamicsWorld::getNbIterationsVelocitySolver)
		.addFunction("setNbIterationsVelocitySolver", &reactphysics3d::DynamicsWorld::setNbIterationsVelocitySolver)
		.addFunction("getNbIterationsPositionSolver", &reactphysics3d::DynamicsWorld::getNbIterationsPositionSolver)
		.addFunction("setNbIterationsPositionSolver", &reactphysics3d::DynamicsWorld::setNbIterationsPositionSolver)
		/*.addFunction("setContactsPositionCorrectionTechnique", &reactphysics3d::DynamicsWorld::setContactsPositionCorrectionTechnique)
		.addFunction("setJointsPositionCorrectionTechnique", &reactphysics3d::DynamicsWorld::setJointsPositionCorrectionTechnique)*/
		.addFunction("createRigidBody", &reactphysics3d::DynamicsWorld::createRigidBody)
		.addFunction("destroyRigidBody", &reactphysics3d::DynamicsWorld::destroyRigidBody)
		.addFunction("createJoint", &reactphysics3d::DynamicsWorld::createJoint)
		.addFunction("destroyJoint", &reactphysics3d::DynamicsWorld::destroyJoint)
		.addFunction("getGravity", &reactphysics3d::DynamicsWorld::getGravity)
		.addFunction("setGravity", &reactphysics3d::DynamicsWorld::setGravity)
		.addFunction("isGravityEnabled", &reactphysics3d::DynamicsWorld::isGravityEnabled)
		.addFunction("isSleepingEnabled", &reactphysics3d::DynamicsWorld::isSleepingEnabled)
		.addFunction("enableSleeping", &reactphysics3d::DynamicsWorld::enableSleeping)
		.addFunction("setEventListener", &reactphysics3d::DynamicsWorld::setEventListener)
		.endClass()
		// math
		.beginClass<reactphysics3d::Quaternion>("Quaternion")
		.addStaticFunction("identity", &reactphysics3d::Quaternion::identity)
		.endClass()
		.beginClass<reactphysics3d::Matrix3x3>("Matrix3x3")
		.addStaticFunction("identity", &reactphysics3d::Matrix3x3::identity)
		.addStaticFunction("zero", &reactphysics3d::Matrix3x3::zero)
		.endClass()
		.beginClass<reactphysics3d::Transform>("Transform")
		.addStaticFunction("identity", &reactphysics3d::Transform::identity)
		.endClass()
		// r32
		.beginClass<b3R32>("b3R32")
		.addStaticFunction("fromInt", &b3R32::fromInt)
		.addStaticFunction("fromFlt32", &b3R32::fromFlt32)
		.addStaticFunction("fromFlt64", &b3R32::fromFlt64)
		.addStaticFunction("MAXIMUM", &b3R32::maximum)
		.addStaticFunction("MINIMUM", &b3R32::minimum)
		.addStaticFunction("PI", &b3R32::pi)
		.addStaticFunction("E", &b3R32::e)
		.addStaticFunction("ONE", &b3R32::one)
		.endClass()
		// l
		.beginClass<reactphysics3d::EventListener>("EventListener")
		.endClass()
		.deriveClass<lEventListener, reactphysics3d::EventListener>("lEventListener")
		.addConstructor<void(*)()>()
		.addCFunction("lregister", &lEventListener::lregister)
		.endClass()
		.beginClass<reactphysics3d::CollisionCallback>("CollisionCallback")
		.endClass()
		.deriveClass<lCollisionCallback, reactphysics3d::CollisionCallback>("lCollisionCallback")
		.addConstructor<void(*)()>()
		.addCFunction("lregister", &lCollisionCallback::lregister)
		.endClass()
		.endNamespace();
	return 0;
}
