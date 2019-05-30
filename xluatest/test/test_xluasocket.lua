local xluasocket = require "xluasocket"

local function run( ... )
	-- body
	local err = xluasocket.new(function (t, id, ud, ... )
		-- body
		if t == xluasocket.SOCKET_DATA then
			print('data:', id, ...)
		elseif t == xluasocket.SOCKET_OPEN then
			print('sokcet connect', id, ud, ...)
			local subcmd = tostring(...)
			if subcmd == 'transfer' then
			end
		elseif t == xluasocket.SOCKET_ACCEPT then
			print("accept", id, ud)
			xluasocket.unpack(ud, xluasocket.HEADER_TYPE_LINE)
			xluasocket.start(ud)
		elseif t == xluasocket.SOCKET_ERROR then
			print('error', id, ...)
		end
	end)

	-- server
	local s = xluasocket.listen("127.0.0.1", 3300)
	if s < 0 then
		error(string.format("id = %d listen failture.", s))
	else
		print('s = ', s)
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
	local c = xluasocket.connect("127.0.0.1", 3300)
	if c < 0 then
		error(string.format("id = %d connect failture.", c))
	else
		print('c = ', c)
	end
	xluasocket.pack(c, xluasocket.HEADER_TYPE_LINE)
	xluasocket.start(c)
	-- err = xluasocket.pack(c, xluasocket.HEADER_TYPE_LINE)
	-- if err ~= 0 then
	-- 	error(string.format("id = %d listen failture.", c))
	-- end

	while true do
		xluasocket.poll()

		local err = xluasocket.send(c, "hello world")
		if err == -1 then
			error(string.format("id = %d send failtrue.", c))
		end
	end
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
	print(err)
end