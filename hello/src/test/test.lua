-- local root = ".\\..\\..\\..\\..\\hello\\src"
local root = ".\\..\\hello\\src"
package.path = root .. "\\?.lua;" .. root .. "\\?\\init.lua;" .. package.path
package.path = root .. "\\lualib\\?.lua;" .. root .. "\\?\\init.lua;" .. package.path
package.path = root .. "\\lualib\\entitas\\?.lua;" .. root .. "\\entitas\\?\\init.lua;" .. package.path

-- require "test.queue_test"

-- print("hello world.")

-- require "main"
-- require "test.queue_test"
-- require "test.test_entity_system"
require "test.server"
-- require "test.client"

os.execute("pause")