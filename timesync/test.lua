package.path = ".\\lualib\\?.lua;" .. package.path
package.cpath = ".\\luaclib\\?.dll;.\\luaclib\\?.so;" .. package.cpath

local timesync = require "timesync"
-- local unpack = require "timesync.unpack"
-- local rb = unpack()
-- local hello = timesync.pack("pg", "hello")
-- local world = timesync.pack("pg", "world")
-- print(rb:memcpy_buffer(hello))
-- print(rb:memcpy_buffer(world))
-- print(rb:get_string())
-- print(rb:get_string())
