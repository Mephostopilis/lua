using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using Maria;
using Maria.UIBase;
using Bacon;
using Bacon.Game;

namespace Bacon.GameSystems.Over {
    class OverUIController : UIController {

        public enum Options {
            NONE = 0,
            SETTLE = 1 << 0,
        }

        public List<SettlementItem> list = new List<SettlementItem>();

        public OverUIController() { }


    }
}
