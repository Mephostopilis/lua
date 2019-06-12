------------------------------------
-- 这里主要是玩家数据
------------------------------------

local MakeComponent = require('entitas.MakeComponent')

local HuCardsComponent = MakeComponent("huCards",
	"hurightoffset",          -- number
	"hubottomoffset",         -- number
	"hucards",                -- {}
	"hashu"
)

return HuCardsComponent
