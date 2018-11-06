using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using Entitas;
using Maria;
using Maria.Event;
using Maria.Timer;
using Bacon.Event;
using Bacon.DataSet;
using Bacon.Game.View;
using Bacon.Service;

namespace Bacon.GameSystems {
    public class DeskSystem : ISystem, IInitializeSystem, ISetContextSystem, ISetIndexSystem {
        private GameContext _context;
        private AppContext _appContext;
        private AppGameSystems _gameSystems;
        private int _desk;

        public DeskSystem(Contexts contexts) {
            _context = contexts.game;
        }

        public void SetAppContext(AppContext context) {
            _appContext = context;
            _gameSystems = _appContext.GameSystems;
        }

        public void Initialize() {
#if (!GEN_COMPONENT)
            EventListenerCmd listener1 = new EventListenerCmd(MyEventCmd.EVENT_SETUP_BOARD, SetupBoard);
            _appContext.EventDispatcher.AddCmdEventListener(listener1);

            var deskItem = DataSetManager.Instance.Say.Desk;

            var entity = _context.CreateEntity();
            entity.AddDesk((float)deskItem.Width,
                (float)deskItem.Length,
                (float)deskItem.Height,
                (float)deskItem.CurorMH,
                0,
                null);
            _desk = entity.index.index;
#endif
        }

        public void SetIndex(int index) {
            _desk = index;
        }

        private void SetupBoard(EventCmd e) {
#if (!GEN_COMPONENT)
            var entity = _appContext.GameSystems.IndexSystem.FindEntity(_desk);
            entity.desk.go = e.Orgin;
#endif
        }

#if (!GEN_COMPONENT)
        public GameEntity FindEntity() {
            return _appContext.GameSystems.IndexSystem.FindEntity(_desk);
        }

        public void UpdateClock(float left) {
            var e = _appContext.GameSystems.IndexSystem.FindEntity(_desk);
            e.desk.clockleft = (long)left;
            _appContext.EnqueueRenderQueue(RenderUpdateClock);
        }

        protected void RenderUpdateClock() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().ShowCountdown((int)e.desk.clockleft);
        }

        public void ShowCountdown(long cd) {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.clockleft = cd;

            Timer.Register(cd, null, UpdateClock);

            _appContext.EnqueueRenderQueue(RenderShowCountdown);
        }

        private void RenderShowCountdown() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().ShowCountdown();
        }

        public void RenderChangeCursor(Vector3 pos) {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().ChangeCursor(pos);
        }

        public void RenderThrowDice() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().ThrowDice(_context.rule.dice1, _context.rule.dice2);
        }

        public void RenderShowBottomSlot(Action cb) {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().ShowBottomSlot(cb);
        }

        public void RenderCloseBottomSlot(Action cd) {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().CloseBottomSlot(cd);
        }

        public void RenderShowRightSlot(Action cd) {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().ShowRightSlot(cd);
        }

        public void RenderCloseRightSlot(Action cb) {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().CloseRightSlot(cb);
        }

        public void RenderShowTopSlot(Action cd) {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().ShowTopSlot(cd);
        }

        public void RenderCloseTopSlot(Action cb) {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().CloseTopSlot(cb);
        }

        public void RenderShowLeftSlot(Action cb) {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().ShowLeftSlot(cb);
        }

        public void RenderCloseLeftSlot(Action cb) {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().CloseLeftSlot(cb);
        }

        public void RenderSetDongAtRight() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().SetDongAtRight();
        }

        public void RenderSetDongAtTop() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().SetDongAtTop();
        }

        public void RenderSetDongAtLeft() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().SetDongAtLeft();
        }

        public void RenderSetDongAtBottom() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().SetDongAtBottom();
        }

        public void RenderSetNanAtRight() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().SetNanAtRight();
        }

        public void RenderSetNanAtTop() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().SetNanAtTop();
        }

        public void RenderSetNanAtLeft() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().SetNanAtLeft();
        }

        public void RenderSetNanAtBottom() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().SetNanAtBottom();
        }

        public void RenderSetXiAtRight() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().SetXiAtRight();
        }

        public void RenderSetXiAtTop() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().SetXiAtTop();
        }

        public void RenderSetXiAtLeft() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().SetXiAtLeft();
        }

        public void RenderSetXiAtBottom() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().SetXiAtBottom();
        }

        public void RenderSetBeiAtTop() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().SetBeiAtTop();
        }
        public void RenderSetBeiAtLeft() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().SetBeiAtLeft();
        }

        public void RenderSetBeiAtBottom() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().SetBeiAtBottom();
        }

        public void RenderSetBeiAtRight() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().SetBeiAtRight();
        }

        public void RenderTakeOnDong() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().TakeOnDong(false);
        }

        public void RenderTakeOffDong() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().TakeOffDong();
        }

        public void RenderTakeTurnDong() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().TakeTurnDong();
        }

        public void RenderTakeOnNan() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().TakeOnNan(false);
        }

        public void RenderTakeOffNan() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().TakeOffNan();
        }

        public void RenderTakeTurnNan() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().TakeTurnNan();
        }

        public void RenderTakeOnXi() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().TakeOnXi(false);
        }

        public void RenderTakeOffXi() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().TakeOffXi();
        }

        public void RenderTakeTurnXi() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().TakeTurnXi();
        }

        public void RenderTakeOnBei() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().TakeOnBei(false);
        }

        public void RenderTakeOffBei() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().TakeOffBei();
        }

        public void RenderTakeTurnBei() {
            var e = _gameSystems.IndexSystem.FindEntity(_desk);
            e.desk.go.GetComponent<Board>().TakeTurnBei();
        }

        //public void InitUI(int id) {
        //    string name = string.Format("房间号: {0:000000}", id);
        //    if (_RoomId != null) {
        //        _RoomId.GetComponent<TextMesh>().text = name;
        //    }
        //}

        public void SetRoomId(long value) {
            _context.rule.roomid = value;
            _appContext.EnqueueRenderQueue(RenderSetRoomId);
        }

        public void RenderSetRoomId() {
            GameEntity entity = _gameSystems.IndexSystem.FindEntity(_desk);
            entity.desk.go.GetComponent<Board>().SetRoomId(_context.rule.roomid);
        }

#endif
    }
}
