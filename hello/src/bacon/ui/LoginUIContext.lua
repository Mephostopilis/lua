local UIContext = require "maria.uibase.UIContext"
local UIContextManager = require "maria.uibase.UIContextManager"
local EventDispatcher = require "maria.event.EventDispatcher"
local ABLoader = require "maria.res.ABLoader"
local LoginView = require "bacon.ui.LoginView"
local log = require "log"

local cls = class("LoginUIContext", UIContext)

function cls:ctor( ... )
	-- body
	self.view = LoginView.new()
	self.visible = false

end

function cls:OnEnter()
	self.visible = true
	EventDispatcher:getInstance():EnqueueRenderQueue(function ( ... )
		-- body
		log.info("LoginUIContext OnEnter")
		self:RenderViewEnter()
	end)
end

function cls:RenderViewEnter( ... )
	-- body
	local original = ABLoader:getInstance():LoadGameObject("UI", "LoginPanel")
	local go = CS.UnityEngine.GameObject.Instantiate(original)
	go.transform:SetParent(UIContextManager:getInstance().buicanvas.transform)
	self.view:OnEnter(self, go)
end

function cls:OnPause( ... )
	-- body
	log.info("LoginUIContext OnPause")
	EventDispatcher:getInstance():EnqueueRenderQueue(function ( ... )
		-- body
		self:RenderViewPause()
	end)
end

function cls:RenderViewPause( ... )
	-- body
	self.view:OnPause()
end

return cls