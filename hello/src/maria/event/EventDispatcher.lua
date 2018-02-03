local log = require "log"
local pcall = pcall

local cls = class("EventDispatcher")

local instance

function cls:getInstance( ... )
	-- body
	if not instance then
		instance = cls.new()
	end
	return instance
end

function cls:ctor( ... )
	-- body
end

function cls:AddCustomEventListener(eventName, callback, addition, ... )
	-- body
	CS.Bacon.Director.Instance.EventDispatcher:AddCustomEventListener(eventName, function ( ... )
		-- body
		local ok, err = pcall(callback, ... )
		if not ok then
			log.error(err)
		end
	end, addition)
end

function cls:SubCustomEventListener(eventName, callback, addition, ... )
	-- body
	CS.Bacon.Director.Instance.EventDispatcher:SubCustomEventListener(eventName, function ( ... )
		-- body
		local ok, err = pcall(callback, ... )
		if not ok then
			log.error(err)
		end
	end, addition)
end

function cls:AddCmdEventListener(cmd, callback, ... )
	-- body
	CS.Bacon.Director.Instance.EventDispatcher:AddCmdEventListener(cmd, function ( ... )
		-- body
		local ok, err = pcall(callback, ... )
		if not ok then
			log.error(err)
		end
	end)
end

function cls:EnqueueRenderQueue(callback, ... )
	-- body
	CS.Bacon.Director.Instance.EventDispatcher:EnqueueRenderQueue(function ( ... )
		-- body
		local ok, err = pcall(callback, ... )
		if not ok then
			log.error(err)
		end
	end)
end

function cls:Enqueue(cmd, ... )
	-- body
	CS.Bacon.Director.Instance.EventDispatcher:Enqueue(cmd)
end

return cls