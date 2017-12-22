using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Maria;
using Maria.Res;
using Maria.UIBase;
using Maria.Util;
using Bacon.Game;
using Bacon.Event;
using Bacon.Model.Settle;

namespace Bacon.GameSystems.Over {

    public class OverWnd : BaseWnd {

        public GameObject _Bottom;
        public GameObject _Left;
        public GameObject _Top;
        public GameObject _Right;

        public override void OnEnter(IBaseContext context) {
            base.OnEnter(context);

        }

        // Use this for initialization
        void Start() {
        }

        // Update is called once per frame
        void Update() {
        }

        public void OnNext() {
            Close();
            Command cmd = new Command(MyEventCmd.EVENT_RESTART);
            Bacon.GL.Util.App.current.Enqueue(cmd);
        }

        public void Show() {
            if (!gameObject.activeSelf) {
                gameObject.SetActive(true);
            }
        }

        public void Close() {
            if (gameObject.activeSelf) {
                gameObject.SetActive(false);
            }
        }

        private void AddSettleItem(int idx, int max, GameObject go, List<SettlementItem> li) {
            GameObject label = ABLoader.current.LoadAsset<GameObject>("Prefabs/Controls", "SettleItem");

            //for (int i = 0; i < li.Count; i++) {
            //    GameObject l = GameObject.Instantiate<GameObject>(label);

            //    string cause = string.Empty;
            //    string multiple = string.Empty;
            //    string fen = string.Empty;
            //    string who = string.Empty;

            //    long xia = li[i].Idx + 1;
            //    xia = xia > max ? xia - max : xia;
            //    long dui = li[i].Idx + 2;
            //    dui = dui > max ? dui - max : dui;
            //    long sha = li[i].Idx + 3;
            //    sha = sha > max ? sha - max : sha;

            //    if (li[i].Gang == OpCodes.OPCODE_GANG) {
            //        if (li[i].Gang == OpCodes.OPCODE_BUGANG) {
            //            cause += "补杠";
            //        } else if (li[i].Gang == OpCodes.OPCODE_ANGANG) {
            //            cause += "暗杠";
            //        } else if (li[i].Gang == OpCodes.OPCODE_ZHIGANG) {
            //            cause += "直杠";
            //        }
            //        fen = string.Format("{0}", li[i].Chip);

            //        if (li[i].Idx == li[i].Win[0]) {
            //            // 赢家
            //            for (int j = 0; j < li[i].Lose.Count; j++) {
            //                if (xia == li[i].Lose[j]) {
            //                    if (who.Length > 0) {
            //                        who += ",下家";
            //                    } else {
            //                        who += "下家";
            //                    }
            //                } else if (dui == li[i].Lose[j]) {
            //                    if (who.Length > 0) {
            //                        who += ",对家";
            //                    } else {
            //                        who += "对家";
            //                    }
            //                } else if (sha == li[i].Lose[j]) {
            //                    if (who.Length > 0) {
            //                        who += ",上家";
            //                    } else {
            //                        who += "上家";
            //                    }
            //                }
            //            }
            //        } else if (li[i].TuiSui == 1) {
            //            for (int j = 0; j < li[i].Win.Count; j++) {
            //                if (xia == li[i].Win[j]) {
            //                    if (who.Length > 0) {
            //                        who += ",下家";
            //                    } else {
            //                        who += "下家";
            //                    }
            //                } else if (dui == li[i].Win[j]) {
            //                    if (who.Length > 0) {
            //                        who += ",对家";
            //                    } else {
            //                        who += "对家";
            //                    }
            //                } else if (sha == li[i].Win[j]) {
            //                    if (who.Length > 0) {
            //                        who += ",上家";
            //                    } else {
            //                        who += "上家";
            //                    }
            //                }
            //            }
            //        }
            //    } else if (li[i].HuCode != HuType.NONE) {
            //        for (int j = 0; j < li[i].Lose.Count; j++) {
            //            if (xia == li[i].Lose[j]) {
            //                if (who.Length > 0) {
            //                    who += ",下家";
            //                } else {
            //                    who += "下家";
            //                }
            //            } else if (dui == li[i].Lose[j]) {
            //                if (who.Length > 0) {
            //                    who += ",对家";
            //                } else {
            //                    who += "对家";
            //                }
            //            } else if (sha == li[i].Lose[j]) {
            //                if (who.Length > 0) {
            //                    who += ",上家";
            //                } else {
            //                    who += "上家";
            //                }
            //            }
            //        }

            //    }

            //    l.GetComponent<SettleItem>().Init(cause, multiple, fen, who);

            //}
        }

        public void SettleBottom(int idx, int max, List<SettlementItem> li) {
            AddSettleItem(idx, max, _Bottom, li);
        }

        public void SettleLeft(int idx, int max, List<SettlementItem> li) {
            AddSettleItem(idx, max, _Left, li);
        }

        public void SettleTop(int idx, int max, List<SettlementItem> li) {
            AddSettleItem(idx, max, _Top, li);
        }

        public void SettleRight(int idx, int max, List<SettlementItem> li) {
            AddSettleItem(idx, max, _Right, li);
        }

    }
}