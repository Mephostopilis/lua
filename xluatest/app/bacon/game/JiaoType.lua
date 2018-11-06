using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Bacon.Game {
    class JiaoType {
        public static long NONE = 0;
        public static long PINGFANG = 1;       // 平胡，就是一般点炮
        public static long DIANGANGHUA = 2;    // 直杠后摸的牌胡
        public static long GANGSHANGPAO = 3;   // 别人杠后打的牌自己胡了
        public static long QIANGGANGHU = 4;

        public static long ZIGANGHUA = 5;
        public static long ZIMO = 6;
    }
}
