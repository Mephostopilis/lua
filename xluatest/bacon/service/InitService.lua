local timer = require "timer"
local log = require "log"
local NetworkMgr = require "maria.network.NetworkMgr"
local cls = class("InitService")

function cls:ctor(appContext, ... )
	-- body
	self.appContext = appContext
	self._authed = false
end

function cls:Startup( ... )
	-- body
	NetworkMgr:getInstance():RegNetwork(self)
	log.info("init service Startup")
	-- timer.timeloop(self, "Test", 1)
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
		timer.timeloop(self, "Handshake", 1)
	end
end

function cls:OnGateDisconnected( ... )
	-- body
	self._authed = false
end

function cls:Handshake( ... )
	-- body
	if self._authed then
		NetworkMgr:getInstance().client:send_request('handshake')
	end
end

function cls:Test()
	log.info('TEST')
end

return cls