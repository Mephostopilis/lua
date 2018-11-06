local log = require "log"
local res = require "res"
local vector = require "chestnut.vector"
local EventDispatcher = require "event_dispatcher"
local Errorcode = require "errorcode"

local GameType = require "bacon.game.GameType"
local GameState = require "bacon.game.GameState"


local cls = class("GameSystem")

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

    
function cls:Initialize( ... )
    -- body
    -- EventListenerCmd listener2 = new EventListenerCmd(MyEventCmd.EVENT_BOXINGCARDS, OnBoxingCards);
    -- _appContext.EventDispatcher.AddCmdEventListener(listener2);

    -- EventListenerCmd listener5 = new EventListenerCmd(MyEventCmd.EVENT_THROWDICE, OnThrowDice);
    -- _appContext.EventDispatcher.AddCmdEventListener(listener5);

    -- EventListenerCmd listener6 = new EventListenerCmd(MyEventCmd.EVENT_TAKEDEAL, OnTakeDeal);
    -- _appContext.EventDispatcher.AddCmdEventListener(listener6);

    -- EventListenerCmd listener7 = new EventListenerCmd(MyEventCmd.EVENT_PENGCARD, OnPengCard);
    -- _appContext.EventDispatcher.AddCmdEventListener(listener7);

    -- EventListenerCmd listener8 = new EventListenerCmd(MyEventCmd.EVENT_GANGCARD, OnGangCard);
    -- _appContext.EventDispatcher.AddCmdEventListener(listener8);

    -- EventListenerCmd listener9 = new EventListenerCmd(MyEventCmd.EVENT_HUCARD, OnHuCard);
    -- _appContext.EventDispatcher.AddCmdEventListener(listener9);

    -- EventListenerCmd listener10 = new EventListenerCmd(MyEventCmd.EVENT_SORTCARDSAFTERDEAL, OnSortCardsAfterDeal);
    -- _appContext.EventDispatcher.AddCmdEventListener(listener10);

    -- EventListenerCmd listener11 = new EventListenerCmd(MyEventCmd.EVENT_LEADCARD, OnLeadCard);
    -- _appContext.EventDispatcher.AddCmdEventListener(listener11);

    -- --EventListenerCmd listener12 = new EventListenerCmd(MyEventCmd.EVENT_SETUP_BOARD, SetupMap);
    -- --_appContext.EventDispatcher.AddCmdEventListener(listener12);

    -- EventListenerCmd listener13 = new EventListenerCmd(MyEventCmd.EVENT_SENDCHATMSG, OnSendChatMsg);
    -- _appContext.EventDispatcher.AddCmdEventListener(listener13);

    -- EventListenerCmd listener14 = new EventListenerCmd(MyEventCmd.EVENT_TAKEFIRSTCARD, OnTakeFirstCard);
    -- _appContext.EventDispatcher.AddCmdEventListener(listener14);

    -- EventListenerCmd listener15 = new EventListenerCmd(MyEventCmd.EVENT_SETTLE_NEXT, OnSettleNext);
    -- _appContext.EventDispatcher.AddCmdEventListener(listener15);

    --EventListenerCmd listener16 = new EventListenerCmd(MyEventCmd.EVENT_LOADEDCARDS, OnEventLoadedCards);
    --_ctx.EventDispatcher.AddCmdEventListener(listener16);

    -- EventListenerCmd listener16 = new EventListenerCmd(MyEventCmd.EVENT_SORTCARDSAFTERXUANQUE, OnSortCardsAfterXuanQue);
    -- _appContext.EventDispatcher.AddCmdEventListener(listener16);
end

-- <summary>
-- 下一个玩家
-- <summary>  
function cls:NextIdx( ... )
    -- body
    self._context.rule.curidx = self._context.rule.curidx + 1
    if self._context.rule.curidx > self._context.rule.max then
        self._context.rule.curidx = 1
    end
    return self._context.rule.curidx
