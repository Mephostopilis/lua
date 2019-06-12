local log = require "log"
local res = require "res"
local sound = require "sound"
local vector = require "chestnut.vector"
local array = require "chestnut.array"
local Card = require "bacon.game.Card"
local Player = require "bacon.game.Player"

local cls = class("PlayerSystem")

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
    -- local listener2 = CS.Maria.Event.EventListenerCmd(MyEventCmd.EVENT_SETUP_HAND, cls.OnSetupHand)
    -- self._appContext.EventDispatcher.AddCmdEventListener(listener2)
end

function cls:SetXuanQue(idx, value) 
    local entity = self._gameSystems.netIdxSystem:FindEntity(idx)
    entity.playerCard.hasXuanQue = value
end

-- <summary>
-- 
-- </summary>
-- <param name="who">网络索引</param>
-- <param name="nx"></param>
-- <returns>是否拿到牌</returns>
function cls:TakeCard(who) 
    local player = self._gameSystems.netIdxSystem:FindEntity(who)
    if player.takeCards.takecardscnt > 0 then
        if player.takeCards.takecardsidx >= player.takeCards.takecardslen then
            player.takeCards.takecardsidx = 0
            return false, 0
        end

        local cardEntity = player.takeCards.takecards[player.takeCards.takecardsidx]
        cardEntity.card.pos = 0
        cardEntity.card.parent = 0
        local index = cardEntity.index.index

        player.takeCards.takecardscnt = player.takecards.takecardscnt - 1
        player.takeCards.takecards.Remove(player.takeCards.takecardsidx)
        player.takeCards.takecardsidx = player.takeCards.takecardsidx + 1

        return true, index
    else
        return false, 0
    end
end

function cls:CalcPos(entity, pos)
    local deskEntity = self._gameSystems.DeskSystem.FindEntity()
    if entity.player.orient == Player.Orient.BOTTOM then
        local Card = self._appContext.config.card
        local x = entity.handCards.leftoffset + Card.Width * pos + Card.Width / 2.0
        local y = Card.Length / 2.0 + Card.HeightMZ
        y = 0.1
        local z = entity.handCards.bottomoffset + Card.Height / 2.0
        z = 0.235
        return CS.UnityEngine.Vector3(x, y, z)
    elseif entity.player.orient == Player.Orient.RIGHT then
        local x = deskEntity.desk.width - (entity.handCards.bottomoffset + Card.Height / 2.0)
        x = entity.handCards.bottomoffset
        local y = Card.Length / 2.0 + Card.HeightMZ
        local z = entity.handCards.leftoffset + Card.Width * pos + Card.Width / 2.0
        return CS.UnityEngine.Vector3(x, y, z)
    elseif entity.player.orient == Player.Orient.TOP then
        local x = deskEntity.desk.width - (entity.handCards.leftoffset + Card.Width * pos + Card.Width / 2.0)
        local y = Card.Length / 2.0 + Card.HeightMZ
        local z = entity.handCards.bottomoffset
        return CS.UnityEngine.Vector3(x, y, z)
    else
        local x = entity.handCards.bottomoffset + Card.Height / 2.0
        local y = Card.Length / 2.0 + Card.HeightMZ
        local z = deskEntity.desk.length - (entity.handCards.leftoffset + Card.Width * pos + Card.Width / 2.0)
        return CS.UnityEngine.Vector3(x, y, z)
    end
end

function cls:CalcLeadPos(entity, pos)
    local deskEntity = self._gameSystems.DeskSystem.FindEntity()

    --int row = (pos + 1) / 6
    --int col = (pos + 1) % 6
    local row = (pos) / 6
    local col = (pos) % 6

    local x = entity.leadCards.leadleftoffset + (Card.Width * col) + (Card.Width / 2.0)
    local y = Card.Height / 2.0 + Card.HeightMZ
    local z = entity.leadCards.leadbottomoffset - (Card.Length * row) - (Card.Length / 2.0)

    return CS.UnityEngine.Vector3(x, y, z)
end

function cls:CalcHuPos(entity, pos)
    local deskEntity = self._gameSystems.DeskSystem.FindEntity()
    if entity.player.orient == Player.Orient.BOTTOM then
        local x = deskEntity.desk.width - (entity.huCards.hurightoffset + (Card.Width / 2.0) + (Card.Width * pos))
        local y = Card.Height / 2.0
        local z = entity.huCards.hubottomoffset + Card.Length / 2.0
        return CS.UnityEngine.Vector3(x, y, z)
    elseif entity.player.orient == Player.Orient.RIGHT then
        local x = deskEntity.desk.width - (entity.huCards.hubottomoffset + Card.Length / 2.0)
        local y = Card.Height / 2.0
        local z = deskEntity.desk.length - (entity.huCards.hurightoffset + Card.Width / 2.0 + Card.Width * pos)
        return CS.UnityEngine.Vector3(x, y, z)
    elseif entity.player.orient == Player.Orient.TOP then
        local x = entity.huCards.hurightoffset + Card.Width / 2.0 + Card.Width * pos
        local y = Card.Height / 2.0
        local z = deskEntity.desk.length - (deskEntity.huCards.hubottomoffset + Card.Length / 2.0)
        return CS.UnityEngine.Vector3(x, y, z)
    else
        local x = entity.huCards.hubottomoffset + Card.Length / 2.0
        local y = Card.Height / 2.0
        local z = entity.huCards.hurightoffset + Card.Width / 2.0 + (Card.Width * pos)
        return CS.UnityEngine.Vector3(x, y, z)
    end
end

function cls:CalcPGPos(entity, pos)
    if entity.player.orient == Player.Orient.BOTTOM then
    elseif entity.player.orient == Player.Orient.RIGHT then
    elseif entity.player.orient == Player.Orient.TOP then
    else
    end
    return CS.UnityEngine.Vector3.zero
end

function cls:Insert(entity, cardEntity)
    assert(entity.handCards.cards.Count > 0)

    entity.handCards.cards:push_back(cardEntity)
    local last = #entity.handCards.cards - 1
    cardEntity.card.pos = last
    cardEntity.card.parent = entity.index.index
    assert(entity.handCards.cards[last].card.value == cardEntity.card.value)

    for i=last-1,0,-1 do
        if self._gameSystems.CardSystem.CompareTo(entity.handCards.cards[i + 1], entity.handCards.cards[i]) < 0 then

            tmpEntity = entity.handCards.cards[i + 1]
            entity.handCards.cards[i + 1] = entity.handCards.cards[i]
            entity.handCards.cards[i + 1].card.pos = i + 1
            entity.handCards.cards[i] = tmpEntity
            entity.handCards.cards[i].card.pos = i
        end
    end
end

function cls:Remove(entity, cardEntity)
    local last = #entity.handCards.cards - 1

    for i=cardEntity.card.pos,last do
        entity.handCards.cards[i] = entity.handCards.cards[i + 1]
        entity.handCards.cards[i].card.pos = i
    end
    
    cardEntity.card.pos = -1
    cardEntity.card.parent = -1
    entity.handCards.cards.RemoveAt(last)
end

function cls:RemovePG(entity, cardEntity)
    local pg = entity.putCards.putcards[entity.putCards.putidx]
    if pg.cards[0].card == cardEntity.card then
        pg.cards.Remove(cardEntity)
    else
        -- foreach (local item in entity.putCards.putcards)

        -- end
    end
end

function cls:AppendLead(entity, cardEntity)
    entity.leadCards.leadcards.Add(cardEntity)
    cardEntity.card.pos = entity.leadCards.leadcards.Count - 1
    cardEntity.card.parent = entity.index.index
end

function cls:RemoveLead(whoEntity, cardEntity)
    UnityEngine.Debug.Assert(whoEntity.leadCards.leadcards.Count > 0)
    otherEntity = whoEntity.leadCards.leadcards[whoEntity.leadCards.leadcards.Count - 1]
    UnityEngine.Debug.Assert(cardEntity.card.value == otherEntity.card.value)
    cardEntity.card.pos = -1
    cardEntity.card.parent = -1
    whoEntity.leadCards.leadcards.Remove(cardEntity)
end

function cls:AppendHu(entity, cardEntity) 
    entity.huCards.hucards.Add(cardEntity)
    cardEntity.card.pos = #entity.huCards.hucards - 1
    cardEntity.card.parent = entity.index.index
end

function cls:TakeXuanPao() 
    self:RenderTakeXuanPao()
end

function cls:XuanPao()
    self:RenderXuanPao()
end

