local core = require "timer.core"

local timer = {id = 0, max_id = 4294967295, pool = {}}

local function next_id( ... )
	-- body
	timer.id = timer.id + 1
	if timer.id > timer.max_id then
		timer.id = 1
	end
end

local _M = {}

function _M.init( ... )
	-- body
	core.init()
end

function _M.update( ... )
	-- body
	core.update()
end

-- sec
function _M.timeout(time, u, c,  ... )
	-- body
	for i=1,time-1 do
		local id = next_id()
		core.timeout(id, function ( ... )
			-- body
			u(i)
		end)
	end

	local id = next_id()
	
	for k,v in pairs(table_name) do
			print(k,v)
		end	

end

