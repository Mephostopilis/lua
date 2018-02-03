local UserComponent = require "bacon.components.UserComponent"
local cls = class("UserSystem")

function cls:ctor( ... )
	-- body
	self._context = nil
	self._appContext = nil
	self._gameSystems = nil
end

function cls:SetAppContext(context, ... )
	-- body
	self._appContext = context
	self._gameSystems = context.gameSystems
end

function cls:SetContext(context, ... )
	-- body
	self._context = context
	local userGroup = context:get_group(Matcher({UserComponent}))
	cardGroup.on_entity_added:add(function ( ... )
		self:OnEntityAdded( ... )
	        	-- body
	end)

end

function cls:OnEntityAdded(entity, ... )
	-- body
end

function cls:FindEntity(uid, ... )
	-- body
end

return cls