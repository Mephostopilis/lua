using Bacon;
using Maria;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using DG.Tweening;
using Bacon.Service;
using Bacon.Event;
using Maria.Util;
using Maria.Res;
using Entitas;
using Bacon.Game;

namespace Bacon.GameSystems {
    public class RightPlayerSystem : PlayerSystem {

        public RightPlayerSystem(Contexts contexts) : base(contexts) {}

        public override void Initialize() {}

        //private Bacon.GL.Game.RightPlayer _com;

        //public RightPlayer(Context ctx, GameController controller) : base(ctx, controller) {
        //    _upv = Quaternion.AngleAxis(-90.0f, Vector3.up);
        //    _uph = Quaternion.AngleAxis(-180.0f, Vector3.up);
        //    _downv = Quaternion.AngleAxis(-90.0f, Vector3.up) * Quaternion.AngleAxis(180.0f, Vector3.forward);
        //    _backv = Quaternion.Euler(-90.0f, -90.0f, 0.0f);

        //    _ori = Orient.RIGHT;
        //    _takeleftoffset = 0.5f;
        //    _takebottomoffset = 0.385f;

        //    _leftoffset = 0.5f;
        //    _bottomoffset = 1.7f;

        //    _leadcardoffset = new Vector3(0.0f, 0.0f, 0.05f);
        //    _leadleftoffset = 0.8f;
        //    _leadbottomoffset = 0.8f;

        //    _putbottomoffset = 0.07f - Card.Length / 2.0f;
        //    _putrightoffset = 0.55f - Card.Width / 2.0f;

        //    //
        //    _hurightoffset = 0.2f;
        //    _hubottomoffset = 0.4f;

        //    // 手
        //    _rhandinitpos = new Vector3(4.0f, -1.8f, 0.4f);
        //    _rhandinitrot = Quaternion.Euler(0.0f, -90.0f, 0.0f);
        //    _rhandleadoffset = new Vector3(1.08f, -1.95f, -0.6f);
        //    _rhandtakeoffset = new Vector3(0.485f, -2.0f, -0.4f);
        //    _rhandnaoffset = new Vector3(0.425f, -2.108f, -0.43f);
        //    _rhandpgoffset = Vector3.zero;
        //    _rhandhuoffset = Vector3.zero;

        //    _lhandinitpos = new Vector3(4.0f, -1.8f, 1f);
        //    _lhandinitrot = Quaternion.Euler(0.0f, -90.0f, 0.4f);
        //    _lhandhuoffset = Vector3.zero;


        //    EventListenerCmd listener1 = new EventListenerCmd(MyEventCmd.EVENT_SETUP_RIGHTPLAYER, OnSetup);
        //    _ctx.EventDispatcher.AddCmdEventListener(listener1);
        //}

        //public override void Init() {
        //    base.Init();

        //    if (_sex == 1) {
        //        _rhandleadoffset = new Vector3(0.915f, -2.041f, -0.137f);
        //        _rhandtakeoffset = new Vector3(0.51f, -2.029f, -0.513f);
        //        _rhandnaoffset = new Vector3(0.51f, -2.087f, -0.513f);
        //        _rhandpgoffset = new Vector3(0.746f, -2.027f, -0.828f);
        //        _rhandhuoffset = new Vector3(0.66f, -2.143f, -0.16f);
        //    }
        //}

        //protected override void RenderPlayFlameCountdown() {

        //    _com.Head.PlayFlameCountdown(_cd);
        //}

        //protected override void RenderStopFlame() {
        //    _com.Head.StopFlame();
        //}

        //private void OnSetup(EventCmd e) {
        //    _go = e.Orgin;
        //    _ctx.EnqueueRenderQueue(RenderSetup);
        //}

        //private void RenderSetup() {
        //    _com = _go.GetComponent<GL.Game.RightPlayer>();
        //    _com.ShowUI();
        //    _com.Head.SetGold(_chip);
        //}

        //protected override Vector3 CalcPos(GameEntity entity, int pos) {
        //    UnityEngine.Debug.Assert(entity.player.orient == Player.Orient.RIGHT);
        //    GameEntity deskEntity = _gameSystems.DeskSystem.FindEntity();

