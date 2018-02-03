local EventDispatcher = require "maria.event.EventDispatcher"
local Provice = require "bacon.game.Provice"
local OverCode = require "bacon.game.OverCode"
local OverType = require "bacon.game.OverType"
local CreateRoomView = require "bacon.ui.CreateRoomView"

local cls = class("CreateRoomUIContext")

function cls:ctor( ... )
    -- body
    self.view = CreateRoomView.new()
    self._provice = Provice.Sichuan                  --  @省份
    self._ju = 8                                                            -- 
    self._overtype = OverType.JIEHU      -- 1jie
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
    EventDispatcher:getInstance():EnqueueRenderQueue(function ( ... )
        -- body
        self:RenderViewEnter()
    end)
end

function cls:RenderViewEnter( ... )
    -- body
    self.view:OnEnter(self)
end

function cls:Shaking()
    EventDispatcher:getInstance():EnqueueRenderQueue(function ( ... )
        -- body
        self:RenderViewShaking()    
    end)
end

function cls:RenderViewShaking( ... )
    -- body
    self.view:OnShaking()
end

return cls

--         public void RenderViewShaking() { }


--     public class CreateRoomModule : Maria.Module.Module, IBaseContext {

--         private int _provice = Provice.Sichuan;              
--         private int _ju = 8;                                 // 局数，玩的轮数
--         private int _overtype = (int)OverType.JIEHU;              // 结束类型，比如说：1.截胡一人胡了，这局就结束了，2.

--         private int _hujiaozhuanyi = 1;                                // 四川麻将是否支持呼叫转移，默认支持
--         private int _dianganghua = 0;                                  // 点杠花的算自摸还是点炮
--         private int _zimo = 1;                                         // 自摸番数

--         public int _daiyaojiu = 1;         // 带幺九的番数
--         public int _duanyaojiu = 1;        // 断幺九的番数 0:平胡番数，1:4番
--         public int _jiangdui = 1;          // 将对番数 0:4番, 1:将对8番
--         public int _tiandihu = 1;          // 天地胡番数
--         public int _top = 8;               // 最高倍数

--         public int _sxqidui = 1;           // 0:不可以胡七对，1可以七对不加番，2胡七对加饭
--         public int _sxqingyise = 1;

--         public CreateRoomModule(User u) : base(u) {

--             EventListenerCmd listener1 = new EventListenerCmd(MyEventCmd.EVENT_MUI_CREATE, OnSendCreate);
--             Singleton<EventDispatcher>.Instance.AddCmdEventListener(listener1);

--             EventListenerCmd listener2 = new EventListenerCmd(MyEventCmd.EVENT_MUI_MODIFYCREATE, OnModify);
--             Singleton<EventDispatcher>.Instance.AddCmdEventListener(listener2);

--             EventListenerCmd listener5 = new EventListenerCmd(MyEventCmd.EVENT_MUI_CLOSE_CREATE, OnCloseCreate);
--             Singleton<EventDispatcher>.Instance.AddCmdEventListener(listener5);

--             this.Limited = 1;
--             this.Counter = 0;
--             this.IsTop = false;
--         }

--         public override void OnControllerEnter(Controller controller) {
--             this.Controller = controller;
--         }

--         public override void OnControllerResume(Controller controller) {
--             this.Controller = controller;
--         }

--         public override void OnCreateLua() { }

--         public override void OnDestroyLua() { }



--         public int ProviceF { get { return _provice; } }
--         public int OverTypeF { get { return _overtype; } }
--         public int HuJiaoZhuanYi { get { return _hujiaozhuanyi; } }
--         public int ZiMo { get { return _zimo; } }
--         public int DianGangHua { get { return _dianganghua; } }
--         public int DaiYaoJiu { get { return _daiyaojiu; } }
--         public int DuanYaoJiu { get { return _duanyaojiu; } }
--         public int JiangDui { get { return _jiangdui; } }
--         public int TianDiHU { get { return _tiandihu; } }
--         public int Top { get { return _top; } }
--         public int Ju { get { return _ju; } }

--         public int SxQiDui { get { return _sxqidui; } }
--         public int SxQingYiSe { get { return _sxqingyise; } }

--         public int Limited { get; set; }
--         public int Counter { get; set; }
--         public bool IsTop { get; set; }
--         public bool Visible { get; set; }
--         public BaseView View { get; set; }
--         public Controller Controller { get; set; }

--         public void OnEnter() {
--             _user.Context.EnqueueRenderQueue(RenderViewEnter);
--         }

--         public void RenderViewEnter() {
--             GameObject original = ABLoader.current.LoadAsset<GameObject>("UI/CreateRoom", "CreateRoomView");
--             GameObject go = GameObject.Instantiate<GameObject>(original);
--             View = go.GetComponent<CreateRoomView>();
--             Transform transform = Controller.BuiCanvas.transform;
--             View.transform.SetParent(transform);
--             View.OnEnter(this);
--         }

--         public void RenderViewExit() {
--             View.OnExit(this);
--         }

--         public void OnExit() {
--             _user.Context.EnqueueRenderQueue(RenderViewExit);
--         }

--         public void OnPause() {
--             _user.Context.EnqueueRenderQueue(RenderViewPause);
--         }

--         public void RenderViewPause() {
--             View.OnPause(this);
--         }

--         public void RenderViewResume() {
--             View.OnResume(this);
--         }

--         public void OnResume() {
--             _user.Context.EnqueueRenderQueue(RenderViewResume);
--         }

--         public void Shaking() { }

--         public void RenderViewShaking() { }

--         #region send
--         public void SendCreate() {
--             C2sSprotoType.create.request request = new C2sSprotoType.create.request();

--             if (_provice == Provice.Sichuan) {
--                 request.provice = _provice;
--                 request.ju = _ju;
--                 request.overtype = _overtype;
--                 request.sc = new C2sSprotoType.crsc();
--                 request.sc.hujiaozhuanyi = _hujiaozhuanyi;
--                 request.sc.zimo = _zimo;
--                 request.sc.dianganghua = _dianganghua;
--                 request.sc.daiyaojiu = _daiyaojiu;
--                 request.sc.duanyaojiu = _duanyaojiu;
--                 request.sc.jiangdui = _jiangdui;
--                 request.sc.tiandihu = _tiandihu;
--                 request.sc.top = _top;
--             } else if (_provice == Provice.Shaanxi) {
--                 request.provice = Provice.Shaanxi;
--                 request.ju = _ju;
--                 request.overtype = _overtype;
--                 request.sx = new C2sSprotoType.crsx();
--                 request.sx.huqidui = _sxqidui;
--                 request.sx.qingyise = _sxqingyise;
--             }
--             Director.Instance.NetworkMgr.SendReq<C2sProtocol.create>(C2sProtocol.create.Tag, request);
--         }
--         #endregion

--         #region response

--         public void Create(SprotoTypeBase responseObj) {
--             C2sSprotoType.create.response obj = responseObj as C2sSprotoType.create.response;
--             RoomModule roomModule = _user.GetModule<RoomModule>();
--             roomModule.RoomId = obj.roomid;
--             roomModule.RoomMax = obj.room_max;

--             JoinModule joinModule = _user.GetModule<JoinModule>();
--             joinModule.Host = true;
--             joinModule.SendJoin(obj.roomid);

--             GameUIModule gameUIModule = _user.GetModule<GameUIModule>();
--             GameUIController gameUIController = gameUIModule.GameUIController;
--             gameUIController.SetInvite(true);

--         }
--         #endregion

--         #region event
--         private void OnSendCreate(EventCmd e) {
--             _user.Context.UIContextManager.Pop();
--             SendCreate();
--         }

--         private void OnModify(EventCmd e) {
--             foreach (var item in e.Msg) {
--             }
--         }

--         private void OnCloseCreate(EventCmd e) {
--             _user.Context.UIContextManager.Pop();
--         }
--         #endregion
--     }
-- }
