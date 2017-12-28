using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace Entitas.Components.Game {
    [Game]
    public sealed class LeadCardsComponent : IComponent {
        public int leadcard;                         // 当前出的那张牌
        public bool isHoldCard;                      // 判断出的牌是否是holdcard
        public Vector3 leadcardMove = Vector3.one;   // 当前出牌时便宜值做动作移动
        public float leadcardMoveDelta = 0.0f;       // 出牌小动下

        public float leadleftoffset = 0.7f;
        public float leadbottomoffset = 0.7f;  // 偏移起始值
        public List<GameEntity> leadcards = new List<GameEntity>();
    }
}
