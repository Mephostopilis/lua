
local HeadView = require "bacon.ui.HeadView"
local Card = require "bacon.game.Card"

local Options = {
    NONE = 0,
    LEAVE = 1 << 0,
    GOLD = 1 << 1,
    READY = 1 << 2,
    TIPS = 1 << 3,
    --MARK = 1 << 4,
    SAY = 1 << 5,
    HEAD = 1 << 6,
    HU = 1 << 7,
    PENG = 1 << 8,
    WAL = 1 << 9,
    FLAME = 1 << 10,
    QUE = 1 << 11,
    QUEANIM = 1 << 12,
}


local cls = class("HeadUIContext")

cls.Options = Options

function cls:ctor(appContext, ... )
    -- body
    self.appContext = appContext
    self.View = HeadView.new(self)
    self.State = Options.NONE
    self.Orient = nil
    self.tips = ""
    self.leave = false
    self.gold = 0
    self.mark = ""
    self.say = ""
    self.head = ""
    self.hu = false
    self.peng = false
    self.wal = ""
    self.ready = false
    self.flame = 0
    self.que = Card.CardType.None
end

function cls:OnEnter( ... )
    -- body
    self.View:OnEnter(self)
end

function cls:OnPause()
end

function cls:OnResume()
end

function cls:OnExit()
end

function cls:Shaking()
    self.View:OnShaking()
end

function cls:SetLeave(value)
    if self.leave ~= value then
        self.leave = value
        self.State = self.State | Options.LEAVE;
    end
end

function cls:SetGold(value)
    if self.gold ~= value then
        self.gold = value
        self.State = self.State | Options.GOLD
    end
end

--function cls:SetMark(value)
--    if (self.mark ~= value)
--        self.mark = value;
--        self.State = self.State | Options.MARK;
--    }
--}

function cls:SetSay(value)
    if self.say ~= value then
        self.say = value;
        self.State = self.State | Options.SAY
    end
end

function cls:SetHead(value)
    if self.head ~= value then
        self.head = value
        self.State = self.State | Options.HEAD;
    end
end

function cls:SetHu(value)
    if self.hu ~= value then
        self.hu = value
        self.State = self.State | Options.HU;
    end
end

function cls:SetPeng(value)
    if self.peng ~= value then
        self.peng = value
        self.State = self.State | Options.PENG;
    end
end

function cls:SetWal(value)
    if self.wal ~= value then
        self.wal = value;
        self.State = self.State | Options.WAL;
    end
end

function cls:SetReady(value)
    if self.ready ~= value then
        self.ready = value
        self.State = self.State | Options.READY;
    end
end

function cls:SetFlame(value)
    if self.flame ~= value then
        self.flame = value;
        self.State = self.State | Options.FLAME;
    end
end

function cls:SetQue(value) 
    if self.que ~= value then
        self.que = value;
        self.State = self.State | Options.QUE;
    end
end

function cls:SetQueAnim(value)
    if self.que ~= value then
        self.que = value
        self.State = self.State | Options.QUEANIM
    end
end
    
function cls:OnClean(e)
    self.State = Options.NONE;
end

return cls
        