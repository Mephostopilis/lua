local MakeComponent = require('entitas.MakeComponent')


local HuCardsComponent = MakeComponent("huCards", 
	"hurightoffset",          -- number
	"hubottomoffset",         -- number
	"hucards",                -- list
	)

-- // using System;
-- // using System.Collections.Generic;
-- // using System.Linq;
-- // using System.Text;
-- // using System.Threading.Tasks;
-- // using Entitas;

-- // namespace Entitas.Components.Game {
-- //     [Game]
-- //     public sealed class HuCardsComponent : IComponent {
-- //         public float hurightoffset = 0.2f;
-- //         public float hubottomoffset = 0.4f;
-- //         public List<GameEntity> hucards = new List<GameEntity>();
-- //     }
-- // }
