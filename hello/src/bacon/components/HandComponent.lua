using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Entitas;
using UnityEngine;

namespace Entitas.Components.Game {
    [Game]
    public sealed class HandComponent : IComponent {

        public GameObject rhand = null;
        public GameObject lhand = null;
        public Vector3 rhandinitpos = Vector3.one;
        public Quaternion rhandinitrot = Quaternion.identity;
        public Vector3 rhanddiuszoffset = Vector3.zero;
        public Vector3 rhandtakeoffset = Vector3.one;
        public Vector3 rhandleadoffset = Vector3.one;
        public Vector3 rhandnaoffset = Vector3.one;
        public Vector3 rhandpgoffset = Vector3.zero;
        public Vector3 rhandhuoffset = Vector3.zero;

        public Vector3 lhandinitpos = Vector3.one;
        public Quaternion lhandinitrot = Quaternion.identity;
        public Vector3 lhandhuoffset = Vector3.zero;


        public float diushaizishendelta = 0.5f;
        public float diushaizishoudelta = 0.5f;
        public float chupaishendelta = 0.5f;
        public float chupaishoudelta = 0.5f;
        public float napaishendelta = 0.5f;     // 拿牌伸手消耗的时间s
        public float fangpaishoudelta = 0.5f;
        public float hupaishendelta = 0.5f;
        public float hupaishoudelta = 0.5f;
        public float penggangshendelta = 0.5f;
        public float penggangshoudelta = 0.5f;
    }
}
