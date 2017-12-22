using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Bacon.Game {
    public class PGCards {
        public long opcode;
        public long gangtype;
        public long hor;
        public float width;
        public List<GameEntity> cards;
        public bool isHoldcard;
        public bool isHoldcardInsLast;
    }
}
