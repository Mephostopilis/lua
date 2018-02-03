
local cls = class("BaseView")

function cls:ctr( ... )
	-- body
	self.context = nil
	self.child = {}
	self.go = nil
end

function cls:OnEnter(context, ... )
	-- body
	
end

function cls:OnPause(context, ... )
	-- body
end

function cls:OnResume(context, ... )
	-- body
end

function cls:OnExit(context, ... )
	-- body
end

return cls