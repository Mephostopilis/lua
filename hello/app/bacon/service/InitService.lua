local timer = require "timer"
local log = require "log"
local cls = class("InitService")

function cls:ctor(appContext, ... )
	-- body
	self.appContext = appContext
	self._authed = false
end

function cls:Startup( ... )
	-- body
	self.appContext.networkMgr:RegNetwork(self)
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
		timer.timeloop(self, "Handshake", 5)
	end
end

function cls:OnGateDisconnected( ... )
	-- body
	self._authed = false
end

function cls:Handshake( ... )
	-- body
	if self._authed then
		self.appContext.networkMgr.client:send_request("handshake")
	end
end

return cls