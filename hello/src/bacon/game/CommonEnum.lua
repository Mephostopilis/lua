using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bacon.Game {
    public enum GameType {
        NONE = 0,
        GAME = 1,
        PLAY = 2,
    }

    public enum GameState {
        NONE = 0,
        START = 1,
        CREATE = 2,
        JOIN = 3,
        READY = 4,
        SHUFFLE = 5,
        DICE = 6,
        XUANPAO = 7,
        XUANQUE = 8,
        TURN = 9,
        LEAD = 10,

        MCALL = 11,
        OCALL = 12,
        PENG = 13,
        GANG = 14,
        HU = 15,

        OVER = 16,
        SETTLE = 17,
        RESTART = 18
    }

    

    public enum GangType {
        NONE = 0,
        BUGANG = 1 << 1,
        ZHIGANG = 1 << 2,
        ANGANG = 1 << 3,
    }
}
