#pragma once

#include "../EntitasPP/ISystem.h"
#include "../EntitasPP/Pool.h"
#include "../EntitasPP/Entity.h"
#include <unordered_map>

namespace Chestnut {
	namespace Ball {

		class IndexSystem :
			public EntitasPP::ISystem, public EntitasPP::IInitializeSystem, public EntitasPP::IFixedExecuteSystem {
		public:

			IndexSystem() = default;
			virtual ~IndexSystem() {}

			auto SystemType() ->int;

			auto SetPool(luabridge::RefCountedPtr<EntitasPP::Pool> pool) -> void;

			auto Initialize() -> void;

			auto FixedExecute() -> void;

			auto OnEntityCreated(EntitasPP::Pool* pool, EntitasPP::EntityPtr entity) -> void;

			auto FindEntity(int index)->EntitasPP::EntityPtr;

		protected:

		private:
			luabridge::RefCountedPtr< Chestnut::EntitasPP::Pool>  _pool;
			std::unordered_map<int, EntitasPP::EntityPtr> _entitas;

		};

	}
}