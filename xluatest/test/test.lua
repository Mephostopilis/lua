package.path = ".\\lualib\\?.lua;" .. package.path

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
print('[[ -------------- TEST LIST -------------- ]]')
-- require "test_list"
print('[[ -------------- TEST TIMER -------------- ]]')
-- require "test_timer"
print('[[ -------------- TEST RANDOM -------------- ]]')
-- require "test_random"
print('[[ -------------- TEST QUEUE -------------- ]]')
-- require "test.test_chestnut"
print('[[ -------------- TEST ENTITIES -------------- ]]')
-- require "test.test_entity_system"
require "test.test_xluasocket"
-- require "test.client"
print('[[ -------------- TEST NETWORK -------------- ]]')
-- require "test.test_network"
print('[[ -------------- TEST RAPIDJSON -------------- ]]')
-- require "test.test_dbpack"

-- os.execute("pause")