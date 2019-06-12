local ps = require "xluasocket"
local clientlogin = require "maria.network.clientlogin"
local clientsock = require "maria.network.clientsock"
local list = require "common.list"
local log = require "log"
local assert = assert
local instance
local host = {}
local sockets = {}
local l = list()
local cls = {}

local handler = function (t, id, ud, ... )
	if t == ps.SOCKET_DATA then
		if id == self.login._login_fd then
			local line = tostring(...)
			local ok, err = pcall(clientlogin.login_data, self.login, line)
			if not ok then
				log.error(err)
			end
		elseif id == self.client._gate_fd then
			local pg = tostring	(...)
			local ok, err = pcall(clientsock.gate_data, self.client, pg)
			if not ok then
				log.error(err)
			end
		end
	elseif t == ps.SOCKET_OPEN then
		local subcmd = tostring(...)
		if subcmd == 'transfor' then
			local so = assert(sockets[id])
			so:connected()
		end
	elseif t == ps.SOCKET_CLOSE then
		if id == self.login._login_fd then
			local ok, err = pcall(clientlogin.login_disconnected, self.login)
			if not ok then
				log.error(err)
			end
		elseif id == self.client._gate_fd then
			local ok, err = pcall(clientsock.gate_disconnected, self.client)
			if not ok then
				log.error(err)
			end
		end
	elseif t == ps.SOCKET_ERROR then
	end
end

function cls.Startup( ... )
	-- body
	ps.new(handler)
end

function cls.Cleanup( ... )
	-- body
	ps.exit()
	ps.close()
end

function cls.Update( ... )
	-- body
	ps.poll()
end

function cls.RegNetwork(deleget, ... )
	-- body
	if not deleget then
		log.error("deleget is nil")
		return
	end
	self._l:push_back(deleget)
end

function cls.UnrNetwork(deleget, ... )
	-- body
	self._l:remove(deleget)
end

-- login
function cls.LoginAuth(ip, port, server, u, p, ... )
	-- body
	assert(ip and port and server and u and p)
	local err = self.login:login_auth(ip, port, u, p, server)
	if err == 0 then
		log.info("login auth success.")
	end
	return err
end

function cls.OnLoginConnected(connected, ... )
	-- body
	self._l:foreach(function (i, ... )
		-- body
		i:OnLoginConnected(connected)
	end)
end

function cls.OnLoginAuthed(code, uid, subid, secret, ... )
	-- body

	self._l:foreach(function (i, ... )
		-- body
		if i.OnLoginAuthed then
			i:OnLoginAuthed(code, uid, subid, secret, ... )
		end
	end)
end

function cls.OnLoginDisconnected( ... )
	-- body
	log.info("login disconnected.")
	self._l:foreach(function (i, ... )
		-- body
		i:OnLoginDisconnected(connected)
	end)
end

function cls.OnLoginError( ... )
	-- body
end

-- gate
function cls.GateAuth(ip, port, server, uid, subid, secret, ... )
	-- body
	local so = clientlogin.new()
	local id = self.client:gate_auth(ip, port, server, uid, subid, secret)
	sockets[id] = so
	return id
end

function cls.OnGateAuthed(code, ... )
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

function cls.OnGateDisconnected( ... )
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

function cls.OnGateError()
end

return cls