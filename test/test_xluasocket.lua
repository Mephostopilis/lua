local xluasocket = require "xluasocket"
local random = require "random"

local function log(fmt, ...)
	local s = string.format(fmt, ...) .. '\n'
	xluasocket.log(s)
end

local function run1( ... )
	-- body

	local s
	local xc
	local map = {}
	local r1 = random(0)
	local times = 100
	local cc = 0
	local xxxx = 100000000
	local handle = function (t, id, ud, ... )
		-- body
		if t == xluasocket.SOCKET_DATA then
			log('data: [id = %d][%s]', id, ...)
		elseif t == xluasocket.SOCKET_OPEN then
			local subcmd = tostring(...)
			if subcmd == 'transfer' then
				-- connect start
				xluasocket.pack(id, xluasocket.HEADER_TYPE_LINE)
				map[id] = true
				log('sokcet transfer [id = %d][%d][%s]', id, ud, subcmd)
			elseif subcmd == 'start' then
				-- listen accept start
				log('sokcet start [id = %d][%d][%s]', id, ud, subcmd)
			else
				xluasocket.start(id)
				-- log('sokcet connect [id = %d][%d][%s]', id, ud, subcmd)
			end
		elseif t == xluasocket.SOCKET_ACCEPT then
			log("sokcet accept [id = %d][acc = %d]", id, ud)
			xluasocket.unpack(ud, xluasocket.HEADER_TYPE_LINE)
			xluasocket.start(ud)
		elseif t == xluasocket.SOCKET_ERROR then
			log('socket error [id = %d][msg = %s]', id, tostring(...))
			-- log('socket error')
		end
	end
	local err = xluasocket.new(handle)
	if err ~= 0 then
		error('new err = ', err)
	end

	while xxxx > 1 do
		xxxx = xxxx - 1
		xluasocket.poll()
		-- server
		if s == nil then
			s = xluasocket.listen("127.0.0.1", 3300)
			if s < 0 then
				error(string.format("id = %d listen failture.", s))
			else
				log('s = %d', s)
			end
			xluasocket.start(s)
		end
		
		-- client
		if cc < 50 then
			local c = xluasocket.connect("127.0.0.1", 3300)
			if c < 0 then
				error(string.format("id = %d connect failture.", c))
			else
				log('c = %d', c)
			end
			cc = cc + 1
		end

		if s ~= nil and cc >= 50 then
			if times > 0 then
				times = times - 1
				-- local id = r1(1, 100)
				-- if map[id] then
				-- 	log('send %d hell world times(%d)', id, times)
				-- 	local err = xluasocket.send(id, "hello world")
				-- 	if err == -1 then
				-- 		error(string.format("id = %d send failtrue.", id))
				-- 	end
				-- end
				if xc == nil then
					local id = r1(1, 100)
					while not map[id] do
						id = r1(1, 100)
					end
					xc = id
				end
				if xc ~= nil then
					log('send %d hell world times(%d)', xc, times)
					local err = xluasocket.send(xc, "hello world")
					if err == -1 then
						error(string.format("id = %d send failtrue.", xc))
					end
				end
			end
		end
	end

	-- err = xluasocket.pack(s, xluasocket.HEADER_TYPE_LINE)
	-- if err ~= 0 then
	-- 	error(string.format("id = %d listen failture.", id))
	-- end
	-- local err = xluasocket.start(id)
	-- if err ~= 0 then
	-- 	error(string.format("id = %d start failture code %d.", err))
	-- end

	-- err = xluasocket.pack(c, xluasocket.HEADER_TYPE_LINE)
	-- if err ~= 0 then
	-- 	error(string.format("id = %d listen failture.", c))
	-- end
	xluasocket.exit()
	xluasocket.close()
end

local function run2( ... )
	-- body
	local s
	local map = {}
	local r1 = random(0)
	local times = 0
	local cc = 0
	local handle = function (t, id, ud, ... )
		-- body
		if t == xluasocket.SOCKET_DATA then
			log('data: [id = %d][%s]', id, ...)
		elseif t == xluasocket.SOCKET_OPEN then
			local subcmd = tostring(...)
			if subcmd == 'transfer' then
				-- connect start
				xluasocket.pack(id, xluasocket.HEADER_TYPE_LINE)
				map[id] = true
				log('sokcet transfer [id = %d][%d][%s]', id, ud, subcmd)
			elseif subcmd == 'start' then
				-- listen accept start
				log('sokcet start [id = %d][%d][%s]', id, ud, subcmd)
			else
				xluasocket.start(id)
				-- log('sokcet connect [id = %d][%d][%s]', id, ud, subcmd)
			end
		elseif t == xluasocket.SOCKET_ACCEPT then
			log("sokcet accept [id = %d][acc = %d]", id, ud)
			xluasocket.unpack(ud, xluasocket.HEADER_TYPE_LINE)
			xluasocket.start(ud)
		elseif t == xluasocket.SOCKET_ERROR then
			log('socket error [id = %d][msg = %s]', id, tostring(...))
			-- log('socket error')
		end
	end
	local err = xluasocket.new(handle)
	if err ~= 0 then
		error('new err = ', err)
	end

	-- server
	if s == nil then
		s = xluasocket.listen("127.0.0.1", 3300)
		if s < 0 then
			error(string.format("id = %d listen failture.", s))
		else
			log('s = %d', s)
		end
		xluasocket.start(s)
	end
	
	-- client
	for i=1,50 do
		local c = xluasocket.connect("127.0.0.1", 3300)
		if c < 0 then
			error(string.format("id = %d connect failture.", c))
		else
			log('c = %d', c)
		end
	end

	while true do
		xluasocket.poll()
	
		if times > 0 then
			times = times - 1
			local id = r1(1, 100);
			log('send %d hell world times(%d)', arr[id], times)
			if arr[id] then
				local err = xluasocket.send(arr[id], "hello world")
				if err == -1 then
					error(string.format("id = %d send failtrue.", arr[id]))
				end
			end
		end
	end

	-- err = xluasocket.pack(s, xluasocket.HEADER_TYPE_LINE)
	-- if err ~= 0 then
	-- 	error(string.format("id = %d listen failture.", id))
	-- end
	-- local err = xluasocket.start(id)
	-- if err ~= 0 then
	-- 	error(string.format("id = %d start failture code %d.", err))
	-- end

	-- err = xluasocket.pack(c, xluasocket.HEADER_TYPE_LINE)
	-- if err ~= 0 then
	-- 	error(string.format("id = %d listen failture.", c))
	-- end
end

local ok, err = xpcall(run1, debug.traceback)
if not ok then
	log(err)
end