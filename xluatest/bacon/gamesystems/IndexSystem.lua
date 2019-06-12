local log = require "log"

local Matcher = require "entitas.Matcher"
local PrimaryEntityIndex = require "entitas.PrimaryEntityIndex"

local IndexComponent = require "bacon.components.IndexComponent"

local cls = class("IndexSystem")

function cls:ctor(systems, ... )
    -- body
    self._gameSystems = systems
    self._appContext = nil
    self._context = nil
    
    self._index = 0
end

function cls:SetAppContext(context, ... )
    -- body
    self._appContext = context
end

function cls:SetContext(context, ... )
    -- body
    self._context = context
end

function cls:NextIndex( ... )
    -- body
    self._index = self._index + 1
    return self._index
end

-- @breif
-- @param index : integer
--
function cls:FindEntity(index, ... )
    -- body
    local indexPrimaryIndex = self._context:get_entity_index(IndexComponent)
    return indexPrimaryIndex:get_entity(index)
end

return cls
