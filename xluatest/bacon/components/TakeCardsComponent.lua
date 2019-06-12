local MakeComponent = require('entitas.MakeComponent')

return MakeComponent("takeCards",
    "takeleftoffset",
    "takebottomoffset",
    "takemove",
    "takemovedelta",

    "takecardsidx",
    "takecardscnt",
    "takecardslen",       -- vector(PGCards)
    "takecards"
)
