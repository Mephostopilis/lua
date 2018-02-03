local MakeComponent = require('entitas.MakeComponent')

return MakeComponent("hand",
              "leftoffset",                                     -- GameObject 
              "bottomoffset",                                     -- GameObject
              "cards",                       -- CS.UnityEngine.Vector3
              "dealcarddelta",                          -- public Quaternion 
              "sortcardsdelta",
              "pgsortcardsdelta",
              "fangdaopaidelta",
)
