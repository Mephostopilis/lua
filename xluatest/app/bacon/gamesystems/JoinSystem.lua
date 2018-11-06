-------------------------------------------------------------
-- @breif  此模块管理进游戏场景时候实体组建
-- @date  
-- @author
-------------------------------------------------------------

local log = require "log"
local vector = require "chestnut.vector"
local array = require "chestnut.array"
local scene_mgr = require "scene_mgr"
local language = require "language"
local Context = require "entitas.Context"
local Matcher = require "entitas.Matcher"
local PrimaryEntityIndex = require "entitas.PrimaryEntityIndex"

local SceneComponent = require "bacon.components.SceneComponent"
local MyIndexComponent = require "bacon.components.MyIndexComponent"
local RuleComponent = require "bacon.components.RuleComponent"
local PlayerComponent = require "bacon.components.PlayerComponent"
local HandCardsComponent = require "bacon.components.HandCardsComponent"
local HandComponent = require "bacon.components.HandComponent"
local HoldCardComponent = require "bacon.components.HoldCardComponent"
local HuCardsComponent = require "bacon.components.HuCardsComponent"
local LeadCardsComponent = require "bacon.components.LeadCardsComponent"
local PlayerCardComponent = require "bacon.components.PlayerCardComponent"
local PutCardsComponent = require "bacon.components.PutCardsComponent"
local TakeCardsComponent = require "bacon.components.TakeCardsComponent"
local HeadComponent = require "bacon.components.HeadComponent"
local IndexComponent = require "bacon.components.IndexComponent"
local UserComponent = require "bacon.components.UserComponent"

-- ui
local HeadUIContext = require "bacon.ui.HeadUIContext"

local errorcode = require "bacon.errorcode"
local MyEventCmd = require "bacon.event.MyEventCmd"
local GameType = require "bacon.game.GameType"
local Player = require "bacon.game.Player"
local Card = require "bacon.game.Card"
local Provice = require "bacon.game.Provice"
local TransferType = require "bacon.game.TransferType"

local EventDispatcher = require "event_dispatcher"

local cls = class("GameSystems")

function cls:ctor(systems)
        -- body
    self._gameSystems = systems
    self._appContext = nil
    self._context = nil
end

function cls:SetAppContext(context)
    assert(context)
    self._appContext = context
end

function cls:SetContext(context)
    -- body
    assert(context)
    self._context = context
end

function cls:Initialize( ... )
    -- body
end

function cls:Reset( ... )
    -- body
    -- self._context.ReplaceRule(GameType.GAME, 0, 0, 0, 0, 0, false, 0, 0, 0, false, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, vector(), nil, 0)
end

function cls:Cleanup( ... )
    -- body
    -- self._context.ReplaceRule(GameType.GAME, 0, 0, 0, 0, 0, false, 0, 0, 0, false, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, vector(), nil, 0)
end

function cls:getOrient(myIdx, idx)
    -- body
    local offset = 0
    if idx > myIdx then
        offset = idx - myIdx
    else
        offset = idx + 4 - myIdx
    end
    if offset == 1 then
        return Player.Orient.RIGHT
    elseif offset == 2 then
        return Player.Orient.TOP
    elseif offset == 3 then
        return Player.Orient.LEFT
    end
end

