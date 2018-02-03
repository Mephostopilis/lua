local MakeComponent = require('entitas.MakeComponent')

local LeadCardsComponent = MakeComponent("leadCards",
        "turntype",                                        -- integer   @  // 1: 只是拿一张牌
        "fen",                                                  -- integer   @  // 叫分的时候用
        "hasXuanQue",                               -- boolean @        // 判断本地选取
        "que",                                                   -- Card.CardType @  // 叫缺的时候用
        "hashu",

        "upv"         -- public Quaternion 
        "uph"         -- Quaternion.identity;
        "downv"   -- Quaternion.identity;
        "backvst" -- = Quaternion.identity;
        "backv"      --= Quaternion.identity;

        "cd" ------  // 当前倒计时

        "holdleftoffset"

        "settle" -- = new List<SettlementItem>();
        "wal" ----------         // 赢的钱或者输的钱
        "say"

        ---// 手
        "oknum"          


        "cs"      -- vector<long>
        "call"

        "avatar"          --- // ui 头像

        "leadcard",                            -- integer @
        "isHoldCard",                       -- boolean
        "leadcardMove",                -- math3d.vector3
        "leadcardMoveDelta",      -- number
        "leadleftoffset",                    -- number
        "leadbottomoffset",            --  number
        "leadCards",                        -- vector
)

return LeadCardsComponent
