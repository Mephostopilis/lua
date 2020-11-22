package.path = "./lualib/?.lua;./sproto/?.lua;" .. package.path
package.cpath = "./luaclib/?.dll;" .. package.cpath
local network = require "xnet.manager"
local timer = require "timer.timer"
local table_dump = require "luaTableDump"
local function log(fmt, ...)
	print(string.format(fmt, ...))
end

io.stdout:write("请输入:")
print(io.stdin:lines())

local host = "127.0.0.1"
-- local host = "119.27.191.44"

local function run()
	network.Startup()
	local username = "12311"
	local password = "Password"
	local server = "sample1"

	local c = 0 -- client so
	local subid = 0
	local t = {
		OnDisconnected = function(self, id)
			print("------------")
			log("Disconnected ---------------------")
		end,
		OnLoginAuthed = function(id, code, uid, subid, secret)
			if code == 200 then
				log("OnLoginAuthed ---------------------")
				log("uid = %d", uid)
				log("subid = %d", subid)
				log("secrete = %s", secret)
				log("gate Auth ---------------------")
				local ok, err = pcall(network.GateAuth, host, 3301, server, uid, subid, secret)
				if not ok then
					log(err)
				end
			end
			print("test onLoginaud")
		end,
		OnGateAuthed = function(id) --
			c = id
			log("**OnGateAuthed**")
			-- timer.timeout(network, "timeout", TI)
			local ok = network.Request(id, "enter", {sid = 0})
			if ok < 0 then
				print("err:  not send", ok)
			end
		end,
		handshake = function(requestObj)
			-- log.error("requestObj ===>")
		end,
		base_info = function(id, ty, requestObj)
			if ty == "request" then
				log("[base_info] => %s", table_dump(requestObj))
				subid = requestObj.info.subid
				log("[base_info] => subid =  %d", subid)
			end
		end,
		player_funcs = function(id, ty, requestObj)
			if ty == "request" then
				log("[player_funcs] => %s", table_dump(requestObj))
			end
		end,
		room_info = function(id, ty, requestObj)
			if ty == "request" then
				log("[room_info] => %s", table_dump(requestObj))
			end
		end,
		player_heros = function(id, ty, requestObj)
			log("[player_heros] => %s", table_dump(requestObj))
		end,
		inbox = function(id, ty, requestObj)
			log("[inbox] => %s", table_dump(requestObj))
		end,
		new_name = function(id, ty, requestObj)
			log("[new_name] => %s", table_dump(requestObj))
		end,
		enter = function(id, ty, responseObj)
			if ty == "response" then
				log("[enter] ===> %s", table_dump(responseObj))
				local ok = network.Request(id, "fetch_items", {sid = 0})
				if ok < 0 then
					print("err:  not send", ok)
				end
				local ok = network.Request(id, "create_chat_session", {sid = 0, to = 12})
				if ok < 0 then
					print("err:  not send", ok)
				end
				local ok = network.Request(id, "match", {sid = subid})
				if ok < 0 then
					print("err:  not send", ok)
				end
			end
		end,
		modify_name = function(responseObj)
			log("[modify_name] ===> %s", table_dump(responseObj))
		end,
		user_info = function(responseObj)
			log("[user_info] ===> %s", table_dump(responseObj))
		end,
		fetch_rank_power = function(responseObj)
			log("[fetch_rank_power] ===> %s", table_dump(responseObj))
		end,
		fetch_store_items = function(responseObj)
			log("[fetch_store_items] ===> %s", table_dump(responseObj))
		end,
		fetch_dailytasks = function(responseObj)
			log("[fetch_dailytasks] ===> %s", table_dump(responseObj))
		end,
		fetch_items = function(id, ty, responseObj)
			log("[fetch_items] ===> %s", table_dump(responseObj))
		end,
		create_chat_session = function(id, ty, responseObj)
			log("[create_chat_session] ===> %s", table_dump(responseObj))
		end,
		match = function(id, ty, responseObj)
			log("[match] ===> %s", table_dump(responseObj))
		end
	}

	network.RegNetwork("test", t)
	network.LoginAuth(host, "3002", server, username, password)

	local function execute(obj, message, arg)
		-- print(timer.now())
		if obj == network then
			if message == "timeout" then
				local client = network.GetSo(c)
				if not client then
					log.error("disconnect")
					return
				end
				client:send_request("handshake", {sid = 0})
				timer.timeout(network, "timeout", TI)
				count = count + 1
				if count == 1 then
				elseif count == 2 then
					log.info("send modify_name")
					local client = network.GetSo(c)
					client:send_request("modify_name", {nickname = "lihao"})
				elseif count == 3 then
					local client = network.GetSo(c)
					client:send_request("user_info", {uid = 0})
				elseif count == 4 then
					local client = network.GetSo(c)
					client:send_request("fetch_rank_power", {uid = 0})
				elseif count == 5 then
					local client = network.GetSo(c)
					client:send_request("fetch_store_items", {sid = 0})
				elseif count == 6 then
					local client = network.GetSo(c)
					client:send_request("fetch_dailytasks", {sid = 0})
				elseif count == 7 then
					local client = network.GetSo(c)
					client:send_request("fetch_dailytasks", {sid = 0})
				end
			end
		end
	end
	while true do
		network:Update()
		-- timer.update(10, execute)
	end
	network:Cleanup()
end

local ok, err = pcall(run)
if not ok then
	print(err)
end
