local stack = require "chestnut.stack"
local timer = require "maria.timer"
local NetworkMgr = require "maria.network.NetworkMgr"

local cls = class("AppContext")

function cls:ctor( ... )
	-- body
	timer.init()
	NetworkMgr.getInstance()
	self._stack = stack()
end

function cls:Startup( ... )
	-- body
	NetworkMgr.getInstance():Startup()
end

function cls:Cleanup( ... )
	-- body
end

function cls:Push(context, ... )
	-- body
	self._stack:push(context)
end

function cls:Pop( ... )
	-- body
	self._stack:pop()
end

function cls:Peek( ... )
	-- body
	return self._stack:peek()
end

return cls