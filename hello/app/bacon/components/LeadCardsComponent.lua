local MakeComponent = require('entitas.MakeComponent')

local LeadCardsComponent = MakeComponent("leadCards",
        "leadcard",                            -- integer @
        "isHoldCard",                          -- boolean
        "leadcardMove",                        -- math3d.vector3
        "leadcardMoveDelta",                   -- number
        "leadleftoffset",                      -- number
        "leadbottomoffset",                    --  number
        "leadCards"                            -- vector
)

return LeadCardsComponent

