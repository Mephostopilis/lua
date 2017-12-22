using Maria;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using Entitas;

namespace Bacon.Game {
    public class Card {

        public static float Width = 0.074f;
        public static float Height = 0.054f;
        public static float Length = 0.1f;
        public static float HeightMZ = 0.06f;

        public enum CardType {
            None = 0,
            Crak = 1,
            Bam = 2,
            Dot = 3,
        }

    }
}
