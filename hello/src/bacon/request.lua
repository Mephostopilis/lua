local log = require "log"
local errorcode = require "errorcode"
local assert = assert

local cls = class("request")

function cls:cls:ctor(ctx, cs) 
    self._appContext = ctx

    cs.RegisterRequest("handshake", cls.handshake, self)
    cs.RegisterRequest("inbox", cls.inbox, self)
    cs.RegisterRequest("match", cls.match, self)
    cs.RegisterRequest("join", cls.join, self)
    cs.RegisterRequest("leave", cls.leave, self)
    cs.RegisterRequest("offline", cls.afk, self)
    cs.RegisterRequest("online", cls.authed, self)

    cs.RegisterRequest("ready", "ready", self)
    cs.RegisterRequest("shuffle", "shuffle", self)
    cs.RegisterRequest("dice", "dice", self)
    cs.RegisterRequest("deal", "deal", self)
    cs.RegisterRequest("take_xuanpao", "takexuanpao", self)
    cs.RegisterRequest("take_xuanque", takexuanque)
    cs.RegisterRequest("xuanpao", xuanpao)
    cs.RegisterRequest("xuanque", xuanque)
    cs.RegisterRequest("ocall", ocall)
    cs.RegisterRequest("mcall", mcall)
    cs.RegisterRequest("take_turn", taketurn)

    cs.RegisterRequest("peng", peng)
    cs.RegisterRequest("gang", gang)
    cs.RegisterRequest("hu", hu)
    cs.RegisterRequest("lead", lead)

    cs.RegisterRequest("over", over)
    cs.RegisterRequest("settle", settle)
    cs.RegisterRequest("final_settle", finalsettle)
    cs.RegisterRequest("restart", restart)
    cs.RegisterRequest("take_restart", takerestart)

    cs.RegisterRequest("rchat", rchat)
    cs.RegisterRequest("radio", radio)
end

function cls:handshake( requestObj) 
    log.info("request hanshake.")
    local responseObj = {}
    responseObj.errorcode = errorcode.SUCCESS
    return responseObj
end

function cls:inbox( requestObj) 
    log.info("request inbox.")
    local m = _appContext.U.GetModule<local>()
    return m.OnInbox(requestObj)
end

function cls:match( requestObj) 
    -- return null
    -- //MainController controller = ctx.Peek<MainController>()
    -- //return controller.OnMatch(requestObj)
end

function cls:join( requestObj) 
    GameSystems.JoinSystem joinSystem = _appContext.GameSystems.JoinSystem
    return joinSystem.OnJoin(requestObj)
end

function cls:leave( requestObj) 
    GameSystems.JoinSystem joinSystem = _appContext.GameSystems.JoinSystem
    return joinSystem.OnLeave(requestObj)
end

function cls:authed( requestObj) 
    GameSystems.GameSystem gameSystem = _appContext.GameSystems.GameSystem
    return gameSystem.OnOnline(requestObj)
end

function cls:afk( requestObj) 
    GameSystems.GameSystem gameSystem = _appContext.GameSystems.GameSystem
    return gameSystem.OnOffline(requestObj)
end

function cls:ready( requestObj) 
    GameSystems.GameSystem gameSystem = _appContext.GameSystems.GameSystem
    return gameSystem.OnReady(requestObj)
end

function cls:shuffle( requestObj) 
    GameSystems.GameSystem gameSystem = _appContext.GameSystems.GameSystem
    return gameSystem.OnShuffle(requestObj)
end

function cls:dice( requestObj) 
    GameSystems.GameSystem gameSystem = _appContext.GameSystems.GameSystem
    return gameSystem.OnDice(requestObj)
end

function cls:deal( requestObj) 
    GameSystems.GameSystem gameSystem = _appContext.GameSystems.GameSystem
    return gameSystem.OnDeal(requestObj)
end

function cls:takexuanpao( requestObj) 
    GameSystems.GameSystem gameSystem = _appContext.GameSystems.GameSystem
    return gameSystem.OnTakeXuanPao(requestObj)
end

function cls:xuanpao( requestObj) 
    GameSystems.GameSystem gameSystem = _appContext.GameSystems.GameSystem
    return gameSystem.OnXuanPao(requestObj)
end

function cls:takexuanque( requestObj) 
    GameSystems.GameSystem gameSystem = _appContext.GameSystems.GameSystem
    return gameSystem.OnTakeXuanQue(requestObj)
end

function cls:xuanque( requestObj) 
    GameSystems.GameSystem gameSystem = _appContext.GameSystems.GameSystem
    return gameSystem.OnXuanQue(requestObj)
end

function cls:taketurn( requestObj) 
    GameSystems.GameSystem gameSystem = _appContext.GameSystems.GameSystem
    return gameSystem.OnTakeTurn(requestObj)
end

function cls:ocall( requestObj) 
    GameSystems.GameSystem gameSystem = _appContext.GameSystems.GameSystem
    return gameSystem.OnOCall(requestObj)
end

function cls:mcall( requestObj) 
    GameSystems.GameSystem gameSystem = _appContext.GameSystems.GameSystem
    return gameSystem.OnMCall(requestObj)
end

function cls:peng( requestObj) 
    GameSystems.GameSystem gameSystem = _appContext.GameSystems.GameSystem
    return gameSystem.OnPeng(requestObj)
end

function cls:gang( requestObj) 
    GameSystems.GameSystem gameSystem = _appContext.GameSystems.GameSystem
    return gameSystem.OnGang(requestObj)
end

function cls:hu( requestObj) 
    GameSystems.GameSystem gameSystem = _appContext.GameSystems.GameSystem
    return gameSystem.OnHu(requestObj)
end

function cls:lead( requestObj) 
    GameSystems.GameSystem gameSystem = _appContext.GameSystems.GameSystem
    return gameSystem.OnLead(requestObj)
end

function cls:over( requestObj) 
    GameSystems.GameSystem gameSystem = _appContext.GameSystems.GameSystem
    return gameSystem.OnOver(requestObj)
end

function cls:settle( requestObj) 
    GameSystems.GameSystem gameSystem = _appContext.GameSystems.GameSystem
    return gameSystem.OnSettle(requestObj)
end

function cls:finalsettle( requestObj) 
    GameSystems.GameSystem gameSystem = _appContext.GameSystems.GameSystem
    return gameSystem.OnFinalSettle(requestObj)
end

function cls:restart( requestObj) 
    GameSystems.GameSystem gameSystem = _appContext.GameSystems.GameSystem
    return gameSystem.OnRestart(requestObj)
end

-- //function cls:takerestart( requestObj) 
-- //    GameSystems.GameSystem gameSystem = _appContext.GameSystems.GameSystem
-- //    return gameSystem.OnTakeRestart(requestObj)
-- //end

-- //function cls:rchat( requestObj) 
-- //    GameSystems.GameSystem gameSystem = _appContext.GameSystems.GameSystem
-- //    return gameSystem.OnRChat(requestObj)
-- //end

function cls:radio( requestObj) 
    AdverModule adverModule = _appContext.U.GetModule<AdverModule>()
    return adverModule.Radio(requestObj)
end


