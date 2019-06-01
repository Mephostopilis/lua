package.cpath = "luaclib/?.so;"..package.cpath
package.path = "../../test/?.lua;lualib/?.lua;"..package.path

local socket = require "clientsocket"
local crypt = require "crypt"
local proto = require "proto"
local sproto = require "sproto"

if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end

local fd = assert(socket.connect("192.168.1.104", 3002))

local function writeline(fd, text)
	socket.send(fd, text .. "\n")
end

local function unpack_line(text)
	local from = text:find("\n", 1, true)
	if from then
		return text:sub(1, from-1), text:sub(from+1)
	end
	return nil, text
end

local last = ""

local function unpack_f(f)
	local function try_recv(fd, last)
		local result
		result, last = f(last)
		if result then
			return result, last
		end
		local r = socket.recv(fd)
		if not r then
			return nil, last
		end
		if r == "" then
			error "Server closed"
		end
		return f(last .. r)
	end

	return function()
		while true do
			local result
			result, last = try_recv(fd, last)
			if result then
				return result
			end
			socket.usleep(100)
		end
	end
end

local readline = unpack_f(unpack_line)
-- 0
--local cha = crypt.base64decode(readline())
-- print(readline())

-- 1. get challenge
local challenge = crypt.base64decode(readline())

-- 2. generate clientkey
local clientkey = crypt.randomkey()

-- 3. send clientkey to server
writeline(fd, crypt.base64encode(crypt.dhexchange(clientkey)))

-- 4. achieve secret.

local secret = crypt.dhsecret(crypt.base64decode(readline()), clientkey)

print("sceret is ", crypt.hexencode(secret))

-- 5. check secret.
local hmac = crypt.hmac64(challenge, secret)
writeline(fd, crypt.base64encode(hmac))

-- 6. (optionl) readline server
-- 
-- writeline(fd, "get_servers")
-- local proto = [[
-- 	.server {
-- 		.node {
-- 			name 0 : string
-- 			address 1 : string
-- 		}
-- 		nodes 0 : *node
-- 	}
-- ]]
-- local sp = sproto.parse(proto)
-- local servers = sp:decode("server", readline())
-- for k,v in pairs(servers) do
-- 	print(k,v)
-- end
--print(readline())

local p = {...}
local token = {
	server = p[1] or "sample",
	user = p[2] or "123",
	pass = p[3] or "123",
}

local function encode_token(token)
	return string.format("%s@%s:%s",
		crypt.base64encode(token.user),
		crypt.base64encode(token.server),
		crypt.base64encode(token.pass))
end

local etoken = crypt.desencode(secret, encode_token(token))
local b = crypt.base64encode(etoken)

-- 7. auth
writeline(fd, crypt.base64encode(etoken))

local result = readline()
print(result)
local code = tonumber(string.sub(result, 1, 3))
assert(code == 200)
socket.close(fd)

-- 8. subid
local uid = crypt.base64decode(string.sub(result, 6, 9))
local subid = crypt.base64decode(string.sub(result, 11, 14))
print("login ok, subid=", subid, "uid=", uid)

----- connect to game server

local host = sproto.new(proto.s2c):host "package"
local request = host:attach(sproto.new(proto.c2s))

--local function send_package(fd, pack)
--	local package = string.pack(">s2", pack)
--	socket.send(fd, package)
--end

local c2s_req_tag  = 1 << 0
local c2s_resp_tag = 1 << 1
local s2c_req_tag  = 1 << 2
local s2c_resp_tag = 1 << 3

