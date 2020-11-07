#define LUA_LIB

#ifdef __cplusplus
extern "C" {
#endif
#include <lauxlib.h>
#include <lua.h>
#include <linalg.h>
#include <math3dfunc.h>

LUAMOD_API int luaopen_physx(lua_State* L);

#ifdef __cplusplus
}
#endif

#include <LuaBridge\LuaBridge.h>
#include <PxPhysicsAPI.h>
#include <PxRigidDynamic.h>

#include <foundation/PxPlane.h>
#include <foundation/PxSimpleTypes.h>
#include <foundation/PxVec2.h>
#include <foundation/PxVec3.h>

#include <atlimage.h>
#include <extensions/PxExtensionsAPI.h>
#include <extensions/PxSimpleFactory.h>
#include <mutex>

/**
\brief default implementation of the allocator interface required by the SDK
功能区
*/
class JemallocAllocator : public physx::PxAllocatorCallback {
public:
    void* allocate(size_t size, const char*, const char*, int)
    {
        //void* ptr = platformAlignedAlloc(size);
        /*PX_ASSERT((reinterpret_cast<size_t>(ptr) & 15) == 0);
        return ptr;*/
        return nullptr;
    }

    void deallocate(void* ptr)
    {
        //platformAlignedFree(ptr);
    }
};

static std::mutex mtx;
static bool initialized = false;
static physx::PxDefaultAllocator gDefaultAllocatorCallback;
static physx::PxDefaultErrorCallback gDefaultErrorCallback;
static physx::PxFoundation* gFoundation = NULL;
//physx::PxProfileZoneManager    *_profileZoneManager;
static physx::PxPhysics* gPhysics = NULL;
static physx::PxCooking* gCooking = NULL;
static physx::PxDefaultCpuDispatcher* gDispatcher = NULL;
static physx::PxScene* gScenes[255] = {0};

#if defined(PX_SUPPORT_PVD)
static physx::PxPvd* gPvd = NULL;
static physx::PxPvdTransport* gPvdTransport = NULL;
static physx::PxPvdInstrumentationFlags gPvdFlags;
#endif

namespace luabridge {

template <>
struct Stack<physx::PxVec2> {
    static void push(lua_State* L, physx::PxVec2 const& vec2)
    {
        lua_createtable(L, 0, 2);
        Stack<float>::push(L, vec2.x);
        lua_setfield(L, -2, "x");
        Stack<float>::push(L, vec2.y);
        lua_setfield(L, -2, "y");

        // create meta bable
    }

    static physx::PxVec2 get(lua_State* L, int index)
    {
        if (!lua_istable(L, index)) {
            luaL_error(L, "#%d argments must be table", index);
        }
        physx::PxVec2 vec2;
        lua_pushvalue(L, index);
        lua_getfield(L, -1, "x");
        vec2.x = Stack<float>::get(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, -1, "y");
        vec2.y = Stack<float>::get(L, -1);
        lua_pop(L, 2);
        return vec2;
    }
};

template <>
struct Stack<physx::PxVec2 const&> : Stack<physx::PxVec2> {
};

template <>
struct Stack<physx::PxVec3> {
    static void push(lua_State* L, physx::PxVec3 const& vec3)
    {
        lua_createtable(L, 0, 3);
        Stack<float>::push(L, vec3.x);
        lua_setfield(L, -2, "x");
        Stack<float>::push(L, vec3.y);
        lua_setfield(L, -2, "y");
        Stack<float>::push(L, vec3.z);
        lua_setfield(L, -2, "z");

        // create meta bable
		
    }

    static physx::PxVec3 get(lua_State* L, int index)
    {
        if (!lua_istable(L, index)) {
            luaL_error(L, "#%d argments must be table", index);
        }
        physx::PxVec3 vec3;
        lua_pushvalue(L, index);
        lua_getfield(L, -1, "x");
        vec3.x = Stack<float>::get(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, -1, "y");
        vec3.y = Stack<float>::get(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, -1, "z");
        vec3.z = Stack<float>::get(L, -1);
        lua_pop(L, 2);
        return vec3;
    }
};

template <>
struct Stack<physx::PxVec3 const&> : Stack<physx::PxVec3> {
};

template <>
struct Stack<physx::PxVec4> {
    static void push(lua_State* L, physx::PxVec4 const& vec4)
    {
        lua_createtable(L, 0, 4);
        Stack<float>::push(L, vec4.x);
        lua_setfield(L, -2, "x");
        Stack<float>::push(L, vec4.y);
        lua_setfield(L, -2, "y");
        Stack<float>::push(L, vec4.z);
        lua_setfield(L, -2, "z");
        Stack<float>::push(L, vec4.w);
        lua_setfield(L, -2, "w");
        // create meta bable
    }

