local RoomTipsView = require "bacon.ui.RoomTipsView"
local assert = assert

local cls = class("RoomTipsUIContext")

function cls:ctor(appContext, ... )
	-- body
	assert(appContext)
    self.appContext = appContext
    self.view = RoomTipsView.new()
end

function cls:OnEnter( ... )
	-- body
	assert(self.view:OnEnter(self))
	self.visible = true
end

function cls:OnExit( ... )
	-- body
	-- print('TEST ROOM')
	self.view:OnExit(self)
	self.visible = false
end

return cls