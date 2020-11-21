#define LUA_LIB

#ifdef __cplusplus
extern "C" {
#endif
#include <lauxlib.h>
#include <lua.h>

LUAMOD_API int luaopen_physx(lua_State* L);

#ifdef __cplusplus
}
#endif

#include <PxPhysicsAPI.h>
#include <PxRigidDynamic.h>

#include <foundation/PxPlane.h>
#include <foundation/PxSimpleTypes.h>
#include <foundation/PxVec2.h>
#include <foundation/PxVec3.h>

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

static physx::PxPvd* gPvd = NULL;
static physx::PxPvdTransport* gPvdTransport = NULL;
static physx::PxPvdInstrumentationFlags gPvdFlags;

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
        luaL_error(L, "create foundation failture.");
        return 0;
    }

#if defined(PX_SUPPORT_PVD)
    gPvdTransport = physx::PxDefaultPvdSocketTransportCreate("127.0.0.1", 5425, 10);
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
        luaL_error(L, "PxCreatePhysics failed.");
        return 0;
    }

    if (!PxInitExtensions(*gPhysics, gPvd)) {
        luaL_error(L, "PxInitExtensions failed.");
        return 0;
    }

    physx::PxCookingParams params(scale);
    params.meshWeldTolerance = 0.001f;
    params.meshPreprocessParams = physx::PxMeshPreprocessingFlags(physx::PxMeshPreprocessingFlag::eWELD_VERTICES);
    params.buildGPUData = true;

    gCooking = PxCreateCooking(PX_PHYSICS_VERSION, *gFoundation, params);

    gDispatcher = physx::PxDefaultCpuDispatcherCreate(1);

    //_physics->registerDeletionListener(*this, PxDeletionEventFlag::eUSER_RELEASE);
    //PxArticulationJointReducedCoordinateGeneratedInfoC

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

#if defined(PX_SUPPORT_PVD)
    gPvd->release();
    //transport->release();
    gPvdTransport->release();
#endif

    gFoundation->release();

    mtx.unlock();
    printf("ball done.\n");
    return 0;
}

static int release(lua_State* L)
{
    if (lua_gettop(L) < 1) {
        return 0;
    }
    physx::PxBase* scene = (physx::PxBase*)lua_touserdata(L, 1);
    if (scene == NULL) {
        return 0;
    }
    if (scene->isReleasable()) {
        scene->release();
    }

    return 0;
}

static int isReleasable(lua_State* L)
{
    physx::PxBase* scene = (physx::PxBase*)lua_touserdata(L, 1);
    bool b = scene->isReleasable();
    lua_pushboolean(L, b);
    return 1;
}

static int createScene(lua_State* L)
{
    const float* vec = (float*)lua_touserdata(L, 1);
    physx::PxVec3 gravity(vec[0], vec[1], vec[2]);

    physx::PxSceneDesc sceneDesc(gPhysics->getTolerancesScale());
    sceneDesc.gravity = gravity;
    //gDispatcher =  PxDefaultCpuDispatcherCreate(2);
    sceneDesc.cpuDispatcher = gDispatcher;
    sceneDesc.filterShader = physx::PxDefaultSimulationFilterShader;

    physx::PxScene* scene = gPhysics->createScene(sceneDesc);
    PX_ASSERT(scene);
    if (scene == NULL) {
        return 0;
    }

#if defined(PX_SUPPORT_PVD)
    physx::PxPvdSceneClient* pvdClient = scene->getScenePvdClient();
    if (pvdClient) {
        pvdClient->setScenePvdFlag(physx::PxPvdSceneFlag::eTRANSMIT_CONSTRAINTS, true);
        pvdClient->setScenePvdFlag(physx::PxPvdSceneFlag::eTRANSMIT_CONTACTS, true);
        pvdClient->setScenePvdFlag(physx::PxPvdSceneFlag::eTRANSMIT_SCENEQUERIES, true);
    }
#endif

    lua_pushlightuserdata(L, scene);
    return 1;
}

static int addActor(lua_State* L)
{
    physx::PxScene* scene = (physx::PxScene*)lua_touserdata(L, 1);
    physx::PxActor* actor = (physx::PxActor*)lua_touserdata(L, 2);
    scene->addActor(*actor);
    return 0;
}

static int removeActor(lua_State* L)
{
    physx::PxScene* scene = (physx::PxScene*)lua_touserdata(L, 1);
    physx::PxActor* actor = (physx::PxActor*)lua_touserdata(L, 2);
    scene->removeActor(*actor);
    return 0;
}

