local NetworkMgr = require "maria.network.NetworkMgr"
local timer = require "timer"

local function run()
	-- body
	-- begain to connect
	local network = NetworkMgr.new()
	network:Startup()
	local username = "hello"
	local password = "Password"
	local server = "sample1"
	local TI = 10000
	local count = 100

	local t = {
		OnLoginAuthed = function (self, code, uid, subid, secret)
			-- body
			assert(self)
			if code == 200 then
				print("OnLoginAuthed ---------------------")
				-- print(user.server)
				-- print(user.uid)
				-- print(user.subid)
				-- print(user.secret)
				print("gate Auth ---------------------")

				network:GateAuth("127.0.0.1", 3301, server, uid, subid, secret)
			end
		end,
		OnGateAuthed = function (self)
			-- body
			assert(self)
			print("OnGateAuthed")
			timer.timeout(network, "timeout", TI)
		end,
		OnGateDisconnected = function (self, ... )
			-- body
		end
	}
	local r = {
		handshake = function (self, responseObj, ... )
			-- body
			print('responseObj ===>', responseObj.errorcode)
		end
	}
	network:RegNetwork(t)
	network.client:register_response("handshake", r.handshake, r)
	network:LoginAuth("127.0.0.1", "3002", server, username, password)

	local function execute(obj, message, arg)
		-- body
		print(timer.now())
		if obj == network then
			if message == "timeout" then
				network.client:send_request("handshake")
				timer.timeout(network, "timeout", TI)
				count = count - 1
			end
		end
	end
	while true do
		network:Update()
		timer.update(1, execute)
		if count <= 0 then
			break
		end
	end
	network:Cleanup()
end

local ok, err = pcall(run)
if not ok then
	print(err)
end
