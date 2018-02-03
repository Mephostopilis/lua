local EventDispatcher = require "maria.event.EventDispatcher"

local cls = class("JoinView")

function cls:ctor( ... )
    -- body
    self._RoomNum = ""
    self._count = 0
    self._max = 0
    self._num = 0

end

return cls

-- using System.Collections;
-- using System.Collections.Generic;
-- using UnityEngine;
-- using UnityEngine.UI;
-- using Maria;
-- using Maria.UIBase;
-- using Bacon;
-- using Bacon.Event;
-- using Maria.Util;
-- using Maria.Event;

-- namespace Bacon.Model.Join {
--     public class JoinView : BaseView {

--         public Text _RoomNum;
--         private int _count = 0;
--         private const int _max = 6;
--         private int _num = 0;
--         private string _numstr = string.Empty;
--         private bool _sended;

--         private string _tips = "请输入六位数字";
--         private JoinModule _context;

--         public override void OnEnter(IBaseContext context) {
--             base.OnEnter(context);
--             _context = context as JoinModule;
--             _RoomNum.text = _tips;
--             _count = 0;
--             _num = 0;
--             _numstr = string.Empty;
--             _sended = false;

--             RectTransform rectTransform = transform as RectTransform;
--             rectTransform.pivot = new Vector2(0.5f, 0.5f);
--             rectTransform.anchorMax = new Vector2(0.5f, 0.5f);
--             rectTransform.anchorMin = new Vector2(0.5f, 0.5f);

--             rectTransform.localScale = Vector3.one;
--             rectTransform.anchoredPosition3D = Vector3.zero;
       
--             //rectTransform.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Top, 0, 750);
--             //rectTransform.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Bottom, 0, 750);
--             //rectTransform.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Left, 0, 1334);
--             //rectTransform.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Right, 0, 1334);

--         }

--         public override void OnClose() {
--             Command cmd = new Command(MyEventCmd.EVENT_JOIN_CLOSE, gameObject);
--             Bacon.GL.Util.App.current.Enqueue(cmd);
--         }

--         private void AddNum(int num) {
--             if (_count >= _max) {
--                 return;
--             }
--             _num *= 10;
--             _num += num;
--             _numstr += string.Format("{0}", num);
--             _RoomNum.text = _numstr;
--             _count++;
--         }

--         public void OnBtn1() {
--             AddNum(1);
--         }

--         public void OnBtn2() {
--             AddNum(2);
--         }

--         public void OnBtn3() {
--             AddNum(3);
--         }

--         public void OnBtn4() {
--             AddNum(4);
--         }

--         public void OnBtn5() {
--             AddNum(5);
--         }

--         public void OnBtn6() {
--             AddNum(6);
--         }

--         public void OnBtn7() {
--             AddNum(7);
--         }

--         public void OnBtn8() {
--             AddNum(8);
--         }

--         public void OnBtn9() {
--             AddNum(9);
--         }

--         public void OnBtn0() {
--             AddNum(0);
--         }

--         public void OnBtnDel() {
--             if (_count > 0) {
--                 _num /= 10;
--                 _numstr = _numstr.Remove(_numstr.Length - 1);
--                 _RoomNum.text = _numstr;
--                 _count--;
--                 if (_count <= 0) {
--                     _RoomNum.text = _tips;
--                 }
--             }
--         }

--         public void OnBtnClr() {

--             _RoomNum.text = _tips;
--             _count = 0;
--             _num = 0;
--             _numstr = string.Empty;
--         }

--         public void OnJoin() {
--             if (_RoomNum == null) {
--                 return;
--             }
--             if (_sended) {
--                 return;
--             }
--             if (_count == _max) {

--                 Message msg = new Message();
--                 msg["roomid"] = _num;

--                 Command cmd = new Command(MyEventCmd.EVENT_MUI_JOIN, gameObject, msg);
--                 Bacon.GL.Util.App.current.Enqueue(cmd);
--                 _sended = true;
--             }
--         }
--     }
-- }