end          


-- <summary>
-- 
-- </summary>
-- <param name="whose">netidx,服务传来的索引,拿谁的牌</param>
-- <param name="card">本地索引</param>
-- <returns>判断牌是否已经拿完，也用来判断游戏是否结束</returns>
function cls:TakeCard()
    local ok, card = self._gameSystems.playerSystem:TakeCard(self._context.rule.curtake)
    if ok then
        return true, card
    else
        self._context.rule.takepoint = self._context.rule.takepoint + 1
        if self._context.rule.takepoint >= 6 then
            -- over 
            return false;
        else
            self._context.rule.curtake = self._context.rule.curtake - 1  -- 网络索引 1,2,3,4倒数
            if self._context.rule.curtake <= 0 then
                self._context.rule.curtake = self._context.rule.max
            end
            ok, card = self._gameSystems.playerSystem:TakeCard(self._context.rule.curtake)
            if ok then
                return true, card
            else
                return false
            end
        end
    end
end

-- <summary>
-- 拿牌4个或者1个
-- </summary>
-- <param name="who">拥有牌的那个人</param>
-- <returns></returns>
function cls:TakeBlock()
    if self._context.rule.takeround == 4 then
        local cards = vector()
        local ok, card = self:TakeCard()
        if ok then
            cards:push_back(card)
        end
        return cards
    else
        local cards = vector()
        for i=1,4 do
            local ok, card = self:TakeCard()
            cards:push_back(card)
        end
        return cards
    end
end

function cls:SetRoomInfo(gameType, roomid, max, myidx, host)
    self._context.rule.type = gameType;
    self._context.rule.roomid = roomid;
    self._context.rule.max = max;
    self._context.rule.myidx = myidx;
    self._context.rule.host = host;
end

function cls:SetState(GameState state)
    if self._context.rule.gamestate ~= state then
        self._context.rule.gamestate = state;
    end
end
        
function cls:OnBoxingCards(e)
    self._context.rule.oknum = self._context.rule.oknum + 1
    if self._context.rule.oknum >= self._context.rule.max then
        self._context.rule.oknum = 0
        if self._context.rule.type == GameType.GAME then
            log.info("send step after boxing.")
            self:SendStep()
        end
    end
end

function cls:OnThrowDice(e)
    if self._context.rule.type == GameType.GAME then
        self:SendStep()
    end
end

function cls:OnTakeDeal(e)
    self._context.rule.take1time = self._context.rule.take1time + 1

    if self._context.rule.take1time > 4 then
        self._context.rule.takeround = self._context.rule.takeround + 1
        self._context.rule.take1time = 1
    end
    if self._context.rule.takeround > 4 then
        self._gameSystems.netIdxSystem:SortCards()
        return
    end

    local idx = self:NextIdx()
    local curIdxEntity = self._gameSystems.netIdxSystem:FindEntity(idx)
    self._gameSystems.playerSystem:Deal(curIdxEntity)
end

function cls:OnSortCardsAfterDeal(e)
    self._context.rule.oknum = self._context.rule.oknum - 1
    if self._context.rule.oknum <= 0 then
        -- Take first card
        local idx = self:NextIdx()
        local curIdxEntity = self._gameSystems.netIdxSystem:FindEntity(idx)
        self._gameSystems.playerSystem:TakeFirsteCard(curIdxEntity, self._context.rule.firstcard)
    end
end

function cls:OnTakeFirstCard(e)
    if self._context.rule.type == GameType.GAME then
        log.info("send step after sort cards.")
        self:SendStep()
    end
end

function cls:OnPengCard(e)
    if self._context.rule.type == GameType.GAME then
        self:SendStep()
    end
end

function cls:OnGangCard(e)
    if self._context.rule.type == GameType.GAME then
        self:SendStep()
    end
end

