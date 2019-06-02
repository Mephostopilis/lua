#include "JoinSystem.h"

#include "../components/IndexComponent.h"
#include "../components/PositionComponent.h"


namespace Chestnut {
namespace Ball {

void JoinSystem::SetPool(luabridge::RefCountedPtr< Chestnut::EntitasPP::Pool> pool) {
	this->_pool = pool;
}

void JoinSystem::Join(int index) {
	auto entity = _pool->CreateEntity();
	entity->Add<IndexComponent>(index);
	entity->Add<PositionComponent>(0, 0, 0);
}

void JoinSystem::Leave(int index) {

}

}
}