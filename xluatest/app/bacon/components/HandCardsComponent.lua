local MakeComponent = require('entitas.MakeComponent')

return MakeComponent("handCards",
	"leftoffset",                  -- GameObject
    "bottomoffset",                -- GameObject
    "cards",                       -- CS.UnityEngine.Vector3
    "dealcarddelta",               -- public Quaternion
    "sortcardsdelta",
    "pgsortcardsdelta",
    "fangdaopaidelta"
)
