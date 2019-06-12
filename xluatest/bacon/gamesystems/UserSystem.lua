local UserComponent = require "bacon.components.UserComponent"
local cls = class("UserSystem")

function cls:ctor(systems, ... )
	-- body
	self._gameSystems = systems
	self._appContext = nil
	self._context = nil
end

function cls:SetAppContext(context, ... )
	-- body
	self._appContext = context
	self._gameSystems = context.gameSystems
end

function cls:SetContext(context, ... )
	-- body
	self._context = context
end

return cls