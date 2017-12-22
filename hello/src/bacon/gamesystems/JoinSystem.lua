using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Bacon.Game;
using UnityEngine;
using Sproto;
using Entitas;
using Bacon.Model;
using Bacon.DataSet;
using Bacon.Model.Join;
using Bacon.Model.GameUI;

namespace Bacon.GameSystems {
    public class JoinSystem : Entitas.ISystem, ISetContextSystem, IInitializeSystem, IResetSystem, ICleanupSystem {

        private GameContext _context;
        private AppContext _appContext;
        private AppGameSystems _gameSystems;

        public JoinSystem(Contexts contexts) {
            _context = contexts.game;
        }

        public void SetAppContext(AppContext context) {
            _appContext = context;
            _gameSystems = context.GameSystems;
        }

        public void Initialize() {
#if (!GEN_COMPONENT)
            _context.SetRule(GameType.GAME, 0, 0, 0, 0, 0, false, 0, 0, 0, false, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, new List<long>(), null, 0);
#endif
        }

        public void Reset() {
#if (!GEN_COMPONENT)
            _context.ReplaceRule(GameType.GAME, 0, 0, 0, 0, 0, false, 0, 0, 0, false, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, new List<long>(), null, 0);
#endif
        }

        public void Cleanup() {
#if (!GEN_COMPONENT)
            _context.ReplaceRule(GameType.GAME, 0, 0, 0, 0, 0, false, 0, 0, 0, false, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, new List<long>(), null, 0);
#endif
        }