    static physx::PxVec4 get(lua_State* L, int index)
    {
        if (!lua_istable(L, index)) {
            luaL_error(L, "#%d argments must be table", index);
        }
        physx::PxVec4 vec4;
        lua_pushvalue(L, index);
        lua_getfield(L, -1, "x");
        vec4.x = Stack<float>::get(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, -1, "y");
        vec4.y = Stack<float>::get(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, -1, "z");
        vec4.z = Stack<float>::get(L, -1);
        lua_getfield(L, -1, "w");
        vec4.z = Stack<float>::get(L, -1);
        lua_pop(L, 2);
        return vec4;
    }
};

template <>
struct Stack<physx::PxVec4 const&> : Stack<physx::PxVec4> {
};

template <>
struct Stack<physx::PxQuat> {
    static void push(lua_State* L, physx::PxQuat const& quat)
    {
        lua_createtable(L, 0, 4);
        Stack<float>::push(L, quat.x);
        lua_setfield(L, -2, "x");
        Stack<float>::push(L, quat.y);
        lua_setfield(L, -2, "y");
        Stack<float>::push(L, quat.z);
        lua_setfield(L, -2, "z");
        Stack<float>::push(L, quat.w);
        lua_setfield(L, -2, "w");

        // create meta bable
    }

    static physx::PxQuat get(lua_State* L, int index)
    {
        if (!lua_istable(L, index)) {
            luaL_error(L, "#%d argments must be table", index);
        }
        physx::PxQuat quat;
        lua_pushvalue(L, index);
        lua_getfield(L, -1, "x");
        quat.x = Stack<float>::get(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, -1, "y");
        quat.y = Stack<float>::get(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, -1, "z");
        quat.z = Stack<float>::get(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, -1, "w");
        quat.w = Stack<float>::get(L, -1);
        lua_pop(L, 2);
        return quat;
    }
};

template <>
struct Stack<physx::PxQuat const&> : Stack<physx::PxQuat> {
};

template <>
struct Stack<physx::PxMat33> {
    static void push(lua_State* L, physx::PxMat33 const& mat)
    {
        lua_createtable(L, 3, 0);
        Stack<physx::PxVec3>::push(L, mat[0]);
        lua_rawseti(L, -2, 1);
        Stack<physx::PxVec3>::push(L, mat[1]);
        lua_rawseti(L, -2, 2);
        Stack<physx::PxVec3>::push(L, mat[2]);
        lua_rawseti(L, -2, 3);

        // create meta bable
    }

    static physx::PxMat33 get(lua_State* L, int index)
    {
        if (!lua_istable(L, index)) {
            luaL_error(L, "#%d argments must be table", index);
        }
        physx::PxMat33 mat;
        lua_pushvalue(L, index);
        lua_rawgeti(L, -1, 1);
        mat[0] = Stack<physx::PxVec3>::get(L, -1);
        lua_pop(L, 1);
        lua_rawgeti(L, -1, 2);
        mat[1] = Stack<physx::PxVec3>::get(L, -1);
        lua_pop(L, 1);
        lua_rawgeti(L, -1, 3);
        mat[2] = Stack<physx::PxVec3>::get(L, -1);
        lua_pop(L, 2);
        return mat;
    }
};

template <>
struct Stack<physx::PxMat33 const&> : Stack<physx::PxMat33> {
};

template <>
struct Stack<physx::PxMat44> {
    static void push(lua_State* L, physx::PxMat44 const& mat)
    {
        lua_createtable(L, 3, 0);
        Stack<physx::PxVec4>::push(L, mat[0]);
        lua_rawseti(L, -2, 1);
        Stack<physx::PxVec4>::push(L, mat[1]);
        lua_rawseti(L, -2, 2);
        Stack<physx::PxVec4>::push(L, mat[2]);
        lua_rawseti(L, -2, 3);
        Stack<physx::PxVec4>::push(L, mat[3]);
        lua_rawseti(L, -2, 4);

        // create meta bable
    }

