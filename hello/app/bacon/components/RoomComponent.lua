local MakeComponent = require('entitas.MakeComponent')

local UserComponent = MakeComponent("room",
	"isCreated",                      -- string @
	"roomid",
	"room_max",
	"rule"
)

return UserComponent
