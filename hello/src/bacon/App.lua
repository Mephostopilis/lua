
local AppContext = require "bacon.AppContext"

local cls = class("App")


function cls:ctor( ... )
	-- body
	self._context = AppContext.new()
end

function cls:Startup( ... )
	-- body
	self._context:Startup()
end

function cls:Cleanup( ... )
	-- body
	self._context:Cleanup()
end

return cls