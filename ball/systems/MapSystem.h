#pragma once


#include "../EntitasPP/ISystem.h"
#include "../EntitasPP/Pool.h"
#include "../hexmap/hexmap.h"

#include <LuaBridge/RefCountedPtr.h>

namespace Chestnut {
namespace Ball {

class MapSystem :
	public  EntitasPP::ISystem, public EntitasPP::ISetRefPoolSystem, public EntitasPP::IInitializeSystem, public EntitasPP::IFixedExecuteSystem {

public:
	
	MapSystem() = default;
	virtual ~MapSystem();

	
	void SetPool(luabridge::RefCountedPtr<EntitasPP::Pool> pool);

	void Initialize();

	void FixedExecute();

	void FindPath(int index, struct vector3 start, struct vector3 dst);

protected:

private:
	luabridge::RefCountedPtr<Chestnut::EntitasPP::Pool> _pool;
	struct HexMap *_map;

};

}
}