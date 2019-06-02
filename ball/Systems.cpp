#include "Systems.h"
#include "EntitasPP/Pool.h"

namespace Chestnut {
	namespace Ball {


		Systems::Systems() {
			_indexSystem = luabridge::RefCountedPtr<IndexSystem>(new IndexSystem());
			_joinSystem = luabridge::RefCountedPtr<Chestnut::Ball::JoinSystem>(new JoinSystem());
		}

		Systems::~Systems() {}

		auto Systems::GetIndexSystem()-> luabridge::RefCountedPtr<IndexSystem> const {
			return _indexSystem;
		}
		
		auto Systems::GetJoinSystem()->luabridge::RefCountedPtr<JoinSystem> const {
			return _joinSystem;
		}

	}
}