local MakeComponent = require('entitas.MakeComponent')

local UserComponent = MakeComponent("scene",
	"username",                      -- string @
	"password",
	"server",
	"uid",
	"subid",
	"secret"
)

return UserComponent
