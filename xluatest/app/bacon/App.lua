local notification_center = require "notification_center"
local EventDispatcher = require "event_dispatcher"

local NetworkMgr = require "maria.network.NetworkMgr"
local UIContextManager = require "maria.uibase.UIContextManager"
local ServiceMgr = require "maria.service.ServiceMgr"

local AppGameSystems = require "bacon.AppGameSystems"
local AppContext = require "bacon.AppContext"
local InitService = require "bacon.service.InitService"
local request = require "bacon.request"
local response = require "bacon.response"


local log = require "log"

local cls = class("App")

function cls:ctor()
	-- body
	self.context = AppContext.new(self)
	self.networkMgr = NetworkMgr.new(self.context)
	self.gameSystems = AppGameSystems.new(self.context)
	self.notificationCenter = notification_center.new(self.context)
	self._request = request.new(self.context, self.networkMgr.client)
	self._response = response.new(self.context, self.networkMgr.client)
	self.serviceMgr = ServiceMgr.new(self.context)
	self.uicontextMgr = UIContextManager.new(self.context)

	self.serviceMgr:RegService(InitService)

	self.context.networkMgr = self.networkMgr
	self.context.gameSystems = self.gameSystems
	self.context.notificationCenter = self.notificationCenter
	self.context.serviceMgr = self.serviceMgr
	self.context.uicontextMgr = self.uicontextMgr
end

function cls:Startup()
	-- body
	log.info("App Startup")
	assert(self.config)
	self.context.config = self.config
	assert(self.context.config)
	self.networkMgr:Startup()
	self.gameSystems:SetAppContext(self.context)
	self.gameSystems:Initialize()
	self.serviceMgr:Startup()
	self.uicontextMgr:Startup()

	self.context:Startup()
end

function cls:Cleanup()
	-- body
	self.context:Cleanup()
	self.networkMgr:Cleanup()
	self.gameSystems:Cleanup()
	self.serviceMgr:Cleanup()
	self.uicontextMgr:Cleanup()

	log.info("App Cleanup")
end

function cls:Update(delta)
	-- body
	assert(self.config)
	assert(self.context.config)
	self.context:Update(delta)
	self.networkMgr:Update(delta)
	self.gameSystems:Execute()
end

return cls