function cls:SendCreate()
    -- body
    local request = {}
    local index = self._context:get_unique_component(MyIndexComponent).index
    local entity = self._gameSystems.indexSystem:FindEntity(index)

    if entity.main.createRoomUIContext._provice == Provice.Sichuan then
        request.provice = entity.main.createRoomUIContext._provice
        request.ju = entity.main.createRoomUIContext._ju
        request.overtype = entity.main.createRoomUIContext._overtype
        request.sc = {}
        request.sc.hujiaozhuanyi = entity.main.createRoomUIContext._hujiaozhuanyi
        request.sc.zimo = entity.main.createRoomUIContext._zimo
        request.sc.dianganghua = entity.main.createRoomUIContext._dianganghua
        request.sc.daiyaojiu = entity.main.createRoomUIContext._daiyaojiu
        request.sc.duanyaojiu = entity.main.createRoomUIContext._duanyaojiu
        request.sc.jiangdui = entity.main.createRoomUIContext._jiangdui
        request.sc.tiandihu = entity.main.createRoomUIContext._tiandihu
        request.sc.top = entity.main.createRoomUIContext._top
    elseif entity.main.createRoomUIContext._provice == Provice.Shaanxi then
        request.provice = Provice.Shaanxi
        request.ju = entity.main.createRoomUIContext._ju
        request.overtype = entity.main.createRoomUIContext._overtype
        request.sx = {}
        request.sx.huqidui = entity.main.createRoomUIContext._sxqidui
        request.sx.qingyise = entity.main.createRoomUIContext._sxqingyise
    end
    self._appContext.networkMgr.client:send_request("create", request)
end

function cls:Create(responseObj)
    -- body
    if responseObj.errorcode == 0 then
        local index = self._context:get_unique_component(MyIndexComponent).index
        local indexEntityIndex = self._context:get_entity_index(IndexComponent)
        local entity = indexEntityIndex:get_entity(index)
        entity.room.isCreated = true
        entity.room.roomid = responseObj.roomid
        self:SendJoin()
    elseif responseObj.errorcode == 10 then
        log.error("has create room.")
    elseif responseObj.errorcode == 13 then
        log.error("create room more than max.")
    end
end

function cls:SendJoin()
    -- body
    local index = self._context:get_unique_component(MyIndexComponent).index
    local indexEntityIndex = self._context:get_entity_index(IndexComponent)
    local entity = indexEntityIndex:get_entity(index)
    local request = {}
    request.roomid = entity.room.roomid
    self._appContext.networkMgr.client:send_request("join", request) 
end

-- 发送重新加入指令
function cls:SendRejoin()
    self._appContext.networkMgr.client:send_request("rejoin") 
end