function cls:OnHuCard(e)
    -- JoinModule joinModule = _appContext.U.GetModule<JoinModule>();
    -- var entity = _gameSystems.netIdxSystem:FindEntity(joinModule.MyIdx);

    -- entity.rule.oknum++;
    -- if (entity.rule.oknum >= entity.rule.huscount)
    --     if (entity.rule.type == GameType.GAME)
    --         SendStep();
    --     }
    -- }
end

function cls:OnLeadCard(e)
    local entity = self._gameSystems.netIdxSystem:FindEntity(self._context.rule.curidx)
    entity.holdCard.holdCardEntity = nil

    if self._context.rule.type == GameType.GAME then
        self:SendStep()
    end
end

function cls:OnSettleNext(e) 
    --_oknum++;
    --if (_oknum >= _max)
    --    if (_settlesidx >= _settles.Count)
    --        SendStep();
    --        return;
    --    }

    --    foreach (var i in _playes)
    --        Player player = i.Value;

    --        player.ClearSettle();

    --        S2cSprotoType.settlementitem si = null;
    --        S2cSprotoType.settle settle = _settles[_settlesidx];
    --        long idx = 0;
    --        if (player.Idx == 1)
    --            idx = 1;
    --            if (settle.p1 != null)
    --                si = settle.p1;
    --            }
    --        } else if (player.Idx == 2)
    --            idx = 2;
    --            if (settle.p2 != null)
    --                si = settle.p2;
    --            }
    --        } else if (player.Idx == 3)
    --            idx = 3;
    --            if (settle.p3 != null)
    --                si = settle.p3;
    --            }
    --        } else if (player.Idx == 4)
    --            idx = 4;
    --            if (settle.p4 != null)
    --                si = settle.p4;
    --            }
    --        }
    --        if (si != null)
    --            SettlementItem item = new SettlementItem();
    --            item.Idx = si.idx;
    --            item.Chip = si.chip;  -- 有正负
    --            item.Left = si.left;  -- 以次值为准

    --            item.Win = si.win;
    --            item.Lose = si.lose;

    --            item.Gang = si.gang;
    --            item.HuCode = si.hucode;
    --            item.HuJiao = si.hujiao;
    --            item.HuGang = si.hugang;
    --            item.HuaZhu = si.huazhu;
    --            item.DaJiao = si.dajiao;
    --            item.TuiSui = si.tuisui;

    --            _playes[idx].AddSettle(item);
    --            _playes[idx].Settle();
    --        }
    --    }
    --    _settlesidx++;
    --}
end

function cls:OnSendChatMsg(e)
    -- JoinModule joinModule = _appContext.U.GetModule<JoinModule>();
    -- var entity = _gameSystems.netIdxSystem:FindEntity(joinModule.MyIdx);

    -- if (entity.rule.type == GameType.GAME)
    --     C2sSprotoType.rchat.request request = new C2sSprotoType.rchat.request();
    --     request.idx = joinModule.MyIdx;
    --     if ((int)e.Msg["type"] == 1)
    --         request.type = 1;
    --         request.textid = (long)e.Msg["code"];
    --     } else if ((int)e.Msg["type"] == 2)

    --     }
    --     _appContext.SendReq<C2sProtocol.rchat>(C2sProtocol.rchat.Tag, request);
    -- }
end

function cls:OnSortCardsAfterXuanQue(e)
    self._context.rule.oknum = self._context.rule.oknum - 1
    if self._context.rule.oknum <= 0 then
        self:SendStep()
    end
end

-- region send
function cls:SendStep()
    C2sSprotoType.step.request request = new C2sSprotoType.step.request();
    request.idx = _context.rule.myidx;
    _appContext.SendReq<C2sProtocol.step>(C2sProtocol.step.Tag, request);
end

function cls:SendRestart()
    local request = {}
    request.idx = self._context.rule.myidx
    self._appContext.networkMgr.client:send_request("restart", request)
end
-- endregion

