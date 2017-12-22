local clientsock = require "clientsock"
local assert = assert

local cls = class("context")

function cls:ctor(ctx, ... )
	-- body
	-- printInfo("hello world.")

	-- 启动网络功能（开始同步远程数据）
	self.up = ctx

	return self
end

function cls:clientsock( ... )
	-- body
	return self._clientsock
end

function cls:Update(delta, ... )
	-- body
	-- print("update test")
end

function cls:Peek( ... )
	-- body
	return self.up:Peek()
end

function cls:Push(controller, ... )
	-- body
	self.up:Push(controller)
end

function cls:Pop( ... )
	-- body
	self.up:Pop()
end

function cls:Test( ... )
	-- body
	print("context test")
end

-- function cls:send_request(name, args, ... )
-- 	self._clientsock:send_request(name, args, ...)
-- end

-- function cls:pause( ... )
-- 	-- body
-- end

-- function cls:resume( ... )
-- 	-- body
-- end

-- function cls.new( ... )
-- 	-- body
-- 	local inst = {}
-- 	inst.ctor = cls.ctor

-- 	inst:ctor( ... )

-- 	return inst
-- end

return cls