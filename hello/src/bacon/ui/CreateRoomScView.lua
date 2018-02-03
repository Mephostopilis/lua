using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Maria.UIBase;
using Maria.Event;
using Bacon.Model;
using Bacon.GL.Util;
using Bacon.Event;

namespace Bacon.Model.CreateRoom {
    public class ScView : BaseView {

        

        private readonly Color _normal = new Color(123.0f / 255.0f, 87.0f / 255.0f, 9.0f / 255.0f);
        private readonly Color _pressed = new Color(168.0f / 255.0f, 39.0f / 255.0f, 7.0f / 255.0f);

        public void SendModfyCommand(string key, object value) {
            Command cmd = new Command(MyEventCmd.EVENT_MUI_MODIFYCREATE);
            Message msg = new Message();
            msg[key] = value;
            cmd.Msg = msg;
            Bacon.GL.Util.App.current.Enqueue(cmd);
        }

        public override void OnEnter(IBaseContext context) {
            base.OnEnter(context);


            CreateRoomModule createRoomModule = _baseContext as CreateRoomModule;

            if (createRoomModule.HuJiaoZhuanYi == 1) {
                _HuJiaoZhuanYi.SetActive(true);
                _HuJiaoZhuanYi.GetComponent<Toggle>().isOn = true;
                _HuJiaoZhuanYiLabel.GetComponent<Text>().color = _pressed;
            } else {
                _HuJiaoZhuanYi.SetActive(false);
                _HuJiaoZhuanYiLabel.GetComponent<Text>().color = _normal;
            }

            if (createRoomModule.ZiMo == 0) {
                _ZiMoBuJiaBei.GetComponent<Toggle>().isOn = true;
                _ZiMoBuJiaBeiLabel.GetComponent<Text>().color = _pressed;
                _ZiMoJiaDiLabel.GetComponent<Text>().color = _normal;
                _ZiMoJiaBeiLabel.GetComponent<Text>().color = _normal;

                //_ZiMoJiaDi.GetComponent<Toggle>().isOn = false;
                //_ZiMoJiaBei.GetComponent<Toggle>().isOn = false;
            } else if (createRoomModule.ZiMo == 1) {
                _ZiMoBuJiaBei.GetComponent<Toggle>().isOn = false;
                _ZiMoJiaDi.GetComponent<Toggle>().isOn = true;
                _ZiMoJiaBei.GetComponent<Toggle>().isOn = false;
            } else {
                _ZiMoBuJiaBei.GetComponent<Toggle>().isOn = false;
                _ZiMoJiaDi.GetComponent<Toggle>().isOn = false;
                _ZiMoJiaBei.GetComponent<Toggle>().isOn = true;
            }

            if (createRoomModule.DianGangHua == 0) {
                _DianGangHuaZiMo.GetComponent<Toggle>().isOn = true;
                _DianGangHuaDianPao.GetComponent<Toggle>().isOn = false;
            } else {
                _DianGangHuaZiMo.GetComponent<Toggle>().isOn = false;
                _DianGangHuaDianPao.GetComponent<Toggle>().isOn = true;
            }

            if (createRoomModule.DaiYaoJiu == 0) {
                _DaiYaoJiux4.GetComponent<Toggle>().isOn = true;
                _DuanYaoJiux2.GetComponent<Toggle>().isOn = false;
            } else {
                _DaiYaoJiux4.GetComponent<Toggle>().isOn = false;
                _DuanYaoJiux2.GetComponent<Toggle>().isOn = true;
            }

            if (createRoomModule.JiangDui == 0) {
                _JiangDuix8.GetComponent<Toggle>().isOn = true;
                _TianDiHux32.GetComponent<Toggle>().isOn = false;
            } else {
                _JiangDuix8.GetComponent<Toggle>().isOn = false;
                _TianDiHux32.GetComponent<Toggle>().isOn = true;
            }

            if (createRoomModule.Top == 8) {
                _Top8.GetComponent<Toggle>().isOn = true;
                _Top16.GetComponent<Toggle>().isOn = false;
                _Top32.GetComponent<Toggle>().isOn = false;
            } else {
                _Top8.GetComponent<Toggle>().isOn = false;
                _Top16.GetComponent<Toggle>().isOn = true;
                _Top32.GetComponent<Toggle>().isOn = false;
            }

            if (createRoomModule.Ju == 8) {
                _Ju8.GetComponent<Toggle>().isOn = true;
                _Ju16.GetComponent<Toggle>().isOn = false;
            } else {
                _Ju8.GetComponent<Toggle>().isOn = false;
                _Ju16.GetComponent<Toggle>().isOn = true;
            }
        }

        public override void OnExit(IBaseContext context) {
            base.OnExit(context);
        }

        public override void OnPause(IBaseContext context) {
            base.OnPause(context);
        }

        public override void OnResume(IBaseContext context) {
            base.OnResume(context);
        }

  
    }
}