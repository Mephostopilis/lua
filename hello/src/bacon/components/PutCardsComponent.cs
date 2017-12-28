using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Entitas;
using UnityEngine;
using Bacon.Game;

namespace Entitas.Components.Game {

    public  sealed class PutCardsComponent : IComponent {
        public float putmovedelta = 0.1f;
        public float putmargin = 0.02f;
        public Vector3 putmove = Vector3.zero;
        public float putrightoffset = 0.1f;
        public float putbottomoffset = 0.1f;
        public int putidx = 0;
        public List<PGCards> putcards = new List<PGCards>();
    }
}
