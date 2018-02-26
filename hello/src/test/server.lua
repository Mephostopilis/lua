local xluasocket = require "xluasocket"

local function run( ... )
	-- body
	local g 
	g = xluasocket.new(function (id, t, ... )
	-- body
		if t == xluasocket.SOCKET_DATA then
			print(...)
		elseif t == xluasocket.SOCKET_ACCEPT then
			local accept_id = tonumber(...)
			print("accept", accept_id)
			xluasocket.start(g, accept_id)
		end
	end)

	if g == nil then
		error("g is nil")
	end

	local id = xluasocket.socket(g, xluasocket.PROTOCOL_TCP, xluasocket.HEADER_TYPE_LINE)

	local err = xluasocket.listen(g, id, "127.0.0.1", 3300)
	if err ~= 0 then
		error(string.format("id = %d listen failture.", id))
	end
	local err = xluasocket.start(g, id)
	if err ~= 0 then
		error(string.format("id = %d start failture.", id))
	end

	while true do 
		xluasocket.poll(g)
	end
end

local ok, err = pcall(run)
if not ok then
	print(err)
end