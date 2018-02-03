local UIContext = require "maria.uibase.UIContext"
local UIContextManager = require "maria.uibase.UIContextManager"
local EventDispatcher = require "maria.event.EventDispatcher"
local ABLoader = require "maria.res.ABLoader"
local BottomView = require "bacon.ui.BottomView"
local log = require "log"

local cls = class("BottomUIContext", UIContext)

function cls:ctor( ... )
	-- body
	self.view = BottomView.new()
	self.visible = false
end

function cls:OnEnter( ... )
	-- body
	self.visible = true
	EventDispatcher:getInstance():EnqueueRenderQueue(function ( ... )
		-- body
		self:RenderViewEnter()
	end)
end

function cls:RenderViewEnter( ... )
	-- body
	local original = ABLoader:getInstance():LoadGameObject("UI", "bottom")
	local go = CS.UnityEngine.GameObject.Instantiate(original)
	go.transform:SetParent(UIContextManager:getInstance().buicanvas.transform)
	self.view:OnEnter(self, go)
end

function cls:OnPause( ... )
	-- body
end

return cls