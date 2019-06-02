#pragma once
#include "../EntitasPP/IComponent.h"

namespace Chestnut {
namespace Ball {

class IndexComponent :
	public Chestnut::EntitasPP::IComponent {
public:
	void Reset(int idx) {
		index = idx;
	}

	int index;
};
}
}