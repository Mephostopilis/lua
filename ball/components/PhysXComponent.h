#ifndef __PLAYER_H_
#define __PLAYER_H_

#include "../EntitasPP/IComponent.h"

namespace physx {
class PxRigidDynamic;
}

class PhysXComponent : Chestnut::EntitasPP::IComponent {
public:
	void Reset(int uid, int subid, int session, physx::PxRigidDynamic *rigid) {
		this->uid = uid;
		this->subid = subid;
		this->session = session;
		this->rigid = rigid;
	}

	int   uid;
	int   subid;
	int   session;
	physx::PxRigidDynamic *rigid;
};

#endif