local root = "D:\\github\\lua\\hello\\src"
package.path = root .. "\\?.lua;" .. root .. "\\?\\init.lua;" .. package.path
package.path = root .. "\\lualib\\?.lua;" .. root .. "\\?\\init.lua;" .. package.path
package.path = root .. "\\lualib\\entitas\\?.lua;" .. root .. "\\entitas\\?\\init.lua;" .. package.path

-- require "test.queue_test"

-- print("hello world.")

require "main"
local NetworkMgr = require "maria.network.NetworkMgr"
local User = require "maria.module.User"

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
			print(user.server)
			print(user.uid)
			print(user.subid)
			print(user.secret)
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


while true do 
	NetworkMgr:getInstance():Update()
end

os.execute("pause")