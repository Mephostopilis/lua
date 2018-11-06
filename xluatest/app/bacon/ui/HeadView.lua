local EventDispatcher = require "event_dispatcher"
local res = require "res"
local log = require "log"
local language = require "language"
local Player = require "bacon.game.Player"
local Card = require "bacon.game.Card"

local cls = class("HeadView")

function cls:ctor( ... )
    -- body
    self.context = nil
    self.go = nil
    self._Tips = nil
    self._Gold = nil
    self._Leave = nil
    self._Mark = nil
    self._Say = nil
    self._Head = nil
    self._Hu = nil
    self._Peng = nil
    self._WAL = nil
    self._Ready = nil
    self._Flame = nil
    self.options = nil
    self.crak = nil
    self.bam = nil
    self.dot = nil
    self._enter = false
end

-- void Start( then
--     if (GL.Util.App.current == null then
--         HeadUIController headUIController = new HeadUIController();
--         //headUIController.SetQue(Game.Card.CardType.Bam);
--         headUIController.SetQueAnim(Game.Card.CardType.Bam);
--         headUIController.Orient = Game.Player.Orient.BOTTOM;
--         OnEnterself.context);
--     }
-- }

function cls:OnEnter(context)
    self.context = context
    if not self.go then
        local original = res.LoadGameObject("UI", "HeadView")
        local go = GameObject.Instantiate(original)
        if not go then
            return
        end
        go.transform:SetParent(context.app.uicontextMgr.buicanvas.transform)
        self.go = go
    end

    local rectTransform = go.transform
    rectTransform.pivot = CS.UnityEngine.Vector2(0.5, 0.5)
    rectTransform.anchorMax = CS.UnityEngine.Vector2(0.5, 0.5)
    rectTransform.anchorMin = CS.UnityEngine.Vector2(0.5, 0.5)
    rectTransform.localScale = CS.UnityEngine.Vector3.one
    rectTransform.sizeDelta = CS.UnityEngine.Vector2(50, 50)

    local optionsRectTransform = options.transform
    optionsRectTransform.pivot = new Vector2(0.5, 0.5);
    optionsRectTransform.anchorMax = new Vector2(0.5, 0.5);
    optionsRectTransform.anchorMin = new Vector2(0.5, 0.5);
    optionsRectTransform.localScale = Vector3.one;
    optionsRectTransform.sizeDelta = new Vector2(100, 100);

    local markRectTransform = self._Mark.transform 
    if self.context.Orient == Player.Orient.BOTTOM then
        rectTransform.anchoredPosition3D = CS.UnityEngine.Vector3(-600, -200, 0)
        optionsRectTransform.anchoredPosition3D = CS.UnityEngine.Vector3(600, 40, 0)
    elseif self.context.Orient == Player.Orient.RIGHT then
        rectTransform.anchoredPosition3D = CS.UnityEngine.Vector3(600, 80, 0)
        optionsRectTransform.anchoredPosition3D = CS.UnityEngine.Vector3(-300, 0, 0)
        markRectTransform.anchoredPosition3D = CS.UnityEngine.Vector3(-25, 25, 0)
    elseif self.context.Orient == Player.Orient.TOP then
        rectTransform.anchoredPosition3D = CS.UnityEngine.Vector3(500, 300, 0)
        optionsRectTransform.anchoredPosition3D = CS.UnityEngine.Vector3(-500, -50, 0)
        markRectTransform.anchoredPosition3D = CS.UnityEngine.Vector3(-25, 25, 0)
    elseif self.context.Orient == Player.Orient.LEFT then
        rectTransform.anchoredPosition3D = CS.UnityEngine.Vector3(-600, 80, 0)
        optionsRectTransform.anchoredPosition3D = CS.UnityEngine.Vector3(300, 0, 0)
    end

    self:CloseQueType()

    self._enter = true
    self:OnShaking(context)
    self._enter = false
end

