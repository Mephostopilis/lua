local ps = require "xluasocket"
local clientlogin = require "maria.network.clientlogin"
local clientsock = require "maria.network.clientsock"
local list = require "list"
local log = require "log"
local assert = assert

local cls = class("NetworkMgr")

function cls:ctor()
	-- body
	self._l = list()
	self.login = clientlogin.new(self)
	self.client = clientsock.new(self)

	self._g = assert(ps.new(function (id, code, ... )
		-- body
		if code == ps.SOCKET_DATA then
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
		elseif code == ps.SOCKET_CLOSE then
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
		elseif code == ps.SOCKET_ERROR then
		end
	end))

	log.info(tostring(self.login))
	return self
end

function cls:Startup()
	-- body
end

function cls:Cleanup()
	-- body
	self.login:close()
	self.client:close()
end

function cls:Update()
	-- body
	ps.poll(self._g)
end

function cls:RegNetwork(deleget)
	-- body
	if not deleget then
		log.error("deleget is nil")
		return
	end
	self._l:push_back(deleget)
end

function cls:UnrNetwork(deleget)
	-- body
	self._l:remove(deleget)
end

function cls:LoginAuth(ip, port, server, u, p)
	-- body
	assert(ip and port and server and u and p)
	local err = self.login:login_auth(ip, port, u, p, server)
	if err == 0 then
		log.info("login auth success.")
	end
	return err
end

function cls:OnLoginConnected(connected)
	-- body
	self._l:foreach(function (i)
		-- body
		i:OnLoginConnected(connected)
	end)
end

function cls:OnLoginAuthed(code, uid, subid, secret)
	-- body

	self._l:foreach(function (i, ... )
		-- body
		if i.OnLoginAuthed then
			i:OnLoginAuthed(code, uid, subid, secret, ... )
		end
	end)
end

function cls:OnLoginDisconnected()
	-- body
	log.info("login disconnected.")
	self._l:foreach(function (i)
		-- body
		i:OnLoginDisconnected()
	end)
end

function cls:OnLoginError()
	-- body
	assert(self)
end

function cls:GateAuth(ip, port, server, uid, subid, secret)
	-- body
	local err = self.client:gate_auth(ip, port, server, uid, subid, secret)
	return err
end

function cls:OnGateAuthed(code)
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

function cls:OnGateDisconnected( ... )
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

return cls