static int stepPhysics(lua_State* L)
{
    physx::PxScene* scene = (physx::PxScene*)lua_touserdata(L, 1);
    bool interactive = lua_toboolean(L, 2);
    PX_UNUSED(interactive);
    scene->simulate(1.0f / 60.0f);
    scene->fetchResults(true);
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
    physx::PxMaterial* material = (physx::PxMaterial*)lua_touserdata(L, 4);
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

static int createDynamic(lua_State* L)
{
    float* vec = (float*)lua_touserdata(L, 1);
    physx::PxMat44 mat(vec);
    const physx::PxTransform transform(mat);
    physx::PxRigidDynamic* box = gPhysics->createRigidDynamic(transform);
    PX_ASSERT(box);
    lua_pushlightuserdata(L, box);
    return 1;
}

static int createStatic(lua_State* L)
{
    float* vec = (float*)lua_touserdata(L, 1);
    physx::PxMat44 mat(vec);
    const physx::PxTransform transform(mat);
    physx::PxRigidStatic* box = gPhysics->createRigidStatic(transform);
    PX_ASSERT(box);
    lua_pushlightuserdata(L, box);
    return 1;
}

static int createPlane(lua_State* L)
{
    physx::PxMaterial* material = (physx::PxMaterial*)lua_touserdata(L, 1);
    float distance = lua_tonumber(L, 2);
    const float* vec = (float*)lua_touserdata(L, 3);
    const physx::PxPlane plane(vec[0], vec[1], vec[2], distance);

    physx::PxRigidStatic* body = physx::PxCreatePlane(*gPhysics, plane, *material);
    PX_ASSERT(body);

    lua_pushlightuserdata(L, body);
    return 1;
}

static int createConstraint(lua_State* L)
{
    return 0;
}

// body
static int updateMassAndInertia(lua_State* L)
{
    physx::PxRigidBody* body = (physx::PxRigidBody*)lua_touserdata(L, 1);
    physx::PxRigidBodyExt::updateMassAndInertia(*body, 10.0f);
    return 0;
}

static int attachShape(lua_State* L)
{
    physx::PxRigidBody* body = (physx::PxRigidBody*)lua_touserdata(L, 1);
    physx::PxShape* shape = (physx::PxShape*)lua_touserdata(L, 2);
    bool b = body->attachShape(*shape);
    lua_pushboolean(L, b);
    return 1;
}

static int detachShape(lua_State* L)
{
    physx::PxRigidBody* body = (physx::PxRigidBody*)lua_touserdata(L, 1);
    physx::PxShape* shape = (physx::PxShape*)lua_touserdata(L, 2);
    body->detachShape(*shape);
    return 0;
}

static int setAngularDamping(lua_State* L)
{
    physx::PxRigidBody* body = (physx::PxRigidBody*)lua_touserdata(L, 1);
    lua_Number ang = lua_tonumber(L, 2);
    body->setAngularDamping(ang);
    return 0;
}

static int setLinearVelocity(lua_State* L)
{
    physx::PxRigidBody* body = (physx::PxRigidBody*)lua_touserdata(L, 1);
    const float* vec = (float*)lua_touserdata(L, 2);
    physx::PxVec3 vel(vec[0], vec[1], vec[2]);
    body->setLinearVelocity(vel);
    return 0;
}

LUAMOD_API
int luaopen_physx(lua_State* L)
{
    luaL_checkversion(L);

    luaL_Reg l[] = {
        {"init", initialize},
        {"cleanup", cleanup},
        {"release", release},
        {"is_releasable", isReleasable},

        {"create_scene", createScene},
        {"create_material", createMaterial},
        {"create_shape_sphere", createShapeSphere},
        {"create_shape_box", createShapeBox},
        {"create_shape_capsule", createShapeCapsule},
        {"create_shape_convex", createShapeConvex},
        {"create_dynamic", createDynamic},
        {"create_static", createStatic},
        {"create_plane", createPlane},

        {"scene_add_actor", addActor},
        {"scene_remove_actor", removeActor},
        {"scene_step", stepPhysics},

        {"body_updateMassAndInertia", updateMassAndInertia},
        {"body_attachShape", attachShape},
        {"body_detachShape", detachShape},
        {"body_setAngularDamping", setAngularDamping},
        {"body_setLinearVelocity", setLinearVelocity},

        {NULL, NULL},
    };
    luaL_newlib(L, l);
    return 1;
}
