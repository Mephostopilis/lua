local ps = require "xluasocket"
local log = require "lib.log"
local clientlogin = require "lib.network.clientlogin"
local clientsock = require "lib.network.clientsock"
local assert = assert
local sockets = {}
local delegets = {}
local _M = {}

local handler = function(t, id, ud, ...)
	if t == ps.SOCKET_DATA then
		local so = assert(sockets[id])
		local line = tostring(...)
		local ok, err = pcall(so.data, so, line)
		if not ok then
			log.error(err)
		end
	elseif t == ps.SOCKET_OPEN then
		local subcmd = tostring(...)
		log.info("socket open subcmd = [%s]", subcmd)
		if subcmd == "transfor" then
		else
			local so = assert(sockets[id])
			local ok, err = pcall(so.connected, so)
			if not ok then
				log.error(err)
			end
		end
	elseif t == ps.SOCKET_CLOSE then
		local so = assert(sockets[id])
		local ok, err = pcall(so.disconnected, so)
		if not ok then
			log.error(err)
		end
	elseif t == ps.SOCKET_ERROR then
	end
end

function _M.Startup()
	log.info("------------------------------------------------------")
	log.info("-----------------network manager startup")
	ps.new(handler)
end

function _M.Cleanup()
	-- for k, so in pairs(sockets) do
	-- 	so:close()
	-- end
	ps.exit()
	ps.close()
	log.info("------------------------------------------------------")
	log.info("-----------------network manager cleanup")
end

function _M.Update()
	ps.poll()
end

function _M.RegNetwork(module, t)
	assert(type(t) == "table")
	for k, v in pairs(t) do
		local cb = delegets[k]
		if not cb then
			cb = {}
			delegets[k] = cb
		end
		cb[module] = t
	end
end

function _M.UnrNetwork(module)
end

function _M.Send(id, name, args)
	local so = sockets[id]
	if so then
		so:send_request(name, args)
	end
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
	local so = assert(sockets[id])
	local cb = delegets["OnLoginAuthed"]
	if cb then
		for module, t in pairs(cb) do
			t.OnLoginAuthed(so, code, uid, subid, secret)
		end
	end
end

function _M.OnLoginDisconnected(id)
	local so = assert(sockets[id])
	local cb = delegets["OnLoginDisconnected"]
	if cb then
		for module, t in pairs(cb) do
			local func = t.OnLoginDisconnected
			pcall(func, so)
		end
	end
	sockets[id] = nil
end

function _M.OnLoginError(id)
end

-- gate
function _M.GateAuth(ip, port, server, uid, subid, secret)
	local so = clientsock(_M, ip, port, server, uid, subid, secret)
	if so then
		sockets[so.fd] = so
	end
end

function _M.OnGateAuthed(id, code)
	print(id)
	local cb = delegets["OnGateAuthed"]
	if cb then
		for module, t in pairs(cb) do
			t.OnGateAuthed(id, code)
		end
	end
end

function _M.OnGateData(id, type, name, args)
	local cb = delegets[name]
	if cb then
		for module, t in pairs(cb) do
			t[name](id, type, args)
		end
	end
end

function _M.OnGateDisconnected(id)
	local cb = delegets["OnGateDisconnected"]
	if cb then
		for module, t in pairs(cb) do
			t.OnGateDisconnected(id)
		end
	end
	sockets[id] = nil
end

function _M.OnGateError()
end

return _M
