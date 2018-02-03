using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Maria.UIBase;
using Maria.Event;
using Bacon.Event;

namespace Bacon.Model.CreateRoom {
    public class SxView : BaseView {

        public void SendModfyCommand(string key, object value) {
            Command cmd = new Command(MyEventCmd.EVENT_MUI_MODIFYCREATE);
            Message msg = new Message();
            msg[key] = value;
            cmd.Msg = msg;
            Bacon.GL.Util.App.current.Enqueue(cmd);
        }

        public override void OnEnter(IBaseContext context) {
            base.OnEnter(context);
        }

        public override void OnExit(IBaseContext context) {
            base.OnExit(context);
        }

        public void OnBukehuqiduiChanged(bool value) {
            if (value) {
                SendModfyCommand("sxqidui", 1);
            }
        }

        public void OnHuqiduijiafanChanged(bool value) {
            if (value) {
                SendModfyCommand("sxqidui", 2);
            }
        }

        public void OnHuqiduibujiafanChanged(bool value) {
            if (value) {
                SendModfyCommand("sxqingyise", 1);
            }
        }

        public void OnQingyisejiafanChanged(bool value) {
            if (value) {
                SendModfyCommand("sxqingyise", 1);
            } else {
            }
        }

        public void OnJu8Changed(bool value) {
            if (value) {
                SendModfyCommand("ju", 8);
            }
        }

        public void OnJu16Changed(bool value) {
            if (value) {
                SendModfyCommand("ju", 16);
            }
        }
    }
}