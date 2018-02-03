local MakeComponent = require('entitas.MakeComponent')

local MyIndexComponent = MakeComponent("myIndex",
	"index"                      -- integer @
)

return MyIndexComponent