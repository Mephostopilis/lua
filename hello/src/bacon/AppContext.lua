local stack = require "chestnut.stack"
local timer = require "maria.timer"
local NetworkMgr = require "maria.network.NetworkMgr"
local notification_center = require "notification_center"
local EventDispatcher = require "maria.event.EventDispatcher"
local AppGameSystems = require "bacon.AppGameSystems"
local Context = require "entitas.Context"
local ServiceMgr = require "maria.service.ServiceMgr"
local InitService = require "bacon.service.InitService"
local request = require "bacon.request"
local response = require "bacon.response"
local log = require "log"
local assert = assert

local cls = class("AppContext")

function cls:ctor( ... )
	-- body
	timer.init()
	NetworkMgr.getInstance()
	self._stack = stack()
	self.gameSystems = AppGameSystems:getInstance()
	self.gameSystems:SetAppContext(self)
	self.notificationCenter = notification_center:getInstance()
	self.networkMgr = NetworkMgr:getInstance()
	self._request = request.new(self, self.networkMgr.client)
	self._response = response.new(self, self.networkMgr.client)

	self.serviceMgr = ServiceMgr:getInstance()
	self.serviceMgr:RegService(InitService)
end

function cls:Startup( ... )
	-- body
	self.gameSystems:Initialize()
	self.networkMgr:Startup()
	self.serviceMgr:Startup()
	EventDispatcher.getInstance():SubCustomEventListener("UPDATE", function ( ... )
		-- body
		self:Update()
	end, nil)
	timer.timeout(1, function ( ... )
		-- body
		-- 
		log.info("after 1 sec, enter login")
		self.gameSystems.loginSystem:EnterLogin()
	end)
end

function cls:Cleanup( ... )
	-- body
end

function cls:Update( ... )
	-- body
	timer.update()
	NetworkMgr:getInstance():Update()
	self.gameSystems:Execute()
	self.notificationCenter:pub_notification("UPDATE")
end

function cls:Push(context, ... )
	-- body
	if #self._stack > 0 then
		local ok, err = pcall(self.gameSystems.sceneSystem.OnPause, self.gameSystems.sceneSystem, self._stack:peek())
		if not ok then
			log.error(err)
		end
	end
	self._stack:push(context)
	local ok, err = pcall(self.gameSystems.sceneSystem.OnEnter, self.gameSystems.sceneSystem, context)
	if not ok then
		log.error(err)
	end
	log.info("AppContext SetContext")
	self.gameSystems:SetContext(context)
end

function cls:Pop( ... )
	-- body
	if #self._stack > 0 then
		self.gameSystems.sceneSystem:OnExit(self._stack:peek())
		self._stack:pop()
	end
	if #self._stack > 0 then
		self.gameSystems.sceneSystem:OnResume(self._stack:peek())
	end
end

function cls:Peek( ... )
	-- body
	return self._stack:peek()
end

return cls