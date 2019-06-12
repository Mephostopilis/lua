local MakeComponent = require('entitas.MakeComponent')
local DeskComponent = MakeComponent("desk",
	"width",        -- number
	"length",       -- number
	"height",       -- number
	"curorMH",      -- number
	"clockleft",    -- integer
	"go"            -- GameObject
)

return DeskComponent
