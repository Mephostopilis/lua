local log = require "log"
local UIContextManager = require "maria.uibase.UIContextManager"
local SceneComponent = require "bacon.components.SceneComponent"
local log = require "log"

local cls = class("SceneSystem")

function cls:ctor(systems, ... )
    -- body
    self._gameSystems = systems
    self._appContext = nil
    self._context = nil
end

function cls:SetAppContext(context) 
    self._appContext = context
end

function cls:SetContext(context, ... )
    -- body
    self._context = context 
end

function cls:Initialize()
end

function cls:OnEnter(context, ... )
	-- body
	local scene = context:get_unique_component(SceneComponent)
	if scene.name == "login" then
        self._gameSystems.loginSystem:OnEnter(context, ... )
    elseif scene.name == "game" then
        self._gameSystems.joinSystem:OnEnter(context, ... )
        self._gameSystems.deskSystem:OnEnter(context)
	end
end

function cls:OnPause(context, ... )
    -- body
   local scene = context:get_unique_component(SceneComponent)
    if scene.name == "login" then
        return self._gameSystems.loginSystem:OnPause(context, ... )
    elseif scene.name == "game" then
        return self._gameSystems.joinSystem:OnPause(context, ... )
    end 
end

return cls