local MakeComponent = require('entitas.MakeComponent')

local LeadCardsComponent = MakeComponent("leadCards",
        "turntype",                                        -- integer   @  // 1: 只是拿一张牌
        "fen",                                                  -- integer   @  // 叫分的时候用
        "hasXuanQue"                               -- boolean @        // 判断本地选取
        public Card.CardType que;                // 叫缺的时候用
        public bool hashu = false;

        public Quaternion upv = Quaternion.identity;
        public Quaternion uph = Quaternion.identity;
        public Quaternion downv = Quaternion.identity;

        public Quaternion backvst = Quaternion.identity;
        public Quaternion backv = Quaternion.identity;

        public long cd;  // 当前倒计时

        //public  float holdleftoffset = 0.02f;

        public List<SettlementItem> settle = new List<SettlementItem>();
        public long wal;         // 赢的钱或者输的钱
        public long say;

        // 手
        public int oknum;


        public List<long> cs;
        public CallInfo call;

        public GameObject avatar;  // ui 头像

        "leadcard",                            -- integer @
        "isHoldCard",                       -- boolean
        "leadcardMove",                -- math3d.vector3
        "leadcardMoveDelta",      -- number
        "leadleftoffset",                    -- number
        "leadbottomoffset",            --  number
        "leadCards",                        -- vector
)

return LeadCardsComponent




-- using Bacon.Game;
-- using System;
-- using System.Collections.Generic;
-- using System.Linq;
-- using System.Text;
-- using System.Threading.Tasks;
-- using UnityEngine;

-- namespace Entitas.Components.Game {
--     [Game]
--     public sealed class PlayerCardComponent : IComponent {
--         public long turntype;                    // 1: 只是拿一张牌
--         public long fen;                         // 叫分的时候用
--         public bool hasXuanQue = false;                  // 判断本地选取
--         public Card.CardType que;                // 叫缺的时候用
--         public bool hashu = false;

--         public Quaternion upv = Quaternion.identity;
--         public Quaternion uph = Quaternion.identity;
--         public Quaternion downv = Quaternion.identity;

--         public Quaternion backvst = Quaternion.identity;
--         public Quaternion backv = Quaternion.identity;

--         public long cd;  // 当前倒计时

--         //public  float holdleftoffset = 0.02f;

--         public List<SettlementItem> settle = new List<SettlementItem>();
--         public long wal;         // 赢的钱或者输的钱
--         public long say;

--         // 手
--         public int oknum;


--         public List<long> cs;
--         public CallInfo call;

--         public GameObject avatar;  // ui 头像
--     }
-- }