-- region response
function cls:Step(responseObj)
    local obj = responseObj
    if obj.errorcode == Errorcode.SUCCESS then
    elseif obj.errorcode == Errorcode.SERVER_ERROR then
        log.error("server internal occurs wrrong. ")
    else
        log.error("errorcode {0}", obj.errorcode)
    end
end
-- endregion

-- region requset
function cls:OnOnline(requestObj)

    local obj = requestObj
    self._context.rule.online = self._context.rule.online - 1

    local entity = self._gameSystems.netIdxSystem:FindEntity(obj.idx)
    entity.head.headUIContext:SetLeave(false)
    entity.head.headUIContext:Shaking()

    local responseObj = {}
    responseObj.errorcode = Errorcode.SUCCESS
    return responseObj
end

function cls:OnOffline(requestObj)
    local obj = requestObj
    
    self._context.rule.online = self._context.rule.online - 1

    local afkEntity = self._gameSystems.netIdxSystem:FindEntity(obj.idx)
    afkEntity.head.headUIContext:SetLeave(true)
    afkEntity.head.headUIContext:Shaking()

    local responseObj = {}
    responseObj.errorcode = Errorcode.SUCCESS;
    return responseObj
end

function cls:OnReady(requestObj)
    local obj = requestObj
    self._context.rule.gamestate = GameState.READY

    local entity = self._gameSystems.netIdxSystem:FindEntity(obj.idx)
    entity.head.headUIContext:SetReady(true)
    entity.head.headUIContext:Shaking()

    local responseObj = {}
    responseObj.errorcode = Errorcode.SUCCESS;
    return responseObj
end

function cls:OnShuffle(requestObj)
        self._context.rule.oknum = 0
        self._context.rule.gamestate = GameState.SHUFFLE

        self._gameSystems.cardValueIndexSystem:Clear()
        assert(obj.p1.Count == 28)
        local entity1 = self._gameSystems.netIdxSystem:FindEntity(1)
        self._gameSystems.playerSystem:Boxing(entity1, obj.p1)

        assert(obj.p2.Count == 28)
        local entity2 = self._gameSystems.netIdxSystem:FindEntity(2)
        self._gameSystems.playerSystem:Boxing(entity2, obj.p2)


        assert(obj.p3.Count == 26)
        local entity3 = self._gameSystems.netIdxSystem:FindEntity(3)
        self._gameSystems.playerSystem:Boxing(entity3, obj.p3)

        assert(obj.p4.Count == 26);
        var entity4 = _gameSystems.netIdxSystem:FindEntity(4);
        self._gameSystems.playerSystem.Boxing(entity4, obj.p4);

        self._gameSystems.netIdxSystem:RenderBoxing()

        local responseObj = {}
        responseObj.errorcode = Errorcode.SUCCESS;
        return responseObj;
end

function cls:OnDice(requestObj)
        self._context.rule.gamestate = GameState.DICE;
        self._context.rule.firstidx = obj.first;
        self._context.rule.firsttake = obj.firsttake;   -- 第一个被拿牌的玩家，用色子check一下是否正确

        self._context.rule.dice1 = obj.d1;
        self._context.rule.dice2 = obj.d2;

        --long point = obj.d1 + obj.d2;
        --while (point > _context.rule.max)
        --    point -= _context.rule.max;
        --}
        --assert(point > 0 && point <= _context.rule.max);

        -- 设置被拿牌的玩家的牌的起始牌索引
        local firstTakeEntity = self._gameSystems.netIdxSystem:FindEntity(obj.firsttake);
        local min = math.min(obj.d1, obj.d2);
        firstTakeEntity.takeCards.takecardsidx = (int)(min * 2);

        local firstIdxEntity = self._gameSystems.netIdxSystem:FindEntity(obj.first)
        self._gameSystems.playerSystem:ThrowDice(firstTakeEntity, obj.d1, obj.d2);

        local responseObj = {}
        responseObj.errorcode = Errorcode.SUCCESS;
        return responseObj;
end

