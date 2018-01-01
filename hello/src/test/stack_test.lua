local stack = require "chestnut.stack"

local s = stack()


for i=1,10 do
	s:push(i)
end

print(#s)

for i=1,100 do
	print(s:pop())
end

for i=1,5 do
	s:push(i)
end

print(#s)