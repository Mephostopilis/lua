using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Entitas;
using Maria;

namespace Bacon.GameSystems {
    public class DiceSystem : ISystem, ISetContextSystem, IInitializeSystem {
        private GameContext _context;
        private AppContext _appContext;
        private AppGameSystems _gameSystems;
        private Dictionary<long, GameEntity> _dict = new Dictionary<long, GameEntity>();
        
        public DiceSystem(Contexts contexts) {
            _context = contexts.game;
        }

        public void SetAppContext(AppContext context) {
            _appContext = context;
            _gameSystems = _appContext.GameSystems;
        }

        public void Initialize() {
#if (!GEN_COMPONENT)
#endif
        }


    }
}