        //    float x = deskEntity.desk.width - (entity.handCards.bottomoffset + Card.Height / 2.0f);
        //    x = entity.handCards.bottomoffset;
        //    float y = Card.Length / 2.0f + Card.HeightMZ;
        //    float z = entity.handCards.leftoffset + Card.Width * pos + Card.Width / 2.0f;
        //    return new Vector3(x, y, z);
        //}

        //protected override Vector3 CalcLeadPos(int pos) {
        //    Desk desk = ((GameController)_controller).Desk;
        //    int row = pos / 6;
        //    int col = pos % 6;

        //    float x = desk.Width - (_leadbottomoffset - (Card.Length * row) - (Card.Length / 2.0f));
        //    float y = Card.Height / 2.0f + Card.HeightMZ;
        //    float z = _leadleftoffset + (Card.Width * col) + Card.Width / 2.0f;

        //    return new Vector3(x, y, z);
        //}

        //protected override void RenderFixDirMark() {
        //    if (_idx == 1) {
        //        ((GameController)_controller).Desk.RenderSetDongAtRight();
        //    } else if (_idx == 2) {
        //        ((GameController)_controller).Desk.RenderSetNanAtRight();
        //    } else if (_idx == 3) {
        //        ((GameController)_controller).Desk.RenderSetXiAtRight();
        //    } else if (_idx == 4) {
        //        ((GameController)_controller).Desk.RenderSetBeiAtRight();
        //    } else {
        //        UnityEngine.Debug.Assert(false);
        //    }

        //    if (_sex == 1) {
        //        GameObject rori = ABLoader.current.LoadAsset<GameObject>("Prefabs/Hand", "boyrhand");
        //        _rhand = GameObject.Instantiate<GameObject>(rori);

        //        GameObject lori = ABLoader.current.LoadAsset<GameObject>("Prefabs/Hand", "boylhand");
        //        _lhand = GameObject.Instantiate<GameObject>(lori);
        //    } else {
        //        GameObject rori = ABLoader.current.LoadAsset<GameObject>("Prefabs/Hand", "girlrhand");
        //        _rhand = GameObject.Instantiate<GameObject>(rori);

        //        GameObject lori = ABLoader.current.LoadAsset<GameObject>("Prefabs/Hand", "girllhand");
        //        _lhand = GameObject.Instantiate<GameObject>(lori);
        //    }

        //    _rhand.transform.SetParent(_go.transform);
        //    _rhand.transform.localPosition = _rhandinitpos;
        //    _rhand.transform.localRotation = _rhandinitrot;

        //    _lhand.transform.SetParent(_go.transform);
        //    _lhand.transform.localPosition = _lhandinitpos;
        //    _lhand.transform.localRotation = _lhandinitrot;

        //}

        //public override void RenderBoxing() {
        //    try {
        //        int count = 0;
        //        Desk desk = ((GameController)_controller).Desk;
        //        desk.RenderShowRightSlot(() => {
        //        });

        //        for (int i = 0; i < _takecards.Count; i++) {
        //            int idx = i / 2;
        //            float x = desk.Width - (_takebottomoffset);
        //            float y = Card.HeightMZ + Card.Height / 2.0f;
        //            float z = desk.Length - (_takeleftoffset + idx * Card.Width + Card.Width / 2.0f);

        //            if (i % 2 == 0) {
        //                y = Card.HeightMZ + Card.Height + Card.Height / 2.0f;
        //            } else if (i % 2 == 1) {
        //                y = Card.HeightMZ + Card.Height / 2.0f;
        //            }

        //            Card card = _takecards[i];
        //            card.Go.transform.localRotation = _downv;

        //            card.Go.transform.localPosition = new UnityEngine.Vector3(x, y - _takemove, z);
        //            Tween t = card.Go.transform.DOLocalMoveY(y, _takemovedelta);

        //            Sequence mySequence = DOTween.Sequence();
        //            mySequence.Append(t)
        //            .AppendCallback(() => {
        //                count++;
        //                if (count == _takecards.Count) {
        //                    Maria.Command cmd = new Maria.Command(MyEventCmd.EVENT_BOXINGCARDS);
        //                    _ctx.Enqueue(cmd);
        //                }
        //            });
        //        }

        //        desk.RenderCloseRightSlot(() => {
        //        });

