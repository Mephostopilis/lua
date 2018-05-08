local BaseView = require "maria.uibase.BaseView"
local Provice = require "bacon.game.Provice"
local OverType = require "bacon.game.OverType"
local MyEventCmd = require "bacon.event.MyEventCmd"
local EventDispatcher = require "event_dispatcher"
local log = require "log"
local res = require "res"

local cls = class("CreateRoomView", BaseView)

function cls:ctor( ... )
    -- body
    self.context = nil
    self.go = nil
    self.created = false
    self.scView = nil
    self.sxView = nil
    self._RCard = nil
    self._Point = nil
    self.xueLiu = nil
    self.xueZhan = nil

    -- sc
    self._HuJiaoZhuanYi = nil       -- public GameObject
    self._ZiMoBuJiaBei = nil
    self._ZiMoJiaDi = nil
    self._ZiMoJiaBei = nil
    self._DianGangHuaZiMo = nil
    self._DianGangHuaDianPao = nil

    self._DaiYaoJiux4 = nil
    self._DuanYaoJiux2 = nil
    self._JiangDuix8 = nil
    self._TianDiHux32 = nil

    self._Top8 = nil
    self._Top16 = nil
    self._Top32 = nil

    self._Ju8 = nil
    self._Ju16 = nil

    self._HuJiaoZhuanYiLabel = nil
    self._ZiMoBuJiaBeiLabel = nil
    self._ZiMoJiaDiLabel = nil
    self._ZiMoJiaBeiLabel = nil
    self._DianGangHuaZiMoLabel = nil
    self._DianGangHuaDianPaoLabel = nil

    self._DaiYaoJiux4Label = nil
    self._DuanYaoJiux2Label = nil
    self._JiangDuix8Label = nil
    self._TianDiHux32Label = nil

    self._Top8Label = nil
    self._Top16Label = nil
    self._Top32Label = nil

    self._Ju8Label = nil
    self._Ju16Label =nil

    self._normal = CS.UnityEngine.Color(123.0 / 255.0, 87.0 / 255.0, 9.0 / 255.0)
    self._pressed = CS.UnityEngine.Color(168.0/ 255.0, 39.0 / 255.0, 7.0 / 255.0)
end

function cls:OnEnter(context, ... )
    -- body
    self.context = context
    if not self.go then
        local original = res.LoadGameObject("UI/CreateRoom", "CreateRoomView")
        if not original then
            log.error("LoadGameObject UI/CreateRoom/CreateRoomView failture.")
            return
        end
        local go = CS.UnityEngine.GameObject.Instantiate(original)
        go.transform:SetParent(context.appContext.uicontextMgr.buicanvas.transform)
        self.go = go
    else
        self.go:SetActive(true)
    end

    local rectTransform = self.go.transform
    rectTransform:SetInsetAndSizeFromParentEdge(CS.UnityEngine.RectTransform.Edge.Top, 0, 750)
    rectTransform:SetInsetAndSizeFromParentEdge(CS.UnityEngine.RectTransform.Edge.Left, 0, 1334)
    rectTransform.localPosition = CS.UnityEngine.Vector3(rectTransform.localPosition.x, rectTransform.localPosition.y, 0)
    rectTransform.localScale = CS.UnityEngine.Vector3.one

    self.scView = rectTransform:Find("ScView").gameObject
    self.sxView = rectTransform:Find("SxView").gameObject
    self._RCard = rectTransform:Find("RCard").gameObject
    self._RCard:GetComponent("Text").text = string.format("已有房卡{0}张", context.RCard)
    self._Point = rectTransform:Find("Point").gameObject
    self.xueLiu = rectTransform:Find("Menu"):Find("Viewport"):Find("Content"):Find("XueLiu")
    self.xueZhan = rectTransform:Find("Menu"):Find("Viewport"):Find("Content"):Find("XueZhan")

    local close = rectTransform:Find("Close")
    close:GetComponent("Button").onClick:AddListener(function ( ... )
        -- body
        self:OnClose()
    end)

    local ok = rectTransform:Find("OK")
    ok:GetComponent("Button").onClick:AddListener(function ( ... )
        -- body
        self:OnCreate()
    end)

    if self.context._provice == Provice.Sichuan then
        if self.context._overtype == OverType.XUELIU then
            self:OnScXL(true)
        else
            self:OnScXZ(true)
        end
    end
end

function cls:OnExit( ... )
    -- body
    if self.go then
        self.go:SetActive(false)
    end
end

function cls:OnClose( ... )
    -- body
    if self.context.visible then
        self.context.appContext.uicontextMgr:Pop()
    end
end

function cls:OnScXL(value) 
    if value then
        self.scView:SetActive(true)
        self.sxView:SetActive(false)
        local xpos = self.go.transform.worldToLocalMatrix:MultiplyPoint(self.xueLiu.transform.position)
        local pos = self._Point.transform.localPosition
        self._Point.transform.localPosition = CS.UnityEngine.Vector3(pos.x, xpos.y, pos.z)

        -- hujiaozhuanyi
        local modeTransform = self.scView.transform:Find("Mode")
        local hujiaozhuanyiTransform = modeTransform:Find("HuJiaoZhuanYi")
        local hujiaozhuanyiToggleTransform = hujiaozhuanyiTransform:Find("HuJiaoZhuanYi")
        hujiaozhuanyiToggleTransform:GetComponent("Toggle").onValueChanged:AddListener(function (value, ... )
            -- body
            self:OnHujiaozhuanyiChanged(value)
        end)
        self._HuJiaoZhuanYiLabel = hujiaozhuanyiToggleTransform:Find("Label").gameObject

        if self.context._hujiaozhuanyi == 1 then

        end
    else
        self.scView:SetActive(false)
    end
