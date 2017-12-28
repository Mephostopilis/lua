using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Bacon.Game;
using Entitas;
using UnityEngine;

namespace Entitas.Components.Game {
    [Game]
    public sealed class PlayerComponent : IComponent {

        public long uid;
        public long subid;
        public long idx;
        public long sex; // 1, 男； 0， 女
        public long chip;
        public string name;
        public Player.Orient orient;

        public bool loadedHand;
        public GameObject go;
    }

}