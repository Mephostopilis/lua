using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace Entitas.Components.Game {
    [Game]
    public sealed class HandCardsComponent : IComponent {
        public float leftoffset = 0.56f;
        public float bottomoffset = 0.1f;
        public List<GameEntity> cards = new List<GameEntity>();

        

        // 都是关于手上的牌
        public float dealcarddelta = 0.3f;         // 拿牌的时候，牌旋转到最适合的位置消耗的时间，单位s
        public float sortcardsdelta = 0.3f;        // 自己的牌排序通用花费时间
        public float pgsortcardsdelta = 0.3f;      // 碰杠后排序

        
        public float fangdaopaidelta = 0.3f;    // 牌局结束时放到动作
    }
}