        public int Join(long idx, long chip, long uid, long subid, long sex, string name, Player.Orient orient) {
#if (!GEN_COMPONENT)
            var playItem = DataSetManager.Instance.Say.GetPlayItem((long)orient, sex);
            var handItem = DataSetManager.Instance.Say.GetHandItem((long)orient, sex);
            var entity = _context.CreateEntity();
            entity.AddPlayer(uid, subid, idx, sex, chip, name, orient, false, null);
            entity.AddHandCards((float)playItem.LeftOffset, (float)playItem.BottomOffset, new List<GameEntity>(),
                (float)playItem.SortCardsDelta, (float)playItem.PGSortCardsDelta, (float)playItem.DealCardDelta, (float)playItem.FangDaoPaiDelta);

            Quaternion[] quaternion = new Quaternion[6];
            if (orient == Player.Orient.BOTTOM) {
                quaternion[0] = Quaternion.Euler(30.0f, 0.0f, 0.0f);
                quaternion[1] = Quaternion.Euler(30.0f, 0.0f, 0.0f);
            } else if (orient == Player.Orient.RIGHT) {
                quaternion[0] = Quaternion.Euler(0.0f, -90.0f, 0.0f);
                quaternion[1] = Quaternion.Euler(0.0f, -90.0f, 0.4f);
            } else if (orient == Player.Orient.TOP) {
                quaternion[0] = Quaternion.Euler(0.0f, 180.0f, 0.0f);
                quaternion[1] = Quaternion.Euler(0.0f, 180.0f, 0.0f);
            } else if (orient == Player.Orient.LEFT) {
                quaternion[0] = Quaternion.Euler(0.0f, 90.0f, 0.0f);
                quaternion[1] = Quaternion.Euler(0.0f, 90.0f, 0.0f);
            }
            entity.AddHand(null, null,
                    new Vector3((float)handItem.RHandInitPos[0], (float)handItem.RHandInitPos[1], (float)handItem.RHandInitPos[2]),
                    quaternion[0],
                    new Vector3((float)handItem.RHandDiuszOffset[0], (float)handItem.RHandDiuszOffset[1], (float)handItem.RHandDiuszOffset[2]),
                    new Vector3((float)handItem.RHandTakeOffset[0], (float)handItem.RHandTakeOffset[1], (float)handItem.RHandTakeOffset[2]),
                    new Vector3((float)handItem.RHandLeadOffset[0], (float)handItem.RHandLeadOffset[1], (float)handItem.RHandLeadOffset[2]),
                    new Vector3((float)handItem.RHandNaOffset[0], (float)handItem.RHandNaOffset[1], (float)handItem.RHandNaOffset[2]),
                    new Vector3((float)handItem.RhandPGOffset[0], (float)handItem.RhandPGOffset[1], (float)handItem.RhandPGOffset[2]),
                    new Vector3((float)handItem.RHandHuOffset[0], (float)handItem.RHandHuOffset[1], (float)handItem.RHandHuOffset[2]),
                    new Vector3((float)handItem.LHandInitPos[0], (float)handItem.LHandInitPos[0], (float)handItem.LHandInitPos[0]),                 // TODO:
                    quaternion[1],
                    new Vector3((float)handItem.LHandHuOffset[0], (float)handItem.LHandHuOffset[1], (float)handItem.LHandHuOffset[2]),
                    (float)handItem.DiuszShenDelta,
                    (float)handItem.DiuszShouDelta,
                    (float)handItem.ChuPaiShenDelta,
                    (float)handItem.ChuPaiShouDelta,
                    (float)handItem.NaPaiShenDelta,
                    (float)handItem.FangPaiShouDelta,
                    (float)handItem.HuPaiShenDelta,
                    (float)handItem.HuPaiShouDelta,
                    (float)handItem.PGShenDelta,
                    (float)handItem.PGShouDelta);

            entity.AddHoldCard(null,
                new Vector3((float)playItem.HoldNaMove[0], (float)playItem.HoldNaMove[1], (float)playItem.HoldNaMove[2]),
                (float)playItem.HoldNaMoveDelta,
                (float)playItem.HoldFlyDelta,
                (float)playItem.HoldDownDelta,
                (float)playItem.HoldInsSortCardsdelta,
                (float)playItem.HoldAfterPGDelta);

            entity.AddHuCards((float)playItem.HuRightOffset, (float)playItem.HuBottomOffset, new List<GameEntity>());
            entity.AddLeadCards(0, false,
                new Vector3((float)playItem.LeadCardMove[0], (float)playItem.LeadCardMove[1], (float)playItem.LeadCardMove[2]),
                (float)playItem.LeadCardMoveDelta,
                (float)playItem.LeadLeftOffset, (float)playItem.LeadBottomOffset,
                new List<GameEntity>());

            // qu
            if (orient == Player.Orient.BOTTOM) {
                quaternion[0] = Quaternion.AngleAxis(0.0f, Vector3.up);          // upv
                quaternion[1] = Quaternion.AngleAxis(-90.0f, Vector3.up);        // uph
                quaternion[2] = Quaternion.AngleAxis(180.0f, Vector3.forward);   // downh
                quaternion[3] = Quaternion.AngleAxis(-90.0f, Vector3.right);     // backvst
                quaternion[4] = Quaternion.AngleAxis(-25.0f, Vector3.right);     // backv
            } else if (orient == Player.Orient.RIGHT) {
                quaternion[0] = Quaternion.AngleAxis(-90.0f, Vector3.up);
                quaternion[1] = Quaternion.AngleAxis(-180.0f, Vector3.up);
                quaternion[2] = Quaternion.AngleAxis(-90.0f, Vector3.up) * Quaternion.AngleAxis(180.0f, Vector3.forward);
                quaternion[3] = Quaternion.Euler(-120.0f, -90.0f, 0.0f);
                quaternion[4] = Quaternion.Euler(-90.0f, -90.0f, 0.0f);
            } else if (orient == Player.Orient.TOP) {
                quaternion[0] = Quaternion.AngleAxis(180.0f, Vector3.up);
                quaternion[1] = Quaternion.AngleAxis(90.0f, Vector3.up);
                quaternion[2] = Quaternion.AngleAxis(180.0f, Vector3.up) * Quaternion.AngleAxis(180.0f, Vector3.forward);
                quaternion[3] = Quaternion.AngleAxis(180.0f, Vector3.up) * Quaternion.AngleAxis(-120.0f, Vector3.right);
                quaternion[4] = Quaternion.AngleAxis(180.0f, Vector3.up) * Quaternion.AngleAxis(-90.0f, Vector3.right);
            } else if (orient == Player.Orient.LEFT) {
                quaternion[0] = Quaternion.AngleAxis(90.0f, Vector3.up);
                quaternion[1] = Quaternion.AngleAxis(0.0f, Vector3.up);
                quaternion[2] = Quaternion.AngleAxis(90.0f, Vector3.up) * Quaternion.AngleAxis(180.0f, Vector3.forward);
                quaternion[3] = Quaternion.AngleAxis(90.0f, Vector3.up) * Quaternion.AngleAxis(-120.0f, Vector3.right);
                quaternion[4] = Quaternion.AngleAxis(90.0f, Vector3.up) * Quaternion.AngleAxis(-90.0f, Vector3.right);
            }

            entity.AddPlayerCard(0, 0, false, Card.CardType.Bam, false,
                quaternion[0],
                quaternion[1],
                quaternion[2],
                quaternion[3],
                quaternion[4],
                    0, new List<SettlementItem>(), 0, 0, 0,
                    new List<long>(), null, null);
            entity.AddPutCards((float)playItem.PutMoveDelta, (float)playItem.PutMargin,
                new Vector3((float)playItem.PutMove[0], (float)playItem.PutMove[1], (float)playItem.PutMove[2]),
                 (float)playItem.PutRightOffset, (float)playItem.PutBottomOffset, 0, new List<PGCards>());
            entity.AddTakeCards((float)playItem.TakeLeftOffset, (float)playItem.TakeBottomOffset, (float)playItem.TakeMove, (float)playItem.TakeMoveDelta, 0, 0, 0, new Dictionary<int, GameEntity>());
            entity.AddHead(new UI.Head.HeadUIController(_appContext));
            entity.head.headUIController.Orient = orient;
            entity.head.headUIController.SetGold((int)chip);

            _gameSystems.NetIdxSystem.AddEntity(entity);
            _gameSystems.NetIdxSystem.ShowHeadFirst();
            _gameSystems.NetIdxSystem.LoadHand();
            _context.rule.online++;
            _context.rule.joined++;

            return entity.index.index;
#else
            return 0
#endif
        }

