
local Context = require "entitas.Context"
local Matcher = require "entitas.Matcher"
local PrimaryEntityIndex = require "entitas.PrimaryEntityIndex"

local SceneComponent = require "bacon.components.SceneComponent"
local UserComponent = require "bacon.components.UserComponent"
local IndexComponent = require "bacon.components.IndexComponent"
local MyIndexComponent = require "bacon.components.MyIndexComponent"
local LoginComponent = require "bacon.components.LoginComponent"
local MainComponent = require "bacon.components.MainComponent"
local RoomComponent = require "bacon.components.RoomComponent"
local PlayerComponent = require "bacon.components.PlayerComponent"

local LoginUIContext = require "bacon.ui.LoginUIContext"
local BottomUIContext = require "bacon.ui.BottomUIContext"
local RoomUIContext = require "bacon.ui.RoomUIContext"
local CreateRoomUIContext = require "bacon.ui.CreateRoomUIContext"
local JoinUIContext = require "bacon.ui.JoinUIContext"
local MainBgUIContext = require "bacon.ui.MainBgUIContext"
local TitleUIContext = require "bacon.ui.TitleUIContext"
local RoomTipsUIContext = require "bacon.ui.RoomTipsUIContext"

local MyEventCmd = require "bacon.event.MyEventCmd"
local TransferType = require "bacon.common.TransferType"

local log = require "log"
local EventDispatcher = require "event_dispatcher"

local cls = class("LoginSystem")

function cls:ctor(systems, ... )
    -- body
    self._gameSystems = systems
    self._appContext = nil
    self._context = nil
end

function cls:SetAppContext(context) 
    assert(context)
    self._appContext = context
end

function cls:SetContext(context, ... )
    -- body
    assert(context)
    self._context = context
end

function cls:Initialize( ... )
    -- body
    log.info("LoginSystem Initialize")
    self._appContext.networkMgr:RegNetwork(self)
    EventDispatcher.AddCmdEventListener(MyEventCmd.EVENT_LOGIN, function (e, ... )
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
    local indexPrimaryIndex = PrimaryEntityIndex.new(IndexComponent, indexGroup, 'index')
    context:add_entity_index(indexPrimaryIndex)
    assert(context:get_entity_index(IndexComponent))

    local userGroup = context:get_group(Matcher({UserComponent}))
    local userPrimaryIndex = PrimaryEntityIndex.new(UserComponent, userGroup, 'uid')
    context:add_entity_index(userPrimaryIndex)

    local param = {}
    param.transferType = TransferType.Direct
    self._appContext:Push(context, param)
end

function cls:OnEnter(context, param, ... )
    -- body
    local entity = context:create_entity()

    local index = context:get_unique_component(MyIndexComponent).index
    entity:add(IndexComponent, index)
    entity:add(UserComponent, "hello", "Password", "Sample1", 1, 1, "")
    local loginUIContext = LoginUIContext.new(self._appContext)
    entity:add(LoginComponent, false, false, false, loginUIContext)

    local bottomUIContext = BottomUIContext.new(self._appContext)
    local roomUIContext = RoomUIContext.new(self._appContext)
    local createRoomUIContext = CreateRoomUIContext.new(self._appContext)
    local joinUIContext = JoinUIContext.new(self._appContext)
    local mainBgUIContext = MainBgUIContext.new(self._appContext)
    local titleUIContext = TitleUIContext.new(self._appContext)
    local roomTipsUIContext = RoomTipsUIContext.new(self._appContext)
    entity:add(MainComponent, mainBgUIContext, titleUIContext, bottomUIContext, roomUIContext, createRoomUIContext, joinUIContext, roomTipsUIContext)
    entity:add(RoomComponent, false, 0)
    entity:add(PlayerComponent, 0)

    self._appContext.uicontextMgr:Push(loginUIContext)
    self._appContext.uicontextMgr:CleanStartPanel()
end

function cls:OnPause(context, param, ... )
    -- body
    if param.transferType == TransferType.Direct then
        local res = {}
        local index = self._context:get_unique_component(MyIndexComponent).index
        local indexEntityIndex = self._context:get_entity_index(IndexComponent)
        local entity = indexEntityIndex:get_entity(index)
        res.myEntity = entity
        return res
    end
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

            self._appContext.networkMgr:LoginAuth("127.0.0.1", 3002, server, username, password)
        end
    else
        log.info("is isSended true")
    end 
end

function cls:OnLoginAuthed(code, uid, subid, secret, ... )
    -- body
    if code == 200 then
        log.info("OnLoginAuthed code = 200.")
        local index = self._context:get_unique_component(MyIndexComponent).index
        local indexEntityIndex = self._context:get_entity_index(IndexComponent)
        local entity = indexEntityIndex:get_entity(index)
        local user = entity:get(UserComponent)
        user.uid = uid
        user.subid = subid
        user.secret = secret
        self._appContext.networkMgr:GateAuth("127.0.0.1", 3301, user.server, user.uid, user.subid, user.secret)
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
        self._appContext.uicontextMgr:Push(main.mainBgUIContext)
        self._appContext.uicontextMgr:Push(main.titleUIContext)
        self._appContext.uicontextMgr:Push(main.bottomUIContext)
        self._appContext.uicontextMgr:Push(main.roomUIContext)

        self._appContext.networkMgr.client:send_request("inituser")
    end
end

function cls:InitUser(responseObj, ... )
    -- body
    if responseObj.errorcode == 0 then
        self._appContext.networkMgr.client:send_request("first")
        self._appContext.networkMgr.client:send_request("room_info")
    else
        log.error("inituser errorcode = %d", responseObj.errorcode)
    end
end

function cls:RoomInfo(responseObj, ... )
    -- body
    if responseObj.errorcode == 0 then
        local index = self._context:get_unique_component(MyIndexComponent).index
        local indexEntityIndex = self._context:get_entity_index(IndexComponent)
        local entity = indexEntityIndex:get_entity(index)
        entity.room.isCreated = responseObj.isCreated
        entity.room.roomid = responseObj.roomid
        if entity.room.isCreated then
            self._appContext.uicontextMgr:Push(entity.main.roomTipsUIContext)
        end
    else
        log.error("room into errorcode = %d", responseObj.errorcode)
    end
end

return cls