--
function cls:Add(entity, orient, player)
    -- body
    log.info("%d", orient * 10 + player.sex)
    local playItem = self._appContext.config.config.play[orient * 10 + player.sex]
    local handItem = self._appContext.config.config.hand[orient * 10  + player.sex]

    entity:add(PlayerComponent, player.idx, player.sex, player.chip, player.name, orient, false, nil)
    entity:add(HandCardsComponent,
        playItem.LeftOffset,
        playItem.BottomOffset,
        vector(),
        playItem.SortCardsDelta,
        playItem.PGSortCardsDelta,
        playItem.DealCardDelta,
        playItem.FangDaoPaiDelta)

    local quaternion = array(6)()
    if orient == Player.Orient.BOTTOM then
        quaternion[0] = CS.UnityEngine.Quaternion.Euler(30.0, 0.0, 0.0)
        quaternion[1] = CS.UnityEngine.Quaternion.Euler(30.0, 0.0, 0.0)
    elseif orient == Player.Orient.RIGHT then
        quaternion[0] = CS.UnityEngine.Quaternion.Euler(0.0, -90.0, 0.0)
        quaternion[1] = CS.UnityEngine.Quaternion.Euler(0.0, -90.0, 0.4)
    elseif orient == Player.Orient.TOP then
        quaternion[0] = CS.UnityEngine.Quaternion.Euler(0.0, 180.0, 0.0)
        quaternion[1] = CS.UnityEngine.Quaternion.Euler(0.0, 180.0, 0.0)
    elseif orient == Player.Orient.LEFT then
        quaternion[0] = CS.UnityEngine.Quaternion.Euler(0.0, 90.0, 0.0)
        quaternion[1] = CS.UnityEngine.Quaternion.Euler(0.0, 90.0, 0.0)
    end

    -- entity:add(HandComponent, nil, nil,
    --         CS.UnityEngine.Vector3(handItem.RHandInitPos[0], handItem.RHandInitPos[1], handItem.RHandInitPos[2]),
    --         quaternion[0],
    --         CS.UnityEngine.Vector3(handItem.RHandDiuszOffset[0], handItem.RHandDiuszOffset[1], handItem.RHandDiuszOffset[2]),
    --         CS.UnityEngine.Vector3(handItem.RHandTakeOffset[0], handItem.RHandTakeOffset[1], handItem.RHandTakeOffset[2]),
    --         CS.UnityEngine.Vector3(handItem.RHandLeadOffset[0], handItem.RHandLeadOffset[1], handItem.RHandLeadOffset[2]),
    --         CS.UnityEngine.Vector3(handItem.RHandNaOffset[0], handItem.RHandNaOffset[1], handItem.RHandNaOffset[2]),
    --         CS.UnityEngine.Vector3(handItem.RhandPGOffset[0], handItem.RhandPGOffset[1], handItem.RhandPGOffset[2]),
    --         CS.UnityEngine.Vector3(handItem.RHandHuOffset[0], handItem.RHandHuOffset[1], handItem.RHandHuOffset[2]),
    --         CS.UnityEngine.Vector3(handItem.LHandInitPos[0], handItem.LHandInitPos[0], handItem.LHandInitPos[0]),                 -- TODO:
    --         quaternion[1],
    --         CS.UnityEngine.Vector3(handItem.LHandHuOffset[0], handItem.LHandHuOffset[1], handItem.LHandHuOffset[2]),
    --         handItem.DiuszShenDelta,
    --         handItem.DiuszShouDelta,
    --         handItem.ChuPaiShenDelta,
    --         handItem.ChuPaiShouDelta,
    --         handItem.NaPaiShenDelta,
    --         handItem.FangPaiShouDelta,
    --         handItem.HuPaiShenDelta,
    --         handItem.HuPaiShouDelta,
    --         handItem.PGShenDelta,
    --         handItem.PGShouDelta)

    -- entity:add(HoldCardComponent, nil,
    --     CS.UnityEngine.Vector3(playItem.HoldNaMove[0], playItem.HoldNaMove[1], playItem.HoldNaMove[2]),
    --     playItem.HoldNaMoveDelta,
    --     playItem.HoldFlyDelta,
    --     playItem.HoldDownDelta,
    --     playItem.HoldInsSortCardsdelta,
    --     playItem.HoldAfterPGDelta)

    -- entity:add(HuCardsComponent, playItem.HuRightOffset, playItem.HuBottomOffset, vector())
    -- entity:add(LeadCardsComponent, 0, false,
    --     CS.UnityEngine.Vector3(playItem.LeadCardMove[0], playItem.LeadCardMove[1], playItem.LeadCardMove[2]),
    --     playItem.LeadCardMoveDelta,
    --     playItem.LeadLeftOffset, playItem.LeadBottomOffset,
    --     vector())

    -- qu
    -- if orient == Player.Orient.BOTTOM then
    --     quaternion[0] = CS.UnityEngine.Quaternion.AngleAxis(0.0, CS.UnityEngine.Vector3.up)          -- upv
    --     quaternion[1] = CS.UnityEngine.Quaternion.AngleAxis(-90.0, CS.UnityEngine.Vector3.up)        -- uph
    --     quaternion[2] = CS.UnityEngine.Quaternion.AngleAxis(180.0, CS.UnityEngine.Vector3.forward)   -- downh
    --     quaternion[3] = CS.UnityEngine.Quaternion.AngleAxis(-90.0, CS.UnityEngine.Vector3.right)     -- backvst
    --     quaternion[4] = CS.UnityEngine.Quaternion.AngleAxis(-25.0, CS.UnityEngine.Vector3.right)     -- backv
    -- elseif orient == Player.Orient.RIGHT then
    --     quaternion[0] = CS.UnityEngine.Quaternion.AngleAxis(-90.0, CS.UnityEngine.Vector3.up)
    --     quaternion[1] = CS.UnityEngine.Quaternion.AngleAxis(-180.0, CS.UnityEngine.Vector3.up)
    --     quaternion[2] = CS.UnityEngine.Quaternion.AngleAxis(-90.0, CS.UnityEngine.Vector3.up):Dot(Quaternion.AngleAxis(180.0, CS.UnityEngine.Vector3.forward))
    --     quaternion[3] = CS.UnityEngine.Quaternion.Euler(-120.0, -90.0, 0.0)
    --     quaternion[4] = CS.UnityEngine.Quaternion.Euler(-90.0, -90.0, 0.0)
    -- elseif orient == Player.Orient.TOP then
    --     quaternion[0] = CS.UnityEngine.Quaternion.AngleAxis(180.0, CS.UnityEngine.Vector3.up)
    --     quaternion[1] = CS.UnityEngine.Quaternion.AngleAxis(90.0, Vector3.up)
    --     quaternion[2] = CS.UnityEngine.Quaternion.AngleAxis(180.0, CS.UnityEngine.Vector3.up):Dot(Quaternion.AngleAxis(180.0, Vector3.forward))
    --     quaternion[3] = CS.UnityEngine.Quaternion.AngleAxis(180.0, Vector3.up) * Quaternion.AngleAxis(-120.0, Vector3.right)
    --     quaternion[4] = CS.UnityEngine.Quaternion.AngleAxis(180.0, Vector3.up) * Quaternion.AngleAxis(-90.0, Vector3.right)
    -- elseif orient == Player.Orient.LEFT then
    --     quaternion[0] = CS.UnityEngine.Quaternion.AngleAxis(90.0, Vector3.up)
    --     quaternion[1] = CS.UnityEngine.Quaternion.AngleAxis(0.0, Vector3.up)
    --     quaternion[2] = CS.UnityEngine.Quaternion.AngleAxis(90.0, Vector3.up) * Quaternion.AngleAxis(180.0, Vector3.forward)
    --     quaternion[3] = CS.UnityEngine.Quaternion.AngleAxis(90.0, Vector3.up) * Quaternion.AngleAxis(-120.0, Vector3.right)
    --     quaternion[4] = CS.UnityEngine.Quaternion.AngleAxis(90.0, Vector3.up) * Quaternion.AngleAxis(-90.0, Vector3.right)
    -- end

    -- entity:add(PlayerCardComponent, 0, 0, false, Card.CardType.Bam, false,
    --     quaternion[0],
    --     quaternion[1],
    --     quaternion[2],
    --     quaternion[3],
    --     quaternion[4],
    --     0, vector(), 0, 0, 0, vector(), nil, nil)

    -- entity:add(PutCardsComponent, playItem.PutMoveDelta, playItem.PutMargin, CS.UnityEngine.Vector3(playItem.PutMove[0], playItem.PutMove[1], playItem.PutMove[2]), playItem.PutRightOffset, playItem.PutBottomOffset, 0, vector())
    -- entity:add(TakeCardsComponent, playItem.TakeLeftOffset, playItem.TakeBottomOffset, playItem.TakeMove, playItem.TakeMoveDelta, 0, 0, 0, {})
    entity:add(HeadComponent, HeadUIContext.new(self._appContext))
    entity.head.headUIContext.Orient = orient
    entity.head.headUIContext:SetGold(player.chip)

    -- self._gameSystems.netIdxSystem.AddEntity(entity)
    self._gameSystems.netIdxSystem:ShowHeadFirst()
    self._gameSystems.netIdxSystem:LoadHand()

    return true
