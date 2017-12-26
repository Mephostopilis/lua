local root = ".\\..\\..\\..\\..\\hello\\src"
package.path = root .. "\\?.lua;" .. root .. "\\?\\init.lua;" .. package.path
package.path = root .. "\\lualib\\?.lua;" .. root .. "\\?\\init.lua;" .. package.path
package.path = root .. "\\lualib\\entitas\\?.lua;" .. root .. "\\entitas\\?\\init.lua;" .. package.path

-- require "test.queue_test"

-- print("hello world.")

require "main"
local NetworkMgr = require "maria.network.NetworkMgr"
local User = require "maria.module.User"

print("hello")
-- begain to connect
local username = "hello"
local password = "workd"
local server = "sample"


local user = User.new()
user.username = username
user.password = password
user.server = server
NetworkMgr:getInstance():RegNetwork(user)

NetworkMgr:getInstance():LoginAuth("127.0.0.1", "3002", server, username, password)

while true do 
	NetworkMgr:getInstance():Update()
end

os.execute("pause")