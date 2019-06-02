#ifndef ISETSYSTEMS_H
#define ISETSYSTEMS_H

#include <LuaBridge/RefCountedPtr.h>
#include <Systems.h>

namespace Chestnut {
	namespace Ball {
		class ISetSystem {
		public:
			virtual auto SetSystems(RefCountedPtr<Systems> systems) -> void = 0;
		};
	}
}

#endif // !ISETSYSTEMS_H
