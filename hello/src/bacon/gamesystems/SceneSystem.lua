local log = require "log"
local UIContextManager = require "maria.uibase.UIContextManager"
local SceneComponent = require "bacon.components.SceneComponent"
local log = require "log"

local cls = class("SceneSystem")

function cls:ctor( ... )
    -- body
    self._context = nil
    self._appContext = nil
    self._gameSystems = nil
end

function cls:SetAppContext(context) 
    self._appContext = context
    self._gameSystems = context.gameSystems
end

function cls:SetContext(context, ... )
    -- body
    self._context = context 
end


function cls:OnEnter(context, ... )
	-- body
	local scene = context:get_unique_component(SceneComponent)
	if scene.name == "login" then
        self._gameSystems.loginSystem:OnEnter(context)
	end
end


function cls:Initialize()         
end

return cls