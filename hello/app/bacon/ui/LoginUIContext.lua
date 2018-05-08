local UIContext = require "maria.uibase.UIContext"
local UIContextManager = require "maria.uibase.UIContextManager"
local LoginView = require "bacon.ui.LoginView"
local log = require "log"
local res = require "res"
local EventDispatcher = require "event_dispatcher"

local cls = class("LoginUIContext", UIContext)

function cls:ctor(appContext, ... )
	-- body
	assert(appContext)
	self.appContext = appContext
	self.view = LoginView.new()
	self.visible = false
end

function cls:OnEnter()
	self.view:OnEnter(self, go)
end

function cls:OnPause( ... )
	-- body
	log.info("LoginUIContext OnPause")
	self.view:OnPause()
end

return cls