local RoomTipsView = require "bacon.ui.RoomTipsView"

local cls = class("RoomTipsUIContext")

function cls:ctor(appContext, ... )
    -- body
    self.appContext = appContext
    self.view = RoomTipsView.new()
end

function cls:OnEnter( ... )
	-- body
	self.view:OnEnter(self)
end

function cls:OnExit( ... )
	-- body
	self.view:OnExit(self)
end

return cls