        public void Leave(long idx) {
            IEntity entity = _gameSystems.NetIdxSystem.FindEntity(idx);
            _gameSystems.NetIdxSystem.RemoveEntity(entity);
        }

        #region request
        public SprotoTypeBase OnJoin(SprotoTypeBase requestObj) {
            S2cSprotoType.join.request obj = requestObj as S2cSprotoType.join.request;
            JoinModule joinModule = _appContext.U.GetModule<JoinModule>();
            long myidx = joinModule.MyIdx;
            long offset = 0;
            if (obj.p.idx > myidx) {
                offset = obj.p.idx - myidx;
            } else {
                offset = obj.p.idx + 4 - myidx;
            }
            switch (offset) {
                case 1: {
                        Join(obj.p.idx, obj.p.chip, 0, obj.p.sid, obj.p.sex, obj.p.name, Player.Orient.RIGHT);
                    }
                    break;
                case 2: {
                        Join(obj.p.idx, obj.p.chip, 0, obj.p.sid, obj.p.sex, obj.p.name, Player.Orient.TOP);
                    }
                    break;
                case 3: {
                        Join(obj.p.idx, obj.p.chip, 0, obj.p.sid, obj.p.sex, obj.p.name, Player.Orient.LEFT);
                    }
                    break;
                default:
                    break;
            }
            if (obj.ready) {
                _appContext.GameSystems.GameSystem.SetState(GameState.READY);
                _appContext.GameSystems.NetIdxSystem.Ready();

                GameUIModule gameUIModule = _appContext.U.GetModule<GameUIModule>();
                MyOptionsUIController myOptionsUIController = gameUIModule.MyOptionsUIController;
                myOptionsUIController.SetReady(true);
                if (myOptionsUIController.Counter > 0) {
                    myOptionsUIController.Shaking();
                } else {
                    if (_appContext.Peek().Name == "game" && _appContext.Peek().LoadedUI) {
                        _appContext.UIContextManager.Push(myOptionsUIController);
                    }
                }

                GameUIController gameUIController = gameUIModule.GameUIController;
                gameUIController.SetInvite(false);
                gameUIController.Shaking();
            }
            S2cSprotoType.join.response responseObj = new S2cSprotoType.join.response();
            responseObj.errorcode = Errorcode.SUCCESS;
            return responseObj;
        }

        public SprotoTypeBase OnLeave(SprotoTypeBase requestObj) {
            S2cSprotoType.leave.request obj = requestObj as S2cSprotoType.leave.request;
            Leave(obj.idx);

            S2cSprotoType.leave.response responseObj = new S2cSprotoType.leave.response();
            responseObj.errorcode = Errorcode.SUCCESS;
            return responseObj;
        }
        #endregion

    }
}
