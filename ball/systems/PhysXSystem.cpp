#include "PhysXSystem.h"

#include <PxPhysicsAPI.h>
#include <extensions/PxExtensionsAPI.h>
#include <foundation/PxVec2.h>
#include <foundation/PxPlane.h>
#include <foundation/PxVec3.h>
#include <foundation/PxSimpleTypes.h>

#include <PxRigidDynamic.h>
#include <extensions/PxSimpleFactory.h>

#include <cassert>
#include <iostream>
#include <cstdarg>
#include <errno.h>

using namespace physx;

namespace Chestnut {

#define error(A) (void)(A);

void SetupDefaultRigidDynamic(PxRigidDynamic& body, bool kinematic = false) {
	body.setActorFlag(PxActorFlag::eVISUALIZATION, true);
	body.setAngularDamping(0.5f);
	body.setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC, kinematic);
}

PhysXSystem::~PhysXSystem() {
}

void PhysXSystem::Initialize() {
	bool recordMemoryAllocations = true;
#ifdef ANDROID
	const bool useCustomTrackingAllocator = false;
#else
	const bool useCustomTrackingAllocator = true;
#endif // ANDROID

	physx::PxAllocatorCallback *allocator = &_allocator;
	if (useCustomTrackingAllocator) {
	}

	_foundation = PxCreateFoundation(PX_FOUNDATION_VERSION, *allocator, _error);
	if (!_foundation) {
		error("create foundation failture.");
	}

	physx::PxTolerancesScale scale;
	_physics = PxCreatePhysics(PX_PHYSICS_VERSION, *_foundation, scale, _recordMem, _pvd);

	if (_physics) {
		error("PxCreatePhysics failed.");
	}

	if (!PxInitExtensions(*_physics, _pvd)) {
		error("PxInitExtensions failed.");
	}

	PxCookingParams params(scale);
	params.meshWeldTolerance = 0.001f;
	params.meshPreprocessParams = PxMeshPreprocessingFlags(PxMeshPreprocessingFlag::eWELD_VERTICES);
	params.buildGPUData = true;

	_cooking = PxCreateCooking(PX_PHYSICS_VERSION, *_foundation, params);

	_physics->registerDeletionListener(*this, PxDeletionEventFlag::eUSER_RELEASE);

	_material = _physics->createMaterial(0.5f, 0.5f, 0.1f);
	if (!_material) {
		error("create Material failed.");
	}

}

void PhysXSystem::Update(float delta) {
	
}

void PhysXSystem::onRelease(const PxBase* observed, void* userData, PxDeletionEventFlag::Enum deletionEvent) {
}

void PhysXSystem::onConstraintBreak(PxConstraintInfo* constraints, PxU32 count) {
}

void PhysXSystem::onWake(PxActor** actors, PxU32 count) {
}

void PhysXSystem::onSleep(PxActor** actors, PxU32 count) {
}

void PhysXSystem::onContact(const PxContactPairHeader& pairHeader, const PxContactPair* pairs, PxU32 nbPairs) {
}

void PhysXSystem::onTrigger(PxTriggerPair* pairs, PxU32 count) {
}

void PhysXSystem::onAdvance(const PxRigidBody*const* bodyBuffer, const PxTransform* poseBuffer, const PxU32 count) {
}

PxRigidDynamic* PhysXSystem::createBox(const PxVec3& pos, const PxVec3& dims, const PxVec3* linVel, PxReal density) {
	//PxPhysics  *physics = _ctx->getPhysics();
	/////*PxMaterial *material = _ctx->getDefaultMaterial();
	////PxRigidDynamic* box = PxCreateDynamic(*physics, PxTransform(pos), PxBoxGeometry(dims), *material, density);*/
	////PX_ASSERT(box);

	////SetupDefaultRigidDynamic(*box);
	///*_ctx->getScene()->get ->addActor(*box);
	//addPhysicsActors(box);*/

	//if (linVel)
	//	box->setLinearVelocity(*linVel);

	//return box;
	return nullptr;
}

///////////////////////////////////////////////////////////////////////////////

PxRigidDynamic* PhysXSystem::createSphere(const PxVec3& pos, PxReal radius, const PxVec3* linVel, PxReal density) {

	////PxPhysics  *physics = _ctx->getPhysics();
	//PxMaterial *material = _ctx->getDefaultMaterial();
	//PxRigidDynamic* sphere = PxCreateDynamic(*physics, PxTransform(pos), PxSphereGeometry(radius), *material, density);
	//PX_ASSERT(sphere);

	////SetupDefaultRigidDynamic(*sphere);
	///*mScene->addActor(*sphere);
	//addPhysicsActors(sphere);*/

	//if (linVel)
	//	sphere->setLinearVelocity(*linVel);

	////createRenderObjectsFromActor(sphere, material);
	//return sphere;
	return NULL;
}

///////////////////////////////////////////////////////////////////////////////

PxRigidDynamic* PhysXSystem::createCapsule(const PxVec3& pos, PxReal radius, PxReal halfHeight, const PxVec3* linVel, PxReal density) {

	////PxPhysics  *physics = _ctx->getPhysics();
	//PxMaterial *material = _ctx->getDefaultMaterial();

	//const PxQuat rot = PxQuat(PxIdentity);
	//PX_UNUSED(rot);

	//PxRigidDynamic* capsule = PxCreateDynamic(*physics, PxTransform(pos), PxCapsuleGeometry(radius, halfHeight), *material, density);
	//PX_ASSERT(capsule);

	////SetupDefaultRigidDynamic(*capsule);
	///*mScene->addActor(*capsule);
	//addPhysicsActors(capsule);*/

	//if (linVel)
	//	capsule->setLinearVelocity(*linVel);

	////createRenderObjectsFromActor(capsule, material);

	//return capsule;
	return nullptr;
}

///////////////////////////////////////////////////////////////////////////////

PxRigidDynamic* PhysXSystem::createConvex(const PxVec3& pos, const PxVec3* linVel, PxReal density) {

	/*PxConvexMesh* convexMesh = GenerateConvex(*mPhysics, *mCooking, getDebugConvexObjectScale(), false, true);
	PX_ASSERT(convexMesh);

	PxRigidDynamic* convex = PxCreateDynamic(*mPhysics, PxTransform(pos), PxConvexMeshGeometry(convexMesh), *mMaterial, density);
	PX_ASSERT(convex);

	SetupDefaultRigidDynamic(*convex);
	mScene->addActor(*convex);
	addPhysicsActors(convex);

	if (linVel)
	convex->setLinearVelocity(*linVel);

	createRenderObjectsFromActor(convex, material);

	return convex;*/
	return nullptr;
}

}