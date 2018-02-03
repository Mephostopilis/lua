local xluasocket = require "xluasocket"

local g = xluasocket.new(function (id, t, ... )
	-- body
	if t == xluasocket.SOCKET_DATA then
		print(...)
	end
end)

if g == nil then
	print("g is nil")
	return
end

local id = xluasocket.socket(g, xluasocket.PROTOCOL_TCP, xluasocket.HEADER_TYPE_LINE)

xluasocket.listen(g, id, "127.0.0.1", 3300)
xluasocket.start(g, id)

while true do 
	xluasocket.poll(g)
end