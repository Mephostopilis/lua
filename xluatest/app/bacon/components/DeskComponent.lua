local MakeComponent = require('entitas.MakeComponent')
local DeskComponent = MakeComponent("desk",
	"width",        -- number
	"length",       -- number
	"height",       -- number
	"curorMH",      -- number
	"clockleft",    -- integer
	"go"           -- GameObject
)

return DeskComponent

-- using System;
-- using System.Collections.Generic;
-- using System.Linq;
-- using System.Text;
-- using System.Threading.Tasks;
-- using UnityEngine;
-- using Entitas;

-- namespace Entitas.Components.Game {
--     [Game]
--     public sealed class DeskComponent : IComponent {
--         public float width = 2.0f;
--         public float length = 2.0f;
--         public float height = 2.0f;
--         public float curorMH = 0.1f;
--         public long clockleft = 0;       // 桌面剩下的时间
--         public GameObject go;
--     }
-- }