        //    } catch (Exception ex) {
        //        UnityEngine.Debug.LogException(ex);
        //    }
        //}

        //protected override void RenderThrowDice() {

        //    // 1.0 伸手
        //    Tween t = _rhand.transform.DOLocalMove(new Vector3(1.877f, -1.95f, 0.215f), _diushaizishendelta);
        //    Animator animator = _rhand.GetComponent<Animator>();
        //    Sequence mySequence = DOTween.Sequence();
        //    mySequence.Append(t)
        //        .AppendCallback(() => {
        //            // 2.0 点击启动
        //            GL.Game.Hand hand = _rhand.GetComponent<GL.Game.Hand>();
        //            hand.Rigster(GL.Game.Hand.EVENT.DIUSHAIZI_COMPLETED, () => {
        //                // 3.1
        //                UnityEngine.Debug.Log("right diu saizi ");
        //                ((GameController)_controller).RenderThrowDice(_d1, _d2);

        //                // 3.2
        //                Tween t32 = _rhand.transform.DOLocalMove(_rhandinitpos, _diushaizishoudelta);
        //                Sequence mySequence32 = DOTween.Sequence();
        //                mySequence32.Append(t32)
        //                .AppendCallback(() => {
        //                    animator.SetBool("Idle", true);
        //                });
        //            });
        //            animator.SetBool("Diushaizi", true);
        //        });
        //}

        //protected override void RenderDeal() {
        //    _oknum = 0;
        //    int count = 0;
        //    int i = 0;
        //    if (_cards.Count == 13) {
        //        i = 12;
        //        count = 1;
        //    } else {
        //        i = _cards.Count - 4;
        //        count = 4;
        //    }
        //    for (; i < _cards.Count; i++) {
        //        Vector3 dst = CalcPos(i);
        //        var card = _cards[i];
        //        card.Go.transform.localPosition = dst;
        //        card.Go.transform.localRotation = Quaternion.Euler(-115.0f, -90.0f, 0.0f);
        //        Tween t = card.Go.transform.DOLocalRotateQuaternion(_backv, _dealcarddelta);
        //        Sequence mySequence = DOTween.Sequence();
        //        mySequence.Append(t)
        //            .AppendCallback(() => {
        //                _oknum++;
        //                if (_oknum >= count) {
        //                    Command cmd = new Command(MyEventCmd.EVENT_TAKEDEAL);
        //                    _ctx.Enqueue(cmd);
        //                }
        //            });
        //    }
        //}

        //protected override void RenderSortCards() {
        //    Desk desk = ((GameController)_controller).Desk;
        //    int count = 0;
        //    int i = 0;
        //    for (; i < _cards.Count; i++) {
        //        Sequence mySequence = DOTween.Sequence();
        //        mySequence.Append(_cards[i].Go.transform.DORotateQuaternion(Quaternion.Euler(-120.0f, -90.0f, 0.0f), _sortcardsdelta))
        //            .AppendCallback(() => {
        //                for (int j = 0; j < _cards.Count; j++) {
        //                    Vector3 dst = CalcPos(j);
        //                    _cards[j].Go.transform.localPosition = dst;
        //                }
        //            })
        //            .Append(_cards[i].Go.transform.DORotateQuaternion(_backv, _sortcardsdelta))
        //            .AppendCallback(() => {
        //                count++;
        //                if (count >= _cards.Count) {
        //                    UnityEngine.Debug.LogFormat("player right send sort cards.");
        //                    Command cmd = new Command(MyEventCmd.EVENT_SORTCARDSAFTERDEAL);
        //                    _ctx.Enqueue(cmd);
        //                }
        //            });
        //    }
        //}

        //protected override void RenderTakeXuanPao() {
        //}

        //protected override void RenderXuanPao() {
        //    _go.GetComponent<GL.Game.RightPlayer>().Head.ShowMark(string.Format("{0}", _fen));
        //}

        //protected override void RenderTakeFirstCard() {
        //    base.RenderTakeFirstCard();
        //    RenderTakeCard(() => {
        //        Command cmd = new Command(MyEventCmd.EVENT_TAKEFIRSTCARD);
        //        _ctx.Enqueue(cmd);
        //    });
        //}

        //protected override void RenderTakeXuanQue() {
        //}

