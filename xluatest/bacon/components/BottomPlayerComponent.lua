local MakeComponent = require('entitas.MakeComponent')

local BottomPlayerComponent = MakeComponent("bottomPlayer",
	"leadCard",         -- 作为出牌检测, 出的牌的本地索引
	"xuanPao",
	"xuanQue"
)

return BottomPlayerComponent