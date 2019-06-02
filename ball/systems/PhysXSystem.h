#ifndef __PHYSX_SYSTEM_H_
#define __PHYSX_SYSTEM_H_

#include "../EntitasPP/ISystem.h"

#include <PxPhysicsAPI.h>
#include <extensions/PxExtensionsAPI.h>
#include <PxDeletionListener.h>

#include <map>
#include <string>
#include <list>

namespace Chestnut {

class PhysXSystem : public Chestnut::EntitasPP::ISystem,
	public Chestnut::EntitasPP::IInitializeSystem,
	public physx::PxDeletionListener,
	public physx::PxSimulationEventCallback {

public:
	~PhysXSystem();

	virtual void Initialize() override;

	void Update(float delta);

	inline physx::PxFoundation * getFoundation() const { return _foundation; }
	inline physx::PxPhysics    * getPhysics() const { return _physics; }
	inline physx::PxCooking    * getCooking() const { return _cooking; }

	inline physx::PxMaterial * getDefaultMaterial() const { return _material; }

	virtual void onRelease(const physx::PxBase* observed, void* userData, physx::PxDeletionEventFlag::Enum deletionEvent);

	virtual void onConstraintBreak(physx::PxConstraintInfo* constraints, physx::PxU32 count);
	virtual void onWake(physx::PxActor** actors, physx::PxU32 count);
	virtual void onSleep(physx::PxActor** actors, physx::PxU32 count);
	virtual void onContact(const physx::PxContactPairHeader& pairHeader, const physx::PxContactPair* pairs, physx::PxU32 nbPairs);
	virtual void onTrigger(physx::PxTriggerPair* pairs, physx::PxU32 count);
	virtual void onAdvance(const physx::PxRigidBody*const* bodyBuffer, const physx::PxTransform* poseBuffer, const physx::PxU32 count);

	physx::PxRigidDynamic*	    createBox(const physx::PxVec3& pos, const physx::PxVec3& dims, const physx::PxVec3* linVel = NULL, physx::PxReal density = 1.0f);
	physx::PxRigidDynamic*		createSphere(const physx::PxVec3& pos, physx::PxReal radius, const physx::PxVec3* linVel = NULL, physx::PxReal density = 1.0f);
	physx::PxRigidDynamic*		createCapsule(const physx::PxVec3& pos, physx::PxReal radius, physx::PxReal halfHeight, const physx::PxVec3* linVel = NULL, physx::PxReal density = 1.0f);
	physx::PxRigidDynamic*		createConvex(const physx::PxVec3& pos, const physx::PxVec3* linVel = NULL, physx::PxReal density = 1.0f);

private:
	bool                            _recordMem;
	physx::PxDefaultAllocator       _allocator;
	physx::PxDefaultErrorCallback   _error;
	physx::PxFoundation            *_foundation;
	//physx::PxProfileZoneManager    *_profileZoneManager;
	physx::PxPhysics               *_physics;
	physx::PxCooking               *_cooking;
	physx::PxMaterial              *_material;

	physx::PxPvd*                    _pvd;
	physx::PxPvdTransport*           _pvdTransport;
	physx::PxPvdInstrumentationFlags _pvdFlags;

	physx::PxScene                   *_scene;
	//physx::PxDefaultCpuDispatcher  *_dispatcher;
	//physx::PxRigidStatic           *_plane;
	//physx::PxRigidDynamic          *_a;

	std::list<physx::PxRigidStatic*> _list;
};

}
#endif