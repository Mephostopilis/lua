local xluasocket = require "xluasocket"

local function run( ... )
	-- body
	local g = xluasocket.new(function (id, t, ... )
	-- body
		if t == xluasocket.SOCKET_DATA then
			print(...)
		elseif t == xluasocket.SOCKET_ERROR then
			print(string.format("id = %d socket error.", id))
		elseif t == xluasocket.SOCKET_CLOSE then
			print(string.format("id = %d socket close.", id))
		end
	end)

	local id = xluasocket.socket(g, xluasocket.PROTOCOL_TCP, xluasocket.HEADER_TYPE_LINE)

	local err = xluasocket.connect(g, id, "127.0.0.1", 3300)
	if err ~= 0 then
		error(string.format("id = %d connect 127.0.0.1 failtrue.", id))
	end

	local err = xluasocket.start(g, id)
	if err ~= 0 then
		error(string.format("id = %d start failtrue.", id))
	end

	while true do 
		xluasocket.poll(g)
		local err = xluasocket.send(g, id, "hello world")
		if err == -1 then
			print(string.format("id = %d send failtrue.", id))
		end
	end
end

local ok, err = pcall(run)
if not ok then
	print(err)
end
