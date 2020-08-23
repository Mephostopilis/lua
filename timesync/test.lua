package.path = ".\\lualib\\?.lua;" .. package.path
package.cpath = ".\\luaclib\\?.dll;.\\luaclib\\?.so;" .. package.cpath

-- 测试1
-- 只是测试下方法能不能通过
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

local function log(fmt, ...)
    local s = string.format(fmt, ...) .. "\n"
    print(s)
end

-- 测试2
-- 联合xluasocket line
local xluasocket = require "xluasocket"
local function testline(...)
    local map = {}
    local cc
    local times = 1000

    local handle = function(t, id, ud, ...)
        if t == xluasocket.SOCKET_DATA then
            log("data: [id = %d][%s]", id, ...)
            if id == ic then
                local rb = map[ic]
                rb:memcpy_buffer(ud)
                local line = rb:get_line()
                print("accept", line)
                xluasocket.send(id, timesync.pack("line", line))
            elseif id == cc then
                print("respone", line)
            end
        elseif t == xluasocket.SOCKET_OPEN then
            local subcmd = tostring(...)
            if subcmd == "transfer" then
                -- connect start
                local so = map[id]
                so.ok = true
                log("sokcet transfer [id = %d][%d][%s]", id, ud, subcmd)
            elseif subcmd == "start" then
                -- log('sokcet connect [id = %d][%d][%s]', id, ud, subcmd)
                -- listen accept start
                log("sokcet start [id = %d][%d][%s]", id, ud, subcmd)
                local so = map[id]
                so.ok = true
            else
                print("server", id, "start")
                xluasocket.start(id)
            end
        elseif t == xluasocket.SOCKET_ACCEPT then
            log("sokcet accept [id = %d][acc = %d]", id, ud)
            local s = {}
            s.id = id
            s.ok = false
            s.unpack = unpack()
            map[id] = s
            xluasocket.start(ud)
        elseif t == xluasocket.SOCKET_ERROR then
            log("socket error [id = %d][msg = %s]", id, tostring(...))
            map[id] = nil
        end
    end
    local err = xluasocket.new(handle)
    if err ~= 0 then
        error("new err = ", err)
    end

    -- server
    local err = xluasocket.listen("127.0.0.1", 3300)
    if err < 0 then
        error(string.format("id = %d listen failture.", s))
    else
        local s = {}
        s.id = err
        s.ok = false
        s.unpack = unpack()
        map[err] = s
    end

    -- client
    local err = xluasocket.connect("127.0.0.1", 3300)
    if err < 0 then
        error(string.format("id = %d connect failture.", c))
    else
        local s = {}
        s.id = err
        s.ok = false
        s.unpack = unpack()
        map[err] = s
        cc = s
    end

    while true do
        xluasocket.poll()
        if times > 0 then
            times = times - 1
            if cc and cc.ok then
                local err = xluasocket.send(cc.id, "hello world")
                if err == -1 then
                    error(string.format("id = %d send failtrue.", cc.id))
                end
            end
        end
    end
end

local ok, err = xpcall(testline, debug.traceback)
if not ok then
    log(err)
end
