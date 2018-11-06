local stack = require "chestnut.stack"

local s = stack()


for i=1,10 do
	s:push(i)
end

print(#s)