--/ <summary>
--/ 发牌，这其实是每个玩家去拿牌的过程
--/ </summary>
--/ <param name="requestObj"></param>
--/ <returns></returns>
function cls:OnDeal(requestObj)
    self._context.rule.oknum = 0
    assert(_context.rule.firstidx == obj.firstidx
        and _context.rule.firsttake == obj.firsttake)
    self._context.rule.curidx = obj.firstidx;
    self._context.rule.curtake = obj.firsttake;
    self._context.rule.firstcard = obj.card;

    self._context.rule.take1time = 1
    self._context.rule.takeround = 1
    self._context.rule.takepoint = 1

    local entity1 = self._gameSystems.netIdxSystem:FindEntity(1)
    entity1.playerCard.cs = obj.p1

    local entity2 = self._gameSystems.netIdxSystem:FindEntity(2)
    entity2.playerCard.cs = obj.p2

    local entity3 = self._gameSystems.netIdxSystem:FindEntity(3)
    entity3.playerCard.cs = obj.p3

    local entity4 = self._gameSystems.netIdxSystem:FindEntity(4)
    entity4.playerCard.cs = obj.p4

    local firstIdxEntity = self._gameSystems.netIdxSystem:FindEntity(obj.firstidx)
    self._gameSystems.playerSystem:Deal(firstIdxEntity);

    local responseObj = {}
    responseObj.errorcode = Errorcode.SUCCESS;
    return responseObj;
end

--/ <summary>
--/ 暂时不用
--/ </summary>
--/ <param name="requestObj"></param>
--/ <returns></returns>
function cls:OnTakeXuanPao(requestObj)
    -- S2cSprotoType.take_xuanpao.request obj = requestObj as S2cSprotoType.take_xuanpao.request;
    -- 
    --     -- TODO: coundown
    --     --_appContext.Countdown(Timer.CLOCK, (int)obj.countdown, OnUpdateClock, null);

    --     ---- 这个协议需要改
    --     --_playes[_myidx].TakeXuanPao();

    --     S2cSprotoType.take_xuanpao.response responseObj = new S2cSprotoType.take_xuanpao.response();
    --     responseObj.errorcode = Errorcode.SUCCESS;
    --     return responseObj;
    -- } catch (Exception ex)
    --     UnityEngine.Debug.LogException(ex);
    --     S2cSprotoType.take_xuanpao.response responseObj = new S2cSprotoType.take_xuanpao.response();
    --     responseObj.errorcode = Errorcode.FAIL;
    --     return responseObj;
    -- }
end

function cls:OnXuanPao(requestObj)
    -- 

    --     local responseObj = {}
    --     responseObj.errorcode = Errorcode.SUCCESS;
    --     return responseObj;
    -- } catch (Exception ex)
    --     UnityEngine.Debug.LogException(ex);
    --     local responseObj = {}
    --     responseObj.errorcode = Errorcode.FAIL;
    --     return responseObj;
    -- }
end

function cls:OnTakeXuanQue(requestObj)
    local obj = requestObj
    
    -- 凡是有倒计时的都要单独设计一个过程
    self._gameSystems.deskSystem:ShowCountdown(obj.countdown);
    GameUIModule gameUIModule = _appContext.U.GetModule<GameUIModule>();
    XuanQueUIController xuanQueUIController = gameUIModule:XuanQueUIController;
    if xuanQueUIController.Counter <= 0 then
        self._appContext.UIContextManager.Push(xuanQueUIController);
    end


    local responseObj = {}
    responseObj.errorcode = Errorcode.SUCCESS;
    return responseObj;
end

function cls:OnXuanQue(requestObj)
    local obj = requestObj
    
    self._context.rule.oknum = 4;
    self._gameSystems.playerSystem:XuanQue(1, obj.p1);
    self._gameSystems.playerSystem:XuanQue(2, obj.p2);
    self._gameSystems.playerSystem:XuanQue(3, obj.p3);
    self._gameSystems.playerSystem:XuanQue(4, obj.p4);

    self._gameSystems.netIdxSystem:RenderXuanQue()

    local  responseObj = {}
    responseObj.errorcode = Errorcode.SUCCESS;
    return responseObj;
