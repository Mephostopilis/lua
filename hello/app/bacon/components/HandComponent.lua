local MakeComponent = require('entitas.MakeComponent')

return MakeComponent("hand",
              "rhand",                                     -- GameObject 
              "lhand",                                     -- GameObject
              "rhandinitpos",                              -- CS.UnityEngine.Vector3
              "rhandinitrot",                              -- public Quaternion 
              "rhanddiuszoffset",
              "rhandtakeoffset",
              "rhandleadoffset",
              "rhandnaoffset",
              "rhandpgoffset",
              "rhandhuoffset",
              "lhandinitpos",
              "lhandinitrot",
              "lhandhuoffset",
              "diushaizishendelta",
              "diushaizishoudelta",
              "chupaishendelta",
              "chupaishoudelta",
              "napaishendelta",           --     // 拿牌伸手消耗的时间s
              "fangpaishoudelta",
              "hupaishendelta",
              "hupaishoudelta",
              "penggangshendelta",
              "penggangshoudelta"
)
