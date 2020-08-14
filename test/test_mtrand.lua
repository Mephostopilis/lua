local mtrand = require "mtrand"

local state = mtrand(5)


for i=1,100 do
	print(state:rand())
end

