local UIContext = require "maria.uibase.UIContext"
local LoginView = require "bacon.ui.LoginView"
local log = require "log"
local res = require "res"

local cls = class("LoginUIContext", UIContext)

function cls:ctor()
	-- body
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

return cls.new()