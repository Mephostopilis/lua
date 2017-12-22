
local NetworkMgr = require "maria.network.NetworkMgr"
local MyEventCmd = require "bacon.event.MyEventCmd"
local OpCodes = require "bacon.game.OpCodes"

local _context;
local _appContext;
local _gameSystems;

local _M = {}

function  _M.Initialize() 
    EventListenerCmd listener6 = new EventListenerCmd(MyEventCmd.EVENT_LEAD, OnLead);
    _appContext.EventDispatcher.AddCmdEventListener(listener6);
end

        

function _M.SendPeng() 
            local request = {}
            request.op = {}
            request.op.idx = _context.rule.myidx
            request.op.opcode = OpCodes.OPCODE_PENG

            _appContext.SendReq<C2sProtocol.call>(C2sProtocol.call.Tag, request);
end

        public void SendGang() {
#if (!GEN_COMPONENT)

            C2sSprotoType.call.request request = new C2sSprotoType.call.request();
            request.op = new C2sSprotoType.opinfo();
            request.op.idx = _context.rule.myidx;
            request.op.opcode = OpCodes.OPCODE_PENG;

            _appContext.SendReq<C2sProtocol.call>(C2sProtocol.call.Tag, request);
#endif
        }

        public void SendGuo() {
#if (!GEN_COMPONENT)
            C2sSprotoType.call.request request = new C2sSprotoType.call.request();
            request.op = new C2sSprotoType.opinfo();
            request.op.idx = _context.rule.myidx;
            request.op.opcode = OpCodes.OPCODE_GUO;

            _appContext.SendReq<C2sProtocol.call>(C2sProtocol.call.Tag, request);
#endif
        }

        public void SendHu() {
#if (!GEN_COMPONENT)

            C2sSprotoType.call.request request = new C2sSprotoType.call.request();
            request.op = new C2sSprotoType.opinfo();
            request.op.idx = _context.rule.myidx;
            request.op.opcode = OpCodes.OPCODE_HU;

            _appContext.SendReq<C2sProtocol.call>(C2sProtocol.call.Tag, request);
#endif
        }

        public void SendLead(long value, bool isHoldcard) {
#if (!GEN_COMPONENT)
            C2sSprotoType.lead.request request = new C2sSprotoType.lead.request();
            request.idx = _context.rule.myidx;
            request.card = value;
            request.isHoldcard = isHoldcard;
            _appContext.SendReq<C2sProtocol.lead>(C2sProtocol.lead.Tag, request);
#endif
        }
        #endregion

        #region event
        private void OnLead(EventCmd e) {
#if (!GEN_COMPONENT)
            SendLead((long)e.Msg["value"], (bool)e.Msg["isHoldcard"]);
#endif
        }
        #endregion

    }
}
