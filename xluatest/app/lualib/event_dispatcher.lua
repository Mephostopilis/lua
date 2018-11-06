local log = require "log"
local pcall = pcall
local debug = debug

local cls = {}

function cls.AddCustomEventListener(eventName, callback, addition, ... )
	-- body
	CS.Maria.Event.EventDispatcher.current:AddCustomEventListener(eventName, function ( ... )
		-- body
		local traceback = debug.traceback
		local ok, err = xpcall(callback, traceback, ... )
		if not ok then
			log.error(err)
		end
	end, addition)
end

function cls.SubCustomEventListener(eventName, callback, addition, ... )
	-- body
	CS.Maria.Event.EventDispatcher.current:SubCustomEventListener(eventName, function ( ... )
		-- body
		local traceback = debug.traceback
		local ok, err = xpcall(callback, traceback, ... )
		if not ok then
			log.error(err)
		end
	end, addition)
end

function cls.AddCmdEventListener(cmd, callback, ... )
	-- body
	CS.Maria.Event.EventDispatcher.current:AddCmdEventListener(cmd, function ( ... )
		-- body
		local traceback = debug.traceback
		local ok, err = xpcall(callback, traceback, ... )
		if not ok then
			log.error(err)
		end
	end)
end

function cls.EnqueueRenderQueue(callback, ... )
	-- body
	CS.Maria.Event.EventDispatcher.current:EnqueueRenderQueue(function ( ... )
		-- body
		local traceback = debug.traceback
		local ok, err = xpcall(callback, traceback, ... )
		if not ok then
			log.error(err)
		end
	end)
end

function cls.Enqueue(cmd, ... )
	-- body
	CS.Maria.Event.EventDispatcher.current:Enqueue(cmd)
end

return cls