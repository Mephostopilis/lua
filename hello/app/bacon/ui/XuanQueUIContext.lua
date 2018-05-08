local XuanQueView = require "bacon.ui.XuanQueView"

local cls = class("XuanQueUIContext")

function cls:ctor(app, ... )
    -- body
    self.app = app
    self.view = XuanQueView.new(self)
end

function cls:RenderViewEnter( ... )
    -- body
end

return cls

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using Maria;
using Maria.UIBase;
using Maria.Res;
using Maria.Event;
using Bacon.Event;
using Bacon.Game;
using Bacon.Model.Join;

namespace Bacon.Model.GameUI {
    class XuanQueUIController : UIController {
        public XuanQueUIController() {
            EventListenerCmd listener7 = new EventListenerCmd(MyEventCmd.EVENT_XUANQUE, OnQue);
            Director.Instance.EventDispatcher.AddCmdEventListener(listener7);
        }

        public override void RenderViewEnter() {
            if (View == null) {
                GameObject original = ABLoader.current.LoadAsset<GameObject>("UI", "ScXuanQueView");
                GameObject go = GameObject.Instantiate<GameObject>(original);
                View = go.GetComponent<XuanQueView>();
                Transform transform = Controller.BuiCanvas.transform;
                View.transform.SetParent(transform);
                View.OnEnter(this);
            } else {
                View.OnEnter(this);
            }
        }

        
    }
}
