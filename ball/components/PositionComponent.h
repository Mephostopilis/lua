#pragma once
#include "../EntitasPP/IComponent.h"

namespace Chestnut {
	namespace Ball {

		class PositionComponent :
			public Chestnut::EntitasPP::IComponent {
		public:
			void Reset(float px, float py, float pz) {
				x = px;
				y = py;
				z = pz;
			}

			float x;
			float y;
			float z;
		};
	}
}