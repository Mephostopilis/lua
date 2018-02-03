
local Context = require "entitas.Context"
local Matcher = require "entitas.Matcher"
local PrimaryEntityIndex = require "entitas.PrimaryEntityIndex"

local EventDispatcher = require "maria.event.EventDispatcher"
local UIContextManager = require "maria.uibase.UIContextManager"
local NetworkMgr = require "maria.network.NetworkMgr"

local IndexSystem = require "bacon.gamesystems.IndexSystem"

local SceneComponent = require "bacon.components.SceneComponent"
local UserComponent = require "bacon.components.UserComponent"
local IndexComponent = require "bacon.components.IndexComponent"
local MyIndexComponent = require "bacon.components.MyIndexComponent"
local LoginComponent = require "bacon.components.LoginComponent"
local MainComponent = require "bacon.components.MainComponent"

local LoginUIContext = require "bacon.ui.LoginUIContext"
local BottomUIContext = require "bacon.ui.BottomUIContext"
local RoomUIContext = require "bacon.ui.RoomUIContext"
local CreateRoomUIContext = require "bacon.ui.CreateRoomUIContext"
local JoinUIContext = require "bacon.ui.JoinUIContext"

local MyEventCmd = require "bacon.event.MyEventCmd"

local log = require "log"

local cls = class("LoginSystem")

function cls:ctor( ... )
    -- body
    self._context = nil
    self._appContext = nil
    self._gameSystems = nil
end

function cls:SetAppContext(context) 
    assert(context)
    self._appContext = context
    self._gameSystems = context.gameSystems
end

function cls:SetContext(context, ... )
    -- body
    assert(context)
    self._context = context
end

function cls:Initialize( ... )
    -- body
    NetworkMgr:getInstance():RegNetwork(self)
    EventDispatcher:getInstance():AddCmdEventListener(MyEventCmd.EVENT_LOGIN, function (e, ... )
        -- body
        self:OnLogin(e)
    end)
end

function cls:EnterLogin( ... )
	-- body
	local context = Context.new()
    context:set_unique_component(SceneComponent, "login")
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

function cls:OnEnter(context, ... )
    -- body
    local entity = context:create_entity()

    local index = context:get_unique_component(MyIndexComponent).index
    entity:add(IndexComponent, index)
    entity:add(UserComponent, "hello", "Password", "Sample1", 1, 1, "")
    local loginUIContext = LoginUIContext.new()
    entity:add(LoginComponent, false, false, false, loginUIContext)
    local bottomUIContext = BottomUIContext.new()
    local roomUIContext = RoomUIContext.new()
    local createRoomUIContext = CreateRoomUIContext.new()
    local joinUIContext = JoinUIContext.new()
    entity:add(MainComponent, bottomUIContext, roomUIContext, createRoomUIContext, joinUIContext)

    UIContextManager:getInstance():Push(loginUIContext)
    UIContextManager:getInstance():CleanStartPanel()
end

function cls:OnLogin(e, ... )
    -- body
    log.info("hello OnLogin")
    local index = self._context:get_unique_component(MyIndexComponent).index
    local indexEntityIndex = self._context:get_entity_index(IndexComponent)
    local entity = indexEntityIndex:get_entity(index)
    if not entity.login.isSended then
        log.info("is isSended false")
        entity.login.isSended = true
        if not entity.login.logined then
            log.info("is logined false")
            local username = e.Msg:GetString("username")
            local password = e.Msg:GetString("password")
            local server = e.Msg:GetString("server")    
            log.info("logined: %s:%s:%s", username, password, server)
            local user = entity:get(UserComponent)
            user.username = username
            user.password = password
            user.server = server

            NetworkMgr:getInstance():LoginAuth("127.0.0.1", 3002, server, username, password)
        end
    else
        log.info("is isSended true")
    end 
end

function cls:OnLoginAuthed(code, uid, subid, secret, ... )
    -- body
    if code == 200 then
        local index = self._context:get_unique_component(MyIndexComponent).index
        local indexEntityIndex = self._context:get_entity_index(IndexComponent)
        local entity = indexEntityIndex:get_entity(index)
        local user = entity:get(UserComponent)
        user.uid = uid
        user.subid = subid
        user.secret = secret
        NetworkMgr:getInstance():GateAuth("127.0.0.1", 3301, user.server, user.uid, user.subid, user.secret)
    end
end

function cls:OnGateAuthed(code, ... )
    -- body
    if code == 200 then
        log.info("GateAuthed succussful.")
        local index = self._context:get_unique_component(MyIndexComponent).index
        local indexEntityIndex = self._context:get_entity_index(IndexComponent)
        local entity = indexEntityIndex:get_entity(index)
        local main = entity:get(MainComponent)
        UIContextManager:getInstance():Push(main.bottomUIContext)
        UIContextManager:getInstance():Push(main.roomUIContext)
    end
end

return cls