local function send_request_b(v, session)
	local size = #v + 4 + 1
	local package = string.pack(">I2", size)..v..string.pack(">I4", session)..string.pack("B", c2s_req_tag)
	print("size is", size, "actual size is", #package)
	socket.send(fd, package)
	return v, session
end

local function recv_response(v)
	local size = #v - 5
	local content, session, tag = string.unpack("c"..tostring(size)..">I4B", v)
	return tag, session, content
end

local function unpack_package(text)
	local size = #text
	if size < 2 then
		return nil, text
	end
	local s = text:byte(1) * 256 + text:byte(2)
	if size < s+2 then
		return nil, text
	end

	return text:sub(3,2+s), text:sub(3+s)
end

local readpackage = unpack_f(unpack_package)

local function send_package(fd, pack)
	local package = string.pack(">s2", pack)
	socket.send(fd, package)
end

local session = 0

local function send_request(name, args)
	session = session + 1
	local str = request(name, args, session)
	-- str = crypt.desencode(secret, str)
	-- str = crypt.base64encode(str)
	--send_package(fd, str)
	send_request_b(str, session)
	print("Request:", session)
end

local function print_request(name, args)
	print("REQUEST", name)
	if args then
		for k,v in pairs(args) do
			print(k,v)
		end
	end
end

local function print_response(session, args)
	print("RESPONSE", session)
	if args then
		for k,v in pairs(args) do
			print(k,v)
		end
	end
end

local function print_package(t, ...)
	if t == "REQUEST" then
		print_request(...)
	else
		assert(t == "RESPONSE")
		print_response(...)
	end
end

local function recv_package(last)
	local result
	result, last = unpack_package(last)
	if result then
		return result, last
	end
	local r = socket.recv(fd)
	if not r then
		return nil, last
	end
	if r == "" then
		error "Server closed"
	end
	return unpack_package(last .. r)
end

local function dispatch_package()
	while true do
		local v
		v, last = recv_package(last)
		if not v then
			break
		end
		local tag, session, content = recv_response(v)
		if tag == c2s_resp_tag then
			print("tag is", tag, "session is", session)
			-- local str = crypt.base64decode(content)
			-- str = crypt.desdecode(secret, str)
			print_package(host:dispatch(content))
		end
	end
end

--local text = "echo"
local index = 1

print("connect")
fd = assert(socket.connect("192.168.1.104", 3301))
last = ""

local handshake = string.format("%s@%s#%s:%d", crypt.base64encode(uid), crypt.base64encode(token.server),crypt.base64encode(subid) , index)
local hmac = crypt.hmac64(crypt.hashkey(handshake), secret)

-- send handshake
send_package(fd, handshake .. ":" .. crypt.base64encode(hmac))

print(readpackage())


while true do
	dispatch_package()
	local cmd = socket.readstdin()
	if cmd then
		if cmd == "quit" then
			send_request("quit")
		elseif cmd == "corefight" then
			send_request("BeginGUQNQIACoreFight", {monsterid = 1001})
		elseif cmd == "role_info" then
			send_request(cmd, { role_id = 1})
		elseif cmd == "mails" then
			send_request(cmd)
		elseif cmd == "user" then
			send_request(cmd)
		elseif cmd == "get" then
			send_request("get", { what = cmd })
		elseif cmd == "handshake" then
			send_request(cmd)
		elseif cmd == "reward" then
			send_request( "lilian_get_reward_list" , { quanguan_id = 1}  )
		elseif cmd == "lilian" then
			send_request( "get_lilian_info" )
		elseif cmd == "start_lilian" then
			send_request( "start_lilian" , { quanguan_id = 1 , invitation_id = 50001 } )
		elseif cmd == "kungfu" then
			send_request( cmd )
		elseif cmd == "klevelup" then
			send_request( "kungfu_levelup" , { k_csv_id = 1001 , k_level = 1 , k_type = 1 } )
		elseif cmd == "role" then
			send_request(cmd, { role_id = 1})
		elseif cmd == "upgrade" then
			send_request(cmd, { role_id = 1})
		elseif cmd == "choose_role" then
			send_request(cmd, { role_id = 1})
		elseif cmd == "wake" then
			send_request(cmd, { role_id = 1})
		elseif cmd == "props" then
			send_request(cmd)
		elseif cmd == "use_prop" then
			send_request(cmd, { props = {{ csv_id = 1, num = 1}}, role_id = 2})
		elseif cmd == "achievement" then
			send_request(cmd)
		elseif cmd == "channel" then
			send_request(cmd)
		elseif cmd == "login" then
			send_request("login", { account = "zzzzx" , password = "zzzzx" })
		elseif cmd == "signup" then
			send_request("signup", { account = "hello46" , password = "world2" })
		elseif cmd == "role_upgrade_star" then
			send_request("role_upgrade_star", { role_csv_id=1})
		elseif cmd == "user_can_modify_name" then
			send_request("user_can_modify_name")
		elseif cmd == "user_modify_name" then
			send_request("user_modify_name", { name = "wahah"})
		elseif cmd == "user" then
			send_request("user")
		elseif cmd == "user" then
			send_request("user")
		elseif cmd == "user_upgrade" then
			send_request("user_upgrade")
		elseif cmd == "recharge_all" then
			send_request("recharge_all")
		elseif cmd == "recharge_purchase" then
			send_request(cmd, { g = {{ csv_id = 1101, num = 1 }}})
		elseif cmd == "recharge_collect" then
			send_request(cmd)
		elseif cmd == "shop_all" then
			send_request(cmd)
		elseif cmd == "shop_refresh" then
			send_request(cmd, { goods_id=1001})
		elseif cmd == "shop_purchase" then
			send_request(cmd, { g = {{ goods_id = 1001, goods_num = 1 }}})
		elseif cmd == "fl" then
			send_request( "friend_list" )
		elseif cmd == "applied" then
			send_request( "applied_list" )
		elseif cmd == "other" then
			send_request( "otherfriend_list" )
		elseif cmd == "apply" then
			send_request( "applyfriend" , { friendlist = {  {  signtime = 0 , friendid = 5 , type = 1 } }  } )
		elseif cmd == "find" then
			send_request( "findfriend" , { friendid = 6 } )
		elseif cmd == "delete" then
			send_request( "deletefriend" , { friendid = 1 } ) 
		elseif cmd == "send" then
			send_request( "sendheart" , { totalamount = 3 , hl = { { } }} )
		elseif cmd == "recv" then
			send_request( "recvheart" , {})
		elseif cmd == "logout" then
			send_request( "logout" )
		elseif cmd == "draw" then
			send_request( "draw" )
		elseif cmd == "applydraw1" then
			send_request( "applydraw" , { drawtype = 1 , iffree = false } )
		elseif cmd == "applydraw2" then
			send_request( "applydraw" , { drawtype = 2 , iffree = false } )
		elseif cmd == "applydraw3" then
			send_request( "applydraw" , { drawtype = 3 , iffree = false } )
		elseif cmd == "checkin" then
			send_request( "checkin" )
		elseif cmd == "aday" then
			send_request( "checkin_aday" )
		elseif cmd == "reward" then
			send_request( "checkin_reward" )
		elseif cmd == "exercise" then
			send_request("exercise" )
		elseif cmd == "eonce" then
			send_request("exercise_once" , { daily_type = 1 , exercise_type = 1 , exercise_level = 0 } )
		elseif cmd == "equipment_all" then
			send_request("equipment_all")
		elseif cmd == "equipment_enhance" then
			send_request("equipment_enhance", { csv_id=1 })
		elseif cmd == "role_all" then
			send_request(cmd)
		elseif cmd == "role_recruit" then
			send_request(cmd, { csv_id=4})
		elseif cmd == "role_battle" then
			send_request(cmd, { csv_id=4})
		elseif cmd == "user_sign" then
			send_request(cmd, { sign="abc"})
		elseif cmd == "user_random_name" then
			send_request(cmd)
		elseif cmd == "recharge_vip_reward_purchase" then
			send_request(cmd, { vip = 1})
		elseif cmd == "ara_bat_ovr" then
			send_request(cmd, { win=1})
		elseif cmd == "ara_bat_clg" then
			send_request(cmd, { role_id1=1, role_id2=2, role_id3=3})
		elseif cmd == "ara_rfh" then
			send_request(cmd)
		elseif cmd == "ara_clg_tms_purchase" then
			send_request(cmd)
		elseif cmd == "ara_worship" then
			send_request(cmd, { uid=328})
		elseif cmd == "ara_rnk_reward_collected" then
			send_request(cmd)
		elseif cmd == "ara_convert_pts" then
			send_request(cmd, { pts=2})
		end
	else
		socket.usleep(100)
	end
end

--print(readpackage())
--print("===>",send_request(text,0))
-- don't recv response
-- print("<===",recv_response(readpackage()))

print("disconnect")
socket.close(fd)

--index = index + 1

--print("connect again")
--fd = assert(socket.connect("127.0.0.1", 8888))
--last = ""

--local handshake = string.format("%s@%s#%s:%d", crypt.base64encode(token.user), crypt.base64encode(token.server),crypt.base64encode(subid) , index)
--local hmac = crypt.hmac64(crypt.hashkey(handshake), secret)

--send_package(fd, handshake .. ":" .. crypt.base64encode(hmac))



--print(readpackage())
--print("===>",send_request("fake",0))	-- request again (use last session 0, so the request message is fake)
--print("===>",send_request("again",1))	-- request again (use new session)
--print("<===",recv_response(readpackage()))
--print("<===",recv_response(readpackage()))


--print("disconnect")
--socket.close(fd)

