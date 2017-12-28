using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Entitas;
using Entitas.CodeGeneration.Attributes;
using UnityEngine;
using Bacon.Game;

namespace Entitas.Components.Game {

    [Game]
    [Unique]
    public sealed class RuleComponent : IComponent {

        // 房间信息
        public GameType type;
        public long roomid = 0;    // 房间id
        public long max = 0;       // 房间最多人数

        public long first = 1;     // 房间玩家起始索引
        public long last = 4;      // 房间玩家结束索引

        public long myidx = 0;     // 我的索引
        public bool host = false;  // 是否是房主

        public long online = 0;    // 在线人数，主要用来判断已经加入的人是否掉线
        public long joined = 0;    // 用来判断房间设计的人数是否已经满足



        // 游戏数据
        public GameState gamestate = 0;
        public bool fixedReady = false;    // 是否在ready状态的时候显示了该显示的。
        //public long tmpidx = 0;            // 临时索引，可能由于其他原因，而打乱curidx的顺序，所以，另外起一个

        public long firstidx = 0;       // 第一个拿牌的人，网络索引
        public long firsttake = 0;      // 第一个被那牌的人，网络索引
        public long firstcard = 0;      // 发完牌后第个人哪的一张牌
        public long dice1 = 0;         // 第一颗色子的值
        public long dice2 = 0;         // 第二颗色子的值

        public long curidx = 0;
        public long curtake = 0;
        public long curcard = 0;
        public long lastidx = 0;       // 出牌上个人
        public long lastCard = 0;      // 刚才出的牌

        public int oknum = 0;
        public int take1time = 0;  // 1圈4次
        public int takeround = 0;  // 发牌时圈数
        public int takepoint = 0;  // 最多是6 
        public int huscount = 0;
        public List<long> huIdxs = new List<long>();

        public S2cSprotoType.settle settles = null;
        public int settlesidx = 0;

    }

}