        //protected override void RenderXuanQue() {
        //    if (_que == Card.CardType.Bam) {
        //        _go.GetComponent<GL.Game.RightPlayer>().Head.ShowMark("条");
        //    } else if (_que == Card.CardType.Crak) {
        //        _go.GetComponent<GL.Game.RightPlayer>().Head.ShowMark("万");
        //    } else if (_que == Card.CardType.Dot) {
        //        _go.GetComponent<GL.Game.RightPlayer>().Head.ShowMark("同");
        //    }
        //    RenderSortCardsToDo(_sortcardsdelta, () => {
        //    });
        //}

        //protected override void RenderTakeTurn() {
        //    base.RenderTakeTurn();

        //    if (_turntype == 1) {
        //        RenderTakeCard(() => { });
        //    } else if (_turntype == 0) {
        //        Vector3 dst = CalcPos(_cards.Count + 1);
        //        _holdcard.Go.transform.localRotation = _backv;

        //        Sequence mySequence = DOTween.Sequence();
        //        mySequence.Append(_holdcard.Go.transform.DOLocalMove(dst, _holddowndelta));
        //    }
        //}

        //protected override void RenderInsert(Action cb) {
        //    base.RenderInsert(cb);
        //}

        //protected override void RenderSortCardsAfterFly(Action cb) {
        //    base.RenderSortCardsAfterFly(cb);
        //}

        //protected override void RenderFly(Action cb) {
        //    base.RenderFly(cb);
        //}

        //protected override void RenderLead() {
        //    base.RenderLead();

        //    RenderLead1(RenderLead1Cb);
        //}

        //protected override void RenderClearCall() {
        //    _com.Head.CloseWAL();
        //}

        //protected override void RenderPeng() {
        //    base.RenderPeng();

        //    Desk desk = ((GameController)_controller).Desk;
        //    PGCards pg = _putcards[_putidx];
        //    UnityEngine.Debug.Assert(pg.Cards.Count == 3);
        //    float offset = _putrightoffset;
        //    for (int i = 0; i < _putidx; i++) {
        //        UnityEngine.Debug.Assert(_putcards[i].Width > 0.0f);
        //        offset += _putcards[i].Width + _putmargin;
        //    }

        //    _putmove = new Vector3(0.0f, 0.0f, 1.0f);
        //    for (int i = 0; i < pg.Cards.Count; i++) {
        //        float x = _putbottomoffset;
        //        float y = Card.Height / 2.0f + Card.HeightMZ;
        //        float z = 0.0f;
        //        if (i == pg.Hor) {
        //            x = desk.Width - (_putbottomoffset + Card.Width / 2.0f);
        //            z = desk.Length - (offset + Card.Length / 2.0f);
        //            offset += Card.Length;
        //            pg.Width += Card.Length;
        //            pg.Cards[i].Go.transform.localRotation = _uph;
        //        } else {
        //            x = desk.Width - (_putbottomoffset + Card.Length / 2.0f);
        //            z = desk.Length - (offset + Card.Width / 2.0f);
        //            offset += Card.Width;
        //            pg.Width += Card.Width;
        //            pg.Cards[i].Go.transform.localRotation = _upv;
        //        }
        //        pg.Cards[i].Go.transform.localPosition = new Vector3(x, y, z) - _putmove;
        //    }

        //    RenderPeng1();
        //}

        //protected override void RenderGang() {
        //    base.RenderGang();

        //    Desk desk = ((GameController)_controller).Desk;
        //    PGCards pg = _putcards[_putidx];
        //    UnityEngine.Debug.Assert(pg.Cards.Count > 0.0f);

        //    float offset = _putrightoffset;
        //    for (int i = 0; i < _putidx; i++) {
        //        UnityEngine.Debug.Assert(_putcards[i].Width > 0.0f);
        //        offset += _putcards[i].Width + _putmargin;
        //    }
        //    _putmove = new Vector3(0.0f, 0.0f, 1.0f);

