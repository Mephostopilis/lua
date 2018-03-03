local lu = require "luaunit"

local stack = require "chestnut.stack"
local assert = assert

local GLOBAL = _G

GLOBAL.test_collector =  function()
	local s = stack(1, 2, 3, 4)
	assert(#s == 4)
	local find = false
	for _,v in pairs(s) do
		if v == 4 then
			find = true
		end
	end
	assert(find)

	for i=1,10 do
		s:push(i)
	end
	assert(#s == 14)
end

local runner = lu.LuaUnit.new()
runner:setOutputType("tap")
local ret = runner:runSuite()
if 0 == ret then
    print("test_stack success with result "..ret)
else
    print("test_stack failed with result "..ret)
end