function cls:OnShaking(context)
    
    local crakRectTransform = crak.transform
    local bamRectTransform = bam.transform 
    local dotRectTransform = dot.transform 
    if self.context.Orient == Player.Orient.BOTTOM then
        local dst = CS.UnityEngine.Vector3(600, 40, 0)
        crakRectTransform.anchoredPosition3D = dst;
        bamRectTransform.anchoredPosition3D = dst;
        dotRectTransform.anchoredPosition3D = dst;
    elseif self.context.Orient == Player.Orient.RIGHT then
        local dst = CS.UnityEngine.Vector3(-300, 0, 0);
        crakRectTransform.anchoredPosition3D = dst;
        bamRectTransform.anchoredPosition3D = dst;
        dotRectTransform.anchoredPosition3D = dst;
    elseif self.context.Orient == Player.Orient.TOP then
        local dst = CS.UnityEngine.Vector3(-500, -50, 0)
        crakRectTransform.anchoredPosition3D = dst;
        bamRectTransform.anchoredPosition3D = dst;
        dotRectTransform.anchoredPosition3D = dst;
    elseif self.context.Orient == Player.Orient.LEFT then
        local dst = CS.UnityEngine.Vector3(300, 0, 0)
        crakRectTransform.anchoredPosition3D = dst;
        bamRectTransform.anchoredPosition3D = dst;
        dotRectTransform.anchoredPosition3D = dst;
    end

    if self._enter or (self.context.State & self.context.Options.LEAVE) > 0 then
        self:SetLeave(self.context.leave)
    end
    if self._enter or (self.context.State & self.context.Options.GOLD) > 0 then
        self:SetGoldself(self.context.gold)
    end
    if self._enter or (self.context.State & self.context.Options.READY) > 0 then
        self:SetReady(self.context.ready)
    end
    if self._enter or (self.context.State & self.context.Options.TIPS) > 0 then
        if self.context.tips.Length > 0 then
            self:ShowTips(self.context.tips)
        else
            self:CloseTips();
        end
    end

    if self._enter or (self.context.State & self.context.Options.SAY) > 0 then
        if self.context.say.Length > 0 then
            self:ShowSay(self.context.say)
        else
            self:CloseSay()
        end
    end

    if self._enter or (self.context.State & self.context.Options.HEAD) > 0 then
    end

    if self._enter or (self.context.State & self.context.Options.HU) > 0 then
        self:SetHu(self.context.hu)
    end

    if self._enter or (self.context.State & self.context.Options.PENG) > 0 then
        self:SetPeng(self.context.peng)
    end

    if self._enter or (self.context.State & self.context.Options.WAL) > 0 then
        if self.context.wal.Length > 0 then
            self:ShowWAL(self.context.Orient, self.context.wal)
        else
            self:CloseWAL()
        end
    end

    if self._enter or (self.context.State & self.context.Options.HEAD) > 0 then
        if self.context.flame > 0 then
            self:PlayFlameCountdown(self.context.flame)
        else
            self:StopFlame()
        end
    end

    if self._enter or (self.context.State & self.context.Options.QUE) > 0 then
        if self.context.que == Game.Card.CardType.Crak then
            self:ShowMark(language(2))
        elseif self.context.que == Game.Card.CardType.Bam then
            self:ShowMark(language(3))
        elseif self.context.que == Game.Card.CardType.Dot then
            self:ShowMark(language(4))
        else
            self:CloseMark()
        end
    end

    if self.context.State & self.context.Options.QUEANIM > 0 then
        self:CloseMark()
        self:CloseQueType()

        local que
        if self.context.que == Card.CardType.Crak then
            if not self.crak.activeSelf then
                self.crak:SetActive(true)
            end
            que = self.crak
        elseif self.context.que == Card.CardType.Bam then
            if not self.bam.activeSelf then
                self.bam:SetActive(true)
            end
            que = self.bam
        elseif self.context.que == Card.CardType.Dot then
            if not self.dot.activeSelf then
                self.dot.SetActive(true)
            end
            que = dot
        end

        local moveDst = self._Mark.transform.anchoredPosition3D
        local scaleDst = CS.UnityEngine.Vector3(0.2, 0.2, 0.2)
        local moveDuration = 0.8
        local scaleDuration = 0.5

        local sequence = CS.DOTween.Sequence()
        sequence:Append(que.transform:DOLocalMove(moveDst, moveDuration))
            :Append(que.transform:DOScale(scaleDst, scaleDuration))
            :AppendCallback(function ( ... )
                -- body
                if que.activeSelf then
                    que:SetActive(false);
                end
                if self.context.que == Game.Card.CardType.Crak then
                    self:ShowMark(language(2))
                elseif self.context.que == Game.Card.CardType.Bam then
                    self:ShowMark(language(3))
                elseif self.context.que == Game.Card.CardType.Dot then
                    self:ShowMark(language(4))
                else
                    self:CloseMark()
                end
            end)
    end

    self.context:OnClean()
