local MakeComponent = require('entitas.MakeComponent')

return MakeComponent("rule",
              -- 房间信息
              "type",  -- public GameType 
              "roomid", --    // 房间id
              "max",   --       // 房间最多人数

              "first",         --     // 房间玩家起始索引
              "last",        --      // 房间玩家结束索引

              "myidx",     --     // 我的索引
              "host",       -- // 是否是房主

              "online",   --   // 在线人数，主要用来判断已经加入的人是否掉线
              "joined",   --   // 用来判断房间设计的人数是否已经满足

              "gamestate",   --public GameState
              "fixedReady",         ------   // 是否在ready状态的时候显示了该显示的。
              "tmpidx",      --            // 临时索引，可能由于其他原因，而打乱curidx的顺序，所以，另外起一个//public long

              "firstidx",               ------    // 第一个拿牌的人，网络索引
              "firsttake",             ------ // 第一个被那牌的人，网络索引
              "firstcard",             ---      // 发完牌后第个人哪的一张牌
              "dice1",                 --  // 第一颗色子的值
              "dice2",                 --   // 第二颗色子的值

        "curidx ",
        "curtake",
        "curcard",
        "lastidx",              ------// 出牌上个人
        "lastCard",         ------  // 刚才出的牌

        "oknum",
        "take1time",
        "takeround",
        "takepoint",
        "huscount",
        "huIdxs",            -- vector

        "settles",
        "settlesidx"
)
