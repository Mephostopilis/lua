local MakeComponent = require('entitas.MakeComponent')

local Component = MakeComponent("main",
	"mainBgUIContext",
	"titleUIContext",
	"bottomUIContext",
	"roomUIContext",
	"createRoomUIContext",
	"joinUIContext",
	"roomTipsUIContext"
)

return Component