-- <summary>
-- 洗牌后玩家砌一长条
-- </summary>
-- <param name="cs"></param>
-- <param name="cards"></param>
function cls:Boxing(entity, cs)
    if entity.takeCards.takecards == nil then
        entity.takeCards.takecards = array(#cs)()
    end
    for i=1,#cs do
        local value = cs[i]
        local cardEntity = self._gameSystems.cardValueIndexSystem:FindEntity(value)
        assert(cardEntity.card.parent == 0)
        cardEntity.card.parent = entity.index.index
        cardEntity.card.pos = i
        entity.takeCards.takecards[i] = cardEntity
    end
    entity.takeCards.takecardsidx = 1
    entity.takeCards.takecardscnt = #cs
    entity.takeCards.takecardslen = #cs
    assert(#cs == 28 or #cs == 26)
    self:RenderBoxing(entity)
end

function cls:ThrowDice(entity, d1, d2)
    self._appContext.EnqueueRenderQueue(RenderThrowDice)
end

-- <summary>
-- 拿牌，每个人拿十三张
-- </summary>
-- <param name="entity"></param>
function cls:Deal(entity)
    local cards = self._gameSystems.GameSystem.TakeBlock()
    assert(#cards == 4 or #cards == 1)

    for i=1,#cards do
        cardEntity = self._gameSystems.IndexSystem.FindEntity(cards[i])
        entity.handCards.cards.Add(cardEntity)
        cardEntity.card.parent = entity.index.index
        cardEntity.card.pos = i - 1
    end
    RenderDeal()
end

-- function cls:QuickSort(cards, int low, int high)
--     if (low >= high)
--         return
--     end
--     int first = low
--     int last = high
--     local keyEntity = cards[first]
--     while (first < last)
--         while (first < last)
--             local dstEntity = cards[last]
--             if (_gameSystems.CardSystem.CompareTo(dstEntity, keyEntity) > 0)  -- dstEntity > keyEntity
--                 dstEntity.card.pos = last
--                 --last
--             end else  -- dstEntity < keyEntity
--                 cards[first] = dstEntity
--                 cards[first].card.pos = first
--                 break
--             end
--         end
--         while (first < last)
--             local dstEntity = cards[first]
--             if (_gameSystems.CardSystem.CompareTo(dstEntity, keyEntity) < 0)
--                 dstEntity.card.pos = first
--                 ++first
--             end else
--                 cards[last] = dstEntity
--                 cards[last].card.pos = last
--                 break
--             end
--         end
--     end
--     cards[first] = keyEntity
--     cards[first].card.pos = first

--     QuickSort(cards, low, first - 1)
--     QuickSort(cards, first + 1, high)
-- end

-- <summary>
-- 整理自己拿到的牌
-- </summary>
function cls:SortCards(entity)
    -- QuickSort(entity.handCards.cards, 0, entity.handCards.cards.Count - 1)
    -- TODO: 
    -- entity.handCards.cards:sort(function (l, r, ... )
    --     -- body
    -- end)
    for i=1,entity.handCards.cards.Count do
        if entity.handCards.cards[i].card.pos ~= i then
            UnityEngine.Debug.Assert(false)
        end
    end
end

function cls:TakeFirsteCard(entity, c)
    assert(self._context.rule.curidx == self._context.rule.firstidx)
    
    -- card = 本地索引
    local ok, card = self._gameSystems.gameSystem:TakeCard()
    if ok then
        entity.holdCard.holdCardEntity = self._gameSystems.indexSystem:FindEntity(card)
        assert(entity.holdCard.holdCardEntity.card.value == c)
        self:RenderTakeFirstCard()
    end
end

function cls:TakeXuanQue()
    self:RenderTakeXuanQue()
end

function cls:ShowQue(who, cardType)
    local entity = self._gameSystems.netIdxSystem:FindEntity(who)
    entity.head.headUIController.SetQue(cardType)
    entity.head.headUIController.Shaking()
end

function cls:XuanQue(who, que)
    -- 由于在选择的时候动画已经做过，所以这里不需要对自己做
    local entity = self._gameSystems.NetIdxSystem.FindEntity(who)
    if self._context.rule.myidx ~= who then
        entity.playerCard.que = que
        entity.head.headUIController.SetQue(entity.playerCard.que)
        entity.head.headUIController.Shaking()
    else
        if not entity.playerCard.hasXuanQue then
            -- GameUIModule module = _appContext.U.GetModule<GameUIModule>()
            -- if (module.XuanQueUIController.Counter > 0 && module.XuanQueUIController.IsTop)
            --     _appContext.UIContextManager.Pop()
            -- end
            -- entity.playerCard.que = que
            -- entity.head.headUIController.SetQue(entity.playerCard.que)
            -- entity.head.headUIController.Shaking()
        end
    end

    for _,item in pairs(entity.handCards.cards) do
        self._gameSystems.CardSystem.SetQue(item.index.index, que)
    end
    
    if self._context.rule.firstidx == who then
        _gameSystems.CardSystem.SetQue(entity.holdCard.holdCardEntity.index.index, que)
    end
    -- QuickSort(entity.handCards.cards, 0, entity.handCards.cards.Count - 1)
end

function cls:TakeTakeCard(entity, c)

    local ok, card = self._gameSystems.gameSystem:TakeCard()
    if ok then
        entity.holdCard.holdCardEntity = _gameSystems.IndexSystem.FindEntity(card)
        self._gameSystems.CardSystem.SetQue(entity.holdCard.holdCardEntity.index.index, entity.playerCard.que)

        assert(entity.holdCard.holdCardEntity.card.value == c)
        self:RenderTakeTakeCard()
    end
end

function cls:TakeTurn(entity, cd) 
    _appContext.EnqueueRenderQueue(RenderTakeTurn)
end

function cls:Lead(entity, c, isHoldcard)
    assert(entity.holdCard.holdCardEntity ~= null)
    if isHoldcard then
        assert(entity.holdCard.holdCardEntity.card.value == c)
        self._gameSystems.cardSystem.Clear(entity.holdCard.holdCardEntity.index.index)
        self:AppendLead(entity, entity.holdCard.holdCardEntity)
        entity.leadCards.leadcard = entity.holdCard.holdCardEntity.index.index
        entity.leadCards.isHoldCard = true
        entity.holdCard.holdCardEntity = nil

    else
        local cardEntity = _gameSystems.CardValueIndexSystem.FindEntity(c)
        if cardEntity then
            UnityEngine.Debug.Assert(cardEntity.card.value == c)
            Remove(entity, cardEntity)
            AppendLead(entity, cardEntity)
            entity.leadCards.isHoldCard = false
            entity.leadCards.leadcard = cardEntity.index.index

            -- insert holdcard
            self:Insert(entity, entity.holdCard.holdCardEntity)
            -- 必须保留此变量作为后面移动表现
            --entity.holdCard.holdCardEntity = null
        else
            log.error("card value0end not found.", c)
        end
    end
    self:RenderLead()
end

function cls:SetupCall(entity)
    self:RenderCall()
end

function cls:Peng(whoEntity, dianEntity, cardEntity, hor)
    local cards = vector()
    for i=1,whoEntity.handCards.cards.Count do
        if (whoEntity.handCards.cards[i].card == cardEntity.card) then
            cards.Add(whoEntity.handCards.cards[i])
        end
        if (cards.Count == 2) then
            break
        end
    end
    assert(cards.Count == 2)
    for i=1,cards.Count do
        self:Remove(whoEntity, cards[i])
    end

    self:RemoveLead(dianEntity, cardEntity)
    cards.Add(cardEntity)
    assert(cards.Count == 3)

    local pgcards = {}
    -- pgcards.opcode = OpCodes.OPCODE_NONE
    pgcards.opcode = OpCodes.OPCODE_PENG
    pgcards.hor = hor
    pgcards.width = 0
    pgcards.cards = cards

    whoEntity.putCards.putcards.Add(pgcards)
    whoEntity.putCards.putidx = whoEntity.putCards.putcards.Count - 1

    self._context.rule.curidx = whoEntity.player.idx
    self._appContext.EnqueueRenderQueue(RenderPeng)
end

-- <summary>
-- 
-- </summary>
-- <param name="entity"></param>
-- <param name="code">杠的类型</param>
-- <param name="dian"></param>
-- <param name="c"></param>
-- <param name="hor"></param>
-- <param name="isHoldcard"></param>
-- <param name="isHoldcardInsLast"></param>
function cls:Gang(entity, code, dian, c, hor, isHoldcard, isHoldcardInsLast)
    cardEntity = _gameSystems.CardValueIndexSystem.FindEntity(c)
    if (code == GangType.ZHIGANG) then
        local cards = vector()
        for i=1,entity.handCards.cards.Count do
            if (cardEntity == entity.handCards.cards[i]) then
                cards:push_back(entity.handCards.cards[i])
            end
            if #cards == 3 then
                break
            end
        end
        

        assert(cards.Count == 3)
        for i,v in ipairs(cards) do
            self:Remove(entity, cards[i])
        end

        local dianEntity = _gameSystems.NetIdxSystem.FindEntity(dian)
        self:RemoveLead(dianEntity, cardEntity)
        cards.Add(cardEntity)
        assert(cards.Count == 4)

        local pg = {}
        pg.cards = cards
        pg.opcode = OpCodes.OPCODE_GANG
        pg.gangtype = code
        pg.hor = hor
        pg.width = 0
        pg.isHoldcard = isHoldcard
        pg.isHoldcardInsLast = isHoldcardInsLast
        entity.putCards.putcards.Add(pg)
        entity.putCards.putidx = entity.putCards.putcards.Count - 1
        assert(not pg.isHoldcard and not pg.isHoldcardInsLast)
    elseif (code == GangType.ANGANG) then
        assert(entity.holdCard.holdCardEntity ~= nil)
        local cards = vector()
        local pg = {}
        if (isHoldcard) then
            assert(entity.holdCard.holdCardEntity.card == cardEntity.card)
            for i=1,#entity.handCards.cards do
                if (cardEntity.card == entity.handCards.cards[i].card) then
                    cards.Add(entity.handCards.cards[i])
                    entity.handCards.cards[i].card.pos = cards.Count - 1
                end
                if (cards.Count == 3) then
                    break
                end
            end
            
            assert(cards.Count == 3)
            for i=1,#cards do
                self:Remove(entity, cards[i])
            end
            cards.Add(entity.holdCard.holdCardEntity)
            entity.holdCard.holdCardEntity.card.pos = cards.Count - 1
            entity.holdCard.holdCardEntity = null
            pg.isHoldcard = isHoldcard
            pg.isHoldcardInsLast = false
        else
            for i=1,#entity.handCards.cards do
                if (cardEntity.card == entity.handCards.cards[i].card) then
                    cards.Add(entity.handCards.cards[i])
                    entity.handCards.cards[i].card.pos = cards.Count - 1
                end
                if (cards.Count == 4) then
                    break
                end
            end
            assert(#cards == 4)
            for i=1,#cards do
                self:Remove(entity, cards[i])
            end
            
            self:Insert(entity, entity.holdCard.holdCardEntity)
            if (entity.holdCard.holdCardEntity.card.pos == entity.handCards.cards.Count - 1) then
                pg.isHoldcardInsLast = true
            end
            entity.holdCard.holdCardEntity = null
            pg.isHoldcard = false
        end

        assert(#cards == 4)
        pg.cards = cards
        pg.opcode = OpCodes.OPCODE_GANG
        pg.gangtype = code
        pg.hor = hor
        pg.width = 0
        entity.putCards.putcards.Add(pg)
        entity.putCards.putidx = entity.putCards.putcards.Count - 1
    elseif (code == GangType.BUGANG) then
        local pg = nil
        for i=1,#entity.putCards.putcards do
            pg = entity.putCards.putcards[i]
            if (pg.opcode == OpCodes.OPCODE_PENG and pg.cards[0].card == cardEntity.card) then
                UnityEngine.Debug.Assert(pg.cards.Count == 3)
                entity.putCards.putidx = i
                break
            end
        end
        assert(pg ~= nil)

        pg.gangtype = code

        if (isHoldcard) then
            UnityEngine.Debug.Assert(cardEntity.card == entity.holdCard.holdCardEntity.card)
            entity.holdCard.holdCardEntity = nil
            pg.cards.Add(cardEntity)
            cardEntity.card.pos = pg.cards.Count - 1
            pg.isHoldcard = isHoldcard
            pg.isHoldcardInsLast = false
        else
            Remove(entity, cardEntity)
            pg.cards.Add(cardEntity)
            cardEntity.card.pos = pg.cards.Count - 1
            pg.isHoldcard = isHoldcard
            pg.isHoldcardInsLast = false
        end

    else
        assert(false)
    end
    self:RenderGang()
end

function cls:Hu(entity, c, dian, jiao, hutype) 
    local cardEntity = self._gameSystems.CardValueIndexSystem.FindEntity(c)
    if jiao == JiaoType.PINGFANG then
        local dianEntity = self._gameSystems.netIdxSystem:FindEntity(dian)
        self:RemoveLead(dianEntity, cardEntity)
        entity.huCards.hucards:push_back(cardEntity)
    elseif jiao == JiaoType.GANGSHANGPAO then
        local dianEntity = _gameSystems.NetIdxSystem.FindEntity(dian)
        self:RemoveLead(dianEntity, cardEntity)
        entity.huCards.hucards:push_back(cardEntity)
    elseif (jiao == JiaoType.QIANGGANGHU) then
        local dianEntity = self._gameSystems.NetIdxSystem.FindEntity(dian)
        RemovePG(dianEntity, cardEntity)
        entity.huCards.hucards.Add(cardEntity)
    elseif (jiao == JiaoType.DIANGANGHUA) then
        UnityEngine.Debug.Assert(c == entity.holdCard.holdCardEntity.card.value)
        entity.huCards.hucards.Add(entity.holdCard.holdCardEntity)
        entity.holdCard.holdCardEntity = null
    elseif (jiao == JiaoType.ZIGANGHUA) then
        UnityEngine.Debug.Assert(c == entity.holdCard.holdCardEntity.card.value)
        entity.huCards.hucards.Add(entity.holdCard.holdCardEntity)
        entity.holdCard.holdCardEntity = null
    elseif (jiao == JiaoType.ZIMO) then
        UnityEngine.Debug.Assert(c == entity.holdCard.holdCardEntity.card.value)
        entity.huCards.hucards.Add(cardEntity)
        entity.holdCard.holdCardEntity = null
    end

    --if (!_hashu)
    --    _hashu = true
    --end
    self:RenderHu()
end

        --function cls:HuSettle()
        --    UnityEngine.Debug.Assert(_settle.Count >= 1)
        --    _ctx.EnqueueRenderQueue(RenderHuSettle)
        --end

        --protected virtual void RenderHuSettle() end

        --protected virtual void RenderOver() end

        --protected virtual void RenderOverShen(Action<Action> act31, cb)
        --    -- 1.0 伸手
        --    Animator ranimator = _rhand.GetComponent<Animator>()
        --    ranimator.SetTrigger("BeforeHupai")

        --    _lhand.SetActive(true)
        --    Animator lanimator = _rhand.GetComponent<Animator>()
        --    lanimator.SetTrigger("BeforeHupai")

        --    -- 5.0
        --    act5 = delegate ()
        --        -- 发事件
        --        cb()
        --    end

        --    -- 3.0 放到牌
        --    act3 = delegate ()
        --        act31(() =>
        --            -- 4.0 收手
        --            _oknum = 0
        --            Sequence mySequence4r = DOTween.Sequence()
        --            mySequence4r.Append(_rhand.transform.DOLocalMove(_rhandinitpos, _hupaishoudelta))
        --            .AppendCallback(() =>
        --                _oknum++
        --                if (_oknum >= 2)
        --                    act5()
        --                end
        --            end)

        --            Sequence mySequence4l = DOTween.Sequence()
        --            mySequence4l.Append(_lhand.transform.DOLocalMove(_lhandinitpos, _hupaishoudelta))
        --            .AppendCallback(() =>
        --                _oknum++
        --                if (_oknum >= 2)
        --                    act5()
        --                end
        --            end)
        --        end)
        --    end

        --    -- 2.0
        --    act2 = delegate ()
        --        _oknum = 0
        --        Hand rhand = _rhand.GetComponent<Hand>()
        --        rhand.Rigster(Hand.EVENT.HUPAI_COMPLETED, () =>
        --            _oknum++
        --            if (_oknum >= 2)
        --                -- 3.0
        --                act3()
        --            end
        --        end)
        --        ranimator.SetBool("Hupai", true)

        --        Hand lhand = _lhand.GetComponent<Hand>()
        --        lhand.Rigster(Hand.EVENT.HUPAI_COMPLETED, () =>
        --            _oknum++
        --            if (_oknum >= 2)
        --                -- 3.0
        --                act3()
        --            end
        --        end)
        --        lanimator.SetBool("Hupai", true)
        --    end

        --    _oknum = 0
        --    Tween t1r = _rhand.transform.DOLocalMove(_cards[_cards.Count - 1].Go.transform.localPosition, _hupaishendelta)
        --    Sequence mySequence1r = DOTween.Sequence()
        --    mySequence1r.Append(t1r)
        --        .AppendCallback(() =>
        --            _oknum++
        --            if (_oknum >= 2)
        --                -- 2.0
        --                act2()
        --            end
        --        end)

        --    Tween t1l = _lhand.transform.DOLocalMove(_cards[0].Go.transform.localPosition, _hupaishendelta)
        --    Sequence mySequence1l = DOTween.Sequence()
        --    mySequence1l.Append(t1l)
        --        .AppendCallback(() =>
        --            _oknum++
        --            if (_oknum >= 2)
        --                -- 2.0
        --                act2()
        --            end
        --        end)
        --end

        --function cls:Settle() end

        --protected virtual void RenderSettle() end

        --function cls:FinalSettle() end

        --protected virtual void RenderFinalSettle() end

        --function cls:Restart()
        --    _ctx.EnqueueRenderQueue(RenderRestart)
        --end

        --protected virtual void RenderRestart() end

        --function cls:TakeRestart()
        --    UnityEngine.Debug.LogFormat("player0end take restart", _idx)
        --    _d1 = 0
        --    _d2 = 0

        --    _takecardsidx = 0
        --    _takecardscnt = 0
        --    _takecardslen = 0
        --    _takecards = new Dictionary<int, Card>()

        --    _takefirst = false                 -- 庄家
        --    _cards = new List<Card>()
        --    _leadcards = new List<Card>()

        --    _putidx = 0
        --    _putcards = new List<PGCards>()
        --    _hucards = new List<Card>()

        --    _holdcard = null
        --    _leadcard = null

        --    _turntype = 0
        --    _fen = 0
        --    _que = 0
        --    _hashu = false

        --    _wal = 0         -- 赢的钱或者输的钱
        --    _say = 0
        --end

        --protected virtual void RenderTakeRestart() end

        --function cls:Say(code)
        --    _say = code
        --end

        --protected virtual void RenderSay() end

        --function cls:ClearSettle()
        --    _settle.Clear()
        --end

        --function cls:AddSettle(SettlementItem item)
        --    _settle.Add(item)
        --end

-- region render
function cls:RenderLoadHand(entity)

    local root = CS.UnityEngine.GameObject.Find("Root")
    local go = CS.UnityEngine.GameObject()
    go.name = string.format("NetIdx_%d", entity.player.idx)
    go.transform:SetParent(root.transform)
    go:AddAudioSource()
    if (entity.player.orient == Player.Orient.BOTTOM) then
        go:AddComponent('BottomPlayer')
    end

    local rhand, lhand
    if (entity.player.sex == 1) then
        local rhandOriginal = res.LoadGameObject("Prefabs/Hand", "boyrhand")
        rhand = CS.UnityEngine.GameObject.Instantiate(rhandOriginal)

        local lhandOriginal = res.LoadGameObject("Prefabs/Hand", "boylhand")
        lhand = CS.UnityEngine.GameObject.Instantiate(lhandOriginal)
    else
        local rori = res.LoadGameObject("Prefabs/Hand", "girlrhand")
        rhand = CS.UnityEngine.GameObject.Instantiate(rori)

        local lori = res.LoadGameObject("Prefabs/Hand", "girllhand")
        lhand = CS.UnityEngine.GameObject.Instantiate(lori)
    end

    rhand.transform:SetParent(root.transform)
    rhand.transform.localPosition = entity.hand.rhandinitpos
    rhand.transform.localRotation = entity.hand.rhandinitrot

    lhand.transform:SetParent(root.transform)
    lhand.transform.localPosition = entity.hand.lhandinitpos
    lhand.transform.localRotation = entity.hand.lhandinitrot

    entity.hand.rhand = rhand
    entity.hand.lhand = lhand
    entity.player.go = go
end

function cls:RenderReady(entity)
    if entity.player.idx == 1 then
       if entity.player.orient == Player.Orient.BOTTOM then
           self._gameSystems.deskSystem.RenderSetDongAtBottom()
       elseif entity.player.orient == Player.Orient.RIGHT then
           self._gameSystems.DeskSystem.RenderSetDongAtRight()
       elseif entity.player.orient == Player.Orient.TOP then
           self._gameSystems.DeskSystem.RenderSetDongAtTop()
       elseif entity.player.orient == Player.Orient.LEFT then
           self._gameSystems.DeskSystem.RenderSetDongAtLeft()
       end
    elseif entity.player.idx == 2 then
       if entity.player.orient == Player.Orient.BOTTOM then
           self._gameSystems.DeskSystem.RenderSetNanAtBottom()
       elseif entity.player.orient == Player.Orient.RIGHT then
           self._gameSystems.DeskSystem.RenderSetNanAtRight()
       elseif entity.player.orient == Player.Orient.TOP then
           self._gameSystems.DeskSystem.RenderSetNanAtTop()
       elseif entity.player.orient == Player.Orient.LEFT then
           self._gameSystems.DeskSystem.RenderSetNanAtLeft()
       end
    elseif entity.player.idx == 3 then
       if entity.player.orient == Player.Orient.BOTTOM then
           self._gameSystems.deskSystem:RenderSetXiAtBottom()
       elseif entity.player.orient == Player.Orient.RIGHT then
           self._gameSystems.DeskSystem.RenderSetXiAtRight()
       elseif entity.player.orient == Player.Orient.TOP then
           self._gameSystems.DeskSystem.RenderSetXiAtTop()
       elseif entity.player.orient == Player.Orient.LEFT then
           self._gameSystems.DeskSystem.RenderSetXiAtLeft()
       end
    elseif entity.player.idx == 4 then
       if entity.player.orient == Player.Orient.BOTTOM then
           self._gameSystems.DeskSystem.RenderSetBeiAtBottom()
       elseif entity.player.orient == Player.Orient.RIGHT then
           self._gameSystems.DeskSystem.RenderSetBeiAtRight()
       elseif entity.player.orient == Player.Orient.TOP then
           self._gameSystems.DeskSystem.RenderSetBeiAtTop()
       elseif entity.player.orient == Player.Orient.LEFT then
           self._gameSystems.DeskSystem.RenderSetBeiAtLeft()
       end
    else
        assert(false)
    end
end

function cls:RenderXuanPao() end

function cls:RenderBoxing(entity)
    local counter = 0
    local deskEntity = self._gameSystems.deskSystem:FindEntity()
    if (entity.player.orient == Player.Orient.BOTTOM) then
        self._gameSystems.deskSystem:RenderShowBottomSlot(function () end)
    elseif (entity.player.orient == Player.Orient.RIGHT) then
        self._gameSystems.deskSystem:RenderShowRightSlot(function () end) 
    elseif (entity.player.orient == Player.Orient.TOP) then
        self._gameSystems.deskSystem:RenderShowTopSlot(function () end)
    elseif (entity.player.orient == Player.Orient.LEFT) then
        self._gameSystems.deskSystem:RenderShowLeftSlot(function () end)
    end

    for i=1,#entity.takeCards.takecards do
        local idx = i / 2
        local x, y, z
        if (entity.player.orient == Player.Orient.BOTTOM) then
            x = deskEntity.desk.width - (entity.takeCards.takeleftoffset + idx * Card.Width + Card.Width / 2.0)
            z = entity.takeCards.takebottomoffset
        elseif (entity.player.orient == Player.Orient.RIGHT) then
            x = deskEntity.desk.width - (entity.takeCards.takebottomoffset)
            z = deskEntity.desk.length - (entity.takeCards.takeleftoffset + idx * Card.Width + Card.Width / 2.0)
        elseif (entity.player.orient == Player.Orient.TOP) then
            x = entity.takeCards.takeleftoffset + idx * Card.Width + Card.Width / 2.0
            z = deskEntity.desk.length - (entity.takeCards.takebottomoffset + Card.Length / 2.0)
        else
            x = entity.takeCards.takebottomoffset
            z = entity.takeCards.takeleftoffset + idx * Card.Width + Card.Width / 2.0
        end
        if (i % 2 == 0) then
            y = Card.HeightMZ + Card.Height + Card.Height / 2.0
        else
            y = Card.HeightMZ + Card.Height / 2.0
        end

        local cardEntity = entity.takeCards.takecards[i]
        if entity.player.orient == Player.Orient.BOTTOM then
            cardEntity.card.go.transform.localRotation = entity.playerCard.upv
            cardEntity.card.go.transform.localPosition = CS.UnityEngine.Vector3(x, y - entity.takeCards.takemove, z)
        elseif entity.player.orient == Player.RIGHT then
            cardEntity.card.go.transform.localRotation = entity.playerCard.uph
            cardEntity.card.go.transform.localPosition = CS.UnityEngine.Vector3(x, y - entity.takeCards.takemove, z)
        elseif entity.player.orient == Player.Orient.TOP then
            cardEntity.card.go.transform.localRotation = entity.playerCard.upv
            cardEntity.card.go.transform.localPosition = CS.UnityEngine.Vector3(x, y - entity.takeCards.takemove, z)
        else
            cardEntity.card.go.transform.localRotation = entity.playerCard.uph
            cardEntity.card.go.transform.localPosition = CS.UnityEngine.Vector3(x, y - entity.takeCards.takemove, z)
        end

        local t = cardEntity.card.go.transform:DOLocalMoveY(y, entity.takeCards.takemovedelta)
        local mySequence = CS.DG.Tweening.DOTween.Sequence()
        mySequence:Append(t)
        :AppendCallback(function ()
            local counter = counter + 1
            if (counter == #entity.takeCards.takecards) then
                -- local cmd = new Maria.Command(MyEventCmd.EVENT_BOXINGCARDS)
                -- _appContext.Enqueue(cmd)
            end
        end)
    end
end

function cls:RenderThrowDice()
    -- 1.0 浼告墜
    local deskEntity = _gameSystems.DeskSystem.FindEntity()
    local entity = _gameSystems.NetIdxSystem.FindEntity(_context.rule.firstidx)

    local animator = entity.hand.rhand.GetComponent('Animator')
    entity.hand.rhand.transform.localRotation = Quaternion.Euler(0, 0, 0)
    local t = entity.hand.rhand.transform.DOLocalMove(entity.hand.rhanddiuszoffset, entity.hand.diushaizishendelta)
    local mySequence = CS.DOTween.Sequence()
    mySequence.Append(t)
        .AppendCallback(function ()
            -- 2.0 涓㈠暐瀛?
            local hand = entity.hand.rhand.GetComponent('Hand')
            hand.Rigster(Hand.EVENT.DIUSHAIZI_COMPLETED, function ()
                -- 3.1
                _gameSystems.DeskSystem.RenderThrowDice()

                -- 3.2 鏀舵墜
                local t32 = entity.hand.rhand.transform.DOLocalMove(entity.hand.rhandinitpos, entity.hand.diushaizishoudelta)
                local mySequence32 = CS.DOTween.Sequence()
                mySequence32.Append(t32)
                .AppendCallback(function ()
                    -- 4.0
                    animator.SetBool("Idle", true)
                end)
            end)
            animator.SetBool("Diushaizi", true)
        end)
end

function cls:RenderDeal()
    local counter = 0
    local i = 0
    local entity = _gameSystems.NetIdxSystem.FindEntity(_context.rule.curidx)
    if (entity.handCards.cards.Count == 13) then
        counter = 1
        i = entity.handCards.cards.Count - counter
    else
        counter = 4
        i = entity.handCards.cards.Count - counter
    end

    for i=1,#entity.handCards.cards do
        local cardEntity = entity.handCards.cards[i]
        local dst = self:CalcPos(entity, i)

        cardEntity.card.go.transform.localPosition = dst
        cardEntity.card.go.transform.localRotation = entity.playerCard.backvst
        local t = cardEntity.card.go.transform.DOLocalRotateQuaternion(entity.playerCard.backv, entity.handCards.dealcarddelta)
        local mySequence = DOTween.Sequence()
        mySequence.Append(t)
            .AppendCallback(function ()
                counter = counter - 1
                if (counter <= 0) then
                    -- Command cmd = new Command(MyEventCmd.EVENT_TAKEDEAL)
                    -- GL.Util.App.current.Enqueue(cmd)
                end
            end)
    end
end

function cls:RenderSortCardsAfterDeal(entity)
    local counter = entity.handCards.cards.Count
    for i=1,#entity.handCards.cards do
        local cardEntity = entity.handCards.cards[i]
        local mySequence = CS.DOTween.Sequence()
        mySequence.Append(cardEntity.card.go.transform.DORotateQuaternion(entity.playerCard.backvst, entity.handCards.sortcardsdelta))
            .AppendCallback(function ()
                local dst = CalcPos(entity, cardEntity.card.pos)
                cardEntity.card.go.transform.localPosition = dst
            end)
            .Append(cardEntity.card.go.transform.DORotateQuaternion(entity.playerCard.backv, entity.handCards.sortcardsdelta))
            .AppendCallback(function ()
                counter = counter - 1
                if (counter <= 0) then
                    UnityEngine.Debug.LogFormat("bottom player send event sortcards")
                    -- Command cmd = new Command(MyEventCmd.EVENT_SORTCARDSAFTERDEAL)
                    -- _appContext.Enqueue(cmd)
                end
            end)
    end
end

function cls:RenderTakeXuanPao() end

function cls:RenderTakeFirstCard()
    local entity = self._gameSystems.netIdxSystem:FindEntity(self._context.rule.curidx)
    self:RenderTakeCard(entity, function ()
        -- Command cmd = new Command(MyEventCmd.EVENT_TAKEFIRSTCARD)
        -- _appContext.Enqueue(cmd)
    end)
end

function cls:RenderTakeCard(entity, cb)
    local cdst = self:CalcPos(entity, entity.handCards.cards.Count + 1)
    local hdst = cdst + entity.hand.rhandtakeoffset
    local cdst1 = CS.UnityEngine.Vector3(cdst.x, cdst.y + Card.Length, cdst.z)
    local hdst1 = cdst1 + entity.hand.rhandtakeoffset

    -- 1.0 伸手
    local animator = entity.hand.rhand.GetComponent('Animator')
    animator.SetTrigger("BeforeFangpai")
    local t1 = entity.hand.rhand.transform.DOLocalMove(hdst1, entity.hand.napaishendelta)
    local mySequence1 = DOTween.Sequence()
    mySequence1.Append(t1)
        .AppendCallback(function ()

            -- 2.1 牌下移
            entity.holdCard.holdCardEntity.card.go.transform.localPosition = cdst1
            entity.holdCard.holdCardEntity.card.go.transform.localRotation = entity.playerCard.backv

            local mySequence21 = CS.DOTween.Sequence()
            mySequence21.Append(entity.holdCard.holdCardEntity.card.go.transform.DOLocalMove(cdst, entity.holdCard.holddowndelta))
                .AppendCallback(function ()
                    cb()
                end)

            -- 2.2 手下移
            local mySequence22 = DOTween.Sequence()
            mySequence22.Append(entity.hand.rhand.transform.DOLocalMove(hdst, entity.holdCard.holddowndelta))
            .AppendCallback(function ()
                -- 3.0 放手
                local hand = entity.hand.rhand.GetComponent('Hand')
                hand.Rigster(Hand.EVENT.FANGPAI_COMPLETED, function ()
                    -- 4.0 收手
                    local t4 = entity.hand.rhand.transform.DOLocalMove(entity.hand.rhandinitpos, entity.hand.fangpaishoudelta)
                    local mySequence4 = CS.DOTween.Sequence()
                    mySequence4.Append(t4)
                    .AppendCallback(function ()

                        --cb()

                        -- 5.0 归位
                        animator.SetBool("Idle", true)
                    end)
                end)
                animator.SetBool("Fangpai", true)
            end)
        end)
end

function cls:RenderTakeXuanQue() end

function cls:RenderXuanQue(entity)
    local counter = #entity.handCards.cards
    for i=1,counter do
        local cardEntity = entity.handCards.cards[i]
        local dst = self:CalcPos(entity, cardEntity.card.pos)
        cardEntity.card.go.transform.localPosition = dst
        if self._context.rule.myidx == entity.player.idx then
            self._gameSystems.cardSystem:RenderQueBrightness(cardEntity)
        end
    end

    if self._context.rule.firstidx == entity.player.idx then
        assert(entity.holdCard.holdCardEntity)
        self._gameSystems.CardSystem.RenderQueBrightness(entity.holdCard.holdCardEntity)
    end

    -- self:SortCards()

    -- Command cmd = new Command(MyEventCmd.EVENT_SORTCARDSAFTERXUANQUE)
    -- _appContext.Enqueue(cmd)
end

function cls:RenderTakeTurnDir(entity) 
    if entity.player.idx == 1 then
        self._gameSystems.deskSystem:RenderTakeTurnDong()
    elseif entity.player.idx == 2 then
        self._gameSystems.deskSystem:RenderTakeTurnNan()
    elseif entity.player.idx == 3 then
        self._gameSystems.DeskSystem.RenderTakeTurnXi()
    elseif entity.player.idx == 4 then
        self._gameSystems.DeskSystem.RenderTakeTurnBei()
    else
        assert(false)
    end
end

function cls:RenderTakeTakeCard()
    local entity = _gameSystems.NetIdxSystem.FindEntity(_context.rule.curidx)
    self:RenderTakeCard(entity, function ()
        --Command cmd = new Command(MyEventCmd.)
    end)
end

-- <summary>
-- take turn 的时候需要下方玩家做出选择
-- </summary>
function cls:RenderTakeTurn()
    entity = _gameSystems.NetIdxSystem.FindEntity(_context.rule.curidx)
    RenderTakeTurnDir(entity)
    if entity.player.orient == Player.Orient.BOTTOM then
        local cards = {}
        for i=1,#entity.handCards.cards do
            cardEntiy = entity.handCards.cards[i]
            cards[cardEntiy.card.value] = cardEntiy.card.go
        end
        assert(entity.holdCard.holdCardEntity ~= nil)

        local bottomPlayer = entity.player.go.GetComponent('BottomPlayer')
        bottomPlayer.cards = cards
        bottomPlayer.holdcard = entity.holdCard.holdCardEntity.card.go
        bottomPlayer.holdcardValue = entity.holdCard.holdCardEntity.card.value
        bottomPlayer.touch = true
    end
end

function cls:RenderLead()
    local entity = self._gameSystems.NetIdxSystem.FindEntity(_context.rule.curidx)
    local prefix = "Sound/scmj/"
    local path = prefix
    local name = string.Empty
    if (entity.player.sex == 1) then
        path = path .. "male"
    else
        path = path .. "female"
    end

    if (entity.leadCards.leadcard == -1) then
        return
    end
    local leadCardEntity = _gameSystems.IndexSystem.FindEntity(entity.leadCards.leadcard)
    if (leadCardEntity.card.type == Card.CardType.Bam) then
        name = "s_"
    elseif (leadCardEntity.card.type == Card.CardType.Crak) then
        name = "w_"
    elseif (leadCardEntity.card.type == Card.CardType.Dot) then
        name = "t_"
    end
    name = name .. string.format("%dend_", leadCardEntity.card.num)
    if (leadCardEntity.card.type == Card.CardType.Bam and leadCardEntity.card.num == 1) then
        name = name .. string.format("%dend", _appContext.Range(1, 3))
    elseif (leadCardEntity.card.type == Card.CardType.Bam and leadCardEntity.card.num == 2) then
        name = name .. string.format("%dend", _appContext.Range(1, 2))
    elseif (leadCardEntity.card.type == Card.CardType.Bam and leadCardEntity.card.num == 4) then
        name = name .. string.format("%dend", _appContext.Range(1, 2))
    else
        name = name .. string.format("%dend", 1)
    end

    res.LoadAssetAsync(path, name, function (clip)
        SoundMgr.current.PlaySound(leadCardEntity.card.go, clip)
    end)

    RenderLead1(entity, RenderLead1Cb)
end

function cls:RenderLead1(entity, cb)

    assert(entity.leadCards.leadcards.Count > 0)
    cardEntity = _gameSystems.IndexSystem.FindEntity(entity.leadCards.leadcard)

    local cdst = CalcLeadPos(entity, cardEntity.card.pos)
    local hdst = cdst + entity.hand.rhandleadoffset

    local csrc = cdst + entity.leadCards.leadcardMove
    local hsrc = hdst + entity.leadCards.leadcardMove

    -- 1.0 伸手
    local animator = entity.hand.rhand.GetComponent('Animator')
    animator.SetTrigger("BeforeChupai")
    animator.SetBool("Chupai", true)

    local mySequence1 = CS.DOTween.Sequence()
    mySequence1.Append(entity.hand.rhand.transform.DOLocalMove(hsrc, entity.hand.chupaishendelta))
        .AppendCallback(function ()
            -- 21. 牌向前移

            local leadCardEntity = _gameSystems.IndexSystem.FindEntity(entity.leadCards.leadcard)
            leadCardEntity.card.go.transform.localPosition = csrc
            leadCardEntity.card.go.transform.localRotation = entity.playerCard.upv

            local t21 = leadCardEntity.card.go.transform.DOLocalMove(cdst, entity.leadCards.leadcardMoveDelta)
            local mySequence21 = CS.DOTween.Sequence()
            mySequence21.Append(t21)
            .AppendCallback(function ()
                local deskEntity = _gameSystems.DeskSystem.FindEntity()
                self._gameSystems.DeskSystem.RenderChangeCursor(CS.UnityEngine.Vector3(cdst.x, cdst.y + deskEntity.desk.curorMH, cdst.z))
            end)

            local t22 = entity.hand.rhand.transform.DOLocalMove(hdst, entity.leadCards.leadcardMoveDelta)
            local mySequence22 = DOTween.Sequence()
            mySequence22.Append(t22)
            .AppendCallback(function ()
                -- 
                --3.0 收手
                local mySequence4 = CS.DOTween.Sequence()
                mySequence4.Append(entity.hand.rhand.transform.DOLocalMove(entity.hand.rhandinitpos, entity.hand.chupaishoudelta))
                .AppendCallback(function ()
                    -- 4.1 归为
                    animator.SetBool("Idle", true)

                    entity.hand.rhand.transform.localRotation = entity.hand.rhandinitrot

                    -- 4.2 整理手上的牌
                    cb()
                end)
            end)
        end)
end

function cls:RenderLead1Cb()
    local entity = self._gameSystems.netIdxSystem.FindEntity(self._context.rule.curidx)
    if entity.leadCards.isHoldCard then

        -- Command cmd = new Command(MyEventCmd.EVENT_LEADCARD)
        -- _appContext.Enqueue(cmd)
    else
        self:RenderFly(entity, function ()
            -- Command cmd = new Command(MyEventCmd.EVENT_LEADCARD)
            -- _appContext.Enqueue(cmd)
        end)
    end
end

function cls:RenderSortCardsToDo(entity, duration, cb)
    local oknum = 0
    for i=1,#entity.handCards.cards do
        local dst = CalcPos(entity, i)
        local s = CS.DOTween.Sequence()
        s.Append(entity.handCards.cards[i].card.go.transform.DOLocalMove(dst, duration))
            .AppendCallback(function ()
                oknum = oknum + 1
                if (oknum >= entity.handCards.cards.Count) then
                    cb()
                end
            end)
    end
end

function cls:RenderInsert(entity, cb)
    -- 1.0
    local to = CalcPos(entity, entity.holdCard.holdCardEntity.card.pos)

    local cdst = to
    local hdst = to + entity.hand.rhandnaoffset

    local animator = entity.hand.rhand.GetComponent('Animator')

    -- 1.1 牌下放
    local t11 = entity.holdCard.holdCardEntity.card.go.transform.DOLocalMove(cdst, entity.holdCard.holddowndelta)
    local mySequence11 = DOTween.Sequence()
    mySequence11.Append(t11)
    .AppendCallback(function ()
        entity.holdCard.holdCardEntity = null
        entity.leadCards.leadcard = 0
        cb()
    end)

    -- 1.2 手下放
    local t12 = entity.hand.rhand.transform.DOLocalMove(hdst, entity.holdCard.holddowndelta)
    local mySequence12 = DOTween.Sequence()
    mySequence12.Append(t12)
        .AppendCallback(function ()
            -- 2.0 放手
            local hand = entity.hand.rhand.GetComponent('Hand')
            hand.Rigster(Hand.EVENT.FANGPAI_COMPLETED, function ()
                -- 3.0 收手
                local t31 = entity.hand.rhand.transform.DOLocalMove(entity.hand.rhandinitpos, entity.hand.fangpaishoudelta)
                local mySequence31 = DOTween.Sequence()
                mySequence31.Append(t31)
                .AppendCallback(function ()
                    animator.SetBool("Idle", true)
                    --cb()
                end)
            end)
            animator.SetBool("Fangpai", true)
        end)
end

function cls:RenderSortCardsAfterFly(entity, cb)
    assert(entity and cb)
    local counter = entity.handCards.cards.Count - 1
    for i=1,#entity.handCards.cards do
        local cardEntity = entity.handCards.cards[i]
        assert(cardEntity.card.pos == i)
        if cardEntity ~= entity.holdCard.holdCardEntity then
            local dst = self:CalcPos(entity, cardEntity.card.pos)
            local s = CS.DOTween.Sequence()
            s.Append(cardEntity.card.go.transform.DOLocalMove(dst, entity.holdCard.holdinsortcardsdelta))
                .AppendCallback(function ()
                    counter = counter - 1
                    if (counter <= 0) then
                        self:RenderInsert(entity, cb)
                    end
                end)    
        end 
    end
end

function cls:RenderFly(entity, cb)
    local cfrom = entity.holdCard.holdCardEntity.card.go.transform.localPosition
    local hfrom = cfrom + entity.hand.rhandnaoffset

    -- 1.0
    local animator = entity.hand.rhand.GetComponent('Animator')
    animator.SetTrigger("BeforeNapai")
    local t1 = entity.hand.rhand.transform.DOLocalMove(hfrom, entity.hand.napaishendelta)
    local mySequence1 = DOTween.Sequence()
    mySequence1.Append(t1)
        .AppendCallback(function ()

            -- 2.0 拿牌
            local hand = entity.hand.rhand.GetComponent('Hand')
            hand.Rigster(Hand.EVENT.NAPAI_COMPLETED, function ()

                -- 3.1 上提到目标位置
                local cdst1 = cfrom + entity.holdCard.holdNaMove
                local hdst1 = hfrom + entity.holdCard.holdNaMove
                entity.holdCard.holdCardEntity.card.go.transform.DOLocalMove(cdst1, entity.holdCard.holdNaMovedelta)

                -- 3.2 
                local mySequence32 = CS.DOTween.Sequence()
                local t32 = entity.hand.rhand.transform.DOLocalMove(hdst1, entity.holdCard.holdNaMovedelta)
                mySequence32.Append(t32)
                .AppendCallback(function ()
                    local to = CalcPos(entity, entity.holdCard.holdCardEntity.card.pos)

                    local cdst2 = to + entity.holdCard.holdNaMove
                    local hdst2 = to + entity.hand.rhandnaoffset + entity.holdCard.holdNaMove
                    -- 4.1 移动到目标位置
                    entity.holdCard.holdCardEntity.card.go.transform.DOLocalMove(cdst2, entity.holdCard.holdflydelta)

                    -- 4.2 移动手
                    local t42 = entity.hand.rhand.transform.DOLocalMove(hdst2, entity.holdCard.holdflydelta)
                    local mySequence42 = DOTween.Sequence()
                    mySequence42.Append(t42)
                    .AppendCallback(function ()
                        self:RenderSortCardsAfterFly(entity, cb)
                    end)
                end)

                --local h = 0.05f
                --to.y = to.y + Card.Length + h
                --local[] waypoints = new[]
                --    from,
                --    new local(from.x, (to.y - from.y) * 0.2f + from.y, (to.z - from.z) * 0.2f + from.z),
                --    new local(from.x, (to.y - from.y) * 0.3f + from.y, (to.z - from.z) * 0.3f + from.z),
                --    new local(from.x, (to.y - from.y) * 0.5f + from.y, (to.z - from.z) * 0.5f + from.z),
                --    new local(from.x, (to.y - from.y) * 0.8f + from.y, (to.z - from.z) * 0.8f + from.z),
                --    to,
                --end

                --Tween t = _holdcard.Go.transform.DOPath(waypoints, _holdflydelta).SetOptions(false)
                --Sequence mySequence = DOTween.Sequence()
                --mySequence.Append(t).AppendCallback(() =>
                --    RenderSortCardsAfterFly(cb)
                --end)

                --_rhand.transform.DOPath(waypoints, _holdflydelta).SetOptions(false)
            end)
            animator.SetBool("Napai", true)
        end)
end

function cls:RenderCall() end

function cls:RenderPeng()
    local entity = _gameSystems.NetIdxSystem.FindEntity(_context.rule.curidx)
    local prefix = "Sound/scmj/"
    local path = prefix
    local name = string.Empty
    if (entity.player.sex == 1) then
        path = path .. "male"
    else
        path = path .. "female"
    end

    name = "peng_" + string.Format("{0end", _appContext.Range(1, 3))

    res.LoadAssetAsync(path, name, function (clip)
        if (entity.player.go ~= null) then
            SoundMgr.current.PlaySound(entity.player.go, clip)
        end
    end)

    local deskEntity = _gameSystems.DeskSystem.FindEntity()
    local pg = entity.putCards.putcards[entity.putCards.putidx]
    UnityEngine.Debug.Assert(pg.cards.Count == 3)

    local offset = entity.putCards.putrightoffset
    for i=1,entity.putCards.putidx do
        assert(entity.putCards.putcards[i].width > 0)
        offset = offset + entity.putCards.putcards[i].width + entity.putCards.putmargin
    end

    for i=1,#pg.cards do
        local x, y, z
        y = Card.Height / 2.0 + Card.HeightMZ
        if (i == pg.hor) then
            if (entity.player.orient == Player.Orient.BOTTOM) then
                x = deskEntity.desk.width - (offset + Card.Length / 2.0)
                z = entity.putCards.putbottomoffset + Card.Width / 2.0
            elseif (entity.player.orient == Player.Orient.RIGHT) then
                x = deskEntity.desk.width - (entity.putCards.putbottomoffset + Card.Width / 2.0)
                z = deskEntity.desk.length - (offset + Card.Length / 2.0)
            elseif (entity.player.orient == Player.Orient.TOP) then
                x = offset + Card.Length / 2.0
                z = deskEntity.desk.length - (entity.putCards.putbottomoffset + Card.Width / 2.0)
            else
                x = entity.putCards.putbottomoffset + Card.Width / 2.0
                z = offset + Card.Length / 2.0
            end
            x = entity.putCards.putbottomoffset + Card.Width / 2.0
            z = offset + Card.Length / 2.0

            offset = offset + Card.Length
            pg.width = pg.width + Card.Length
            pg.cards[i].card.go.transform.localRotation = entity.playerCard.uph
        else
            if (entity.player.orient == Player.Orient.BOTTOM) then
                x = deskEntity.desk.width - (offset + Card.Width / 2.0)
                z = deskEntity.putCards.putbottomoffset + Card.Length / 2.0
            elseif (entity.player.orient == Player.Orient.RIGHT) then
                x = deskEntity.desk.width - (entity.putCards.putbottomoffset + Card.Length / 2.0)
                z = deskEntity.desk.length - (offset + Card.Width / 2.0)
            elseif (entity.player.orient == Player.Orient.TOP) then
                x = offset + Card.Length / 2.0
                z = deskEntity.desk.length - (entity.putCards.putbottomoffset + Card.Length / 2.0)
            else
                x = entity.putCards.putbottomoffset + Card.Length / 2.0
                z = offset + Card.Width / 2.0
            end

            x = entity.putCards.putbottomoffset + Card.Length / 2.0
            z = offset + Card.Width / 2.0
            offset = offset + Card.Width
            pg.width = pg.width + Card.Width
            pg.cards[i].card.go.transform.localRotation = entity.playerCard.upv
        end
        pg.cards[i].card.go.transform.localPosition = CS.UnityEngine.Vector3.mul(CS.UnityEngine.Vector3(x, y, z), entity.putCards.putmove)
    end

    self:RenderPeng1()
end

function cls:RenderPeng1()

    local entity = _gameSystems.NetIdxSystem.FindEntity(_context.rule.curidx)
    local pg = entity.putCards.putcards[entity.putCards.putidx]

    local cdst = pg.cards[2].card.go.transform.localPosition
    local hdst = cdst + entity.hand.rhandpgoffset

    -- 1.0 伸手
    local animator = entity.hand.rhand.GetComponent('Animator')
    animator.SetTrigger("BeforePenggang")
    animator.SetBool("Penggang", true)
    local t1 = entity.hand.rhand.transform.DOLocalMove(hdst, entity.hand.penggangshendelta)
    local mySequence1 = DOTween.Sequence()
    mySequence1.Append(t1)
        .AppendCallback(function ()
            -- 2.0
            _context.rule.oknum = 0

            -- 2.1 牌移动
            for i=1,#pg.cards do
                local t2 = pg.cards[i].card.go.transform.DOLocalMove(cdst + entity.putCards.putmove, entity.putCards.putmovedelta)
                local mySequence21 = DOTween.Sequence()
                mySequence21.Append(t2)
                    .AppendCallback(function ()
                        self._context.rule.oknum = self._context.rule.oknum + 1
                        if (self._context.rule.oknum >= pg.cards.Count) then
                            -- 3.0 收手
                            local c2pos = pg.cards[2].card.go.transform.localPosition
                            local deskEntity = _gameSystems.DeskSystem.FindEntity()
                            _gameSystems.DeskSystem.RenderChangeCursor(CS.UnityEngine.Vector3(c2pos.x, c2pos.y + deskEntity.desk.curorMH, c2pos.z))
                        end
                    end)
            end

            -- 2.2 手移动                    
            local t22 = entity.hand.rhand.transform.DOLocalMove(hdst + entity.putCards.putmove, entity.putCards.putmovedelta)
            local mySequence22 = DOTween.Sequence()
            mySequence22.Append(t22)
            .AppendCallback(function ()

                -- 3.0 收手
                local t3 = entity.hand.rhand.transform.DOLocalMove(entity.hand.rhandinitpos, entity.hand.penggangshoudelta)
                local mySequence3 = DOTween.Sequence()
                mySequence3.Append(t3)
                .AppendCallback(function ()
                    self:RenderSortCardsToDo(entity, entity.handCards.sortcardsdelta, function ()
                        -- 4.0 归为
                        animator.SetBool("Idle", true)

                        -- Command cmd = new Command(MyEventCmd.EVENT_PENGCARD)
                        -- _appContext.Enqueue(cmd)
                    end)
                end)
            end)
        end)
end

function cls:RenderGang1(entity, cb)
    local deskEntity = _gameSystems.DeskSystem.FindEntity()
    local pg = entity.putCards.putcards[entity.putCards.putidx]

    -- 1.0 伸手
    local animator = entity.hand.rhand.GetComponent('Animator')
    animator.SetTrigger("BeforePenggang")
    local t1 = entity.hand.rhand.transform.DOMove(pg.cards[3].card.go.transform.position, entity.hand.penggangshendelta)
    local mySequence1 = DOTween.Sequence()
    mySequence1.Append(t1)
        .AppendCallback(function ()
            -- 2.0
            self._context.rule.oknum = 0

            -- 2.1 牌移动
            if (pg.gangtype == GangType.BUGANG) then
                local mySequence21 = DOTween.Sequence()
                mySequence1.Append(pg.cards[3].card.go.transform.DOMove(pg.cards[3].card.go.transform.position + entity.putCards.putmove, entity.putCards.putmovedelta))
                .AppendCallback(function ()
                    local c2pos = pg.cards[3].card.go.transform.position
                    _gameSystems.DeskSystem.RenderChangeCursor(CS.UnityEngine.Vector3(c2pos.x, c2pos.y + deskEntity.desk.curorMH, c2pos.z))
                end)
            else
                for i=1,#pg.cards do
                    local t2 = pg.cards[i].card.go.transform.DOMove(pg.cards[i].card.go.transform.position + entity.putCards.putmove, entity.putCards.putmovedelta)
                    local mySequence21 = DOTween.Sequence()
                    mySequence21.Append(t2)
                        .AppendCallback(function ()
                            self._context.rule.oknum = self._context.rule.oknum + 1
                            if (_context.rule.oknum >= pg.cards.Count) then
                                -- 3.0 收手
                                local c2pos = pg.cards[3].card.go.transform.position
                                _gameSystems.DeskSystem.RenderChangeCursor(CS.UnityEngine.Vector3(c2pos.x, c2pos.y + deskEntity.desk.curorMH, c2pos.z))
                            end
                        end)
                end
            end


            -- 2.2 手移动                    
            local t22 = entity.hand.rhand.transform.DOLocalMove(entity.hand.rhand.transform.localPosition + entity.putCards.putmove, entity.putCards.putmovedelta)
            local mySequence22 = DOTween.Sequence()
            mySequence22.Append(t22)
            .AppendCallback(function ()

                -- 3.0 收手
                local t3 = entity.hand.rhand.transform.DOMove(entity.hand.rhandinitpos, entity.hand.penggangshoudelta)
                local mySequence3 = DOTween.Sequence()
                mySequence3.Append(t3)
                .AppendCallback(function ()
                    self:RenderSortCardsToDo(entity, entity.handCards.sortcardsdelta, function ()
                        -- 4.0 归为
                        animator.SetBool("Idle", true)

                        cb()
                    end)
                end)
            end)
        end)
end

function cls:RenderZhiGang(entity, deskEntity, pg, offset)
    for i=1,#pg.cards do
        local x, y, z
        y = Card.Height / 2.0 + Card.HeightMZ
        if (i == pg.hor) then
            if (entity.player.orient == Player.Orient.BOTTOM) then
                x = deskEntity.desk.width - (offset + Card.Length / 2.0)
                z = entity.putCards.putbottomoffset + Card.Width / 2.0
            elseif (entity.player.orient == Player.Orient.RIGHT) then
                x = deskEntity.desk.width - (entity.putCards.putbottomoffset + Card.Width / 2.0)
                z = deskEntity.desk.length - (offset + Card.Length / 2.0)
            elseif (entity.player.orient == Player.Orient.TOP) then
                x = offset + Card.Length / 2.0
                z = deskEntity.desk.length - (entity.putCards.putbottomoffset + Card.Width / 2.0)
            else
                x = entity.putCards.putbottomoffset + Card.Width / 2.0
                z = offset + Card.Length / 2.0
            end
            x = entity.putCards.putbottomoffset + Card.Width / 2.0
            z = offset + Card.Length / 2.0

            offset = offset + Card.Length
            pg.width = pg.width + Card.Length
            pg.cards[i].card.go.transform.localRotation = entity.playerCard.uph
        else
            if (entity.player.orient == Player.Orient.BOTTOM) then
                x = deskEntity.desk.width - (offset + Card.Width / 2.0)
                z = deskEntity.putCards.putbottomoffset + Card.Length / 2.0
            elseif (entity.player.orient == Player.Orient.RIGHT) then
                x = deskEntity.desk.width - (entity.putCards.putbottomoffset + Card.Length / 2.0)
                z = deskEntity.desk.length - (offset + Card.Width / 2.0)
            elseif (entity.player.orient == Player.Orient.TOP) then
                x = offset + Card.Length / 2.0
                z = deskEntity.desk.length - (entity.putCards.putbottomoffset + Card.Length / 2.0)
            else
                x = entity.putCards.putbottomoffset + Card.Length / 2.0
                z = offset + Card.Width / 2.0
            end

            x = entity.putCards.putbottomoffset + Card.Length / 2.0
            z = offset + Card.Width / 2.0
            offset = offset + Card.Width
            pg.width = pg.width + Card.Width
            pg.cards[i].card.go.transform.localRotation = entity.playerCard.upv
        end
        pg.cards[i].card.go.transform.localPosition = CS.UnityEngine.Vector3(x, y, z) - entity.putCards.putmove
    end

    RenderGang1(entity, function ()
        RenderSortCardsToDo(entity, entity.handCards.pgsortcardsdelta, function ()
            -- Command cmd = new Command(MyEventCmd.EVENT_GANGCARD)
            -- GL.Util.App.current.Enqueue(cmd)
        end)
    end)
end

-- function cls:RenderAnGang(entity, deskEntity, pg, offset)
--     local Card = self._appContext.config.card
--     for i=0,9 do
--         local x, y, z
--         y = Card.Height / 2.0 + Card.HeightMZ
--         if (entity.player.orient == Player.Orient.BOTTOM)
--             x = deskEntity.desk.width - (offset + Card.Width / 2.0)
--             z = entity.putCards.putbottomoffset + Card.Length / 2.0
--         end else if (entity.player.orient == Player.Orient.RIGHT)
--             x = entity.putCards.putbottomoffset + Card.Length / 2.0
--             z = deskEntity.desk.length - (offset + Card.Width / 2.0)
--         end else if (entity.player.orient == Player.Orient.TOP)
--             x = offset + Card.Width / 2.0
--             z = deskEntity.desk.length - (entity.putCards.putbottomoffset + Card.Length / 2.0)
--         end else
--             x = entity.putCards.putbottomoffset + Card.Length / 2.0
--             z = offset + Card.Width / 2.0
--         end

--         offset += Card.Width
--         pg.width += Card.Width

--         if (i == 0)
--             pg.cards[i].card.go.transform.localRotation = entity.playerCard.upv
--         end else
--             pg.cards[i].card.go.transform.localRotation = entity.playerCard.downv
--         end
--         pg.cards[i].card.go.transform.localPosition = new local(x, y, z) - entity.putCards.putmove
--     end

--     RenderGang1(entity, () =>
--         if (pg.isHoldcard)
--             RenderSortCardsToDo(entity, entity.handCards.pgsortcardsdelta, () =>
--                 Command cmd = new Command(MyEventCmd.EVENT_GANGCARD)
--                 GL.Util.App.current.Enqueue(cmd)
--             end)
--         end else
--             if (pg.isHoldcardInsLast)
--                 RenderSortCardsToDo(entity, entity.handCards.pgsortcardsdelta, () =>
--                     Command cmd = new Command(MyEventCmd.EVENT_GANGCARD)
--                     GL.Util.App.current.Enqueue(cmd)
--                 end)
--             end else
--                 RenderFly(entity, () =>
--                     Command cmd = new Command(MyEventCmd.EVENT_GANGCARD)
--                     GL.Util.App.current.Enqueue(cmd)
--                 end)
--             end
--         end
--     end)
-- end

-- function cls:RenderBuGang(entity, deskEntity, pg, offset)
--     local x, y, z
--     y = Card.Height / 2.0 + Card.HeightMZ
--     if (entity.player.orient == Player.Orient.BOTTOM)
--         x = deskEntity.desk.width - (offset + (Card.Width * pg.hor) + (Card.Length / 2.0))
--         z = entity.putCards.putbottomoffset + Card.Width + Card.Width / 2.0
--     end else if (entity.player.orient == Player.Orient.RIGHT)
--         x = entity.putCards.putbottomoffset + Card.Width / 2.0 + Card.Width
--         z = deskEntity.desk.length - (offset + Card.Width * pg.hor + Card.Width / 2.0)
--     end else if (entity.player.orient == Player.Orient.TOP)
--         x = offset + Card.Width * pg.hor + Card.Width / 2.0
--         z = deskEntity.desk.length - (entity.putCards.putbottomoffset + Card.Width / 2.0 + Card.Width)
--     end else
--         x = entity.putCards.putbottomoffset + Card.Width / 2.0 + Card.Width
--         z = offset + Card.Width * pg.hor + Card.Length / 2.0
--     end
--     pg.cards[3].card.go.transform.localPosition = new local(x, y, z) - entity.putCards.putmove
--     pg.cards[3].card.go.transform.localRotation = entity.playerCard.uph

--     RenderGang1(entity, () =>
--         if (pg.isHoldcard)
--             Command cmd = new Command(MyEventCmd.EVENT_GANGCARD)
--             GL.Util.App.current.Enqueue(cmd)
--         end else
--             RenderFly(entity, () =>
--                 Command cmd = new Command(MyEventCmd.EVENT_GANGCARD)
--                 GL.Util.App.current.Enqueue(cmd)
--             end)
--         end
--     end)
-- end

function cls:RenderGang()
    local entity = self._gameSystems.netIdxSystem:FindEntity(self._context.rule.curidx)
    local prefix = "Sound/scmj/"
    local path = prefix
    local name = string.Empty
    if (entity.player.sex == 1) then
        path = path .. "male"
    else
        path = path .. "female"
    end

    name = "minggang_2"

    res.LoadAssetAsync(path, name, function (clip)
        sound.PlaySound(entity.player.go, clip)
    end)

    local deskEntity = _gameSystems.DeskSystem.FindEntity()
    local pg = entity.putCards.putcards[entity.putCards.putidx]
    pg.width = 0
    assert(pg.cards.Count == 4)

    local offset = entity.putCards.putrightoffset
    for i=1,#entity.putCards do
        assert(entity.putCards.putcards[i].width > 0)
        offset = offset + entity.putCards.putcards[i].width + entity.putCards.putmargin
    end

    if (pg.gangtype == GangType.ZHIGANG) then
        RenderZhiGang(entity, deskEntity, pg, offset)
    elseif (pg.gangtype == GangType.ANGANG) then
        RenderAnGang(entity, deskEntity, pg, offset)
    elseif (pg.gangtype == GangType.BUGANG) then
        RenderBuGang(entity, deskEntity, pg, offset)
    else
        UnityEngine.Debug.Assert(false)
    end
end

--function cls:GangSettle()
--    _ctx.EnqueueRenderQueue(RenderGangSettle)
--end

--protected virtual void RenderGangSettle() end

-- function cls:RenderHu()
--     local entity = self._gameSystems.NetIdxSystem.FindEntity(self._context.rule.curidx)
--     local prefix = "Sound/"
--     local path = prefix
--     local name = "hu"
--     if entity.player.sex == 1 then
--         path += "male"
--     else
--         path += "female"
--     end

--     -- res.LoadAssetAsync<AudioClip>(path, name, (AudioClip clip) =>
--     --     SoundMgr.current.PlaySound(entity.player.go, clip)
--     -- end)

--     -- int idx = entity.huCards.hucards.Count - 1
--     -- cardEntity = entity.huCards.hucards[idx]
--     -- local dst = CalcHuPos(entity, cardEntity.card.pos)
--     -- cardEntity.card.go.transform.localPosition = dst
--     -- cardEntity.card.go.transform.localRotation = entity.playerCard.upv

--     -- deskEntity = _gameSystems.DeskSystem.FindEntity()
--     -- _gameSystems.DeskSystem.RenderChangeCursor(new local(dst.x, dst.y + deskEntity.desk.curorMH, dst.z))

--     -- Sequence mySequence = DOTween.Sequence()
--     -- mySequence.AppendInterval(1.0f)
--     --     .AppendCallback(() =>
--     --         Command cmd = new Command(MyEventCmd.EVENT_HUCARD)
--     --         GL.Util.App.current.Enqueue(cmd)
--     --     end)
-- end

--endregion


return cls