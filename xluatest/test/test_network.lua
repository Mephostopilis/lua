local network = require "maria.network.NetworkMgr"
local timer = require "timer"
local log = require "log"
local table_dump = require "luaTableDump"

local function run()
	-- body
	-- begain to connect

	network.Startup()
	local username = "12311"
	local password = "Password"
	local server = "sample1"
	local TI = 10000
	local count = 0
	local l = 0 -- login so
	local c = 0 -- client so

	local req = {
		handshake = function(requestObj)
			-- log.error("requestObj ===>")
		end,
		base_info = function(requestObj)
			log.error("[base_info] => %s", table_dump(requestObj))
		end,
		room_info = function(requestObj)
			log.error("[room_info] => %s", table_dump(requestObj))
		end,
		player_funcs = function(requestObj)
			log.error("[player_funcs] => %s", table_dump(requestObj))
		end,
		player_heros = function(requestObj)
			log.error("[player_heros] => %s", table_dump(requestObj))
		end,
		new_name = function(responseObj)
			log.error("[new_name] => %s", table_dump(requestObj))
		end
	}
	local resp = {
		handshake = function(responseObj)
			-- log.error("[handshake] ===> %s", table_dump(responseObj))
		end,
		enter = function(responseObj)
			log.error("[enter] ===> %s", table_dump(responseObj))
		end,
		modify_name = function(responseObj)
			log.error("[modify_name] ===> %s", table_dump(responseObj))
		end
	}

	local t = {
		OnLoginAuthed = function(self, id, code, uid, subid, secret)
			-- body
			assert(self)
			l = id
			if code == 200 then
				log.info("OnLoginAuthed ---------------------")
				log.info("uid = %d", uid)
				log.info("subid = %d", subid)
				log.info("secrete = %s", secret)
				log.info("gate Auth ---------------------")
				local ok, err = pcall(network.GateAuth, "119.27.191.44", 3301, server, uid, subid, secret)
				if not ok then
					log.error(err)
				end
			end
		end,
		OnLoginDisconnected = function(self, id)
			log.info("OnLoginDisconnected ---------------------")
		end,
		OnGateAuthed = function(self, id)
			assert(self)
			-- 删除login so
			network.CloseSo(l)
			--
			c = id
			log.info("OnGateAuthed")
			local so = network.GetSo(c)
			for k, v in pairs(resp) do
				so:register_response(k, v, resp)
			end
			for k, v in pairs(req) do
				so:regiseter_request(k, v, req)
			end
			timer.timeout(network, "timeout", TI)
			so:send_request("enter")
		end,
		OnGateDisconnected = function(self, id, ...)
			log.info("OnGateDisconnected ---------------------")
		end
	}

	network.RegNetwork(t)
	network.LoginAuth("119.27.191.44", "3002", server, username, password)

	local function execute(obj, message, arg)
		-- print(timer.now())
		if obj == network then
			if message == "timeout" then
				local client = network.GetSo(c)
				client:send_request("handshake")
				timer.timeout(network, "timeout", TI)
				count = count + 1
				if count == 1 then
				elseif count == 2 then
					log.info("send modify_name")
					local client = network.GetSo(c)
					client:send_request("modify_name", {nickname = "nickname"})
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
