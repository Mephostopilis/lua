using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Bacon.Game {
    public class SettlementItem {
        public long Idx { get; set; }
        public long Chip { get; set; }
        public long Opcode { get; set; }
        public List<long> Them { get; set; }
        
        public long GangType { get; set; }
        public long HuType { get; set; }
        public long JiaoType { get; set; }
        public bool HuaZhu { get; set; }
        public bool DaJiao { get; set; }
        public bool TuiSui { get; set; }
    }
}