    static physx::PxMat44 get(lua_State* L, int index)
    {
        if (!lua_istable(L, index)) {
            luaL_error(L, "#%d argments must be table", index);
        }
        physx::PxMat44 mat;
        lua_pushvalue(L, index);
        lua_rawgeti(L, -1, 1);
        mat[0] = Stack<physx::PxVec4>::get(L, -1);
        lua_pop(L, 1);
        lua_rawgeti(L, -1, 2);
        mat[1] = Stack<physx::PxVec4>::get(L, -1);
        lua_pop(L, 1);
        lua_rawgeti(L, -1, 3);
        mat[2] = Stack<physx::PxVec4>::get(L, -1);
        lua_pop(L, 2);
        mat[3] = Stack<physx::PxVec4>::get(L, -1);
        lua_pop(L, 2);
        return mat;
    }
};

template <>
struct Stack<physx::PxMat44 const&> : Stack<physx::PxMat44> {
};

template <>
struct Stack<physx::PxTransform> {
    static void push(lua_State* L, physx::PxTransform const& trans)
    {
        lua_createtable(L, 0, 2);
        Stack<physx::PxVec3>::push(L, trans.p);
        lua_setfield(L, -2, "p");
        Stack<physx::PxQuat>::push(L, trans.q);
        lua_setfield(L, -2, "q");

        // create meta bable
    }

    static physx::PxTransform get(lua_State* L, int index)
    {
        if (!lua_istable(L, index)) {
            luaL_error(L, "#%d argments must be table", index);
        }
        physx::PxTransform trans;
        lua_pushvalue(L, index);
        lua_getfield(L, -1, "p");
        if (lua_istable(L, -1)) {
            physx::PxVec3 position = Stack<physx::PxVec3>::get(L, -1);
            trans.p = (position);
        }
        lua_pop(L, 1);
        lua_getfield(L, -1, "q");
        if (lua_istable(L, -1)) {
            physx::PxQuat quat = Stack<physx::PxQuat>::get(L, -1);
            trans.q = (quat);
        }
        lua_pop(L, 2);
        return trans;
    }
};

template <>
struct Stack<physx::PxTransform const&> : Stack<physx::PxTransform> {
};

template <>
struct Stack<physx::PxSphereGeometry> {
    static void push(lua_State* L, physx::PxSphereGeometry const& geo)
    {
        lua_createtable(L, 0, 2);
        Stack<int>::push(L, geo.getType());
        lua_setfield(L, -2, "type");
        Stack<physx::PxReal>::push(L, geo.radius);
        lua_setfield(L, -2, "radius");

        // create meta bable
    }

    static physx::PxSphereGeometry get(lua_State* L, int index)
    {
        if (!lua_istable(L, index)) {
            luaL_error(L, "#%d argments must be table", index);
        }

        lua_pushvalue(L, index);
        lua_getfield(L, -1, "radius");
        physx::PxReal radius = Stack<physx::PxReal>::get(L, -1);
        physx::PxSphereGeometry geo(radius);
        return geo;
    }
};

template <>
struct Stack<physx::PxSphereGeometry const&> : Stack<physx::PxSphereGeometry> {
};

template <>
struct Stack<physx::PxBoxGeometry> {
    static void push(lua_State* L, physx::PxBoxGeometry const& geo)
    {
        lua_createtable(L, 0, 2);
        Stack<int>::push(L, geo.getType());
        lua_setfield(L, -2, "type");
        Stack<physx::PxVec3>::push(L, geo.halfExtents);
        lua_setfield(L, -2, "halfExtents");

        // create meta bable
    }