end

function cls:OnTakeCard(requestObj)
    local obj = requestObj
    
    local entity = _gameSystems.netIdxSystem:FindEntity(obj.idx)
    self._gameSystems.playerSystem:TakeTakeCard(entity, obj.card)

    local responseObj = {}
    responseObj.errorcode = Errorcode.SUCCESS;
    return responseObj;
end

function cls:OnTakeTurn(requestObj)
    local obj = requestObj
    
    self._context.rule.gamestate = GameState.TURN;
    self._context.rule.curidx = obj.your_turn;
    self._gameSystems.deskSystem:ShowCountdown(obj.countdown);

    local curIdxEntity = self._gameSystems.netIdxSystem:FindEntity(obj.your_turn)
    self._gameSystems.playerSystem:TakeTurn(curIdxEntity, obj.countdown)
    self._gameSystems.netIdxSystem:PlayFlame(curIdxEntity.player.idx, obj.countdown);

    local responseObj = {}
    responseObj.errorcode = Errorcode.SUCCESS;
    return responseObj
end

function cls:OnOCall(requestObj)
    local obj = requestObj
    
    self._context.rule.gamestate = GameState.OCALL;
    self._gameSystems.deskSystem.ShowCountdown(obj.countdown);

    assert(#obj.opcodes > 0)
    -- for i=1,#obj.opcodes do
    --     if obj.opcodes[i].idx == self._context.rule.myidx
    --         GameUIModule module = _appContext.U.GetModule<GameUIModule>();
    --         MyOptionsUIController myOptionsUIController = module.MyOptionsUIController;
    --         if ((obj.opcodes[i].opcode & OpCodes.OPCODE_PENG) > 0)
    --             myOptionsUIController.SetCall(true, false, false, false);
    --         }
    --         if ((obj.opcodes[i].opcode & OpCodes.OPCODE_GANG) > 0)
    --             myOptionsUIController.SetCall(false, true, false, false);
    --         }
    --         if ((obj.opcodes[i].opcode & OpCodes.OPCODE_HU) > 0)
    --             myOptionsUIController.SetCall(false, false, true, false);
    --         }
    --         if ((obj.opcodes[i].opcode & OpCodes.OPCODE_GUO) > 0)
    --             myOptionsUIController.SetCall(false, false, false, true);
    --         }
    --         myOptionsUIController.Shaking();
    --     }
    -- end
    -- for (int i = 0; i < obj.opcodes.Count; i++)
        
    -- }

    local responseObj = {}
    responseObj.errorcode = Errorcode.SUCCESS;
    return responseObj;
end

function cls:OnMCall(requestObj)
    local obj = requestObj
    
        _context.rule.gamestate = GameState.MCALL;
        _gameSystems.deskSystem.ShowCountdown(obj.countdown);

        GameUIModule module = _appContext.U.GetModule<GameUIModule>();
        MyOptionsUIController myOptionsUIController = module.MyOptionsUIController;
        if ((obj.opcodes.opcode & OpCodes.OPCODE_PENG) > 0)
            myOptionsUIController.SetCall(true, false, false, false);
        }
        if ((obj.opcodes.opcode & OpCodes.OPCODE_GANG) > 0)
            myOptionsUIController.SetCall(false, true, false, false);
        }
        if ((obj.opcodes.opcode & OpCodes.OPCODE_HU) > 0)
            myOptionsUIController.SetCall(false, false, true, false);
        }
        if ((obj.opcodes.opcode & OpCodes.OPCODE_GUO) > 0)
            myOptionsUIController.SetCall(false, false, false, true);
        }
        myOptionsUIController.Shaking();

        CallInfo call = new CallInfo();
        call.Card = obj.opcodes.card;
        call.Dian = obj.opcodes.dian;
        call.OpCode = obj.opcodes.opcode;
        call.GangType = obj.opcodes.gangtype;
        call.HuType = obj.opcodes.hutype;
        call.JiaoType = obj.opcodes.jiaotype;

        local entity = _gameSystems.netIdxSystem:FindEntity(obj.opcodes.idx);
        entity.playerCard.call = call;
        _gameSystems.playerSystem.SetupCall(entity);

        local responseObj = {}
        responseObj.errorcode = Errorcode.SUCCESS;
        return responseObj;
