local ps = require "xluasocket"
local clientlogin = require "maria.network.clientlogin"
local clientsock = require "maria.network.clientsock"
local log = require "log"
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
	-- body
	ps.new(handler)
end

function _M.Cleanup()
	-- body
	ps.exit()
	ps.close()
end

function _M.Update()
	-- body
	ps.poll()
end

function _M.RegNetwork(t)
	-- body
	assert(type(t) == "table")
	delegets[t] = true
end

function _M.UnrNetwork(t)
	-- body
	delegets[t] = nil
end

function _M.GetSo(id)
	return sockets[id]
end

function _M.CloseSo(id)
	if sockets[id] then
		ps.closesocket(id)
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
	for k, _ in pairs(delegets) do
		k.OnLoginAuthed(k, id, code, uid, subid, secret)
	end
end

function _M.OnLoginDisconnected(id)
	assert(sockets[id])
	sockets[id] = nil
	for k, _ in pairs(delegets) do
		local func = k.OnLoginDisconnected
		if func then
			pcall(func, k, id)
		end
	end
end

function _M.OnLoginError(id)
	-- body
end

-- gate
function _M.GateAuth(ip, port, server, uid, subid, secret)
	-- body
	local so = clientsock(_M, ip, port, server, uid, subid, secret)
	if so then
		sockets[so.fd] = so
	end
end

function _M.OnGateAuthed(id, code)
	log.info("NetworkMgr OnGateAuthed")
	for k, _ in pairs(delegets) do
		k.OnGateAuthed(k, id, code)
	end
end

function _M.OnGateDisconnected(id)
	-- body
	assert(sockets[id])
	sockets[id] = nil
	for k, _ in pairs(delegets) do
		k.OnGateDisconnected(k, id)
	end
end

function _M.OnGateError()
end

return _M
