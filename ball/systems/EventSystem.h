#pragma once

#include "../EntitasPP/ISystem.h"
#include "../EntitasPP/Pool.h"
#include "../EntitasPP/ISystem.h"
#include <unordered_map>

namespace Chestnut {
	namespace Ball {

		class EventSystem :
			public EntitasPP::ISystem, public EntitasPP::IInitializeSystem, public EntitasPP::IFixedExecuteSystem {
		public:
			EventSystem() = default;
			virtual ~EventSystem() {}

		private:
			luabridge::RefCountedPtr< Chestnut::EntitasPP::Pool>  _pool;
			std::unordered_map<int, EntitasPP::EntityPtr> _entitas;

		};

	}
}