    static physx::PxBoxGeometry get(lua_State* L, int index)
    {
        if (!lua_istable(L, index)) {
            luaL_error(L, "#%d argments must be table", index);
        }

        lua_pushvalue(L, index);
        lua_getfield(L, -1, "halfExtents");
        physx::PxVec3 halfExtents = Stack<physx::PxVec3>::get(L, -1);
        physx::PxBoxGeometry geo(halfExtents);
        return geo;
    }
};

template <>
struct Stack<physx::PxBoxGeometry const&> : Stack<physx::PxBoxGeometry> {
};

template <>
struct Stack<physx::PxPlane> {
    static void push(lua_State* L, physx::PxPlane const& plane)
    {
        lua_createtable(L, 0, 4);
        Stack<float>::push(L, plane.n.x);
        lua_setfield(L, -2, "nx");
        Stack<float>::push(L, plane.n.y);
        lua_setfield(L, -2, "ny");
        Stack<float>::push(L, plane.n.z);
        lua_setfield(L, -2, "nz");
        Stack<float>::push(L, plane.d);
        lua_setfield(L, -2, "d");
        // create meta bable
    }

    static physx::PxPlane get(lua_State* L, int index)
    {
        if (!lua_istable(L, index)) {
            luaL_error(L, "#%d argments must be table", index);
        }

        lua_pushvalue(L, index);
        lua_getfield(L, -1, "nx");
        float x = Stack<float>::get(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, -1, "ny");
        float y = Stack<float>::get(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, -1, "nz");
        float z = Stack<float>::get(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, -1, "d");
        float d = Stack<float>::get(L, -1);
        lua_pop(L, 2);

        return physx::PxPlane(x, y, z, d);
    }
};

template <>
struct Stack<physx::PxPlane const&> : Stack<physx::PxPlane> {
};
}

class lCommon {
public:
    static void initialize()
    {
        mtx.lock();
        if (initialized) {
            mtx.unlock();
            return;
        }

        bool recordMemoryAllocations = true;

        gFoundation = PxCreateFoundation(PX_PHYSICS_VERSION, gDefaultAllocatorCallback, gDefaultErrorCallback);
        if (!gFoundation) {
            throw std::exception("create foundation failture.");
        }

#if defined(PX_SUPPORT_PVD)
        gPvdTransport = physx::PxDefaultPvdSocketTransportCreate("127.0.0.1", 5425, 10000);
        if (gPvdTransport == NULL)
            return;

        //The connection flags state overall what data is to be sent to PVD.  Currently
        //the Debug connection flag requires support from the implementation (don't send
        //the data when debug isn't set) but the other two flags, profile and memory
        //are taken care of by the PVD SDK.

        //Use these flags for a clean profile trace with minimal overhead
        gPvdFlags = physx::PxPvdInstrumentationFlag::eALL;
        /*if (!mPvdParams.useFullPvdConnection) {
            mPvdFlags = physx::PxPvdInstrumentationFlag::ePROFILE;
        }*/

        gPvd = physx::PxCreatePvd(*gFoundation);
        gPvd->connect(*gPvdTransport, gPvdFlags);
#endif

        physx::PxTolerancesScale scale;
        gPhysics = PxCreatePhysics(PX_PHYSICS_VERSION, *gFoundation, scale, recordMemoryAllocations, gPvd);
        if (!gPhysics) {
            throw std::exception("PxCreatePhysics failed.");
        }

        if (!PxInitExtensions(*gPhysics, gPvd)) {
            throw std::exception("PxInitExtensions failed.");
        }

        physx::PxCookingParams params(scale);
        params.meshWeldTolerance = 0.001f;
        params.meshPreprocessParams = physx::PxMeshPreprocessingFlags(physx::PxMeshPreprocessingFlag::eWELD_VERTICES);
        params.buildGPUData = true;

        gCooking = PxCreateCooking(PX_PHYSICS_VERSION, *gFoundation, params);

        gDispatcher = physx::PxDefaultCpuDispatcherCreate(1);

        //_physics->registerDeletionListener(*this, PxDeletionEventFlag::eUSER_RELEASE);
        initialized = true;
        mtx.unlock();
    }

    static void cleanup()
    {
        mtx.lock();
        if (!initialized) {
            mtx.unlock();
            return;
        }
        gDispatcher->release();

        gCooking->release();

        PxCloseExtensions();
        gPhysics->release();
        //physx::PxPvdTransport* transport = gPvd->getTransport();

        gPvd->release();
        //transport->release();
        gPvdTransport->release();

        gFoundation->release();

        mtx.unlock();
        printf("ball done.\n");
    }

