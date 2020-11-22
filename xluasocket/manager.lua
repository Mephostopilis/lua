local ps = require "xluasocket"
local clientlogin = require "xnet.clientlogin"
local clientsock = require "xnet.clientsock"
local server = require "xnet.server"
local assert = assert
local sockets = {}
local delegets = {}
local _M = {}

local handler = function(t, id, ud, ...)
	if t == ps.SOCKET_DATA then
		print("-=---------------------------")
		local so = assert(sockets[id])
		local ok, err = pcall(so.data, so, ud)
		if not ok then
			print(err)
		end
	elseif t == ps.SOCKET_OPEN then
		local subcmd = tostring(...)
		if subcmd == "transfor" then
		elseif subcmd == "start" then
		else
			print("socket open :", subcmd)
			local so = assert(sockets[id])
			so:connected()
		end
	elseif t == ps.SOCKET_ACCEPT then
		print("sokcet accept [id = %d][acc = %d]", id, ud)
		sockets[ud] = server(_M, ud)
		ps.start(ud)
	elseif t == ps.SOCKET_CLOSE then
		local so = assert(sockets[id])
		local ok, err = pcall(so.disconnected, so)
		if not ok then
			print(err)
		end
	elseif t == ps.SOCKET_ERROR then
	end
end

function _M.Startup()
	print("------------------------------------------------------")
	print("-----------------network manager startup")
	ps.init(handler)
end

function _M.Cleanup()
	-- for k, so in pairs(sockets) do
	-- 	so:close()
	-- end
	ps.exit()
	while ps.poll() == 0 do
	end
	ps.free()
	print("------------------------------------------------------")
	print("-----------------network manager cleanup")
end

function _M.Update()
	for i = 10, 1, -1 do
		-- ps.poll()
		if ps.poll() == 1 then
			break
		end
	end
end

function _M.RegNetwork(name, module)
	assert(type(module) == "table")
	for k, _ in pairs(module) do
		local modules = delegets[k]
		if not modules then
			modules = {}
			delegets[k] = modules
		end
		modules[name] = module
	end
end

function _M.Request(id, name, args)
	local so = assert(sockets[id])
	if so and so.ty == "client" then
		return so:send_request(name, args)
	else
		return -2
	end
end

-- server
function _M.Listen(addr, port)
	addr = addr or "0.0.0.0"
	port = port or 3300
	local s = ps.listen(addr, 3300)
	if s < 0 then
		error(string.format("id = %d listen failture.", s))
	else
		ps.start(s)
		print(string.format("id = %d listen", s))
	end
	return s
end

function _M.OnData(id, type, name, args)
	local cb = delegets[name]
	if cb then
		for module, t in pairs(cb) do
			local f = assert(t[name])
			local ok, err = pcall(f, id, type, args)
			if not ok then
				print(err)
			end
		end
	else
		print(name, "------------")
	end
end

function _M.OnDisconnected(id)
	local so = assert(sockets[id])
	local modules = delegets["OnDisconnected"]
	if modules then
		for _, module in pairs(modules) do
			local func = assert(module.OnDisconnected)
			pcall(func, so)
		end
	end
	sockets[id] = nil
end

function _M.OnError(id)
	local so = assert(sockets[id])
	so:close()
end

-- login
function _M.LoginAuth(ip, port, server, u, p)
	assert(ip and port and server and u and p)
	local so = clientlogin(_M, ip, port, u, p, server)
	if so then
		sockets[so.fd] = so
	end
end

function _M.OnLoginAuthed(id, code, uid, subid, secret)
	print("------------------------OnLoginAuthed", id, code)
	local so = assert(sockets[id])
	local cb = delegets["OnLoginAuthed"]
	if cb then
		for module, t in pairs(cb) do
			t.OnLoginAuthed(id, code, uid, subid, secret)
		end
	end
end

-- gate
function _M.GateAuth(ip, port, server, uid, subid, secret)
	local so = clientsock(_M, ip, port, server, uid, subid, secret)
	if so then
		sockets[so.fd] = so
	end
end

function _M.OnGateAuthed(id, code)
	print("------------------------OnGateAuthed", id, code)
	local cb = delegets["OnGateAuthed"]
	if cb then
		for name, module in pairs(cb) do
			local f = assert(module.OnGateAuthed)
			pcall(f, id, code)
		end
	end
end

return _M
