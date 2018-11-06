package.path = ".\\test\\?.lua;" .. package.path
package.path = ".\\app\\?.lua;" .. package.path
package.path = ".\\app\\lualib\\?.lua;.\\app\\lualib\\?\\init.lua;" .. package.path

if not cc then
	cc = {}
end
require "base.class"
require "base.ctype"
require "base.io"
require "base.math"
require "base.os"
require "base.string"
require "base.table"

class = cc.class

DEBUG_TEST = true

-- require "main"
print('TEST LIST --------------')
require "list_test"
print('TEST TIMER --------------')
require "timer_test"
-- require "random_test"
-- require "test.queue_test"
-- require "test.stack_test"
-- require "test.test_entity_system"
-- require "test.server"
-- require "test.client"
-- require "test.network_test"
-- require "test.dbpack_test"

-- os.execute("pause")