    static int createScene(const physx::PxVec3& gravity)
    {
        size_t i = 0;
        for (; i < 255; i++) {
            physx::PxScene* scene = gScenes[i];
            if (scene == NULL) {
                break;
            }
        }
        physx::PxSceneDesc sceneDesc(gPhysics->getTolerancesScale());
        //sceneDesc.gravity = PxVec3(0.0f, -9.81f, 0.0f);
        sceneDesc.gravity = gravity;
        //gDispatcher =  PxDefaultCpuDispatcherCreate(2);
        sceneDesc.cpuDispatcher = gDispatcher;
        sceneDesc.filterShader = physx::PxDefaultSimulationFilterShader;

        gScenes[i] = gPhysics->createScene(sceneDesc);
        return i;
    }

    static void releaseScene(int id)
    {
        physx::PxScene* scene = gScenes[id];
        if (scene == NULL) {
            return;
        }
        scene->release();
    }

    static physx::PxMaterial* createMaterial(
        physx::PxReal staticFriction, physx::PxReal dynamicFriction, physx::PxReal restitution)
    {
        return gPhysics->createMaterial(staticFriction, dynamicFriction, restitution);
    }

    static physx::PxShape* createShapeSphere(
        const physx::PxSphereGeometry& geometry,
        physx::PxMaterial* material)
    {
        return gPhysics->createShape(geometry, *material);
    }

    static physx::PxShape* createShapeBox(
        const physx::PxBoxGeometry& geometry,
        physx::PxMaterial* material)
    {
        return gPhysics->createShape(geometry, *material);
    }

    static physx::PxShape* createShapeCapsule(
        const physx::PxCapsuleGeometry& geometry,
        physx::PxMaterial* material)
    {
        return gPhysics->createShape(geometry, *material);
    }

    static physx::PxShape* createShapeConvex(
        const physx::PxConvexMeshGeometry& geometry,
        physx::PxMaterial* material)
    {
        return gPhysics->createShape(geometry, *material);
    }

    static physx::PxRigidDynamic* createDynamicSphere(
        const physx::PxTransform& transform,
        const physx::PxSphereGeometry& geometry,
        physx::PxReal staticFriction, physx::PxReal dynamicFriction, physx::PxReal restitution,
        physx::PxReal density)
    {
        physx::PxMaterial* material = gPhysics->createMaterial(staticFriction, dynamicFriction, restitution);
        physx::PxRigidDynamic* sphere = PxCreateDynamic(*gPhysics, transform, geometry, *material, density);
        PX_ASSERT(sphere);
        material->release();
        return sphere;
    }

    static physx::PxRigidDynamic* createDynamicBox(
        const physx::PxTransform& transform,
        const physx::PxBoxGeometry& geometry,
        physx::PxReal staticFriction, physx::PxReal dynamicFriction, physx::PxReal restitution,
        physx::PxReal density)
    {
        physx::PxMaterial* material = gPhysics->createMaterial(staticFriction, dynamicFriction, restitution);
        physx::PxRigidDynamic* box = PxCreateDynamic(*gPhysics, transform, geometry, *material, density);
        PX_ASSERT(box);
        material->release();
        return box;
    }

    static physx::PxRigidDynamic* createDynamicCapsule(
        const physx::PxTransform& transform,
        const physx::PxCapsuleGeometry& geometry,
        physx::PxReal staticFriction, physx::PxReal dynamicFriction, physx::PxReal restitution,
        physx::PxReal density)
    {
        physx::PxMaterial* material = gPhysics->createMaterial(staticFriction, dynamicFriction, restitution);
        physx::PxRigidDynamic* capsule = PxCreateDynamic(*gPhysics, transform, geometry, *material, density);
        PX_ASSERT(capsule);
        material->release();
        return capsule;
    }

    static physx::PxRigidDynamic* createDynamicConvex(const physx::PxTransform& transform,
        const physx::PxConvexMeshGeometry& geometry,
        physx::PxReal staticFriction, physx::PxReal dynamicFriction, physx::PxReal restitution,
        physx::PxReal density)
    {
        physx::PxMaterial* material = gPhysics->createMaterial(staticFriction, dynamicFriction, restitution);
        physx::PxRigidDynamic* convex = PxCreateDynamic(*gPhysics, transform, geometry, *material, density);
        PX_ASSERT(convex);
        material->release();
        return convex;
    }

