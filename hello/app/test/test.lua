-- local root = ".\\..\\..\\..\\..\\hello\\src"
local root = ".\\..\\hello\\app"
package.path = ".\\..\\hello\\?.lua;" .. package.path
package.path = root .. "\\?.lua;" .. root .. "\\?\\init.lua;" .. package.path
package.path = root .. "\\lualib\\?.lua;" .. root .. "\\?\\init.lua;" .. package.path
package.path = root .. "\\lualib\\entitas\\?.lua;" .. root .. "\\entitas\\?\\init.lua;" .. package.path


require "main"
-- require "list_test"
-- require "timer_test"
-- require "random_test"
-- require "test.queue_test"
-- require "test.stack_test"
-- require "test.test_entity_system"
-- require "test.server"
-- require "test.client"
require "test.network_test"
-- require "test.dbpack_test"

os.execute("pause")