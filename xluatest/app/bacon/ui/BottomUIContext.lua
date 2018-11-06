local UIContext = require "maria.uibase.UIContext"
local UIContextManager = require "maria.uibase.UIContextManager"
local BottomView = require "bacon.ui.BottomView"
local log = require "log"
local res = require "res"
local assert = assert

local cls = class("BottomUIContext", UIContext)

function cls:ctor(appContext, ... )
	-- body
	assert(appContext)
	self.appContext = appContext
	self.view = BottomView.new(self)
	self.visible = false
end

function cls:OnEnter( ... )
	-- body
	self.visible = true
	self.view:OnEnter(self)
end

function cls:RenderViewEnter( ... )
	-- body
end

function cls:OnPause( ... )
	-- body
end

return cls