local MakeComponent = require('entitas.MakeComponent')

local UserComponent = MakeComponent("user",
	"username",                      -- string @
	"password",
	"server",
	"uid",
	"subid",
	"secret"
)

return UserComponent
