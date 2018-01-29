local root = ".\\..\\hello\\src"
package.path = root .. "\\?.lua;" .. root .. "\\?\\init.lua;" .. package.path
package.path = root .. "\\lualib\\?.lua;" .. root .. "\\?\\init.lua;" .. package.path
package.path = root .. "\\lualib\\entitas\\?.lua;" .. root .. "\\entitas\\?\\init.lua;" .. package.path

-- print("hello world.")

-- require "main"
-- require "test.queue_test"
-- require "test.test_entity_system"
-- require "example_with_luaunit"
require "test.stack_test"

os.execute("pause")