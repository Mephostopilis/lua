using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Bacon.Game {
    class OpCodes {
        public static long OPCODE_NONE = 0;
        public static long OPCODE_PENG = 1 << 0;
        public static long OPCODE_GANG = 1 << 1;
        public static long OPCODE_HU = 1 << 2;
        public static long OPCODE_GUO = 1 << 3;
    }
}
