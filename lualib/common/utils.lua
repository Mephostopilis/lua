local skynet = require "skynet"

local util = {}

function util.set_timeout(ti, f)
	-- body
	assert(ti and f)
	local function cb()
		-- body
		if f then
			f()
		end
	end
	skynet.timeout(ti, cb)
	return function ()
		-- body
		f = nil
	end
end

function util.cm_sec()
	-- body
	local nt = os.date("*t")
	local t = {}
	t.year  = nt.year
	t.month = nt.month
	t.day   = 1
	return os.time(t), nt.month
end

function util.cd_sec()
	-- body
	local nt = os.date("*t")
	local t = {}
	t.year  = nt.year
	t.month = nt.month
	t.day   = nt.day
	return os.time(t), nt.day
end

function util.redis_hval(hval, ... )
	-- body
	local h = {}
	local key
	for i,v in ipairs(hval) do
		if i % 2 == 1 then
			key = v
		else
			h[key] = v
		end
	end
	return h
end

return util