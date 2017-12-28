using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Entitas;

namespace Entitas.Components.Game {

    [Game]
    public sealed class DiceComponent : IComponent {
        public long index = 0; // 0 左， 1右
        public long dian  = 0;
    }

}