end

function cls:OnPeng(requestObj)
    local obj = requestObj
    
        -- 
        self._context.rule.gamestate = GameState.PENG;
        assert(obj.code == OpCodes.OPCODE_PENG);
        assert(obj.dian == _context.rule.lastidx);
        assert(obj.card == _context.rule.lastCard);

        var entity = _gameSystems.netIdxSystem:FindEntity(obj.idx);
        var dianEntity = _gameSystems.netIdxSystem:FindEntity(obj.dian);
        var cardEntity = _gameSystems.CardValueIndexSystem:FindEntity(obj.card);
        _gameSystems.playerSystem.Peng(entity, dianEntity, cardEntity, obj.hor);

        local responseObj = {}
        responseObj.errorcode = Errorcode.SUCCESS;
        return responseObj;
end

function cls:OnGang(requestObj)
    local obj = {}
    
    self._context.rule.gamestate = GameState.GANG;
    self._context.rule.curidx = obj.idx;

    local entity = _gameSystems.netIdxSystem:FindEntity(obj.idx);
    self._gameSystems.playerSystem.Gang(entity, obj.code, obj.dian, obj.card, obj.hor, obj.isHoldcard, obj.isHoldcardInsLast);
    self._context.rule.settles = obj.settles;

    local responseObj = {}
    responseObj.errorcode = Errorcode.SUCCESS;
    return responseObj;
end

function cls:OnHu(requestObj)
    local obj = {}
    
    self._context.rule.gamestate = GameState.HU;
    self._context.rule.settles = obj.settles;
    self._context.rule.oknum = obj.hus.Count;
    if obj.hus.Count > 1 then
        -- 一炮多响
    end

    long dian = 0;
    for (int i = 0; i < obj.hus.Count; i++)
        local entity = _gameSystems.netIdxSystem:FindEntity(obj.hus[i].idx);
        _gameSystems.playerSystem.Hu(entity, obj.hus[i].idx, obj.hus[i].dian, obj.hus[i].jiaotype, obj.hus[i].hutype);
    }

    local responseObj = {}
    responseObj.errorcode = Errorcode.SUCCESS;
    return responseObj;
end

function cls:OnLead(requestObj)
    local obj = responseObj
    
    self._context.rule.gamestate = GameState.LEAD
    self._context.rule.lastidx = obj.idx
    self._context.rule.lastCard = obj.card
    assert(_context.rule.curidx == obj.idx)

    local entity = self._gameSystems.netIdxSystem:FindEntity(obj.idx)
    self._gameSystems.playerSystem:Lead(entity, obj.card, obj.isHoldcard)

    local responseObj = {}
    responseObj.errorcode = Errorcode.SUCCESS;
    return responseObj
end

function cls:OnOver(requestObj)
    --SendStep();

    local responseObj = {}
    responseObj.errorcode = Errorcode.SUCCESS;
    return responseObj;
end

function cls:OnSettle(requestObj) 
    local obj = requestObj
    
        --_settles = obj.settles;
        --_settlesidx = 0;

        --foreach (var item in _playes)
        --    item.Value.ClearSettle();
        --    OnSettleNext(null);
        --}

        local responseObj = {}
        responseObj.errorcode = Errorcode.SUCCESS;
        return responseObj;
end

