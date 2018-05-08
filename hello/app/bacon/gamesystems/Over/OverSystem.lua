using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Entitas;

namespace Bacon.GameSystems.Over {
    class OverSystem : ISystem, ISetContextSystem, IInitializeSystem {
        private GameContext _context;
        private AppContext _appContext;
        private AppGameSystems _gameSystems;

        public OverSystem(Contexts contexts) {
            _context = contexts.game;
        }

        public void SetAppContext(AppContext context) {
            _appContext = context;
            _gameSystems = _appContext.GameSystems;
        }

        public void Initialize() {
            //throw new NotImplementedException();
        }

    }
}
