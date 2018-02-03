local EventDispatcher = require "maria.event.EventDispatcher"
local cls = class("UIContext")

function cls:ctor( ... )
	-- body
end

function cls:OnEnter()
	self.visible = true
	EventDispatcher:getInstance():EnqueueRenderQueue(function ( ... )
		-- body
		self:RenderViewEnter()
	end)
end

function cls:OnExit()
	EventDispatcher:getInstance():EnqueueRenderQueue(function ( ... )
		-- body
		self:RenderViewExit()
	end)
	self.visible = false
end

function cls:OnPause()
	EventDispatcher:getInstance():EnqueueRenderQueue(function ( ... )
		-- body
		self:RenderViewPause()
	end)
	self.visible = false
end

function cls:OnResume()
	self.visible = true
	EventDispatcher:getInstance():EnqueueRenderQueue(function ( ... )
		-- body
		self:RenderViewResume()
	end)
end

function cls:Shaking()
end

-- //function Clean()end

function cls:RenderViewEnter()
end

function cls:RenderViewExit()
end

function cls:RenderViewPause()
end

function cls:RenderViewResume()
end

function cls:RenderViewShaking()
end

return cls