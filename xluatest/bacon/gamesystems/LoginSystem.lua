
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
local TransferType = require "bacon.game.TransferType"

local log = require "log"
local EventDispatcher = require "event_dispatcher"
local objmgr = require "bacon.objmgr"
local NetworkMgr = require "maria.network.NetworkMgr"
local UIContextManager = require "maria.uibase.UIContextManager"

local cls = {}
local request = {}
local response = {}

function response.inituser(responseObj, ... )
    -- body
    local obj = objmgr.get_myobj()
end

-- function cls:first(responseObj)
-- 	-- body
-- 	AppContext:getInstance().gameSystems.mainSystem:First(responseObj)
-- end

-- function cls:create(responseObj, ... )
-- 	-- body
-- 	AppContext:getInstance().gameSystems.joinSystem:Create(responseObj)
-- end

-- function cls:room_info(responseObj, ... )
-- 	-- body
-- 	AppContext:getInstance().gameSystems.loginSystem:RoomInfo(responseObj)
-- end

function request.room_info(requestObj)
    local obj = objmgr.get_myobj()
    obj.room = {}
    obj.room.isCreated = requestObj.isCreated
    obj.room.joined    = requestObj.joined
    obj.room.roomid    = requestObj.roomid
    obj.room.type      = requestObj.type
    obj.room.mode      = requestObj.mode
end


function cls.Startup( ... )
    -- body
    log.info("LoginSystem Startup")
    local obj = objmgr.get_myobj()
    obj.login = {}
    obj.user = {}

    NetworkMgr.getInstance():RegNetwork(cls)
    local cs = NetworkMgr.getInstance().client
    cs:register_response("enter", response.inituser)
    cs:regiseter_request("room_info", request.room_info)

    EventDispatcher.AddCmdEventListener(MyEventCmd.EVENT_LOGIN, function (e, ... )
        -- body
        cls.OnLogin(e)
    end)

    -- 加入ui
    UIContextManager.getInstance():Push(LoginUIContext)
    UIContextManager.getInstance():CleanStartPanel()
end

function cls.Cleanup( ... )
    -- body
end

function cls.Update( ... )
    -- body
end

function cls.OnLogin(e, ... )
    -- body
    local obj = objmgr.get_myobj()
    if not obj.login.isSended then
        obj.login.isSended = true
        local username = e.Msg:GetString("username")
        local password = e.Msg:GetString("password")
        local server = e.Msg:GetString("server")    
        log.info("logined: %s:%s:%s", username, password, server)
        local user = obj.user
        user.username = username
        user.password = password
        user.server = server
        NetworkMgr.getInstance():LoginAuth("127.0.0.1", 3002, server, username, password)
    else
        log.info("is isSended true")
    end 
end

function cls.OnLoginAuthed(code, uid, subid, secret, ... )
    -- body
    if code == 200 then
        log.info("OnLoginAuthed code = 200.")
        local obj = objmgr.get_myobj()
        obj.uid = uid
        obj.subid = subid
        obj.secret = secret
        NetworkMgr.getInstance():GateAuth("127.0.0.1", 3301, obj.user.server, obj.uid, obj.subid, obj.secret)
    end
end

function cls.OnGateAuthed(code, ... )
    -- body
    if code == 200 then
        log.info("GateAuthed succussful.")
        local obj = objmgr.get_myobj()
        NetworkMgr.getInstance().client:send_request("enter")

        -- local index = self._context:get_unique_component(MyIndexComponent).index
        -- local indexEntityIndex = self._context:get_entity_index(IndexComponent)
        -- local entity = indexEntityIndex:get_entity(index)
        -- local main = entity:get(MainComponent)
        -- self._appContext.uicontextMgr:Push(main.mainBgUIContext)
        -- self._appContext.uicontextMgr:Push(main.titleUIContext)
        -- self._appContext.uicontextMgr:Push(main.bottomUIContext)
        -- self._appContext.uicontextMgr:Push(main.roomUIContext)
    end
end

-- function cls:InitUser(responseObj, ... )
--     -- body
--     if responseObj.errorcode == 0 then
--         self._appContext.networkMgr.client:send_request("first")
--         self._appContext.networkMgr.client:send_request("room_info")
--     else
--         log.error("inituser errorcode = %d", responseObj.errorcode)
--     end
-- end

-- function cls:RoomInfo(responseObj, ... )
--     -- body
--     if responseObj == nil then
--         log.error("response room_info responseObj is nil")
--         return
--     end
--     if responseObj.errorcode == nil then
--         log.error("response room_info responseObj errorcode is nil")
--         return
--     end
--     if responseObj.errorcode == 0 then
--         local index = self._context:get_unique_component(MyIndexComponent).index
--         local indexEntityIndex = self._context:get_entity_index(IndexComponent)
--         local entity = indexEntityIndex:get_entity(index)
--         entity.room.isCreated = responseObj.isCreated
--         entity.room.joined    = responseObj.joined
--         entity.room.roomid    = responseObj.roomid
--         entity.room.type      = responseObj.type
--         entity.room.mode      = responseObj.mode
--         if entity.room.joined and entity.room.type == 1 then
--             self._appContext.uicontextMgr:Push(entity.main.roomTipsUIContext)
--         end
--     else
--         log.error("room into errorcode = %d", responseObj.errorcode)
--     end
-- end

return cls