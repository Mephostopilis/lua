package.path = ".\\lualib\\?.lua;" .. package.path
package.cpath = ".\\luaclib\\?.dll;.\\luaclib\\?.so;" .. package.cpath

local timesync = require "timesync"
local unpack = require "timesync.ringbuf"
local rb = unpack()
local hello = timesync.pack("pg", "hello")
local world = timesync.pack("pg", "world")
timesync.send(hello)
timesync.send(world)
print(rb:memcpy_buffer(hello))
print(rb:memcpy_buffer(world))
print(rb:get_string())
print(rb:get_string())
