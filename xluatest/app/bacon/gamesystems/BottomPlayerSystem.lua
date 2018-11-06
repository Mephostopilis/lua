
local NetworkMgr = require "maria.network.NetworkMgr"
local EventDispatcher = require "maria.event.EventDispatcher"
local MyEventCmd = require "bacon.event.MyEventCmd"
local OpCodes = require "bacon.game.OpCodes"

local cls = class("BottomPlayerSystem")

function cls:ctor( ... )
    -- body
    self._context = nil
    self._appContext = nil
    self._gameSystems = nil
end

function  cls:Initialize() 
    EventListenerCmd listener6 = new EventListenerCmd(MyEventCmd.EVENT_LEAD, OnLead);
    _appContext.EventDispatcher.AddCmdEventListener(listener6);
end

function cls:Cleanup( ... )
            -- body
end        

function cls:SendPeng() 
            local request = {}
            request.op = {}
            request.op.idx = self._context.myidx.index
            request.op.opcode = OpCodes.OPCODE_PENG
            NetworkMgr:getInstance().client:send_request("call", request)
end

function cls:SendGang() 
            local request = {}
            request.op = new C2sSprotoType.opinfo();
            request.op.idx = _context.rule.myidx;
            request.op.opcode = OpCodes.OPCODE_PENG;
            NetworkMgr:getInstance().client:send_request("call", request)
end

function cls:SendGuo() 
            local request = {}
            request.op = new C2sSprotoType.opinfo();
            request.op.idx = _context.rule.myidx;
            request.op.opcode = OpCodes.OPCODE_GUO;
            NetworkMgr:getInstance().client:send_request("call", request)
end

function cls:SendHu() 
            local request = {}
            request.op = new C2sSprotoType.opinfo();
            request.op.idx = _context.rule.myidx;
            request.op.opcode = OpCodes.OPCODE_HU;
            NetworkMgr:getInstance().client:send_request("call", request)
end

function cls:SendLead(value, isHoldcard)
            local request = {}
            request.idx = _context.rule.myidx
            request.card = value
            request.isHoldcard = isHoldcard
            NetworkMgr:getInstance().client:send_request("call", request)
end

       
function cls:OnLead(e) 
            self:SendLead((long)e.Msg["value"], (bool)e.Msg["isHoldcard"])
end

function cls:OnQue(EventCmd e) 
            
                -- Director.Instance .UIContextManager.Pop();
                -- GameUIModule gameUIModule = Director.Instance.User.GetModule<GameUIModule>();
                -- Card.CardType cardType = (Card.CardType)e.Msg["cardtype"];
                -- gameUIModule.SendQue((long)cardType);

                -- AppGameSystems gameSystems = Director.Instance.GameSystems;
                -- gameSystems.PlayerSystem.SetXuanQue(Director.Instance.User.GetModule<JoinModule>().MyIdx, true);
                -- gameSystems.PlayerSystem.ShowQue(Director.Instance.User.GetModule<JoinModule>().MyIdx, cardType);
end

return cls