        //    if (pg.Opcode == OpCodes.OPCODE_ZHIGANG) {
        //        for (int i = 0; i < pg.Cards.Count; i++) {
        //            float x = _putbottomoffset;
        //            float y = Card.Height / 2.0f + Card.HeightMZ;
        //            float z = 0.0f;
        //            if (i == pg.Hor) {
        //                x = desk.Width - (_putbottomoffset + Card.Width / 2.0f);
        //                z = desk.Length - (offset + Card.Length / 2.0f);
        //                offset += Card.Length;
        //                pg.Width += Card.Length;
        //                pg.Cards[i].Go.transform.localRotation = _uph;
        //            } else {
        //                x = desk.Width - (_putbottomoffset + Card.Length / 2.0f);
        //                z = desk.Length - (offset + Card.Width / 2.0f);
        //                offset += Card.Width;
        //                pg.Width += Card.Width;
        //                pg.Cards[i].Go.transform.localRotation = _upv;
        //            }
        //            pg.Cards[i].Go.transform.localPosition = new Vector3(x, y, z) - _putmove;
        //        }

        //        RenderGang1(() => {
        //            RenderSortCardsToDo(_sortcardsdelta, () => {
        //                Command cmd = new Command(MyEventCmd.EVENT_GANGCARD);
        //                _ctx.Enqueue(cmd);
        //            });
        //        });

        //    } else if (pg.Opcode == OpCodes.OPCODE_ANGANG) {
        //        for (int i = 0; i < pg.Cards.Count; i++) {
        //            float x = _putbottomoffset + Card.Length / 2.0f;
        //            float y = Card.Height / 2.0f + Card.HeightMZ;
        //            float z = desk.Length - (offset + Card.Width / 2.0f);
        //            offset += Card.Width;
        //            pg.Width += Card.Width;

        //            if (i == 0) {
        //                pg.Cards[i].Go.transform.localRotation = _upv;
        //            } else {
        //                pg.Cards[i].Go.transform.localRotation = _downv;
        //            }
        //            pg.Cards[i].Go.transform.localPosition = new Vector3(x, y, z) - _putmove;
        //        }

        //        RenderGang1(() => {
        //            if (pg.Cards[3].Value == _holdcard.Value) {
        //                RenderSortCardsToDo(_sortcardsdelta, () => {
        //                    Command cmd = new Command(MyEventCmd.EVENT_GANGCARD);
        //                    _ctx.Enqueue(cmd);
        //                });
        //            } else {
        //                if (_holdcard.Pos == (_cards.Count - 1)) {
        //                    RenderSortCardsToDo(_sortcardsdelta, () => {
        //                        Command cmd = new Command(MyEventCmd.EVENT_GANGCARD);
        //                        _ctx.Enqueue(cmd);
        //                    });
        //                } else {
        //                    RenderFly(() => {
        //                        Command cmd = new Command(MyEventCmd.EVENT_GANGCARD);
        //                        _ctx.Enqueue(cmd);
        //                    });
        //                }
        //            }
        //        });

        //    } else if (pg.Opcode == OpCodes.OPCODE_BUGANG) {
        //        float x = _putbottomoffset + Card.Width / 2.0f + Card.Width;
        //        float y = Card.Height / 2.0f;
        //        float z = desk.Length - (offset + Card.Width * pg.Hor + Card.Width / 2.0f);
        //        pg.Cards[3].Go.transform.localPosition = new Vector3(x, y, z) - _putmove;
        //        pg.Cards[3].Go.transform.localRotation = _uph;

        //        RenderGang1(() => {
        //            if (_holdcard.Value == pg.Cards[3].Value) {
        //                _holdcard = null;
        //                Command cmd = new Command(MyEventCmd.EVENT_GANGCARD);
        //                _ctx.Enqueue(cmd);
        //            } else {
        //                RenderFly(() => {
        //                    Command cmd = new Command(MyEventCmd.EVENT_GANGCARD);
        //                    _ctx.Enqueue(cmd);
        //                });
        //            }
        //        });
        //    }
        //}

        //protected override void RenderGangSettle() {
        //    long chip = 0;
        //    long left = 0;
        //    if (_settle.Count > 0) {
        //        for (int i = 0; i < _settle.Count; i++) {
        //            chip += _settle[i].Chip;
        //            left = _settle[i].Left > left ? _settle[i].Left : left;
        //        }
        //        _chip = (int)left;
        //        _com.Head.SetGold(_chip);
        //        _com.Head.ShowWAL(string.Format("{0}", chip));
        //    }
        //}

        //protected override void RenderHu() {
        //    base.RenderHu();

