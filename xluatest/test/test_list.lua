local lu = require('test.luaunit')
local list = require "list"

local l = list()

l:foreach(function (i, ... )
	-- body
	assert(i)
end)

for i=1,100 do
	l:push_back(i)
end

assert(l.size == 100)
local v = l:pop_front()
assert(v == 1)
-- l:foreach(function (i, ... )
-- 	-- body
-- 	print(i.i)
-- end)

-- for i=1,200 do
-- 	l:pop_front()
-- end

-- l:foreach(function (i, ... )
-- 	-- body
-- 	print(i.i)
-- end)