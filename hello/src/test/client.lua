local xluasocket = require "xluasocket"

local g = xluasocket.new(function (id, t, ... )
	-- body
	if t == xluasocket.SOCKET_DATA then
		print(...)
	end
end)

local id = xluasocket.socket(g, xluasocket.PROTOCOL_TCP, xluasocket.HEADER_TYPE_LINE)

assert(xluasocket.connect(g, id, "127.0.0.1", 3300) == 0)
assert(xluasocket.start(g, id) == 0)

while true do 
	xluasocket.poll(g)
	xluasocket.send(g, id, "hello world")
end