local MakeComponent = require('entitas.MakeComponent')

local PlayerComponent = MakeComponent("player",
    "idx",
    "sex",
    "chip",
    "name",
    "orient",
    "loadedHand",
    "go",
    "state",
    "lastState",
    "que",
    "online"
)

return PlayerComponent
