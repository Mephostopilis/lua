local log = require "log"
local assert = assert

local _M = {}

function _M:handshake(requestObj)
    -- log.info("request hanshake.")
    local responseObj = {}
    responseObj.errorcode = errorcode.SUCCESS
    return responseObj
end

function _M:inbox(requestObj)
    log.info("request inbox.")
    -- local m = _appContext.U.GetModule<local>()
    -- return m.OnInbox(requestObj)
end

function _M:match(requestObj)
    -- return null
    -- //MainController controller = ctx.Peek<MainController>()
    -- //return controller.OnMatch(requestObj)
end

function _M:join(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local joinSystem = gameSystems.joinSystem
    return joinSystem:OnJoin(requestObj)
end

function _M:rejoin(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local joinSystem = gameSystems.joinSystem
    return joinSystem:OnRejoin(requestObj)
end

function _M:afk(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnOffline(requestObj)
end

function _M:leave(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local joinSystem = gameSystems.joinSystem
    return joinSystem:OnLeave(requestObj)
end

-- 此协议将放弃
function _M:authed(requestObj)
    assert(false)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnOnline(requestObj)
end

function _M:take_ready(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnTakeReady(requestObj)

    -- local responseObj = {}
    -- responseObj.errorcode = errorcode.SUCCESS
    -- return responseObj
end

function _M:ready(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnReady(requestObj)
end

function _M:shuffle(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnShuffle(requestObj)
end

function _M:dice(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnDice(requestObj)
end

function _M:deal(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnDeal(requestObj)
end

function _M:takexuanpao(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnTakeXuanPao(requestObj)
end

function _M:xuanpao(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnXuanPao(requestObj)
end

function _M:takexuanque(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnTakeXuanQue(requestObj)
end

function _M:xuanque(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnXuanQue(requestObj)
end

function _M:taketurn(requestObj)
    local gameSystem = self._appContext.gameSystems.gameSystem
    return gameSystem:OnTakeTurn(requestObj)
end

function _M:ocall(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnOCall(requestObj)
end

function _M:mcall(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnMCall(requestObj)
end

function _M:peng(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnPeng(requestObj)
end

function _M:gang(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnGang(requestObj)
end

function _M:hu(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem.OnHu(requestObj)
end

function _M:lead(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem:OnLead(requestObj)
end

function _M:over(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem.OnOver(requestObj)
end

function _M:settle(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem.OnSettle(requestObj)
end

function _M:finalsettle(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem.OnFinalSettle(requestObj)
end

function _M:restart(requestObj)
    local gameSystems = AppContext:getInstance().gameSystems
    local gameSystem = gameSystems.gameSystem
    return gameSystem.OnRestart(requestObj)
end

-- //function _M:takerestart( requestObj)
-- //    GameSystems.GameSystem gameSystem = _appContext.GameSystems.GameSystem
-- //    return gameSystem.OnTakeRestart(requestObj)
-- //end

-- //function _M:rchat( requestObj)
-- //    GameSystems.GameSystem gameSystem = _appContext.GameSystems.GameSystem
-- //    return gameSystem.OnRChat(requestObj)
-- //end

function _M:radio(requestObj)
    -- AdverModule adverModule = self._appContext.U.GetModule<AdverModule>()
    -- return adverModule.Radio(requestObj)
end

--
function _M:sub_item(requestObj)
    local responseObj = {}
    responseObj.errorcode = 0
    return responseObj
end

return _M
