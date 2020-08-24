package.path = ".\\lualib\\?.lua;" .. package.path
package.cpath = ".\\luaclib\\?.dll;.\\luaclib\\?.so;" .. package.cpath
local xluasocket = require "xluasocket"
local random = require "random"

local function log(fmt, ...)
	local s = string.format(fmt, ...) .. "\n"
	print(s)
end

local function run1(...)
	local s
	local ic
	local xc
	local ti = 0

	local handle = function(t, id, ud, ...)
		if t == xluasocket.SOCKET_DATA then
			if ic == id then
				xluasocket.send(ic, ud)
			else
				log("data: [id = %d][%s]", id, ud)
			end
		elseif t == xluasocket.SOCKET_OPEN then
			local subcmd = tostring(...)
			if subcmd == "transfer" then
				-- connect start
				-- client
				log("sokcet transfer [id = %d][%d][%s]", id, ud, subcmd)
				xc = id
			elseif subcmd == "start" then
				-- listen accept start
				log("sokcet start [id = %d][%d][%s]", id, ud, subcmd)
			else
				-- log('sokcet connect [id = %d][%d][%s]', id, ud, subcmd)
				-- server
				xluasocket.start(id)
			end
		elseif t == xluasocket.SOCKET_ACCEPT then
			log("sokcet accept [id = %d][acc = %d]", id, ud)
			ic = ud
			xluasocket.start(ud)
		elseif t == xluasocket.SOCKET_ERROR then
			log("socket error [id = %d][msg = %s]", id, tostring(...))
		-- log('socket error')
		end
	end

	local err = xluasocket.init(handle)
	if err ~= 0 then
		error("new err = ", err)
		return
	end

	-- server
	if s == nil then
		s = xluasocket.listen("127.0.0.1", 3300)
		if s < 0 then
			error(string.format("id = %d listen failture.", s))
		else
			xluasocket.start(s)
			log("s = %d", s)
		end
	end

	-- client
	if xc == nil then
		local err = xluasocket.connect("127.0.0.1", 3300)
		if err < 0 then
			error(string.format("id = %d connect failture.", c))
			return
		else
			log("c = %d", err)
		end
	end

	while ti < 10000 do
		xluasocket.poll()

		if xc then
			xluasocket.send(xc, "hello")
		end
		ti = ti + 1
	end
end

local ok, err = xpcall(run1, debug.traceback)
if not ok then
	log(err)
end

xluasocket.exit()

while xluasocket.poll() == 0 do
	print("not over")
end

xluasocket.free()

print("ss free")
