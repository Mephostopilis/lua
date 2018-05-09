local lu = require "luaunit"

local navigation = require "navigation"

TestNav = {}

function TestNav:setUp( ... )
	-- body
	self.nav = navigation.new()
end

local runner = lu.LuaUnit.new()
runner:setOutputType("tap")
runner:runSuite()