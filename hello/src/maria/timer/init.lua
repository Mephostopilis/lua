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

-- sec
function _M.timeout(time, u, c,  ... )
	-- body
	-- if u then
	-- 	for i=1,time-1 do
	-- 		local id = next_id()
	-- 		core.timeout(time * 100, id, function ( ... )
	-- 			-- body
	-- 			u(i)
	-- 		end)
	-- 	end
	-- end

	local id = assert(next_id())
	print(id)
	core.timeout(time * 100, id, function ( ... )
		-- body
		c(time)
	end)
end

_M.starttime = assert(core.starttime)
_M.now = assert(core.now)

return _M