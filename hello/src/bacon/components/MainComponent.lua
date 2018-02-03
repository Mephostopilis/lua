local MakeComponent = require('entitas.MakeComponent')

local Component = MakeComponent("main",
	"bottomUIContext",
	"roomUIContext",
	"createRoomUIContext",
	"joinUIContext"
)

return Component