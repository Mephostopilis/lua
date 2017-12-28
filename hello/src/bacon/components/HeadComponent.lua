using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Entitas;
using Bacon.UI.Head;

namespace Entitas.Components.Game {

    [Game]
    public class HeadComponent : IComponent {
        public HeadUIController headUIController;
    }
}
