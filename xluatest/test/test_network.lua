local network = require "maria.network.NetworkMgr"
local timer = require "timer"
local log = require 'log'

local function run()
	-- body
	-- begain to connect
	
	network.Startup()
	local username = "12311"
	local password = "Password"
	local server = "sample1"
	local TI = 10000
	local count = 5
	local c = 0

	local req = {
		handshake = function (self, requestObj, ... )
			-- body
			log.error('requestObj ===>')
		end
	}
	local r = {
		handshake = function (self, responseObj, ... )
			-- body
			log.error('responseObj ===>', responseObj.errorcode)
		end
	}

	local t = {
		OnLoginAuthed = function (self, id, code, uid, subid, secret)
			-- body
			assert(self)
			if code == 200 then
				log.info("OnLoginAuthed ---------------------")
				-- print(user.server)
				log.info("%d", uid)
				log.info("%d", subid)
				log.info("%s", secret)
				log.info("gate Auth ---------------------")
				local ok, err = pcall(network.GateAuth, "119.27.191.44", 3301, server, uid, subid, secret)
				if not ok then
					log.error(err)
				end
			end
		end,
		OnLoginDisconnected = function (self, id)
			log.info("OnLoginDisconnected ---------------------")
		end,
		OnGateAuthed = function (self, id)
			-- body
			assert(self)
			c = id
			log.info("OnGateAuthed")
			local so = network.GetSo(c)
			for k,v in pairs(r) do
				so:register_response(k, v, r)	
			end
			for k,v in pairs(req) do
				so:regiseter_request(k, v, r)	
			end
			timer.timeout(network, "timeout", TI)
		end,
		OnGateDisconnected = function (self, id, ... )
			-- body
			log.info("OnGateDisconnected ---------------------")
		end
	}
	
	network.RegNetwork(t)
	-- network.client:register_response("handshake", r.handshake, r)
	network.LoginAuth("119.27.191.44", "3002", server, username, password)

	local function execute(obj, message, arg)
		-- body
		-- print(timer.now())
		if obj == network then
			if message == "timeout" then
				count = count - 1
				if count > 0 then
					local client = network.GetSo(c)
					client:send_request("handshake")
					timer.timeout(network, "timeout", TI)
				end
			end
		end
	end
	while true do
		network:Update()
		timer.update(10, execute)
	end
	network:Cleanup()
end

local ok, err = pcall(run)
if not ok then
	print(err)
end
