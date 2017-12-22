local timer = require "maria.timer"
local NetworkMgr = require "maria.network.NetworkMgr"
local cls = class("AppContext")

function cls:ctor( ... )
	-- body
	timer.init()
	NetworkMgr.getInstance()
end

function cls:Startup( ... )
	-- body
	NetworkMgr.getInstance():Startup()
end

function cls:Cleanup( ... )
	-- body
end

return cls