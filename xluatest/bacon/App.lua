local NetworkMgr = require "maria.network.NetworkMgr"
local UIContextManager = require "maria.uibase.UIContextManager"
local ServiceMgr = require "maria.service.ServiceMgr"

local AppGameSystems = require "bacon.AppGameSystems"
local AppContext = require "bacon.AppContext"
local InitService = require "bacon.service.InitService"
local request = require "bacon.request"
local response = require "bacon.response"
local objmgr = require "bacon.objmgr"
local log = require "log"
local tableDump = require "common.luaTableDump"


local cls = class("App")

function cls:ctor()
	-- body
	-- 网络模块
	self.networkMgr = NetworkMgr:getInstance()
	self._request = request.new(self.networkMgr.client)
	self._response = response.new(self.networkMgr.client)

	-- ui模块
	self.uicontextMgr = UIContextManager:getInstance()

	-- app
	self.context = AppContext:getInstance()

	-- 服务模块
	self.serviceMgr = ServiceMgr:getInstance()
	self.serviceMgr:RegService(InitService)

	return self
end

function cls:Startup()
	-- body
	log.info("App Startup")
	self.networkMgr:Startup()
	self.uicontextMgr:Startup()
	self.context:Startup()
	self.serviceMgr:Startup()
	AppGameSystems.Startup()
end

function cls:Cleanup()
	-- body
	AppGameSystems.Cleanup()
	self.serviceMgr:Cleanup()
	self.context:Cleanup()
	self.uicontextMgr:Cleanup()
	self.networkMgr:Cleanup()
	
	log.info("App Cleanup")
end

function cls:Update(delta)
	-- body
	self.networkMgr:Update(delta)
	self.context:Update(delta)
	AppGameSystems.Update(delta)
end

return cls