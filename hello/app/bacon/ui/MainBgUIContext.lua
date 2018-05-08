local UIContext = require "maria.uibase.UIContext"
local UIContextManager = require "maria.uibase.UIContextManager"
local MainBgView = require "bacon.ui.MainBgView"
local log = require "log"

local cls = class("MainBgUIContext", UIContext)

function cls:ctor(app, ... )
	-- body
	self.app = app
	self.view = MainBgView.new()
	self.visible = false
end

function cls:OnEnter()
	self.view:OnEnter(self)
end

function cls:OnExit()
    -- body
    self.view:OnExit()
end

function cls:OnPause()
    -- body
    self.visible = true
end

return cls