
local cls = class("HeadSystem")

function cls:ctor( ... )
              -- body
              self._appContext = nil
              self._context = nil
              self._gameSystems = nil
end

function cls:SetLeave(entity, value, ... )
            -- body
            entity.head.headUIContext:SetLeave(value)
end

return cls

-- using System;
-- using System.Collections.Generic;
-- using System.Linq;
-- using System.Text;
-- using System.Threading.Tasks;
-- using UnityEngine;
-- using Entitas;
-- using Maria;

-- namespace Bacon.GameSystems {
--     public class HeadSystem : ISystem, ISetContextSystem, IInitializeSystem {
--         private GameContext _context;
--         private AppContext _appContext;
--         private AppGameSystems _gameSystems;

--         public HeadSystem(Contexts contexts) {
--             _context = contexts.game;
--         }

--         public void SetAppContext(AppContext context) {
--             _appContext = context;
--             _gameSystems = _appContext.GameSystems;
--         }
--         public void Initialize() {
--         }

--         public void SetLeave(GameEntity entity, bool value) {
--             entity.head.headUIController.SetLeave(value);
--         }

--     }
-- }