end

-- 请求加入返回值
function cls:Join(responseObj)
    -- body
    if responseObj.errorcode == 0 then
        -- 加入房间成功
        local index = self._context:get_unique_component(MyIndexComponent).index
        local indexEntityIndex = self._context:get_entity_index(IndexComponent)
        local entity = indexEntityIndex:get_entity(index)
        entity.room.room_max = responseObj.room_max
        entity.room.rule = responseObj.rule
        entity.player.idx = responseObj.me.idx
        entity.player.chip = responseObj.me.chip
        entity.player.name = responseObj.me.name
        entity.player.sex = responseObj.me.sex

        -- 创建房间，并且跳转到场景
        local context = Context.new()
        context:set_unique_component(SceneComponent, "game")
        context:set_unique_component(MyIndexComponent, entity.index.index)
        context:set_unique_component(RuleComponent, GameType.GAME, 0, 0, 0, 0, 0, false, 0, 0, 0, false, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, vector(), nil, 0)

        local indexGroup = context:get_group(Matcher({IndexComponent}))
        local indexPrimaryIndex = PrimaryEntityIndex.new(IndexComponent, indexGroup, 'index')
        context:add_entity_index(indexPrimaryIndex)

        local userGroup = context:get_group(Matcher({UserComponent}))
        local userPrimaryIndex = PrimaryEntityIndex.new(UserComponent, userGroup, 'uid')
        context:add_entity_index(userPrimaryIndex)

        local playerGroup = context:get_group(Matcher({PlayerComponent}))
        local netidxPrimaryIndex = PrimaryEntityIndex.new(PlayerComponent, playerGroup, 'idx')
        context:add_entity_index(netidxPrimaryIndex)

        local myEntity = context:create_entity()
        for k,v in pairs(entity._components) do
            if not myEntity:has(k) then
                print(k,k.__comp_name)
                myEntity:add(k, v)
            end
        end
        -- self._context:destroy_entity(entity)

        -- assert(self:Add(myEntity, Player.Orient.BOTTOM, responseObj.me))
        -- context.rule.online = context.rule.online + 1
        -- context.rule.joined = context.rule.joined + 1

        if responseObj.ps then
            for _,v in pairs(responseObj.ps) do
                local entity = context:create_entity()
                local offset = 0
                if v.idx > responseObj.me.idx then
                    offset = v.idx - responseObj.me.idx
                else
                    offset = v.idx + 4 - responseObj.me.idx;
                end
                if offset == 1 then
                    self:Add(entity, Player.Orient.RIGHT, v)
                elseif offset == 2 then
                    self:Add(entity, Player.Orient.TOP, v)
                elseif offset == 3 then
                    self:Add(entity, Player.Orient.LEFT, v)
                end
                context.rule.online = context.rule.online + 1
                context.rule.joined = context.rule.joined + 1
            end
        end

        local param = {}
        param.transferType = TransferType.Direct
        self._appContext:Push(context, param)
    else
        log.info(responseObj.errorcode)
        local id = self._appContext.config.config.errorcode[responseObj.errorcode].language
        log.error(language(id))
    end