end

function cls:OnScXZ(value) 
    if  value then
        self.scView.SetActive(true);
        self.sxView.SetActive(false);

        local xpos = self.transform.worldToLocalMatrix:MultiplyPoint(self.xueZhan.transform.position)
        local pos = self._Point.transform.localPosition
        self._Point.transform.localPosition = CS.UnityEngine.Vector3(pos.x, xpos.y, pos.z)

        local msg = new Message();
        msg:SetInt32("provice",  Provice.Sichuan)
        msg:SetInt32("overtype",  OverType.XUEZHAN)
        local cmd = CS.maria.event.Command(MyEventCmd.EVENT_MUI_MODIFYCREATE, msg)
        
        EventDispatcher:getInstance():Enqueue(cmd)
     else 
        scView.SetActive(false);
    end
end

function cls:OnSx(value) 
    if value then
        self.scView.SetActive(false);
        self.sxView.SetActive(true);
        self.context._provice = Provice.Shaanxi
     else 
        self.sxView.SetActive(false);
    end
end

function cls:OnHujiaozhuanyiChanged(value)
    if value then
        self._HuJiaoZhuanYiLabel:GetComponent("Text").color = self._pressed
        self.context._hujiaozhuanyi = 1
    else
        self._HuJiaoZhuanYiLabel:GetComponent("Text").color = self._normal
        self.context._hujiaozhuanyi = 0
    end
end

function cls:OnZimobujiabeiChanged(value) 
    if value then
        self._ZiMoBuJiaBeiLabel.GetComponent("Text").color = self._pressed
        self.context._zimo = 0
     else
        self._ZiMoBuJiaBeiLabel.GetComponent("Text").color = self._normal
    end
end

function cls:OnZimojiadiChanged(value) 
    if  value then
        self._ZiMoJiaDiLabel.GetComponent("Text").color = self._pressed
        self._zimo = 1
     else 
        self._ZiMoJiaDiLabel.GetComponent("Text").color = self._normal
    end
end

function  cls:OnZimojiabeiChanged(value)
    if value then
        self._ZiMoJiaBeiLabel.GetComponent("Text").color = self._pressed
        self.context._zimo = 2
    else
        self._ZiMoJiaBeiLabel.GetComponent("Text").color = self._normal
    end
end

function cls:OnDianganghuazimoChanged(value) 
    if value then
        self._DianGangHuaZiMoLabel.GetComponent("Text").color = self._pressed
        self.context._dianganghua = 1
     else 
        self._DianGangHuaZiMoLabel.GetComponent("Text").color = self._normal
    end
end

function cls:OnDianganghuadianpaoChanged(value) 
    if value then
        self._DianGangHuaDianPaoLabel.GetComponent("Text").color = self._pressed
        self._dianganghua = 1
     else 
        self._DianGangHuaDianPaoLabel.GetComponent("Text").color = self._normal
    end
end

function cls:OnDaiyaojiuChanged(value) 
    if value then
        self._DaiYaoJiux4Label.GetComponent("Text").color = self._pressed
        self._daiyaojiu = 4
    else 
        self._DaiYaoJiux4Label.GetComponent("Text").color = self._normal
    end
end

function cls:OnDuanyaojiuChanged(value) 
    if value then
        self._DuanYaoJiux2Label.GetComponent("Text").color = self._pressed
        self.context._daiyaojiu = 2
     else 
        self._DuanYaoJiux2Label.GetComponent("Text").color = self._normal
    end
end

function cls:OnJiangduiChanged(value) 
    if value then
        self._JiangDuix8Label.GetComponent("Text").color = self._pressed
        self._jiangdui = 0
    else 
        self._JiangDuix8Label.GetComponent("Text").color = _normal;
    end
end

function cls:OnTiandihuChanged(value) 
    if value then
        self._TianDiHux32Label.GetComponent("Text").color = self._pressed
        self._tiandihu = 32
    else 
        self._TianDiHux32Label.GetComponent("Text").color = _normal;
        self._tiandihu = 4
    end
end

function cls:OnMulti8Changed(value) 
    if value then
       self. _Top8Label.GetComponent("Text").color = self._pressed
       self._top = 8
     else 
        self._Top8Label.GetComponent("Text").color = self._normal
    end
end

function cls:OnMulti16Changed(value) 
    if value then
        self._Top16Label.GetComponent("Text").color = self._pressed
        self._top = 16
    else 
        self._Top16Label.GetComponent("Text").color = self._normal
        self._top = 16
    end
end

function cls:OnMulti32Changed(value) 
    if value then
        self._Top32Label.GetComponent("Text").color = self._pressed
        self._top = 32
    else
        self._Top32Label.GetComponent("Text").color = self._normal
    end
end

function cls:OnJu8Changed(value) 
    if value then
        self._Ju8Label.GetComponent("Text").color = self._pressed
        self._ju = 8
     else 
        self._Ju8Label.GetComponent("Text").color = self._normal;
    end
end

function cls:OnJu16Changed(value) 
    if value then
        self._Ju16Label.GetComponent("Text").color = self._pressed
        self._ju = 16
    else
        self._Ju16Label.GetComponent("Text").color = _normal;
    end
end

function cls:OnCreate()
    if not self.created then
        self.created = true
        local joinSystem = assert(self.context.appContext.gameSystems.joinSystem)
        joinSystem:SendCreate()
    end
end

return cls
