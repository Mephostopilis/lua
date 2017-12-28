using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Entitas;
using UnityEngine;
using Bacon.Game;

namespace Entitas.Components.Game {
    [Game]
    public sealed class HoldCardComponent : IComponent {
        public GameEntity holdCardEntity;                                           // 摸的那张牌,此值此牌本地索引
        public Vector3 holdNaMove = new Vector3(0.0f, Card.Length + 0.1f, 0.0f);  // 摸牌提牌的高度
        public float holdNaMovedelta = 0.1f;                                      // 摸牌提起来花费的时间

        public float holdflydelta = 0.3f;                                     // 出牌非摸的牌，摸牌移动到插入的位置花费时间
        public float holddowndelta = 0.3f;                                    // 摸牌时下放时花费的时间
        public float holdinsortcardsdelta = 0.3f;                             // 插入摸的那张牌整理牌时间
        public float holdafterpengdelta = 0.1f;                               // 在碰后把最右的牌拿出来
    }
}
