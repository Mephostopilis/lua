local UIContext = require "maria.uibase.UIContext"
local Provice = require "bacon.game.Provice"
local OverCode = require "bacon.game.OverCode"
local OverType = require "bacon.game.OverType"
local CreateRoomView = require "bacon.ui.CreateRoomView"
local EventDispatcher = require "event_dispatcher"
local res = require "res"
local assert = assert

local cls = class("CreateRoomUIContext")

function cls:ctor(appContext, ... )
    -- body
    assert(appContext and appContext.__cname == 'AppContext')
    self.appContext = appContext
    self.view = CreateRoomView.new(self)
    self._provice = Provice.Sichuan                  --  @省份
    self._ju = 8                                                            -- 
    self._overtype = OverType.XUELIU                 -- 1jie
    self._hujiaozhuanyi = 1
    self._dianganghua = 0
    self._zimo = 1
    self._daiyaojiu = 1
    self._duanyaojiu = 1
    self._jiangdui = 1
    self._tiandihu = 1
    self._top = 8
    self._sxqidui = 1
    self._sxqingyise = 1
end

function cls:OnEnter( ... )
    -- body
    self.view:OnEnter(self)
end

function cls:OnExit( ... )
    -- body
    self.view:OnExit(self)
end

function cls:Shaking()
    self.view:OnShaking()
end

return cls