        //    int idx = _hucards.Count - 1;
        //    Card card = _hucards[idx];

        //    Desk desk = ((GameController)_controller).Desk;
        //    float x = desk.Width - (_hubottomoffset + Card.Length / 2.0f);
        //    float y = Card.Height / 2.0f;
        //    float z = desk.Length - (_hurightoffset + Card.Width / 2.0f + Card.Width * idx);
        //    _go.transform.localPosition = new Vector3(x, y, z);
        //    _go.transform.localRotation = _upv;

        //    ((GameController)_controller).Desk.RenderChangeCursor(new Vector3(x, y + desk.CurorMH, z));

        //    _com.Head.SetHu(true);

        //    Sequence mySequence = DOTween.Sequence();
        //    mySequence.AppendInterval(1.0f)
        //        .AppendCallback(() => {
        //            Command cmd = new Command(MyEventCmd.EVENT_HUCARD);
        //            _ctx.Enqueue(cmd);
        //        });
        //}

        //protected override void RenderHuSettle() {
        //    long chip = 0;
        //    long left = 0;
        //    if (_settle.Count > 0) {
        //        for (int i = 0; i < _settle.Count; i++) {
        //            chip = _settle[i].Chip;
        //            left = _settle[i].Left > left ? _settle[i].Left : left;
        //        }
        //        _com.Head.SetGold((int)left);
        //        _com.Head.ShowWAL(string.Format("{0}", chip));
        //    }
        //}

        //protected override void RenderOver() {

        //    RenderOverShen((Action act) => {
        //        _oknum = 0;
        //        Desk desk = ((GameController)_controller).Desk;
        //        for (int i = 0; i < _cards.Count; i++) {
        //            float x = desk.Width - (_bottomoffset + Card.Height / 2.0f);
        //            float y = Card.Height / 2.0f;
        //            float z = _leftoffset + Card.Width * i + Card.Width / 2.0f;
        //            _cards[i].Go.transform.DOLocalMove(new Vector3(x, y, z), _fangdaopaidelta);
        //            Tween t3 = _cards[i].Go.transform.DOLocalRotateQuaternion(_upv, _fangdaopaidelta);

        //            Sequence mySequence3 = DOTween.Sequence();
        //            mySequence3.Append(t3)
        //                .AppendCallback(() => {
        //                    _oknum++;
        //                    if (_oknum >= _cards.Count) {
        //                        act();
        //                    }
        //                });
        //        }
        //    }, () => { });
        //}

        //protected override void RenderSettle() {
        //    long chip = 0;
        //    long left = 0;
        //    if (_settle.Count > 0) {
        //        SettlementItem item = _settle[0];
        //        if (item.TuiSui == 1) {
        //            _com.Head.SetGold((int)left);
        //            _com.Head.ShowWAL("退税");

        //            Sequence mySequence = DOTween.Sequence();
        //            mySequence.AppendInterval(1.0f)
        //                .AppendCallback(() => {
        //                    _com.Head.ShowWAL(string.Format("{0}", chip));
        //                })
        //            .AppendInterval(1.0f)
        //            .AppendCallback(() => {
        //                Command cmd = new Command(MyEventCmd.EVENT_SETTLE_NEXT);
        //                _ctx.Enqueue(cmd);
        //            });
        //        } else {
        //            Sequence mySequence = DOTween.Sequence();
        //            mySequence.AppendInterval(1.0f)
        //                .AppendCallback(() => {
        //                    Command cmd = new Command(MyEventCmd.EVENT_SETTLE_NEXT);
        //                    _ctx.Enqueue(cmd);
        //                });
        //        }
        //    }
        //}

        //protected override void RenderFinalSettle() {
        //    _com.Head.SetHu(false);
        //    _com.Head.CloseWAL();
        //    int max = (int)(_ctx.QueryService<GameService>(GameService.Name).Max);
        //    _com.OverWnd.SettleLeft(_idx, max, _settle);
        //}

        //protected override void RenderRestart() {
        //    _com.Head.SetHu(false);
        //    _com.Head.CloseWAL();
        //    _com.Head.SetReady(true);
        //}

        //protected override void RenderTakeRestart() {
        //    _com.Head.SetReady(false);
        //}

        //protected override void RenderSay() {
        //    _com.Say(_say);
        //}
    }
}