end

function cls:Rejoin(responseObj)
    -- body
    if responseObj.errorcode == 0 then
        -- 加入房间成功
        local sceneName = self._context:get_unique_component(SceneComponent).name
        if sceneName ~= 'game' then
            self:Join(responseObj)
        else
            local index = self._context:get_unique_component(MyIndexComponent).index
            local indexEntityIndex = self._context:get_entity_index(IndexComponent)
            local entity = indexEntityIndex:get_entity(index)
            entity.room.room_max = responseObj.room_max
            entity.room.rule = responseObj.rule
            entity.player.idx = responseObj.me.idx
            entity.player.chip = responseObj.me.chip
            entity.player.name = responseObj.me.name
            entity.player.sex = responseObj.me.sex
            print(entity)
        end
    else
        log.info(responseObj.errorcode)
        local id = self._appContext.config.config.errorcode[responseObj.errorcode].language
        log.error(language(id))
    end
end

function cls:Leave( ... )
    -- body
    -- IEntity entity = _gameSystems.NetIdxSystem.FindEntity(idx)
    --         _gameSystems.NetIdxSystem.RemoveEntity(entity)
end

function cls:OnJoin(requestObj)
    -- body
    assert(self._context.scene.name == 'game')
end

function cls:OnLeave(requestObj, ... )
    -- body
    local obj = requestObj
    self:Leave(obj.idx)

    local responseObj = {}
    responseObj.errorcode = Errorcode.SUCCESS;
    return responseObj;
end

function cls:OnEnter(context, param, ... )
    -- body
    log.info("OnEnter scene name = ", context.scene.name)
    if context.scene.name == "game" then
        scene_mgr.LoadScene("game", function ( ... )
            -- body
        end)
    end
end

return cls