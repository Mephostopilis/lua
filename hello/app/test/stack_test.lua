local lu = require "luaunit"

local stack = require "chestnut.stack"

TestStack = {}

function TestStack:setUp( ... )
	-- body
	self.s = stack()
end

function TestStack:test_push( ... )
	-- body
	for i=1,10 do
		self.s:push(i)
	end
	lu.assertEquals(#self.s, 10)
end

function TestStack:test_pop( ... )
	-- body
	for i=1,10 do
		self.s:pop()
	end
	lu.assertEquals(#self.s, 0)
	for i=1,100 do
		self.s:pop()
	end
	lu.assertEquals(#self.s, 0)
end

local runner = lu.LuaUnit.new()
runner:setOutputType("tap")
runner:runSuite()