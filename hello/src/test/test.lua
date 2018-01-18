local root = ".\\..\\..\\..\\..\\hello\\src"
package.path = root .. "\\?.lua;" .. root .. "\\?\\init.lua;" .. package.path
package.path = root .. "\\lualib\\?.lua;" .. root .. "\\?\\init.lua;" .. package.path
package.path = root .. "\\lualib\\entitas\\?.lua;" .. root .. "\\entitas\\?\\init.lua;" .. package.path

-- require "test.queue_test"

-- print("hello world.")

-- require "main"
-- require "test.queue_test"
-- require "test.test_entity_system"
require "test.stack_test"

local m = {}
m[1] = 2
m[2] = 3
m[3] = 4

for i,v in ipairs(m) do
	print(i,v)
end

for k,v in pairs(m) do
	print(k,v)
end

os.execute("pause")