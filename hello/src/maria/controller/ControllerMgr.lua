local stack = require "chestnut.stack"
local list = require "list"

local cls = class("ControllerMgr")

local instance

function cls.getInstance( ... )
	-- body
	if not instance then
		instance = cls.new( ... )
	end
	return instance
end

function cls:ctor( ... )
	-- body
	self._stack = stack()
	self._list = list.new()
end

function cls:Startup( ... )
	-- body
end

function cls:Cleanup( ... )
	-- body
end

function cls:Peek( ... )
	-- body
	return self._stack:peek()
end

function cls:Push(i, ... )
	-- body
	self._stack:push(i)
end

function cls:Pop( ... )
	-- body
	return self._stack:pop()
end

return cls