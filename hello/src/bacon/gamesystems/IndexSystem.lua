local IndexComponent = require "bacon.components.IndexComponent"
local Matcher = require "entitas.Matcher"
local PrimaryEntityIndex = require "entitas.PrimaryEntityIndex"
local log = require "log"
local cls = class("IndexSystem")

function cls:ctor( ... )
    -- body
    self._appContext = nil
    self._context = nil
    self._gameSystems = nil
    self._index = 0
end

function cls:SetAppContext(context, ... )
    -- body
    self._appContext = context
    self._gameSystems = context.gameSystems
end

function cls:SetContext(context, ... )
    -- body
    self._context = context
    local indexGroup = context:get_group(Matcher({IndexComponent}))
    
    -- indexGroup.on_entity_added:add(function ( ... )
    --     self._gameSystems.indexSystem:OnEntityAdded( ... )
    --     -- body
    -- end)
    local indexPrimaryIndex = PrimaryEntityIndex.new(IndexComponent, indexGroup, 'index')
    context:add_entity_index(indexPrimaryIndex)
    log.info("IndexSystem SetContext")
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

function cls:OnEntityAdded(entity, ... )
    -- body
end

function cls:OnEntityRemoved(entity, Entity, ... )
    -- body
end

function cls:OnEntityReplaced(entity, Entity, ... )
    -- body
end


return cls
