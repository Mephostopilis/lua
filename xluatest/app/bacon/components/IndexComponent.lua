local MakeComponent = require('entitas.MakeComponent')

local IndexComponent = MakeComponent("index",
	"index"                      -- integer @
)

return IndexComponent

-- using System;
-- using System.Collections.Generic;
-- using System.Linq;
-- using System.Text;
-- using Entitas;

-- namespace Entitas.Components.Game {
--     [Game]
--     public sealed class IndexComponent : Entitas.IComponent {
--         public int index;
--     }
-- }