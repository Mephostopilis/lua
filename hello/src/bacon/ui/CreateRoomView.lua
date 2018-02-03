local ABLoader = require "maria.res.ABLoader"
local EventDispatcher = require "maria.event.EventDispatcher"
local Provice = require "bacon.game.Provice"
local cls = class("CreateRoomView")

function cls:ctor( ... )
    -- body
    self.context = nil
    self.go = nil
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

function cls:OnEnter(context, go, ... )
    -- body
    self.context = context
    if not self.go then
        local original = ABLoader:getInstance():LoadGameObject("UI", "CreateRoom")
        local go = CS.UnityEngine.GameObject.Instantiate(original)
        go.transform:SetParent(UIContextManager:getInstance().buicanvas.transform)
        self.go = go
    end

    local rectTransform = go.transform
    rectTransform:SetInsetAndSizeFromParentEdge(CS.UnityEngine.RectTransform.Edge.Top, 0, 750);
    rectTransform:SetInsetAndSizeFromParentEdge(RectTransform.Edge.Left, 0, 1334);
    rectTransform.localPosition = CS.UnityEngine.Vector3(rectTransform.localPosition.x, rectTransform.localPosition.y, 0);
    rectTransform.localScale = CS.UnityEngine.Vector3.one;

    self.scView = rectTransform:Find("scView").gameObject
    self.sxView = rectTransform:Find(scView).gameObject
    self._RCard = rectTransform:Find("RCard").gameObject
    self._RCard.GetComponent("Text").text = string.format("已有房卡{0}张", context.RCard)
end

function cls:OnExit( ... )
    -- body
end

function cls:OnClose( ... )
    -- body
    UIContextManager:getInstance():Pop()
end

function cls:OnScXL(value) 
    if value then
        self.scView.SetActive(true);
        self.sxView.SetActive(false);
        local xpos = self.go.transform.worldToLocalMatrix * self.xueLiu.transform.position
        local pos = self._Point.transform.localPosition
        self._Point.transform.localPosition = CS.UnityEngine.Vector3(pos.x, xpos.y, pos.z)

        local msg = CS.maria.event.Message()
        msg:SetInt32("provice", Provice.Sichuan)
        msg:SetInt32("overtype", OverType.XUELIU)
        local cmd = CS.maria.event.Command(MyEventCmd.EVENT_MUI_MODIFYCREATE, msg)
        EventDispatcher:getInstance():Enqueue(cmd)
    else
        self.scView:SetActive(false)
    end
end

function cls:OnScXZ(value) 
    if  value then
        self.scView.SetActive(true);
        self.sxView.SetActive(false);

        local xpos = self.transform.worldToLocalMatrix *  self.xueZhan.transform.position;
        local pos = self._Point.transform.localPosition;
        self._Point.transform.localPosition = CS.UnityEngine.Vector3(pos.x, xpos.y, pos.z);

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
        self._HuJiaoZhuanYiLabel.GetComponent("Text").color = self._pressed
        self.context._hujiaozhuanyi = 1
    else
        self._HuJiaoZhuanYiLabel.GetComponent("Text").color = self._normal
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

function cls:OnCreate()
    local cmd = CS.maria.event.Command(MyEventCmd.EVENT_MUI_MODIFYCREATE)
    EventDispatcher:getInstance():Enqueue(cmd)
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

return cls


-- using UnityEngine;
-- using UnityEngine.UI;
-- using Maria;
-- using Maria.Util;
-- using Maria.UIBase;

-- using Bacon.Game;
-- using Bacon.Event;
-- using Bacon.Model;
-- using Maria.Event;

-- namespace Bacon.Model.CreateRoom {
--     public class CreateRoomView : BaseView {

--         public GameObject scView;
--         public GameObject sxView;
--         public GameObject _RCard;
--         public GameObject _Point;
--         public GameObject xueLiu;
--         public GameObject xueZhan;

--         public override void OnEnter(IBaseContext context) {
--             base.OnEnter(context);

--             RectTransform rectTransform = transform as RectTransform;
--             rectTransform.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Top, 0, 750);
--             rectTransform.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Left, 0, 1334);
--             rectTransform.localPosition = new Vector3(rectTransform.localPosition.x, rectTransform.localPosition.y, 0);
--             rectTransform.localScale = Vector3.one;

--             //transform.FindChild()
--             //transform.GetComponent()
--             //transform.GetComponent<Button>().onClick.AddListener()

--             CreateRoomModule createRoomModule = _baseContext as CreateRoomModule;
--             UUserModule uUserModule = createRoomModule.GetModule<UUserModule>();
--             _RCard.GetComponent<Text>().text = string.Format("已有房卡{0}张", uUserModule.RCard);

--             ScView scView = transform.GetComponentInChildren<ScView>();
--             Push(scView);
--             //SxView sxView = transform.GetComponentInChildren<SxView>();
--             //Push(sxView);

--             if (createRoomModule.ProviceF == Provice.Sichuan) {
--                 //Pop();
--             } else {
--             }
            
--         }

--         public override void OnExit(IBaseContext context) {
--             base.OnExit(context);

--         }

--         public override void OnClose() {
--             Command cmd = new Command(MyEventCmd.EVENT_MUI_CLOSE_CREATE);
--             Bacon.GL.Util.App.current.Enqueue(cmd);
--         }

--         public void OnScXL(bool value) {
--             if (value) {
--                 scView.SetActive(true);
--                 sxView.SetActive(false);
--                 Vector3 xpos = transform.worldToLocalMatrix * xueLiu.transform.position;
--                 Vector3 pos = _Point.transform.localPosition;
--                 _Point.transform.localPosition = new Vector3(pos.x, xpos.y, pos.z);

--                 Command cmd = new Command(MyEventCmd.EVENT_MUI_MODIFYCREATE);
--                 Message msg = new Message();
--                 msg["provice"] = Provice.Sichuan;
--                 msg["overtype"] = OverType.XUELIU;
--                 cmd.Msg = msg;
--                 Bacon.GL.Util.App.current.Enqueue(cmd);
--             } else {
--                 scView.SetActive(false);
--             }

--         }

--         public void OnScXZ(bool value) {
--             if (value) {
--                 scView.SetActive(true);
--                 sxView.SetActive(false);

--                 Vector3 xpos = transform.worldToLocalMatrix * xueZhan.transform.position;
--                 Vector3 pos = _Point.transform.localPosition;
--                 _Point.transform.localPosition = new Vector3(pos.x, xpos.y, pos.z);

--                 local cmd = CS.maria.event.Command(MyEventCmd.EVENT_MUI_MODIFYCREATE);
--                 Message msg = new Message();
--                 msg["provice"] = Provice.Sichuan;
--                 msg["overtype"] = OverType.XUEZHAN;
--                 cmd.Msg = msg;
--                 Bacon.GL.Util.App.current.Enqueue(cmd);
--             } else {
--                 scView.SetActive(false);
--             }
--         }

--         public void OnSx(bool value) {
--             if (value) {
--                 scView.SetActive(false);
--                 sxView.SetActive(true);

--                 Command cmd = new Command(MyEventCmd.EVENT_MUI_MODIFYCREATE);
--                 Message msg = new Message();
--                 msg["provice"] = Provice.Shaanxi;
--                 cmd.Msg = msg;
--                 Bacon.GL.Util.App.current.Enqueue(cmd);
--             } else {
--                 sxView.SetActive(false);
--             }
--         }

--         public void OnCreate() {
--             Command cmd = new Command(MyEventCmd.EVENT_MUI_CREATE);
--             Bacon.GL.Util.App.current.Enqueue(cmd);
--         }

--     }
-- }