end

function cls:SetGold(num)
    local txt = string.Format("{0}", num)
    self._Gold.text = txt
end

function cls:SetLeave(value)
    if value then
        self._Leave:SetActive(true)
    else 
        self._Leave:SetActive(false)
    end
end

function cls:ShowMark(m)
    if not self._Mark.activeSelf then
        self._Mark:SetActive(true)
    end
    self._Mark.transform:Find("Content"):GetComponent("Text").text = m
end

function cls:CloseMark()
    if self._Mark.activeSelf then
        self._Mark:SetActive(false)
    end
end

function cls:CloseQueType()
    if self.crak.activeSelf then
        self.crak:SetActive(false)
    end
    if self.bam.activeSelf then
        self.bam:SetActive(false)
    end
    if self.dot.activeSelf then
        self.dot:SetActive(false)
    end
end

function cls:ShowSay(value)
    if not self._Say.activeSelf then
        self._Say:SetActive(true)
    end
    self._Say:GetComponent("Text").text = value
end

function cls:CloseSay()
    if self._Say.activeSelf then
        self._Say.SetActive(false)
    end
end

function cls:SetHu(value)
    if value then
        if not self._Hu.activeSelf then
            self._Hu:SetActive(true)
            local hu = self._Hu:GetComponent("HuView")
            hu:Play(function ( ... )
                -- body
            end)
        end
    else
        if self._Hu.activeSelf then
            self._Hu:SetActive(false)
        end
    end
end

function cls:SetPeng(value) 
    if value then
        if not self._Peng.activeSelf then
            self._Peng:SetActive(true)
            local peng = self._Peng:GetComponent("PengView")
            peng.Play(function ( ... )
                -- body
            end)
        end
    else
        if self._Peng.activeSelf then
            self._Peng:SetActive(false)
        end
    end
end

function cls:ShowWAL(orient, value) 
    assert(orient and value)
    if not _WAL.activeSelf then
        self._WAL:SetActive(true)
    end
    if orient == Player.Orient.BOTTOM then
        self._WAL:GetComponent("Text").text = value;
        self._WAL:GetComponent("RectTransform").localPosition = CS.UnityEngine.Vector3(600, 110, 0)
        self._WAL.transform:DOLocalMoveY(120.0, 1.0);
    elseif orient == Player.Orient.RIGHT then
        self._WAL:GetComponent("Text").text = value
        self._WAL.transform.localPosition = CS.UnityEngine.Vector3(-360, 0.0, 0.0)
        self._WAL.transform:DOLocalMoveY(10.0, 1.0)
    elseif orient == Player.Orient.TOP then
        self._WAL.GetComponent("Text").text = value
        self._WAL.transform.localPosition = CS.UnityEngine.Vector3(-500, -110.0, 0.0)
        self._WAL.transform:DOLocalMoveY(-100.0, 1.0)
    elseif orient == Player.Orient.LEFT then
        self._WAL:GetComponent("Text").text = value
        self._WAL.transform.localPosition = CS.UnityEngine.Vector3(360.0, 0.0, 0.0)
        self._WAL.transform:DOLocalMoveY(10.0, 1.0)
    end
end

function cls:CloseWAL()
    if self._WAL.activeSelf then
        self._WAL.SetActive(false)
    end
end

function cls:SetReady(value)
    if value then
        if not self._Ready.activeSelf then
            self._Ready:SetActive(true)
        end
    else
        if self._Ready.activeSelf then
            self._Ready:SetActive(false)
        end
    end
end

function cls:PlayFlameCountdown(cd)
    self._Flame:GetComponent("FlameThrower"):Play(cd)
end

function cls:StopFlame()
    self._Flame:GetComponent("FlameThrower"):Stop()
end

function cls:ShowTips(content) 
    if self._Tips ~= nil then
        if not self._Tips.activeSelf then
            self._Tips.SetActive(true)
        end
        self._Tips.GetComponent("Text").text = content
    end
end

function cls:CloseTips()
    if self._Tips ~= nil then
        if self._Tips.activeSelf then
            self._Tips.SetActive(false);
        end
    end
end

return cls