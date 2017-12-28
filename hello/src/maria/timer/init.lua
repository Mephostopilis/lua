local core = require "skynet.timer"
local assert = assert

local timer = {
	id = 0, 
	max_id = 4294967295, 
	init = false,
	pool = {} }

local function next_id( ... )
	-- body
	timer.id = timer.id + 1
	if timer.id > timer.max_id then
		timer.id = 1
	end
	return timer.id
end

local _M = {}

function _M.init( ... )
	-- body
	if not timer.init then
		core.init()
	end
end

function _M.update( ... )
	-- body
	core.update()
end

function _M.timeout_tween(sec, f, ... )
	-- body
	assert(sec and f)
	local function cb( ... )
		-- body
		if f then
			f()
		end
	end
	for i=1,time do
		local id = next_id()
		core.timeout(i * 100, id, cb)
	end
	return function ( ... )
		-- body
		f = nil
	end
end

function _M.timeout(sec, f,  ... )
	assert(sec and f)
	local function cb( ... )
		-- body
		if f then
			f()
		end
	end
	local id = next_id()
	core.timeout(sec * 100, id, cb)
	return function ( ... )
		-- body
		f = nil
	end
end

_M.starttime = assert(core.starttime)
_M.now = assert(core.now)

return _M