local ps = require "xluasocket"
local clientlogin = require "maria.network.clientlogin"
local clientsock = require "maria.network.clientsock"
local list = require "list"
local assert = assert
local instance

local cls = class("NetworkMgr")

function cls.getInstance( ... )
	-- body
	if not instance then
		instance = cls.new( ... )
	end
	return instance
end

function cls:ctor( ... )
	-- body
	self._g = assert(ps.new())
	self._l = list.new()
	self._login = nil
	self._client = nil

	return self
end

function cls:Startup( ... )
	-- body
end

function cls:Cleanup( ... )
	-- body
end

function cls:Update( ... )
	-- body
	ps.poll(self._g)
end

function cls:RegNetwork(deleget, ... )
	-- body
	self._l:push_back(deleget)
end


function cls:UnrNetwork(deleget, ... )
	-- body
	self._l:remove(deleget)
end

function cls:LoginAuth(ip, port, server, u, p, ... )
	-- body
	assert(ip and port and server and u and p)
	self._login = clientlogin.new(self)
	local err = self._login:login_auth(ip, port, u, p, server)
	if err ~= 0 then
		self._login = nil
	end
	return err
end

function cls:OnLoginConnected(connected, ... )
	-- body
	self._l:foreach(function (i, ... )
		-- body
		i:OnLoginConnected(connected)
	end)
end

function cls:OnLoginAuthed(code, uid, subid, secret, ... )
	-- body
	self._l:foreach(function (i, ... )
		-- body
		i:OnLoginAuthed(code, uid, subid, secret, ... )
	end)
end

function cls:OnLoginDisconnected( ... )
	-- body
	print("login disconnected.")
	self._l:foreach(function (i, ... )
		-- body
		i:OnLoginDisconnected(connected)
	end)
end

function cls:OnLoginError( ... )
	-- body
end

function cls:GateAuth(ip, port, server, uid, subid, secret, ... )
	-- body
	self._client = clientsock.new(self)
	return self._client:gate_auth(ip, port, server, uid, subid, secret)
end


function cls:OnGateAuthed(code, ... )
	-- body
	self._l:foreach(function (i, ... )
		-- body
		i:OnGateAuthed(connected)
	end)
end

function cls:OnGateDisconnected( ... )
	-- body
	self._l:foreach(function (i, ... )
		-- body
		i:OnGateDisconnected(connected)
	end)
end

return cls