    static physx::PxRigidDynamic* createDynamic(
        const physx::PxTransform& transform,
        const physx::PxBoxGeometry& geometry,
        physx::PxMaterial* material,
        physx::PxReal density)
    {
        physx::PxRigidDynamic* box = PxCreateDynamic(*gPhysics, transform, geometry, *material, density);
        PX_ASSERT(box);
        return box;
    }

    static physx::PxRigidStatic* createPlane(
        const physx::PxPlane& plane,
        physx::PxReal staticFriction, physx::PxReal dynamicFriction, physx::PxReal restitution)
    {
        physx::PxMaterial* material = gPhysics->createMaterial(staticFriction, dynamicFriction, restitution);
        physx::PxRigidStatic* body = physx::PxCreatePlane(*gPhysics, plane, *material);
        PX_ASSERT(body);
        material->release();
        return body;
    }

    static void stepPhysics(int id, bool interactive)
    {
        PX_UNUSED(interactive);
        physx::PxScene* scene = gScenes[id];
        scene->simulate(1.0f / 60.0f);
        scene->fetchResults(true);
    }

    static void _PxScene_addPxRigidDynamic_(int id, physx::PxRigidDynamic* actor)
    {
        physx::PxScene* scene = gScenes[id];
        scene->addActor(*actor);
    }

    static void _PxScene_addPxRigidStatic_(int id, physx::PxRigidStatic* actor)
    {
        physx::PxScene* scene = gScenes[id];
        scene->addActor(*actor);
    }

    // body
    /*static void updateMassAndInertia(physx::PxRigidDynamic* body, ) {
            physx::PxRigidBodyExt::updateMassAndInertia(*body, 10.0f);
	}*/
};

LUAMOD_API
int luaopen_physx(lua_State* L)
{
    luaL_checkversion(L);

    luabridge::getGlobalNamespace(L)
        .beginNamespace("lphysx")
        .beginClass<lCommon>("Common")
        .addStaticFunction("initialize", &lCommon::initialize)
        .addStaticFunction("createScene", &lCommon::createScene)
        .addStaticFunction("releaseScene", &lCommon::releaseScene)
        .addStaticFunction("createMaterial", &lCommon::createMaterial)
        .addStaticFunction("createShapeSphere", &lCommon::createShapeSphere)
        .addStaticFunction("createShapeBox", &lCommon::createShapeBox)
        .addStaticFunction("createShapeCapsule", &lCommon::createShapeCapsule)
        .addStaticFunction("createShapeConvex", &lCommon::createShapeConvex)
        .addStaticFunction("createShapeCapsule", &lCommon::createShapeCapsule)
        .addStaticFunction("createDynamicSphere", &lCommon::createDynamicSphere)
        .addStaticFunction("createDynamicBox", &lCommon::createDynamicBox)
        .addStaticFunction("createDynamicCapsule", &lCommon::createDynamicCapsule)
        .addStaticFunction("createDynamicConvex", &lCommon::createDynamicConvex)
        .addStaticFunction("createDynamic", &lCommon::createDynamic)
        .addStaticFunction("createPlane", &lCommon::createPlane)
        .addStaticFunction("addRigidDynamic", &lCommon::_PxScene_addPxRigidDynamic_)
        .addStaticFunction("addRigidStatic", &lCommon::_PxScene_addPxRigidStatic_)
        .addStaticFunction("cleanup", &lCommon::cleanup)
        .endClass()
        .beginClass<physx::PxMaterial>("PxMaterial")
        .addFunction("release", &physx::PxMaterial::release)
        .endClass()
        .beginClass<physx::PxShape>("PxShape")
        .addFunction("release", &physx::PxShape::release)
        .endClass()
        .beginClass<physx::PxRigidActor>("PxRigidActor")
        .addFunction("release", &physx::PxRigidActor::release)
        .endClass()
        .deriveClass<physx::PxRigidStatic, physx::PxRigidActor>("PxRigidStatic")
        .endClass()
        .deriveClass<physx::PxRigidDynamic, physx::PxRigidActor>("PxRigidDynamic")
        .endClass()
        .endNamespace();

    return 0;
}
