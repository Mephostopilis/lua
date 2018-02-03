local timer = require "maria.timer"
local NetworkMgr = require "maria.network.NetworkMgr"
local log = require "log"
local cls = class("InitService")

function cls:ctor( ... )
	-- body
	self._authed = false
end

function cls:Startup( ... )
	-- body
	NetworkMgr:getInstance():RegNetwork(self)
	log.info("init service Startup")
end

function cls:Cleanup( ... )
	-- body
end

function cls:OnLoginAuthed( ... )
	-- body
end

function cls:OnGateAuthed(code, ... )
	-- body
	if code == 200 then
		self._authed = true
		timer.timeout(5, function ( ... )
			-- body
			self:Handshake()
		end)
	end
end

function cls:OnGateDisconnected( ... )
	-- body
	self._authed = false
end

function cls:Handshake( ... )
	-- body
	if self._authed then
		local networkMgr = NetworkMgr:getInstance()
		local client = networkMgr.client
		client:send_request("handshake")
		timer.timeout(5, function ( ... )
			-- body
			self:Handshake()
		end)
	end
end

return cls