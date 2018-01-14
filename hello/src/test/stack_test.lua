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

local m = {}

m[1] = 1
m[2] = 2
m[3] = 3

for i,v in ipairs(m) do
	print(i,v)
end

for k,v in pairs(m) do
	print(k,v)
end