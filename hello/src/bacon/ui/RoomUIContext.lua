local UIContext = require "maria.uibase.UIContext"
local UIContextManager = require "maria.uibase.UIContextManager"
local EventDispatcher = require "maria.event.EventDispatcher"
local ABLoader = require "maria.res.ABLoader"
local RoomView = require "bacon.ui.RoomView"

local cls = class("RoomUIContext")

function cls:ctor( ... )
    -- body
    self.roomid = 0
    self.roomMax = 0
    self.view = RoomView.new()
end

function cls:OnEnter( ... )
    -- body
    EventDispatcher:getInstance():EnqueueRenderQueue(function ( ... )
        -- body
        self:RenderViewEnter()
    end)
end

function cls:OnExit( ... )
    -- body
    EventDispatcher:getInstance():EnqueueRenderQueue(function ( ... )
        -- body
        self:RenderViewExit()
    end)
end

function cls:OnPause( ... )
    -- body
end

function cls:OnResume( ... )
    -- body
end

function cls:RenderViewEnter( ... )
    -- body
    self.view:OnEnter(self)
end


return cls

--         public RoomModule(User user) : base(user) {
--             this.Limited = 1;
--             this.Counter = 0;
--             this.IsTop = false;
--         }

--         public override void OnControllerEnter(Controller controller) {
--             this.Controller = controller;
--         }

--         public override void OnCreateLua() {
--         }

--         public override void OnDestroyLua() {
--         }

--         public long RoomId { get; set; }
--         public long RoomMax { get; set; }

--         #region ibasecontext
--         public int Limited { get; set; }
--         public int Counter { get; set; }
--         public bool IsTop { get; set; }
--         public bool Visible { get; set; }
--         public BaseView View { get; set; }
--         public Controller Controller { get; set; }

--         public void OnEnter() {
--             _user.Context.EnqueueRenderQueue(RenderViewEnter);
--         }

--         public void OnExit() {
--             _user.Context.EnqueueRenderQueue(RenderViewExit);
--         }

--         public void OnPause() {
--         }

--         public void OnResume() {
--         }

--         public void RenderViewEnter() {
--             if (View == null) {
--                 GameObject original = ABLoader.current.LoadAsset<GameObject>("UI", "RoomView");
--                 GameObject go = GameObject.Instantiate<GameObject>(original);
--                 View = go.GetComponent<RoomView>();
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

--         public void RenderViewPause() {
--             throw new NotImplementedException();
--         }

--         public void RenderViewResume() {
--             throw new NotImplementedException();
--         }

--         public void Shaking() { }

--         public void RenderViewShaking() { }
--         #endregion

--         #region event
--         private void OnCreate(Maria.Event.EventCmd e) {
--             CreateRoom.CreateRoomModule module = _user.GetModule<CreateRoom.CreateRoomModule>();
--             _user.Context.UIContextManager.Push(module);
--         }

--         private void OnJoin(Maria.Event.EventCmd e) {
--             Join.JoinModule module = _user.GetModule<Join.JoinModule>();
--             _user.Context.UIContextManager.Push(module);
--         }
--         #endregion
--     }
-- }
