local ps = require "xluasocket"
local clientlogin = require "maria.network.clientlogin"
local clientsock = require "maria.network.clientsock"
local log = require "log"
local assert = assert
local host = {}
local sockets = {}
local delegets = {}

local _M = {}

local handler = function (t, id, ud, ... )
	if t == ps.SOCKET_DATA then
		local so = assert(sockets[id])
		local line = tostring(...)
		local ok, err = pcall(so.data, so, line)
		if not ok then
			log.error(err)
		end
	elseif t == ps.SOCKET_OPEN then
		local subcmd = tostring(...)
		if subcmd == 'transfor' then
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

function _M.Startup( ... )
	-- body
	ps.new(handler)
end

function _M.Cleanup( ... )
	-- body
	ps.exit()
	ps.close()
end

function _M.Update( ... )
	-- body
	ps.poll()
end

function _M.RegNetwork(deleget, ... )
	-- body
	if not deleget then
		log.error("deleget is nil")
		return
	end
	delegets[deleget] = true
end

function _M.UnrNetwork(deleget, ... )
	-- body
	if not deleget then
		log.error("deleget is nil")
		return
	end
	delegets[deleget] = nil
end

-- login
function _M.LoginAuth(ip, port, server, u, p, ... )
	-- body
	assert(ip and port and server and u and p)
	local err = self.login:login_auth(ip, port, u, p, server)
	if err == 0 then
		log.info("login auth success.")
	end
	return err
end

function _M.OnLoginConnected(connected, ... )
	-- body
	self._l:foreach(function (i, ... )
		-- body
		i:OnLoginConnected(connected)
	end)
end

function _M.OnLoginAuthed(code, uid, subid, secret, ... )
	-- body

	self._l:foreach(function (i, ... )
		-- body
		if i.OnLoginAuthed then
			i:OnLoginAuthed(code, uid, subid, secret, ... )
		end
	end)
end

function _M.OnLoginDisconnected( ... )
	-- body
	log.info("login disconnected.")
	self._l:foreach(function (i, ... )
		-- body
		i:OnLoginDisconnected(connected)
	end)
end

function _M.OnLoginError( ... )
	-- body
end

-- gate
function _M.GateAuth(ip, port, server, uid, subid, secret, ... )
	-- body
	local so = clientlogin.new()
	local id = self.client:gate_auth(ip, port, server, uid, subid, secret)
	sockets[id] = so
	return id
end

function _M.OnGateAuthed(code, ... )
	-- body
	log.info("NetworkMgr OnGateAuthed")
	self._l:foreach(function (i, ... )
		-- body
		if i['OnGateAuthed'] then
			i:OnGateAuthed(code)
		else
			log.error("[%s] don't contains OnGateAuthed.", tostring(i))
		end
	end)
end

function _M.OnGateDisconnected( ... )
	-- body
	self._l:foreach(function (i, ... )
		-- body
		if i['OnGateDisconnected'] then
			i:OnGateDisconnected()
		else
			log.error("[%s] don't contains OnGateDisconnected", tostring(i))
		end
	end)
end

function _M.OnGateError()
end

return _M