function cls:OnFinalSettle(requestObj)
    
        -- S2cSprotoType.final_settle.request obj = requestObj as S2cSprotoType.final_settle.request;

        --_ui.ShowOver();

        --foreach (var item in _playes)
        --    item.Value.ClearSettle();
        --}

        --foreach (var x in _playes)
        --    Player player = x.Value;

        --    List<S2cSprotoType.settlementitem> settle = null;
        --    long idx = 0;
        --    if (player.Idx == 1)
        --        idx = 1;
        --        if (obj.p1 != null)
        --            settle = obj.p1;
        --        }
        --    } else if (player.Idx == 2)
        --        idx = 2;
        --        if (obj.p2 != null)
        --            settle = obj.p2;
        --        }
        --    } else if (player.Idx == 3)
        --        idx = 3;
        --        if (obj.p3 != null)
        --            settle = obj.p3;
        --        }
        --    } else if (player.Idx == 4)
        --        idx = 4;
        --        if (obj.p4 != null)
        --            settle = obj.p4;
        --        }
        --    }

        --    if (settle != null && settle.Count > 0)
        --        for (int i = 0; i < settle.Count; i++)
        --            SettlementItem item = new SettlementItem();
        --            item.Idx = settle[i].idx;
        --            item.Chip = settle[i].chip;  -- 有正负
        --            item.Left = settle[i].left;  -- 以次值为准

        --            item.Win = settle[i].win;
        --            item.Lose = settle[i].lose;

        --            item.Gang = settle[i].gang;
        --            item.HuCode = settle[i].hucode;
        --            item.HuJiao = settle[i].hujiao;
        --            item.HuGang = settle[i].hugang;
        --            item.HuaZhu = settle[i].huazhu;
        --            item.DaJiao = settle[i].dajiao;
        --            item.TuiSui = settle[i].tuisui;

        --            _playes[idx].AddSettle(item);
        --        }

        --        _playes[idx].FinalSettle();
        --    }
        --}

        local responseObj = {}
        responseObj.errorcode = Errorcode.SUCCESS;
        return responseObj;
end

function cls:OnRestart(requestObj)
    --_playes[obj.idx].Restart();
    local responseObj = {}
    responseObj.errorcode = Errorcode.SUCCESS;
    return responseObj
end

        --function cls:OnTakeRestart(requestObj)
        --    
        --        _fistidx = 0;
        --        _fisttake = 0;

        --        _curidx = 0;
        --        _curtake = 0;

        --        _huscount = 0;
        --        _oknum = 0;
        --        _take1time = 0;
        --        _takeround = 0;
        --        _takepoint = 0;  -- 最多是6 

        --        _lastidx = 0;
        --        _lastCard = null;

        --        foreach (var item in _cards)
        --            item.Value.Clear();
        --        }

        --        foreach (var item in _playes)
        --            item.Value.TakeRestart();
        --        }


        --        {
        --            SendStep();
        --        }

        --        S2cSprotoType.take_restart.response responseObj = new S2cSprotoType.take_restart.response();
        --        responseObj.errorcode = Errorcode.SUCCESS;
        --        return responseObj;
        --    } catch (Exception ex)
        --        UnityEngine.Debug.LogException(ex);
        --        S2cSprotoType.take_restart.response responseObj = new S2cSprotoType.take_restart.response();
        --        responseObj.errorcode = Errorcode.FAIL;
        --        return responseObj;
        --    }
        --}

        --function cls:OnRChat(requestObj)
        --    local obj = requestObj
        --    
        --        _playes[obj.idx].Say(obj.textid);

        --        local responseObj = {}
        --        responseObj.errorcode = Errorcode.SUCCESS;
        --        return responseObj;
        --    } catch (Exception ex)
        --        UnityEngine.Debug.LogException(ex);
        --        local responseObj = {}
        --        responseObj.errorcode = Errorcode.FAIL;
        --        return responseObj;
        --    }
        --}

return cls