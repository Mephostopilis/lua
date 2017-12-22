using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Sproto;
using Entitas;
using Maria;
using Maria.Event;
using Bacon.Event;
using Bacon.Game;
using Bacon.Model.Join;
using Bacon.Model.GameUI;

namespace Bacon.GameSystems {
    public class GameSystem : ISystem, ISetContextSystem, IInitializeSystem {

        private GameContext _context;
        private AppContext _appContext;
        private AppGameSystems _gameSystems;

        public GameSystem(Contexts contexts) {
            _context = contexts.game;
        }

        public void SetAppContext(AppContext context) {
            _appContext = context;
            _gameSystems = _appContext.GameSystems;
        }

        public void Initialize() {
            EventListenerCmd listener2 = new EventListenerCmd(MyEventCmd.EVENT_BOXINGCARDS, OnBoxingCards);
            _appContext.EventDispatcher.AddCmdEventListener(listener2);

            EventListenerCmd listener5 = new EventListenerCmd(MyEventCmd.EVENT_THROWDICE, OnThrowDice);
            _appContext.EventDispatcher.AddCmdEventListener(listener5);

            EventListenerCmd listener6 = new EventListenerCmd(MyEventCmd.EVENT_TAKEDEAL, OnTakeDeal);
            _appContext.EventDispatcher.AddCmdEventListener(listener6);

            EventListenerCmd listener7 = new EventListenerCmd(MyEventCmd.EVENT_PENGCARD, OnPengCard);
            _appContext.EventDispatcher.AddCmdEventListener(listener7);

            EventListenerCmd listener8 = new EventListenerCmd(MyEventCmd.EVENT_GANGCARD, OnGangCard);
            _appContext.EventDispatcher.AddCmdEventListener(listener8);

            EventListenerCmd listener9 = new EventListenerCmd(MyEventCmd.EVENT_HUCARD, OnHuCard);
            _appContext.EventDispatcher.AddCmdEventListener(listener9);

            EventListenerCmd listener10 = new EventListenerCmd(MyEventCmd.EVENT_SORTCARDSAFTERDEAL, OnSortCardsAfterDeal);
            _appContext.EventDispatcher.AddCmdEventListener(listener10);

            EventListenerCmd listener11 = new EventListenerCmd(MyEventCmd.EVENT_LEADCARD, OnLeadCard);
            _appContext.EventDispatcher.AddCmdEventListener(listener11);

            //EventListenerCmd listener12 = new EventListenerCmd(MyEventCmd.EVENT_SETUP_BOARD, SetupMap);
            //_appContext.EventDispatcher.AddCmdEventListener(listener12);

            EventListenerCmd listener13 = new EventListenerCmd(MyEventCmd.EVENT_SENDCHATMSG, OnSendChatMsg);
            _appContext.EventDispatcher.AddCmdEventListener(listener13);

            EventListenerCmd listener14 = new EventListenerCmd(MyEventCmd.EVENT_TAKEFIRSTCARD, OnTakeFirstCard);
            _appContext.EventDispatcher.AddCmdEventListener(listener14);

            EventListenerCmd listener15 = new EventListenerCmd(MyEventCmd.EVENT_SETTLE_NEXT, OnSettleNext);
            _appContext.EventDispatcher.AddCmdEventListener(listener15);

            //EventListenerCmd listener16 = new EventListenerCmd(MyEventCmd.EVENT_LOADEDCARDS, OnEventLoadedCards);
            //_ctx.EventDispatcher.AddCmdEventListener(listener16);

            EventListenerCmd listener16 = new EventListenerCmd(MyEventCmd.EVENT_SORTCARDSAFTERXUANQUE, OnSortCardsAfterXuanQue);
            _appContext.EventDispatcher.AddCmdEventListener(listener16);
        }

