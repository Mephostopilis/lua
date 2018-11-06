local MakeComponent = require('entitas.MakeComponent')
local Card = require "bacon.game.Card"

local CardComponent = MakeComponent("card", 
    "value",                         -- integer
    "type",                          -- Card.CardType @三种类型
    "num",                            -- interger      @9种数字
    "idx",                            -- interger      @同类型同数字唯一标识
    "pos",                            -- integer        
    "que",                           -- boolean       @
    "parent",                         -- integer       @ 本地索引，指着那个玩家的本地索引
    "path",                          -- string   
    "name",                          -- string
    "go"                             -- GameObject
)

return CardComponent


-- namespace Entitas.Components.Game {
--     [Game]
--     public sealed class CardComponent : IComponent, IComparable<CardComponent> {

--         public long value;
--         public Card.CardType type;   // 三种类型
--         public int num;              // 9种数字
--         public int idx;              // 同类型同数字唯一标识
--         public int pos;
--         public bool que;
--         public int parent;           // 本地索引，指着那个玩家的本地索引
--         public string path;
--         public string name;
--         public GameObject go;

--         public override bool Equals(object obj) {
--             return base.Equals(obj);
--         }

--         public override int GetHashCode() {
--             return base.GetHashCode();
--         }

--         public override string ToString() {
--             string res = string.Empty;
--             res += "type:";
--             if (type == Card.CardType.Bam) {
--                 res += "条";
--             } else if (type == Card.CardType.Crak) {
--                 res += "万";
--             } else if (type == Card.CardType.Dot) {
--                 res += "筒";
--             }
--             res += string.Format("num:{0}", num);
--             return res;
--         }

--         public int CompareTo(CardComponent other) {
--             if (this.que == other.que) {
--                 return (int)(this.value - other.value);
--             } else if (que) {
--                 return -1;
--             } else {
--                 return 1;
--             }
--         }

--         public static bool operator ==(CardComponent lhs, CardComponent rhs) {
--             if (object.Equals(lhs, null) && object.Equals(rhs, null)) {
--                 return true;
--             } else if (!object.Equals(lhs, null) && object.Equals(rhs, null)) {
--                 return false;
--             } else if (object.Equals(lhs, null) && !object.Equals(rhs, null)) {
--                 return false;
--             }
--             return (lhs.type == rhs.type) && (lhs.num == rhs.num);
--         }

--         public static bool operator !=(CardComponent lhs, CardComponent rhs) {
--             return !(lhs == rhs);
--         }
--     }
-- }