local function abc()
	-- body
	error("abc")
end

pcall(abc)

local _M = {}

local abc = 1
local cbd = 1

function _M:abc( a, b )
	-- body
	abc = 2
	cbd = 3
	return a + b
end

function _M:print( fmt, ... )
	-- body
	print(fmt, ...)
end

local function abc( a, b )
	-- body
	error("hello world")
	print(a, b)
	return a, b
end

abc(2, 4)

return abc