        #region common public
        public long NextIdx() {
            _context.rule.curidx++;
            if (_context.rule.curidx > _context.rule.max) {
                _context.rule.curidx = 1;
            }
            return _context.rule.curidx;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="whose">netidx,服务传来的索引,拿谁的牌</param>
        /// <param name="card">本地索引</param>
        /// <returns>判断牌是否已经拿完，也用来判断游戏是否结束</returns>
        public bool TakeCard(out int card) {
            if (_gameSystems.PlayerSystem.TakeCard(_context.rule.curtake, out card)) {
                return true;
            } else {
                _context.rule.takepoint++;
                if (_context.rule.takepoint >= 6) {
                    // over 
                    return false;
                } else {
                    _context.rule.curtake--; // 网络索引 1,2,3,4倒数
                    if (_context.rule.curtake <= 0) {
                        _context.rule.curtake = _context.rule.max;
                    }
                    if (_gameSystems.PlayerSystem.TakeCard(_context.rule.curtake, out card)) {
                        return true;
                    } else {
                        return false;
                    }
                }
            }
        }

        /// <summary>
        /// 拿牌4个或者1个
        /// </summary>
        /// <param name="who">拥有牌的那个人</param>
        /// <returns></returns>
        public List<int> TakeBlock() {
            try {
                if (_context.rule.takeround == 4) {
                    List<int> cards = new List<int>();
                    int card = 0;
                    bool ok = TakeCard(out card);
                    UnityEngine.Debug.Assert(ok);
                    cards.Add(card);
                    return cards;
                } else {
                    List<int> cards = new List<int>();
                    int card;
                    for (int i = 0; i < 4; i++) {
                        bool ok = TakeCard(out card);
                        UnityEngine.Debug.Assert(ok);
                        cards.Add(card);
                    }
                    return cards;
                }
            } catch (Exception ex) {
                UnityEngine.Debug.LogException(ex);
                return null;
            }
        }

        public void SetRoomInfo(GameType gameType, long roomid, long max, long myidx, bool host) {
            _context.rule.type = gameType;
            _context.rule.roomid = roomid;
            _context.rule.max = max;
            _context.rule.myidx = myidx;
            _context.rule.host = host;
        }

        public void SetState(GameState state) {
            if (_context.rule.gamestate != state) {
                _context.rule.gamestate = state;
            }
        }
        #endregion

        #region event
        private void OnBoxingCards(EventCmd e) {
#if (!GEN_COMPONENT)
            _context.rule.oknum++;
            if (_context.rule.oknum >= _context.rule.max) {
                _context.rule.oknum = 0;
                if (_context.rule.type == GameType.GAME) {
                    UnityEngine.Debug.LogFormat("send step after boxing.");
                    SendStep();
                }
            }
#endif
        }

        private void OnThrowDice(EventCmd e) {
#if (!GEN_COMPONENT)
            if (_context.rule.type == GameType.GAME) {
                SendStep();
            }
#endif
        }

        private void OnTakeDeal(EventCmd e) {
#if (!GEN_COMPONENT)
            _context.rule.take1time++;
            if (_context.rule.take1time > 4) {
                _context.rule.takeround++;
                _context.rule.take1time = 1;
            }
            if (_context.rule.takeround > 4) {
                _gameSystems.NetIdxSystem.SortCards();
                return;
            }

            long idx = NextIdx();
            var curIdxEntity = _gameSystems.NetIdxSystem.FindEntity(idx);
            _gameSystems.PlayerSystem.Deal(curIdxEntity);
#endif
        }

        private void OnSortCardsAfterDeal(EventCmd e) {
            _context.rule.oknum--;
            if (_context.rule.oknum <= 0) {
                // Take first card
                long idx = NextIdx();
                var curIdxEntity = _gameSystems.NetIdxSystem.FindEntity(idx);
                _gameSystems.PlayerSystem.TakeFirsteCard(curIdxEntity, _context.rule.firstcard);
            }
        }

        private void OnTakeFirstCard(EventCmd e) {
            if (_context.rule.type == GameType.GAME) {
                UnityEngine.Debug.LogFormat("send step after sort cards.");
                SendStep();
            }
        }

        private void OnPengCard(EventCmd e) {
            if (_context.rule.type == GameType.GAME) {
                SendStep();
            }
        }

        private void OnGangCard(EventCmd e) {
            if (_context.rule.type == GameType.GAME) {
                SendStep();
            }
        }

        private void OnHuCard(EventCmd e) {
            JoinModule joinModule = _appContext.U.GetModule<JoinModule>();
            var entity = _gameSystems.NetIdxSystem.FindEntity(joinModule.MyIdx);

            entity.rule.oknum++;
            if (entity.rule.oknum >= entity.rule.huscount) {
                if (entity.rule.type == GameType.GAME) {
                    SendStep();
                }
            }
        }

        private void OnLeadCard(EventCmd e) {
            GameEntity entity = _gameSystems.NetIdxSystem.FindEntity(_context.rule.curidx);
            entity.holdCard.holdCardEntity = null;

            if (_context.rule.type == GameType.GAME) {
                SendStep();
            }
        }

        private void OnSettleNext(EventCmd e) {
            //_oknum++;
            //if (_oknum >= _max) {
            //    if (_settlesidx >= _settles.Count) {
            //        SendStep();
            //        return;
            //    }

            //    foreach (var i in _playes) {
            //        Player player = i.Value;

            //        player.ClearSettle();

            //        S2cSprotoType.settlementitem si = null;
            //        S2cSprotoType.settle settle = _settles[_settlesidx];
            //        long idx = 0;
            //        if (player.Idx == 1) {
            //            idx = 1;
            //            if (settle.p1 != null) {
            //                si = settle.p1;
            //            }
            //        } else if (player.Idx == 2) {
            //            idx = 2;
            //            if (settle.p2 != null) {
            //                si = settle.p2;
            //            }
            //        } else if (player.Idx == 3) {
            //            idx = 3;
            //            if (settle.p3 != null) {
            //                si = settle.p3;
            //            }
            //        } else if (player.Idx == 4) {
            //            idx = 4;
            //            if (settle.p4 != null) {
            //                si = settle.p4;
            //            }
            //        }
            //        if (si != null) {
            //            SettlementItem item = new SettlementItem();
            //            item.Idx = si.idx;
            //            item.Chip = si.chip;  // 有正负
            //            item.Left = si.left;  // 以次值为准

            //            item.Win = si.win;
            //            item.Lose = si.lose;

            //            item.Gang = si.gang;
            //            item.HuCode = si.hucode;
            //            item.HuJiao = si.hujiao;
            //            item.HuGang = si.hugang;
            //            item.HuaZhu = si.huazhu;
            //            item.DaJiao = si.dajiao;
            //            item.TuiSui = si.tuisui;

            //            _playes[idx].AddSettle(item);
            //            _playes[idx].Settle();
            //        }
            //    }
            //    _settlesidx++;
            //}
        }

        private void OnSendChatMsg(EventCmd e) {
            JoinModule joinModule = _appContext.U.GetModule<JoinModule>();
            var entity = _gameSystems.NetIdxSystem.FindEntity(joinModule.MyIdx);

            if (entity.rule.type == GameType.GAME) {
                C2sSprotoType.rchat.request request = new C2sSprotoType.rchat.request();
                request.idx = joinModule.MyIdx;
                if ((int)e.Msg["type"] == 1) {
                    request.type = 1;
                    request.textid = (long)e.Msg["code"];
                } else if ((int)e.Msg["type"] == 2) {

                }
                _appContext.SendReq<C2sProtocol.rchat>(C2sProtocol.rchat.Tag, request);
            }
        }

        private void OnSortCardsAfterXuanQue(EventCmd e) {
            _context.rule.oknum--;
            if (_context.rule.oknum <= 0) {
                SendStep();
            }
        }

        #endregion

        #region send
        public void SendStep() {
            C2sSprotoType.step.request request = new C2sSprotoType.step.request();
            request.idx = _context.rule.myidx;
            _appContext.SendReq<C2sProtocol.step>(C2sProtocol.step.Tag, request);
        }

        public void SendRestart() {
            C2sSprotoType.restart.request request = new C2sSprotoType.restart.request();
            request.idx = _context.rule.myidx;
            _appContext.SendReq<C2sProtocol.restart>(C2sProtocol.restart.Tag, request);
        }
        #endregion

        #region response
        public void Step(SprotoTypeBase responseObj) {
            C2sSprotoType.step.response obj = responseObj as C2sSprotoType.step.response;
            if (obj.errorcode == Errorcode.SUCCESS) {
            } else if (obj.errorcode == Errorcode.SERVER_ERROR) {
                UnityEngine.Debug.LogErrorFormat("server internal occurs wrrong. ");
            } else {
                UnityEngine.Debug.LogErrorFormat("errorcode {0}", obj.errorcode);
            }
        }
        #endregion

        #region requset
        public SprotoTypeBase OnOnline(SprotoTypeBase requestObj) {
#if (!GEN_COMPONENT)
            S2cSprotoType.online.request obj = requestObj as S2cSprotoType.online.request;
            _context.rule.online++;

            GameEntity entity = _gameSystems.NetIdxSystem.FindEntity(obj.idx);
            entity.head.headUIController.SetLeave(false);
            entity.head.headUIController.Shaking();

            S2cSprotoType.online.response responseObj = new S2cSprotoType.online.response();
            responseObj.errorcode = Errorcode.SUCCESS;
            return responseObj;
#endif
        }

        public SprotoTypeBase OnOffline(SprotoTypeBase requestObj) {
            S2cSprotoType.offline.request obj = requestObj as S2cSprotoType.offline.request;
            try {
#if (!GEN_COMPONENT)
                _context.rule.online--;

                var afkEntity = _gameSystems.NetIdxSystem.FindEntity(obj.idx);
                afkEntity.head.headUIController.SetLeave(true);
                afkEntity.head.headUIController.Shaking();
#endif
                S2cSprotoType.offline.response responseObj = new S2cSprotoType.offline.response();
                responseObj.errorcode = Errorcode.SUCCESS;
                return responseObj;
            } catch (Exception) {
                S2cSprotoType.offline.response responseObj = new S2cSprotoType.offline.response();
                responseObj.errorcode = Errorcode.FAIL;
                return responseObj;
            }
        }

        public SprotoTypeBase OnReady(SprotoTypeBase requestObj) {
            S2cSprotoType.ready.request obj = requestObj as S2cSprotoType.ready.request;
            try {
#if (!GEN_COMPONENT)
                _context.rule.gamestate = GameState.READY;

                GameEntity entity = _gameSystems.NetIdxSystem.FindEntity(obj.idx);
                entity.head.headUIController.SetReady(true);
                entity.head.headUIController.Shaking();
#endif
                S2cSprotoType.ready.response responseObj = new S2cSprotoType.ready.response();
                responseObj.errorcode = Errorcode.SUCCESS;
                return responseObj;
            } catch (Exception ex) {
                UnityEngine.Debug.LogException(ex);
                S2cSprotoType.ready.response responseObj = new S2cSprotoType.ready.response();
                responseObj.errorcode = Errorcode.FAIL;
                return responseObj;
            }
        }

        public SprotoTypeBase OnShuffle(SprotoTypeBase requestObj) {
            S2cSprotoType.shuffle.request obj = requestObj as S2cSprotoType.shuffle.request;
            try {
#if (!GEN_COMPONENT)
                _context.rule.oknum = 0;
                _context.rule.gamestate = GameState.SHUFFLE;

                _gameSystems.CardValueIndexSystem.Clear();
                UnityEngine.Debug.Assert(obj.p1.Count == 28);
                var entity1 = _gameSystems.NetIdxSystem.FindEntity(1);
                _gameSystems.PlayerSystem.Boxing(entity1, obj.p1);

                UnityEngine.Debug.Assert(obj.p2.Count == 28);
                var entity2 = _gameSystems.NetIdxSystem.FindEntity(2);
                _gameSystems.PlayerSystem.Boxing(entity2, obj.p2);


                UnityEngine.Debug.Assert(obj.p3.Count == 26);
                var entity3 = _gameSystems.NetIdxSystem.FindEntity(3);
                _gameSystems.PlayerSystem.Boxing(entity3, obj.p3);

                UnityEngine.Debug.Assert(obj.p4.Count == 26);
                var entity4 = _gameSystems.NetIdxSystem.FindEntity(4);
                _gameSystems.PlayerSystem.Boxing(entity4, obj.p4);

                _appContext.EnqueueRenderQueue(_gameSystems.NetIdxSystem.RenderBoxing);
#endif
                S2cSprotoType.shuffle.response responseObj = new S2cSprotoType.shuffle.response();
                responseObj.errorcode = Errorcode.SUCCESS;
                return responseObj;
            } catch (Exception ex) {
                UnityEngine.Debug.LogException(ex);
                S2cSprotoType.shuffle.response responseObj = new S2cSprotoType.shuffle.response();
                responseObj.errorcode = Errorcode.FAIL;
                return responseObj;
            }
        }

        public SprotoTypeBase OnDice(SprotoTypeBase requestObj) {
            S2cSprotoType.dice.request obj = requestObj as S2cSprotoType.dice.request;
            try {
                _context.rule.gamestate = GameState.DICE;
                _context.rule.firstidx = obj.first;
                _context.rule.firsttake = obj.firsttake;   // 第一个被拿牌的玩家，用色子check一下是否正确

                _context.rule.dice1 = obj.d1;
                _context.rule.dice2 = obj.d2;

                //long point = obj.d1 + obj.d2;
                //while (point > _context.rule.max) {
                //    point -= _context.rule.max;
                //}
                //UnityEngine.Debug.Assert(point > 0 && point <= _context.rule.max);

                // 设置被拿牌的玩家的牌的起始牌索引
                var firstTakeEntity = _gameSystems.NetIdxSystem.FindEntity(obj.firsttake);
                long min = Math.Min(obj.d1, obj.d2);
                firstTakeEntity.takeCards.takecardsidx = (int)(min * 2);

                var firstIdxEntity = _gameSystems.NetIdxSystem.FindEntity(obj.first);
                _gameSystems.PlayerSystem.ThrowDice(firstTakeEntity, obj.d1, obj.d2);

                S2cSprotoType.dice.response responseObj = new S2cSprotoType.dice.response();
                responseObj.errorcode = Errorcode.SUCCESS;
                return responseObj;
            } catch (Exception ex) {
                UnityEngine.Debug.LogException(ex);
                S2cSprotoType.dice.response responseObj = new S2cSprotoType.dice.response();
                responseObj.errorcode = Errorcode.FAIL;
                return responseObj;
            }
        }

        /// <summary>
        /// 发牌，这其实是每个玩家去拿牌的过程
        /// </summary>
        /// <param name="requestObj"></param>
        /// <returns></returns>
        public SprotoTypeBase OnDeal(SprotoTypeBase requestObj) {
            S2cSprotoType.deal.request obj = requestObj as S2cSprotoType.deal.request;
            try {
                _context.rule.oknum = 0;
                UnityEngine.Debug.Assert(_context.rule.firstidx == obj.firstidx
                    && _context.rule.firsttake == obj.firsttake);
                _context.rule.curidx = obj.firstidx;
                _context.rule.curtake = obj.firsttake;
                _context.rule.firstcard = obj.card;

                _context.rule.take1time = 1;
                _context.rule.takeround = 1;
                _context.rule.takepoint = 1;

                var entity1 = _gameSystems.NetIdxSystem.FindEntity(1);
                entity1.playerCard.cs = obj.p1;

                var entity2 = _gameSystems.NetIdxSystem.FindEntity(2);
                entity2.playerCard.cs = obj.p2;

                var entity3 = _gameSystems.NetIdxSystem.FindEntity(3);
                entity3.playerCard.cs = obj.p3;

                var entity4 = _gameSystems.NetIdxSystem.FindEntity(4);
                entity4.playerCard.cs = obj.p4;

                var firstIdxEntity = _gameSystems.NetIdxSystem.FindEntity(obj.firstidx);
                _gameSystems.PlayerSystem.Deal(firstIdxEntity);

                S2cSprotoType.deal.response responseObj = new S2cSprotoType.deal.response();
                responseObj.errorcode = Errorcode.SUCCESS;
                return responseObj;
            } catch (Exception ex) {
                UnityEngine.Debug.LogException(ex);
                S2cSprotoType.deal.response responseObj = new S2cSprotoType.deal.response();
                responseObj.errorcode = Errorcode.SUCCESS;
                return responseObj;
            }
        }

        /// <summary>
        /// 暂时不用
        /// </summary>
        /// <param name="requestObj"></param>
        /// <returns></returns>
        public SprotoTypeBase OnTakeXuanPao(SprotoTypeBase requestObj) {
            S2cSprotoType.take_xuanpao.request obj = requestObj as S2cSprotoType.take_xuanpao.request;
            try {
                // TODO: coundown
                //_appContext.Countdown(Timer.CLOCK, (int)obj.countdown, OnUpdateClock, null);

                //// 这个协议需要改
                //_playes[_myidx].TakeXuanPao();

                S2cSprotoType.take_xuanpao.response responseObj = new S2cSprotoType.take_xuanpao.response();
                responseObj.errorcode = Errorcode.SUCCESS;
                return responseObj;
            } catch (Exception ex) {
                UnityEngine.Debug.LogException(ex);
                S2cSprotoType.take_xuanpao.response responseObj = new S2cSprotoType.take_xuanpao.response();
                responseObj.errorcode = Errorcode.FAIL;
                return responseObj;
            }
        }

        public SprotoTypeBase OnXuanPao(SprotoTypeBase requestObj) {
            try {

                S2cSprotoType.xuanpao.response responseObj = new S2cSprotoType.xuanpao.response();
                responseObj.errorcode = Errorcode.SUCCESS;
                return responseObj;
            } catch (Exception ex) {
                UnityEngine.Debug.LogException(ex);
                S2cSprotoType.xuanpao.response responseObj = new S2cSprotoType.xuanpao.response();
                responseObj.errorcode = Errorcode.FAIL;
                return responseObj;
            }
        }

        public SprotoTypeBase OnTakeXuanQue(SprotoTypeBase requestObj) {
            S2cSprotoType.take_xuanque.request obj = requestObj as S2cSprotoType.take_xuanque.request;
            try {
                // 凡是有倒计时的都要单独设计一个过程
                _gameSystems.DeskSystem.ShowCountdown(obj.countdown);
                GameUIModule gameUIModule = _appContext.U.GetModule<GameUIModule>();
                XuanQueUIController xuanQueUIController = gameUIModule.XuanQueUIController;
                if (xuanQueUIController.Counter <= 0) {
                    _appContext.UIContextManager.Push(xuanQueUIController);
                }


                S2cSprotoType.take_xuanque.response responseObj = new S2cSprotoType.take_xuanque.response();
                responseObj.errorcode = Errorcode.SUCCESS;
                return responseObj;
            } catch (Exception ex) {
                UnityEngine.Debug.LogException(ex);
                S2cSprotoType.take_xuanque.response responseObj = new S2cSprotoType.take_xuanque.response();
                responseObj.errorcode = Errorcode.FAIL;
                return responseObj;
            }
        }

        public SprotoTypeBase OnXuanQue(SprotoTypeBase requestObj) {
            S2cSprotoType.xuanque.request obj = requestObj as S2cSprotoType.xuanque.request;
            try {
                _context.rule.oknum = 4;
                _gameSystems.PlayerSystem.XuanQue(1, obj.p1);
                _gameSystems.PlayerSystem.XuanQue(2, obj.p2);
                _gameSystems.PlayerSystem.XuanQue(3, obj.p3);
                _gameSystems.PlayerSystem.XuanQue(4, obj.p4);

                _appContext.EnqueueRenderQueue(_gameSystems.NetIdxSystem.RenderXuanQue);

                S2cSprotoType.xuanque.response responseObj = new S2cSprotoType.xuanque.response();
                responseObj.errorcode = Errorcode.SUCCESS;
                return responseObj;
            } catch (Exception ex) {
                UnityEngine.Debug.LogException(ex);
                S2cSprotoType.xuanque.response responseObj = new S2cSprotoType.xuanque.response();
                responseObj.errorcode = Errorcode.FAIL;
                return responseObj;
            }
        }

        public SprotoTypeBase OnTakeCard(SprotoTypeBase requestObj) {
            S2cSprotoType.take_card.request obj = requestObj as S2cSprotoType.take_card.request;
            try {
                GameEntity entity = _gameSystems.NetIdxSystem.FindEntity(obj.idx);
                _gameSystems.PlayerSystem.TakeTakeCard(entity, obj.card);

                S2cSprotoType.xuanque.response responseObj = new S2cSprotoType.xuanque.response();
                responseObj.errorcode = Errorcode.SUCCESS;
                return responseObj;
            } catch (Exception ex) {
                UnityEngine.Debug.LogException(ex);
                S2cSprotoType.take_card.response responseObj = new S2cSprotoType.take_card.response();
                responseObj.errorcode = Errorcode.FAIL;
                return responseObj;
            }
        }

        public SprotoTypeBase OnTakeTurn(SprotoTypeBase requestObj) {
            S2cSprotoType.take_turn.request obj = requestObj as S2cSprotoType.take_turn.request;
            try {
                _context.rule.gamestate = GameState.TURN;
                _context.rule.curidx = obj.your_turn;
                _gameSystems.DeskSystem.ShowCountdown(obj.countdown);

                var curIdxEntity = _gameSystems.NetIdxSystem.FindEntity(obj.your_turn);
                _gameSystems.PlayerSystem.TakeTurn(curIdxEntity, obj.countdown);
                _gameSystems.NetIdxSystem.PlayFlame(curIdxEntity.player.idx, obj.countdown);

                S2cSprotoType.take_turn.response responseObj = new S2cSprotoType.take_turn.response();
                responseObj.errorcode = Errorcode.SUCCESS;
                return responseObj;
            } catch (KeyNotFoundException ex) {
                UnityEngine.Debug.LogException(ex);
                S2cSprotoType.take_turn.response responseObj = new S2cSprotoType.take_turn.response();
                responseObj.errorcode = Errorcode.FAIL;
                return responseObj;
            }
        }

        public SprotoTypeBase OnOCall(SprotoTypeBase requestObj) {
            S2cSprotoType.ocall.request obj = requestObj as S2cSprotoType.ocall.request;
            try {
                _context.rule.gamestate = GameState.OCALL;
                _gameSystems.DeskSystem.ShowCountdown(obj.countdown);


                UnityEngine.Debug.Assert(obj.opcodes.Count > 0);
                for (int i = 0; i < obj.opcodes.Count; i++) {
                    if (obj.opcodes[i].idx == _context.rule.myidx) {
                        GameUIModule module = _appContext.U.GetModule<GameUIModule>();
                        MyOptionsUIController myOptionsUIController = module.MyOptionsUIController;
                        if ((obj.opcodes[i].opcode & OpCodes.OPCODE_PENG) > 0) {
                            myOptionsUIController.SetCall(true, false, false, false);
                        }
                        if ((obj.opcodes[i].opcode & OpCodes.OPCODE_GANG) > 0) {
                            myOptionsUIController.SetCall(false, true, false, false);
                        }
                        if ((obj.opcodes[i].opcode & OpCodes.OPCODE_HU) > 0) {
                            myOptionsUIController.SetCall(false, false, true, false);
                        }
                        if ((obj.opcodes[i].opcode & OpCodes.OPCODE_GUO) > 0) {
                            myOptionsUIController.SetCall(false, false, false, true);
                        }
                        myOptionsUIController.Shaking();
                    }
                }

                S2cSprotoType.ocall.response responseObj = new S2cSprotoType.ocall.response();
                responseObj.errorcode = Errorcode.SUCCESS;
                return responseObj;
            } catch (Exception ex) {
                UnityEngine.Debug.LogException(ex);
                S2cSprotoType.ocall.response responseObj = new S2cSprotoType.ocall.response();
                responseObj.errorcode = Errorcode.FAIL;
                return responseObj;
            }
        }

        public SprotoTypeBase OnMCall(SprotoTypeBase requestObj) {
            S2cSprotoType.mcall.request obj = requestObj as S2cSprotoType.mcall.request;
            try {
                _context.rule.gamestate = GameState.MCALL;
                _gameSystems.DeskSystem.ShowCountdown(obj.countdown);

                GameUIModule module = _appContext.U.GetModule<GameUIModule>();
                MyOptionsUIController myOptionsUIController = module.MyOptionsUIController;
                if ((obj.opcodes.opcode & OpCodes.OPCODE_PENG) > 0) {
                    myOptionsUIController.SetCall(true, false, false, false);
                }
                if ((obj.opcodes.opcode & OpCodes.OPCODE_GANG) > 0) {
                    myOptionsUIController.SetCall(false, true, false, false);
                }
                if ((obj.opcodes.opcode & OpCodes.OPCODE_HU) > 0) {
                    myOptionsUIController.SetCall(false, false, true, false);
                }
                if ((obj.opcodes.opcode & OpCodes.OPCODE_GUO) > 0) {
                    myOptionsUIController.SetCall(false, false, false, true);
                }
                myOptionsUIController.Shaking();

                CallInfo call = new CallInfo();
                call.Card = obj.opcodes.card;
                call.Dian = obj.opcodes.dian;
                call.OpCode = obj.opcodes.opcode;
                call.GangType = obj.opcodes.gangtype;
                call.HuType = obj.opcodes.hutype;
                call.JiaoType = obj.opcodes.jiaotype;

                GameEntity entity = _gameSystems.NetIdxSystem.FindEntity(obj.opcodes.idx);
                entity.playerCard.call = call;
                _gameSystems.PlayerSystem.SetupCall(entity);

                S2cSprotoType.mcall.response responseObj = new S2cSprotoType.mcall.response();
                responseObj.errorcode = Errorcode.SUCCESS;
                return responseObj;
            } catch (Exception ex) {
                UnityEngine.Debug.LogException(ex);
                S2cSprotoType.mcall.response responseObj = new S2cSprotoType.mcall.response();
                responseObj.errorcode = Errorcode.FAIL;
                return responseObj;
            }
        }

        public SprotoTypeBase OnPeng(SprotoTypeBase requestObj) {
            S2cSprotoType.peng.request obj = requestObj as S2cSprotoType.peng.request;
            try {
                // 
                _context.rule.gamestate = GameState.PENG;
                UnityEngine.Debug.Assert(obj.code == OpCodes.OPCODE_PENG);
                UnityEngine.Debug.Assert(obj.dian == _context.rule.lastidx);
                UnityEngine.Debug.Assert(obj.card == _context.rule.lastCard);

                var entity = _gameSystems.NetIdxSystem.FindEntity(obj.idx);
                var dianEntity = _gameSystems.NetIdxSystem.FindEntity(obj.dian);
                var cardEntity = _gameSystems.CardValueIndexSystem.FindEntity(obj.card);
                _gameSystems.PlayerSystem.Peng(entity, dianEntity, cardEntity, obj.hor);

                S2cSprotoType.peng.response responseObj = new S2cSprotoType.peng.response();
                responseObj.errorcode = Errorcode.SUCCESS;
                return responseObj;
            } catch (KeyNotFoundException ex) {
                UnityEngine.Debug.LogError(ex.Message);
                S2cSprotoType.peng.response responseObj = new S2cSprotoType.peng.response();
                responseObj.errorcode = Errorcode.FAIL;
                return responseObj;
            }
        }

        public SprotoTypeBase OnGang(SprotoTypeBase requestObj) {
            S2cSprotoType.gang.request obj = requestObj as S2cSprotoType.gang.request;
            try {
                _context.rule.gamestate = GameState.GANG;
                _context.rule.curidx = obj.idx;

                GameEntity entity = _gameSystems.NetIdxSystem.FindEntity(obj.idx);
                _gameSystems.PlayerSystem.Gang(entity, obj.code, obj.dian, obj.card, obj.hor, obj.isHoldcard, obj.isHoldcardInsLast);
                _context.rule.settles = obj.settles;

                S2cSprotoType.gang.response responseObj = new S2cSprotoType.gang.response();
                responseObj.errorcode = Errorcode.SUCCESS;
                return responseObj;
            } catch (Exception ex) {
                UnityEngine.Debug.LogException(ex);

                S2cSprotoType.gang.response responseObj = new S2cSprotoType.gang.response();
                responseObj.errorcode = Errorcode.SUCCESS;
                return responseObj;
            }
        }

        public SprotoTypeBase OnHu(SprotoTypeBase requestObj) {
            S2cSprotoType.hu.request obj = requestObj as S2cSprotoType.hu.request;
            try {
                _context.rule.gamestate = GameState.HU;
                _context.rule.settles = obj.settles;
                _context.rule.oknum = obj.hus.Count;
                if (obj.hus.Count > 1) {
                    // 一炮多响
                }

                long dian = 0;
                for (int i = 0; i < obj.hus.Count; i++) {
                    GameEntity entity = _gameSystems.NetIdxSystem.FindEntity(obj.hus[i].idx);
                    _gameSystems.PlayerSystem.Hu(entity, obj.hus[i].idx, obj.hus[i].dian, obj.hus[i].jiaotype, obj.hus[i].hutype);
                }

                S2cSprotoType.hu.response responseObj = new S2cSprotoType.hu.response();
                responseObj.errorcode = Errorcode.SUCCESS;
                return responseObj;
            } catch (Exception ex) {
                UnityEngine.Debug.LogException(ex);

                S2cSprotoType.hu.response responseObj = new S2cSprotoType.hu.response();
                responseObj.errorcode = Errorcode.SUCCESS;
                return responseObj;
            }
        }

        public SprotoTypeBase OnLead(SprotoTypeBase requestObj) {
            S2cSprotoType.lead.request obj = requestObj as S2cSprotoType.lead.request;
            try {
                _context.rule.gamestate = GameState.LEAD;
                _context.rule.lastidx = obj.idx;
                _context.rule.lastCard = obj.card;
                UnityEngine.Debug.Assert(_context.rule.curidx == obj.idx);
                GameEntity entity = _gameSystems.NetIdxSystem.FindEntity(obj.idx);
                _gameSystems.PlayerSystem.Lead(entity, obj.card, obj.isHoldcard);

                S2cSprotoType.lead.response responseObj = new S2cSprotoType.lead.response();
                responseObj.errorcode = Errorcode.SUCCESS;
                return responseObj;
            } catch (Exception ex) {
                UnityEngine.Debug.LogException(ex);
                S2cSprotoType.lead.response responseObj = new S2cSprotoType.lead.response();
                responseObj.errorcode = Errorcode.FAIL;
                return responseObj;
            }
        }

        public SprotoTypeBase OnOver(SprotoTypeBase requestObj) {
            try {

                //SendStep();

                S2cSprotoType.over.response responseObj = new S2cSprotoType.over.response();
                responseObj.errorcode = Errorcode.SUCCESS;
                return responseObj;
            } catch (Exception ex) {
                UnityEngine.Debug.LogException(ex);
                S2cSprotoType.over.response responseObj = new S2cSprotoType.over.response();
                responseObj.errorcode = Errorcode.FAIL;
                return responseObj;
            }
        }

        public SprotoTypeBase OnSettle(SprotoTypeBase requestObj) {
            S2cSprotoType.settle.request obj = requestObj as S2cSprotoType.settle.request;
            try {
                //_settles = obj.settles;
                //_settlesidx = 0;

                //foreach (var item in _playes) {
                //    item.Value.ClearSettle();
                //    OnSettleNext(null);
                //}

                S2cSprotoType.settle.response responseObj = new S2cSprotoType.settle.response();
                responseObj.errorcode = Errorcode.SUCCESS;
                return responseObj;
            } catch (Exception ex) {
                S2cSprotoType.settle.response responseObj = new S2cSprotoType.settle.response();
                responseObj.errorcode = Errorcode.FAIL;
                return responseObj;
            }
        }

        public SprotoTypeBase OnFinalSettle(SprotoTypeBase requestObj) {
            try {
                S2cSprotoType.final_settle.request obj = requestObj as S2cSprotoType.final_settle.request;

                //_ui.ShowOver();

                //foreach (var item in _playes) {
                //    item.Value.ClearSettle();
                //}

                //foreach (var x in _playes) {
                //    Player player = x.Value;

                //    List<S2cSprotoType.settlementitem> settle = null;
                //    long idx = 0;
                //    if (player.Idx == 1) {
                //        idx = 1;
                //        if (obj.p1 != null) {
                //            settle = obj.p1;
                //        }
                //    } else if (player.Idx == 2) {
                //        idx = 2;
                //        if (obj.p2 != null) {
                //            settle = obj.p2;
                //        }
                //    } else if (player.Idx == 3) {
                //        idx = 3;
                //        if (obj.p3 != null) {
                //            settle = obj.p3;
                //        }
                //    } else if (player.Idx == 4) {
                //        idx = 4;
                //        if (obj.p4 != null) {
                //            settle = obj.p4;
                //        }
                //    }

                //    if (settle != null && settle.Count > 0) {
                //        for (int i = 0; i < settle.Count; i++) {
                //            SettlementItem item = new SettlementItem();
                //            item.Idx = settle[i].idx;
                //            item.Chip = settle[i].chip;  // 有正负
                //            item.Left = settle[i].left;  // 以次值为准

                //            item.Win = settle[i].win;
                //            item.Lose = settle[i].lose;

                //            item.Gang = settle[i].gang;
                //            item.HuCode = settle[i].hucode;
                //            item.HuJiao = settle[i].hujiao;
                //            item.HuGang = settle[i].hugang;
                //            item.HuaZhu = settle[i].huazhu;
                //            item.DaJiao = settle[i].dajiao;
                //            item.TuiSui = settle[i].tuisui;

                //            _playes[idx].AddSettle(item);
                //        }

                //        _playes[idx].FinalSettle();
                //    }
                //}

                S2cSprotoType.final_settle.response responseObj = new S2cSprotoType.final_settle.response();
                responseObj.errorcode = Errorcode.SUCCESS;
                return responseObj;
            } catch (Exception ex) {
                S2cSprotoType.final_settle.response responseObj = new S2cSprotoType.final_settle.response();
                responseObj.errorcode = Errorcode.FAIL;
                return responseObj;
            }
        }

        public SprotoTypeBase OnRestart(SprotoTypeBase requestObj) {
            S2cSprotoType.restart.request obj = requestObj as S2cSprotoType.restart.request;
            try {
                //_playes[obj.idx].Restart();

                S2cSprotoType.restart.response responseObj = new S2cSprotoType.restart.response();
                responseObj.errorcode = Errorcode.SUCCESS;
                return responseObj;
            } catch (Exception ex) {
                UnityEngine.Debug.LogException(ex);
                S2cSprotoType.restart.response responseObj = new S2cSprotoType.restart.response();
                responseObj.errorcode = Errorcode.FAIL;
                return responseObj;
            }
        }

        //public SprotoTypeBase OnTakeRestart(SprotoTypeBase requestObj) {
        //    try {
        //        _fistidx = 0;
        //        _fisttake = 0;

        //        _curidx = 0;
        //        _curtake = 0;

        //        _huscount = 0;
        //        _oknum = 0;
        //        _take1time = 0;
        //        _takeround = 0;
        //        _takepoint = 0;  // 最多是6 

        //        _lastidx = 0;
        //        _lastCard = null;

        //        foreach (var item in _cards) {
        //            item.Value.Clear();
        //        }

        //        foreach (var item in _playes) {
        //            item.Value.TakeRestart();
        //        }


        //        {
        //            SendStep();
        //        }

        //        S2cSprotoType.take_restart.response responseObj = new S2cSprotoType.take_restart.response();
        //        responseObj.errorcode = Errorcode.SUCCESS;
        //        return responseObj;
        //    } catch (Exception ex) {
        //        UnityEngine.Debug.LogException(ex);
        //        S2cSprotoType.take_restart.response responseObj = new S2cSprotoType.take_restart.response();
        //        responseObj.errorcode = Errorcode.FAIL;
        //        return responseObj;
        //    }
        //}

        //public SprotoTypeBase OnRChat(SprotoTypeBase requestObj) {
        //    S2cSprotoType.rchat.request obj = requestObj as S2cSprotoType.rchat.request;
        //    try {
        //        _playes[obj.idx].Say(obj.textid);

        //        S2cSprotoType.rchat.response responseObj = new S2cSprotoType.rchat.response();
        //        responseObj.errorcode = Errorcode.SUCCESS;
        //        return responseObj;
        //    } catch (Exception ex) {
        //        UnityEngine.Debug.LogException(ex);
        //        S2cSprotoType.rchat.response responseObj = new S2cSprotoType.rchat.response();
        //        responseObj.errorcode = Errorcode.FAIL;
        //        return responseObj;
        //    }
        //}
        #endregion

        #region render
        #endregion
    }
}
