local MakeComponent = require('entitas.MakeComponent')

local RoomComponent = MakeComponent("room",
	"isCreated",                      -- string @
	"joined",
	"roomid",
	"type",
	"mode",
	"room_max",
	"rule"
)

return RoomComponent
