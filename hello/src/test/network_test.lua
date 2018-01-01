local NetworkMgr = require "maria.network.NetworkMgr"
local User = require "maria.module.User"
local timer = require "maria.timer"
timer.init()


print("hello")

-- local fd = io.open("proto/proto.c2s.sproto", "r+")
-- local line = fd:read()
-- print(line)

-- begain to connect
local username = "hello"
local password = "Password"
local server = "sample1"


local user = User.new()
user.username = username
user.password = password
user.server = server
NetworkMgr:getInstance():RegNetwork(user)

local t = {
	OnLoginAuthed = function (self, code, ... )
		-- body
		if code == 200 then
			print("OnLoginAuthed ---------------------")
			print(user.server)
			print(user.uid)
			print(user.subid)
			print(user.secret)
			print("gate Auth ---------------------")
			NetworkMgr:getInstance():GateAuth("127.0.0.1", 3301, user.server, user.uid, user.subid, user.secret)
		end
	end,
	OnGateAuthed = function (self, ... )
		-- body

	end,
	OnGateDisconnected = function (self, ... )
		-- body
	end
}
NetworkMgr:getInstance():RegNetwork(t)
NetworkMgr:getInstance():LoginAuth("127.0.0.1", "3002", server, username, password)

timer.timeout(10, function ( ... )
	-- body
	print("timeout hello")
	NetworkMgr:getInstance().client:send_request("handshake")
end)

while true do 
	NetworkMgr:getInstance():Update()
	timer.update()
end

os.execute("pause")