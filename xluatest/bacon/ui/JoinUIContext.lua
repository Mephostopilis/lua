local UIContext = require "maria.uibase.UIContext"
local Provice = require "bacon.game.Provice"
local OverCode = require "bacon.game.OverCode"
local OverType = require "bacon.game.OverType"
local JoinView = require "bacon.ui.JoinView"

local cls = class("JoinUIContext")

function cls:ctor(app, ... )
    -- body
    self.app = app
    self.view = JoinView.new()
end

function cls:OnEnter( ... )
	-- body
	self.visible = true
	self.view:OnEnter(self)
end

function cls:OnExit( ... )
	-- body
	self.view:OnExit(self)
	self.visible = false
end

return cls

-- using System;
-- using System.Collections.Generic;
-- using System.Linq;
-- using System.Text;
-- using System.Threading.Tasks;
-- using UnityEngine;
-- using Sproto;

-- using Maria;
-- using Maria.UIBase;
-- using Maria.Res;
-- using Maria.Event;
-- using Maria.Module;
-- using Maria.Controller;

-- using Bacon.Event;
-- using Bacon.Model;
-- using Bacon.Model.Room;
-- using Bacon.Model.Tips;
-- using Bacon.Game;
-- using Bacon.Model.GameUI;

-- namespace Bacon.Model.Join {
--     class JoinModule : Maria.Module.Module, IBaseContext {
--         private long _myidx;

--         public JoinModule(User u) : base(u) {

--             this.Limited = 1;
--             this.Counter = 0;
--             this.IsTop = false;
--         }

--         public override void Startup() {
--             base.Startup();

--             EventListenerCmd listener1 = new EventListenerCmd(MyEventCmd.EVENT_MUI_JOIN, OnJoin);
--             Singleton<EventDispatcher>.Instance.AddCmdEventListener(listener1);

--             EventListenerCmd listener2 = new EventListenerCmd(MyEventCmd.EVENT_JOIN_CLOSE, OnClose);
--             Singleton<EventDispatcher>.Instance.AddCmdEventListener(listener2);

--             EventListenerCmd listener17 = new EventListenerCmd(MyEventCmd.EVENT_EXITROOM, OnEventLeave);
--             Singleton<EventDispatcher>.Instance.AddCmdEventListener(listener17);
--         }

--         public override void OnControllerEnter(Controller controller) {
--             base.OnControllerEnter(controller);
--             this.Controller = controller;
--         }

--         public override void OnCreateLua() { }

--         public override void OnDestroyLua() { }

--         public long MyIdx { get { return _myidx; } set { _myidx = value; } }                 // 网络索引

--         public bool Host { get; set; }

--         #region ibasecontext

--         public int Limited { get; set; }
--         public int Counter { get; set; }
--         public bool IsTop { get; set; }
--         public BaseView View { get; set; }
--         public Controller Controller { get; set; }
--         public bool Visible { get; set; }

--         public void OnEnter() {
--             this.Visible = true;
--             _user.Context.EnqueueRenderQueue(RenderViewEnter);
--         }

--         public void RenderViewEnter() {
--             if (View == null) {
--                 GameObject original = ABLoader.current.LoadAsset<GameObject>("UI", "JoinView");
--                 GameObject go = GameObject.Instantiate<GameObject>(original);
--                 View = go.GetComponent<JoinView>();
--                 Transform transform = Controller.BuiCanvas.transform;
--                 View.transform.SetParent(transform);
--                 View.OnEnter(this);
--             } else {
--                 View.OnEnter(this);
--             }
--         }

--         public void RenderViewExit() {
--             View.OnExit(this);
--         }

--         public void OnExit() {
--             _user.Context.EnqueueRenderQueue(RenderViewExit);
--             this.Visible = false;
--         }

--         public void OnPause() {
--             throw new NotImplementedException();
--         }

--         public void RenderViewPause() {
--             throw new NotImplementedException();
--         }

--         public void RenderViewResume() {
--             throw new NotImplementedException();
--         }

--         public void OnResume() {
--             throw new NotImplementedException();
--         }

--         public void Shaking() { }

--         public void RenderViewShaking() { }

--         #endregion

--         public void SendJoin(long roomid) {
--             RoomModule roomModule = _user.GetModule<RoomModule>();
--             C2sSprotoType.join.request request = new C2sSprotoType.join.request();
--             request.roomid = roomid;
--             Singleton<AppContext>.Instance.NetworkMgr.SendReq<C2sProtocol.join>(C2sProtocol.join.Tag, request);
--         }

--         public void SendLeave() {
--             C2sSprotoType.leave.request request = new C2sSprotoType.leave.request();
--             request.idx = MyIdx;
--             Singleton<AppContext>.Instance.NetworkMgr.SendReq<C2sProtocol.leave>(C2sProtocol.leave.Tag, request);
--         }

--         public void Join(SprotoTypeBase responseObj) {
-- #if (!GEN_COMPONENT)
--             C2sSprotoType.join.response obj = responseObj as C2sSprotoType.join.response;
--             if (obj.errorcode == Errorcode.SUCCESS) {
--                 if (!Host) {
--                     RoomModule roomModule = _user.GetModule<RoomModule>();
--                     roomModule.RoomMax = obj.room_max;
--                     roomModule.RoomId = obj.roomid;
--                 }
--                 this.MyIdx = obj.me.idx;

--                 AppContext appContext = _user.Context as AppContext;
--                 appContext.GameSystems.JoinSystem.Join(obj.me.idx, obj.me.chip, _user.Uid, _user.Subid, obj.me.sex, obj.me.name, Game.Player.Orient.BOTTOM);
--                 appContext.GameSystems.GameSystem.SetRoomInfo(GameType.GAME, obj.roomid, obj.room_max, obj.me.idx, this.Host);

--                 if (obj.ps != null && obj.ps.Count > 0) {
--                     for (int i = 0; i < obj.ps.Count; i++) {
--                         var item = obj.ps[i];
--                         long offset = 0;
--                         if (item.idx > _myidx) {
--                             offset = item.idx - _myidx;
--                         } else {
--                             offset = item.idx + 4 - _myidx;
--                         }
--                         switch (offset) {
--                             case 1: {
--                                     appContext.GameSystems.JoinSystem.Join(item.idx, item.chip, 0, item.sid, item.sex, item.name, Game.Player.Orient.RIGHT);
--                                 }
--                                 break;
--                             case 2: {
--                                     appContext.GameSystems.JoinSystem.Join(item.idx, item.chip, 0, item.sid, item.sex, item.name, Game.Player.Orient.TOP);
--                                 }
--                                 break;
--                             case 3: {
--                                     appContext.GameSystems.JoinSystem.Join(item.idx, item.chip, 0, item.sid, item.sex, item.name, Game.Player.Orient.LEFT);
--                                 }
--                                 break;
--                             default:
--                                 break;
--                         }
--                     }
--                 }
--                 if (obj.ready) {
--                     appContext.GameSystems.GameSystem.SetState(GameState.READY);
--                     appContext.GameSystems.NetIdxSystem.Ready();

--                     GameUIModule gameUIModule = _user.GetModule<GameUIModule>();
--                     MyOptionsUIController myOptionsUIController = gameUIModule.MyOptionsUIController;
--                     myOptionsUIController.SetReady(true);
--                     if (myOptionsUIController.Counter > 0) {
--                         myOptionsUIController.Shaking();
--                     } else {
--                         if (this.Controller.Name == "game" && this.Controller.LoadedUI) {
--                             _user.Context.UIContextManager.Push(myOptionsUIController);
--                         }
--                     }

--                     GameUIController gameUIController = gameUIModule.GameUIController;
--                     gameUIController.SetInvite(false);
--                     gameUIController.Shaking();
--                 }
--                 Director.Instance.ControllerMgr.Push<GameController>();
--             } else if (obj.errorcode == Errorcode.NOEXISTROOMID) {
--                 TipsModule tipsModule = _user.GetModule<TipsModule>();
--                 tipsModule.Content = "不存在此房间";
--                 _user.Context.UIContextManager.Push(tipsModule);
--             } else if (obj.errorcode == Errorcode.ROOMFULL) {
--                 TipsModule tipsModule = _user.GetModule<TipsModule>();
--                 tipsModule.Content = "房间已经满了";
--                 _user.Context.UIContextManager.Push(tipsModule);
--             }
-- #endif
--         }

--         public void Leave(SprotoTypeBase responseObj) {
--             C2sSprotoType.leave.response obj = responseObj as C2sSprotoType.leave.response;
--         }

--         #region event
--         public void OnEventLeave(EventCmd e) {
--             SendLeave();
--         }

--         public void OnJoin(EventCmd e) {
--             _user.Context.UIContextManager.Pop();

--             long roomid = Convert.ToInt64(e.Msg["roomid"]);
--             SendJoin(roomid);
--         }

--         public void OnClose(EventCmd e) {
--             _user.Context.UIContextManager.Pop();
--         }
--         #endregion
--     }
-- }
