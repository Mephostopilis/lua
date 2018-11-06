local NetworkMgr = require "maria.network.NetworkMgr"
local UIContextManager = require "maria.uibase.UIContextManager"
local MyIndexComponent = require "bacon.components.MyIndexComponent"
local IndexComponent = require "bacon.components.IndexComponent"
local MainComponent = require "bacon.components.MainComponent"
local Provice = require "bacon.game.Provice"
local MyEventCmd = require "bacon.event.MyEventCmd"
local log = require "log"
local EventDispatcher = require "event_dispatcher"

local cls = class("MainSystem")

function cls:ctor(systems, ... )
	-- body
	self._gameSystems = systems
	self._appContext = nil
	self._context = nil
end

function cls:SetAppContext(context, ... )
    -- body
    self._appContext = context
end

function cls:SetContext(context, ... )
    -- body
    self._context = context
end

function cls:Initialize( ... )
	-- body
	EventDispatcher.AddCmdEventListener(MyEventCmd.EVENT_MUI_SHOWCREATE, function ( ... )
		-- body
		self:OnShowCreate( ... )
	end)
	EventDispatcher.AddCmdEventListener(MyEventCmd.EVENT_JOIN_SHOW, function ( ... )
		-- body
		self:OnShowJoin( ... )
	end)

	EventDispatcher.AddCmdEventListener(MyEventCmd.EVENT_MUI_MODIFYCREATE, function ( ... )
		-- body
		self._gameSystems.joinSystem:SendCreate()
	end)

	EventDispatcher.AddCmdEventListener(MyEventCmd.EVENT_MUI_JOIN, function ( ... )
		-- body
		self:OnJoin( ... )
	end)

	EventDispatcher.AddCmdEventListener(MyEventCmd.EVENT_JOIN_CLOSE, function ( ... )
		-- body
		self:OnClose()
	end)

	EventDispatcher.AddCmdEventListener(MyEventCmd.EVENT_EXITROOM, function ( ... )
		-- body
		self:OnEventLeave()
	end)
end

function cls:Cleanup( ... )
	-- body
end

function cls:EnterGame( ... )
	-- body
	local context = Context.new()
    context:set_unique_component(SceneComponent, "game")
    local index = self._gameSystems.indexSystem:NextIndex()
    context:set_unique_component(MyIndexComponent, index)

    local indexGroup = context:get_group(Matcher({IndexComponent}))
    indexGroup.on_entity_added:add(function ( ... )
        self._gameSystems.indexSystem:OnEntityAdded( ... )
        -- body
    end)

    local indexPrimaryIndex = PrimaryEntityIndex.new(IndexComponent, indexGroup, 'index')

    context:add_entity_index(indexPrimaryIndex)

    local userGroup = context:get_group(Matcher({UserComponent}))
    local userPrimaryIndex = PrimaryEntityIndex.new(UserComponent, userGroup, 'uid')
    context:add_entity_index(userPrimaryIndex)

    self._appContext:Push(context)
end

-- event
function cls:OnShowCreate( e)
	local index = self._context:get_unique_component(MyIndexComponent).index
	local entity = self._gameSystems.indexSystem:FindEntity(index)
	if not entity.main.createRoomUIContext.visible then
		self._appContext.uicontextMgr:Push(entity.main.createRoomUIContext)
	end
end

function cls:OnShowJoin( e, ... )
	-- body
	local index = self._context:get_unique_component(MyIndexComponent).index
	local entity = self._gameSystems.indexSystem:FindEntity(index)
	if not entity.main.joinUIContext.visible then
		self._appContext.uicontextMgr:Push(entity.main.joinUIContext)
	end
end

-- response
function cls:First(responseObj)
	-- body
	if responseObj.errorcode == 0 then
		local index = self._context:get_unique_component(MyIndexComponent).index
	    local indexEntityIndex = self._context:get_entity_index(IndexComponent)
	    local entity = indexEntityIndex:get_entity(index)
	    local main = entity:get(MainComponent)
	    main.titleUIContext.nickname = responseObj.name
	    main.titleUIContext.nameid   = responseObj.nameid
	    main.titleUIContext.rcard    = responseObj.rcard
	    main.titleUIContext:Shaking()
	else
		log.error("First responseObj.errorcode = [%d]", responseObj.errorcode)
	end
end

return cls