local UIContext = require "maria.uibase.UIContext"
local UIContextManager = require "maria.uibase.UIContextManager"
local BottomView = require "bacon.ui.BottomView"
local log = require "log"
local EventDispatcher = require "event_dispatcher"
local res = require "res"

local cls = class("BottomUIContext", UIContext)

function cls:ctor(app, ... )
	-- body
	self.app = app
	self.view = BottomView.new()
	self.visible = false
end

function cls:OnEnter( ... )
	-- body
	self.visible = true
	self.view:OnEnter(self)
end

function cls:OnPause( ... )
	-- body
	self.visible = true
end

function cls:OnExit()
	-- body
	self.view:OnExit(self)
end

return cls