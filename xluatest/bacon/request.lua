local log = require "log"
local errorcode = require "bacon.errorcode"
local AppContext = require "bacon.AppContext"
local assert = assert

local cls = class("request")

function cls:ctor(cs)
    cs:regiseter_request("handshake", cls.handshake, self)
    cs:regiseter_request("inbox", cls.inbox, self)
    cs:regiseter_request("match", cls.match, self)
    cs:regiseter_request("join", cls.join, self)
    cs:regiseter_request("rejoin", cls.rejoin, self)
    cs:regiseter_request("leave", cls.leave, self)
    cs:regiseter_request("offline", cls.afk, self)
    cs:regiseter_request("online", cls.authed, self)         -- deprecated

    cs:regiseter_request("take_ready", cls.take_ready, self)
    cs:regiseter_request("ready", cls.ready, self)
    cs:regiseter_request("shuffle", cls.shuffle, self)
    cs:regiseter_request("dice", cls.dice, self)
    cs:regiseter_request("deal", cls.deal, self)
    cs:regiseter_request("take_xuanpao", cls.takexuanpao, self)
    cs:regiseter_request("take_xuanque", cls.takexuanque, self)
    cs:regiseter_request("xuanpao", cls.xuanpao, self)
    cs:regiseter_request("xuanque", cls.xuanque, self)
    cs:regiseter_request("ocall", cls.ocall, self)
    cs:regiseter_request("mcall", cls.mcall, self)
    cs:regiseter_request("take_turn", cls.taketurn, self)

    cs:regiseter_request("peng", cls.peng, self)
    cs:regiseter_request("gang", cls.gang, self)
    cs:regiseter_request("hu", cls.hu, self)
    cs:regiseter_request("lead", cls.lead, self)

    cs:regiseter_request("over", cls.over, self)
    cs:regiseter_request("settle", cls.settle, self)
    cs:regiseter_request("final_settle", cls.finalsettle, self)
    cs:regiseter_request("restart", cls.restart, self)
    cs:regiseter_request("take_restart", cls.takerestart, self)

    cs:regiseter_request("rchat", cls.rchat, self)
    cs:regiseter_request("radio", cls.radio, self)
    cs:regiseter_request("sub_item", cls.sub_item, self)
end

function cls:handshake( requestObj) 
    -- log.info("request hanshake.")
    local responseObj = {}
    responseObj.errorcode = errorcode.SUCCESS
    return responseObj
end

function cls:inbox( requestObj) 
    log.info("request inbox.")
    -- local m = _appContext.U.GetModule<local>()
    -- return m.OnInbox(requestObj)
end

function cls:match(requestObj) 
    -- return null
    -- //MainController controller = ctx.Peek<MainController>()
    -- //return controller.OnMatch(requestObj)
end

function cls:join(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local joinSystem = gameSystems.joinSystem
    return joinSystem:OnJoin(requestObj)
end

function cls:rejoin(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local joinSystem = gameSystems.joinSystem
    return joinSystem:OnRejoin(requestObj)
end

function cls:afk(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnOffline(requestObj)
end

function cls:leave(requestObj) 
    local gameSystems = AppContext:getInstance().gameSystems
    local joinSystem = gameSystems.joinSystem
    return joinSystem:OnLeave(requestObj)
end

-- 此协议将放弃
function cls:authed(requestObj)
    assert(false)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnOnline(requestObj)
end

function cls:take_ready(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnTakeReady(requestObj)

    -- local responseObj = {}
    -- responseObj.errorcode = errorcode.SUCCESS
    -- return responseObj
end

function cls:ready(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnReady(requestObj)
end

function cls:shuffle(requestObj) 
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnShuffle(requestObj)
end

function cls:dice(requestObj) 
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnDice(requestObj)
end

function cls:deal(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnDeal(requestObj)
end

function cls:takexuanpao(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnTakeXuanPao(requestObj)
end

function cls:xuanpao(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnXuanPao(requestObj)
end

function cls:takexuanque(requestObj) 
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnTakeXuanQue(requestObj)
end

function cls:xuanque(requestObj) 
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnXuanQue(requestObj)
end

function cls:taketurn(requestObj) 
    local gameSystem = self._appContext.gameSystems.gameSystem
    return gameSystem:OnTakeTurn(requestObj)
end

function cls:ocall( requestObj) 
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnOCall(requestObj)
end

function cls:mcall( requestObj )  
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnMCall(requestObj)
end

function cls:peng( requestObj) 
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnPeng(requestObj)
end

function cls:gang(requestObj) 
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnGang(requestObj)
end

function cls:hu( requestObj) 
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem.OnHu(requestObj)
end

function cls:lead( requestObj) 
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnLead(requestObj)
end

function cls:over( requestObj) 
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem.OnOver(requestObj)
end

function cls:settle( requestObj) 
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem.OnSettle(requestObj)
end

function cls:finalsettle( requestObj) 
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem.OnFinalSettle(requestObj)
end

function cls:restart( requestObj) 
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
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

function cls:radio(requestObj) 
    -- AdverModule adverModule = self._appContext.U.GetModule<AdverModule>()
    -- return adverModule.Radio(requestObj)
end

-- 
function cls:sub_item(requestObj)
    local responseObj = {}
    responseObj.errorcode = 0
    return responseObj
end

return cls