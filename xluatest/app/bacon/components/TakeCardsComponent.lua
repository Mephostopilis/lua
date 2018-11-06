local MakeComponent = require('entitas.MakeComponent')

return MakeComponent("putCards",
    "takeleftoffset",
    "takebottomoffset",
    "takemove",
    "takemovedelta",

    "takecardsidx",
    "takecardscnt",
    "takecardslen",       -- vector(PGCards)
    "takecards"
)


-- using System;
-- using System.Collections.Generic;
-- using System.Linq;
-- using System.Text;
-- using System.Threading.Tasks;
-- using Entitas;

-- namespace Entitas.Components.Game {
--     /// <summary>
--     /// 手中有哪些牌
--     /// </summary>
--     public sealed class TakeCardsComponent : IComponent {
--         public float takeleftoffset = 0.5f;
--         public float takebottomoffset = 0.35f;
--         public float takemove = 0.15f;
--         public float takemovedelta = 1.0f;

--         public int takecardsidx = 0;
--         public int takecardscnt = 0;
--         public int takecardslen = 0;
--         public Dictionary<int, GameEntity> takecards = new Dictionary<int, GameEntity>();      // index
--     }
-- }
