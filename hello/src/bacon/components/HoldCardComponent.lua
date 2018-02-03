local MakeComponent = require('entitas.MakeComponent')

return MakeComponent("holdCard",
              "holdCardEntity",                                          -- // 摸的那张牌,此值此牌本地索引
              "holdNaMove",        -- = new Vector3(0.0f, Card.Length + 0.1f, 0.0f);  // 摸牌提牌的高度
              "holdNaMovedelta",   --  = 0.1f;                                      // 摸牌提起来花费的时间

              "holdflydelta",                          ---                // 出牌非摸的牌，摸牌移动到插入的位置花费时间
              "holddowndelta",         --                                   // 摸牌时下放时花费的时间
              "holdinsortcardsdelta",                             // 插入摸的那张牌整理牌时间
              "holdafterpengdelta"                               // 在碰后把最右的牌拿出来
)