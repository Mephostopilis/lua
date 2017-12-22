using Entitas;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Bacon.GameSystems {
    public class IndexSystem : Entitas.ISystem {
        private static int index = 0;   // index 从1开始，0作为不存在

        private Dictionary<int, Entitas.IEntity> entitas = new Dictionary<int, IEntity>();

        private GameContext context;

        public IndexSystem(Contexts contexts) {
            context = contexts.game;
            context.OnEntityCreated += OnEntityCreated;
            context.OnEntityDestroyed += OnEntityDestroyed;
            context.OnEntityWillBeDestroyed += OnEntityWillBeDestroyed;
        }

        public GameEntity FindEntity(int index) {
            if (entitas.ContainsKey(index)) {
                return entitas[index] as GameEntity;
            }
            return null;
        }

        private void OnEntityWillBeDestroyed(IContext context, IEntity entity) {
            // 其他系统都在这里处理
        }

        private void OnEntityCreated(IContext context, IEntity entity) {
#if (!GEN_COMPONENT)
            index++;
            var gameEntity = entity as GameEntity;
            gameEntity.AddIndex(index);
            entitas.Add(index, gameEntity);
#endif
        }

        private void OnEntityDestroyed(IContext context, IEntity entity) {
#if (!GEN_COMPONENT)
            var gameEntity = entity as GameEntity;
            int index = gameEntity.index.index;
            entitas.Remove(index);
#endif
        }
    }
}
