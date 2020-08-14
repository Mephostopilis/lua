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
print("[[ -------------- TEST LIST     -------------- ]]")
-- require "test_list"
print("[[ -------------- TEST TIMER    -------------- ]]")
-- require "test_timer"
print("[[ -------------- TEST RANDOM   -------------- ]]")
-- require "test_random"
print("[[ -------------- TEST QUEUE    -------------- ]]")
-- require "test.test_chestnut"
print("[[ -------------- TEST ENTITIES -------------- ]]")
-- require "test.test_entity_system"
-- require "test.client"
print("[[ -------------- TEST NETWORK  -------------- ]]")
require "test.test_network"
print("[[ -------------- TEST RAPIDJSON -------------- ]]")
-- require "test.test_dbpack"
print("[[ -------------- TEST PLIST -------------- ]]")
-- require "test.test_plist"
print("[[ -------------- TEST XLOG  -------------- ]]")
-- require "test.test_xlog"
print("[[ -------------- TEST XLUASOCKET  -------------- ]]")
-- require "test.test_xluasocket"
print("[[ -------------- TEST CLIENT  -------------- ]]")
-- require "test.test_client"
print("[[ -------------- TEST CO  -------------- ]]")
-- require "test.test_co"
print("[[ -------------- TEST ZSET  -------------- ]]")
-- require "test.test_zset"
print("[[ -------------- TEST react  -------------- ]]")
-- require "test.test_reactphysics3d"

-- os.execute("pause")
