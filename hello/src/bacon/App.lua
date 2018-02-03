
local AppContext = require "bacon.AppContext"
local log = require "log"

local cls = class("App")


function cls:ctor( ... )
	-- body
	self._context = AppContext.new()
end

function cls:Startup( ... )
	-- body
	log.info("App Startup")
	self._context:Startup()

end

function cls:Cleanup( ... )
	-- body
	self._context:Cleanup()
	log.info("App Cleanup")
end

return cls