#define LUA_LIB

#ifdef __cplusplus
extern "C" {
#endif
#include <lauxlib.h>
#include <linalg.h>
#include <lua.h>

LUAMOD_API int luaopen_physx(lua_State* L);

#ifdef __cplusplus
}
#endif

#include <LuaBridge/LuaBridge.h>

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

static int initialize(lua_State* L)
{
    mtx.lock();
    if (initialized) {
        mtx.unlock();
        return 0;
    }

    bool recordMemoryAllocations = true;

    gFoundation = PxCreateFoundation(PX_PHYSICS_VERSION, gDefaultAllocatorCallback, gDefaultErrorCallback);
    if (!gFoundation) {
        throw std::exception("create foundation failture.");
    }

#if defined(PX_SUPPORT_PVD)
    gPvdTransport = physx::PxDefaultPvdSocketTransportCreate("127.0.0.1", 5425, 10000);
    if (gPvdTransport == NULL)
        return 0;

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
    return 0;
}

static int cleanup(lua_State* L)
{
    mtx.lock();
    if (!initialized) {
        mtx.unlock();
        return 0;
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

static int createScene(lua_State* L)
{
    const float* vec = (float*)lua_touserdata(L, 1);
    physx::PxVec3 gravity(vec[0], vec[1], vec[2]);
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

    physx::PxScene* scene = gPhysics->createScene(sceneDesc);
    lua_pushlightuserdata(L, scene);
    return 1;
}

static int releaseScene(lua_State* L)
{
    physx::PxScene* scene = (physx::PxScene*)lua_touserdata(L, 1);
    if (scene == NULL) {
        return 0;
    }
    scene->release();
    return 0;
}

static int createMaterial(lua_State* L)
{
    physx::PxReal staticFriction = lua_tonumber(L, 1);
    physx::PxReal dynamicFriction = lua_tonumber(L, 2);
    physx::PxReal restitution = lua_tonumber(L, 3);
    physx::PxMaterial* mat = gPhysics->createMaterial(staticFriction, dynamicFriction, restitution);
    lua_pushlightuserdata(L, mat);
    return 1;
}

static int createShapeSphere(lua_State* L)
{
    const physx::PxSphereGeometry geometry;
    physx::PxMaterial* material = (physx::PxMaterial*)lua_touserdata(L, 2);
    physx::PxShape* shape = gPhysics->createShape(geometry, *material);
    lua_pushlightuserdata(L, shape);
    return 1;
}

static int createShapeBox(lua_State* L)
{
    physx::PxReal hx = lua_tonumber(L, 1);
    physx::PxReal hy = lua_tonumber(L, 2);
    physx::PxReal hz = lua_tonumber(L, 3);
    const physx::PxBoxGeometry geometry(hx, hy, hz);
    physx::PxMaterial* material = nullptr;
    physx::PxShape* shape = gPhysics->createShape(geometry, *material);
    lua_pushlightuserdata(L, shape);
    return 1;
}

static int createShapeCapsule(lua_State* L)
{
    lua_Number radis = lua_tonumber(L, 1);
    lua_Number halfHeight = lua_tonumber(L, 2);
    const physx::PxCapsuleGeometry geometry(radis, halfHeight);
    physx::PxMaterial* material = (physx::PxMaterial*)lua_touserdata(L, 3);
    physx::PxShape* shape = gPhysics->createShape(geometry, *material);
    return 0;
}

static int createShapeConvex(lua_State* L)
{
    const physx::PxConvexMeshGeometry geometry;
    physx::PxMaterial* material = (physx::PxMaterial*)lua_touserdata(L, 2);
    physx::PxShape* shape = gPhysics->createShape(geometry, *material);
    lua_pushlightuserdata(L, shape);
    return 1;
}

//static int createDynamicSphere(
//    const physx::PxTransform& transform,
//    const physx::PxSphereGeometry& geometry,
//    physx::PxReal staticFriction, physx::PxReal dynamicFriction, physx::PxReal restitution,
//    physx::PxReal density)
//{
//    physx::PxMaterial* material = gPhysics->createMaterial(staticFriction, dynamicFriction, restitution);
//    physx::PxRigidDynamic* sphere = PxCreateDynamic(*gPhysics, transform, geometry, *material, density);
//    PX_ASSERT(sphere);
//    material->release();
//    return sphere;
//}
//
//static physx::PxRigidDynamic* createDynamicBox(
//    const physx::PxTransform& transform,
//    const physx::PxBoxGeometry& geometry,
//    physx::PxReal staticFriction, physx::PxReal dynamicFriction, physx::PxReal restitution,
//    physx::PxReal density)
//{
//    physx::PxMaterial* material = gPhysics->createMaterial(staticFriction, dynamicFriction, restitution);
//    physx::PxRigidDynamic* box = PxCreateDynamic(*gPhysics, transform, geometry, *material, density);
//    PX_ASSERT(box);
//    material->release();
//    return box;
//}
//
//static physx::PxRigidDynamic* createDynamicCapsule(
//    const physx::PxTransform& transform,
//    const physx::PxCapsuleGeometry& geometry,
//    physx::PxReal staticFriction, physx::PxReal dynamicFriction, physx::PxReal restitution,
//    physx::PxReal density)
//{
//    physx::PxMaterial* material = gPhysics->createMaterial(staticFriction, dynamicFriction, restitution);
//    physx::PxRigidDynamic* capsule = PxCreateDynamic(*gPhysics, transform, geometry, *material, density);
//    PX_ASSERT(capsule);
//    material->release();
//    return capsule;
//}

//static physx::PxRigidDynamic* createDynamicConvex(const physx::PxTransform& transform,
//    const physx::PxConvexMeshGeometry& geometry,
//    physx::PxReal staticFriction, physx::PxReal dynamicFriction, physx::PxReal restitution,
//    physx::PxReal density)
//{
//    physx::PxMaterial* material = gPhysics->createMaterial(staticFriction, dynamicFriction, restitution);
//    physx::PxRigidDynamic* convex = PxCreateDynamic(*gPhysics, transform, geometry, *material, density);
//    PX_ASSERT(convex);
//    material->release();
//
//    return convex;
//}

static int createDynamic(lua_State* L)
{
    const float* vec = (float*)lua_touserdata(L, 1);
    const physx::PxTransform transform;
    physx::PxShape* shape = (physx::PxShape*)lua_touserdata(L, 2);
    physx::PxReal density = lua_tonumber(L, 3);
    physx::PxRigidDynamic* box = PxCreateDynamic(*gPhysics, transform, *shape, density);
    PX_ASSERT(box);
    lua_pushlightuserdata(L, box);
    return 1;
}

static int createPlane(lua_State* L)
{
    const physx::PxPlane plane;
    physx::PxMaterial* material = (physx::PxMaterial*)lua_touserdata(L, 2);
    physx::PxRigidStatic* body = physx::PxCreatePlane(*gPhysics, plane, *material);
    PX_ASSERT(body);
    material->release();
    lua_pushlightuserdata(L, body);
    return 1;
}

static int releaseActor(lua_State* L)
{
    physx::PxActor* body = (physx::PxActor*)lua_touserdata(L, 1);

    const physx::PxTransform transform;
    physx::PxShape* shape = (physx::PxShape*)lua_touserdata(L, 2);
    physx::PxReal density = lua_tonumber(L, 3);
    physx::PxRigidDynamic* box = PxCreateDynamic(*gPhysics, transform, *shape, density);
    PX_ASSERT(box);
    lua_pushlightuserdata(L, box);
    return 1;
}

static int stepPhysics(int id, bool interactive)
{
    PX_UNUSED(interactive);
    physx::PxScene* scene = gScenes[id];
    scene->simulate(1.0f / 60.0f);
    scene->fetchResults(true);
    return 0;
}

static int _PxScene_addPxRigidDynamic_(lua_State* L)
{
    physx::PxScene* scene = (physx::PxScene*)lua_touserdata(L, 1);
    physx::PxRigidDynamic* actor = (physx::PxRigidDynamic*)lua_touserdata(L, 2);
    scene->addActor(*actor);
    return 0;
}

static int _PxScene_addPxRigidStatic_(lua_State* L)
{
    physx::PxScene* scene = (physx::PxScene*)lua_touserdata(L, 1);
    physx::PxRigidStatic* actor = (physx::PxRigidStatic*)lua_touserdata(L, 2);
    scene->addActor(*actor);
    return 0;
}

// body
/*static void updateMassAndInertia(physx::PxRigidDynamic* body, ) {
            physx::PxRigidBodyExt::updateMassAndInertia(*body, 10.0f);
	}*/

LUAMOD_API
int luaopen_physx(lua_State* L)
{
    luaL_checkversion(L);

    luaL_Reg l[] = {
        {"init", initialize},
        {"cleanup", cleanup},
        {"create_scene", createScene},
        {"create_material", createMaterial},
        {"create_shape_sphere", createShapeSphere},
        {"createShapeBox", createShapeBox},
        {"createShapeCapsule", createShapeCapsule},
        {"createShapeConvex", createShapeConvex},
        {"createShapeCapsule", createShapeCapsule},
        {"createShapeCapsule", createShapeCapsule},
        {"release_actor", releaseActor},
        //addStaticFunction("createDynamicSphere", &lCommon::createDynamicSphere)
        //.addStaticFunction("createDynamicBox", &lCommon::createDynamicBox)
        //.addStaticFunction("createDynamicCapsule", &lCommon::createDynamicCapsule)
        //.addStaticFunction("createDynamicConvex", &lCommon::createDynamicConvex)
        {"createDynamic", createDynamic},
        {"createPlane", createPlane},
        {"addRigidDynamic", _PxScene_addPxRigidDynamic_},
        {"addRigidStatic", _PxScene_addPxRigidStatic_},
        {"cleanup", cleanup},

        {NULL, NULL},
    };
    luaL_newlib(L, l);
    return 1;
}
