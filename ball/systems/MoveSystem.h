#pragma once
#include "../EntitasPP/Pool.h"
#include "../EntitasPP/Group.h"
#include "../EntitasPP/ISystem.h"


namespace Chestnut {
namespace Ball {

class MoveSystem :
	public EntitasPP::ISystem, public EntitasPP::ISetRefPoolSystem, public EntitasPP::IFixedExecuteSystem
{
public:
	
	int SystemType();

	void SetPool(luabridge::RefCountedPtr<EntitasPP::Pool> pool);

	void FixedExecute();

protected:
	luabridge::RefCountedPtr<Chestnut::EntitasPP::Pool> pool;

};

}
}