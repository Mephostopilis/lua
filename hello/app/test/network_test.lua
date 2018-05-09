local NetworkMgr = require "maria.network.NetworkMgr"
local timer = require "timer"

local function run()
	-- body
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
			print("OnGateAuthed")
			timer.timeout(NetworkMgr:getInstance(), "timeout", 10)
		end,
		OnGateDisconnected = function (self, ... )
			-- body
		end
	}
	NetworkMgr:getInstance():RegNetwork(t)
	NetworkMgr:getInstance():LoginAuth("127.0.0.1", "3002", server, username, password)

	local function execute(obj, message, arg, ... )
		-- body
		print(timer.now())
		if obj == NetworkMgr:getInstance() then
			if message == "timeout" then
				NetworkMgr:getInstance().client:send_request("handshake")
			end
		end
	end
	while true do 
		NetworkMgr:getInstance():Update()
		timer.update(1, execute)
	end
end

local ok, err = pcall(run)
if not ok then
	print(err)
end
