local MakeComponent = require('entitas.MakeComponent')

local LoginComponent = MakeComponent("login",
	"isSended",
	"logined",                      -- boolean @
	"authed",                       -- boolean @
	"loginUIContext"
)

return LoginComponent