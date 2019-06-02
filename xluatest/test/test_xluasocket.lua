local xluasocket = require "xluasocket"
local random = require "random"

local function log(fmt, ...)
	local s = string.format(fmt,... ) .. '\n'
	xluasocket.log(s)
end

local function run( ... )
	-- body
	local err = xluasocket.new(function (t, id, ud, ... )
		-- body
		if t == xluasocket.SOCKET_DATA then
			log('data: [id = %d][%s]', id, ...)
		elseif t == xluasocket.SOCKET_OPEN then
			log('sokcet connect [id = %d][%d][subcmd = %s]', id, ud, ...)
			local subcmd = tostring(...)
			if subcmd == 'transfer' then
			end
		elseif t == xluasocket.SOCKET_ACCEPT then
			log("sokcet accept [id = %d][acc = %d]", id, ud)
			xluasocket.unpack(ud, xluasocket.HEADER_TYPE_LINE)
			xluasocket.start(ud)
		elseif t == xluasocket.SOCKET_ERROR then
			log('error', id, ...)
		end
	end)

	-- server
	local s = xluasocket.listen("127.0.0.1", 3300)
	if s < 0 then
		error(string.format("id = %d listen failture.", s))
	else
		log('s = %d', s)
	end
	xluasocket.start(s)
	-- err = xluasocket.pack(s, xluasocket.HEADER_TYPE_LINE)
	-- if err ~= 0 then
	-- 	error(string.format("id = %d listen failture.", id))
	-- end
	-- local err = xluasocket.start(id)
	-- if err ~= 0 then
	-- 	error(string.format("id = %d start failture code %d.", err))
	-- end

	-- client
	for i=1,100 do
		local c = xluasocket.connect("127.0.0.1", 3300)
		if c < 0 then
			error(string.format("id = %d connect failture.", c))
		else
			log('c = %d', c)
		end
		xluasocket.pack(c, xluasocket.HEADER_TYPE_LINE)
		xluasocket.start(c)	
	end
	
	-- err = xluasocket.pack(c, xluasocket.HEADER_TYPE_LINE)
	-- if err ~= 0 then
	-- 	error(string.format("id = %d listen failture.", c))
	-- end

	local r1 = random(0)
	local times = 100
	while true do
		xluasocket.poll()
		if times >= 0 then
			times = times - 1
			local id = r1(1, 100);
			log('send %d hell world times(%d)', id, times)
			local err = xluasocket.send(id, "hello world")
			if err == -1 then
				error(string.format("id = %d send failtrue.", id))
			end	
		end
	end
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
	log(err)
end