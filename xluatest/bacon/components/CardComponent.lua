local MakeComponent = require('entitas.MakeComponent')
local Card = require "bacon.game.Card"

local CardComponent = MakeComponent("card", 
    "value",                         -- integer
    "type",                          -- Card.CardType @三种类型
    "num",                           -- interger      @9种数字
    "idx",                           -- interger      @同类型同数字唯一标识
    "pos",                           -- integer        
    "que",                           -- boolean       @
    "parent",                        -- integer       @ 本地索引，指着那个玩家的本地索引
    "path",                          -- string   
    "name",                          -- string
    "go"                             -- GameObject
)

return CardComponent
