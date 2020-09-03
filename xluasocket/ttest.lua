package.path = ".\\lualib\\?.lua;" .. package.path
package.cpath = ".\\luaclib\\?.dll;.\\luaclib\\?.so;" .. package.cpath

-- 测试1
-- 只是测试下方法能不能通过
-- local timesync = require "timesync"
-- local unpack = require "timesync.ringbuf"
-- local rb = unpack()
-- local hello = timesync.pack("pg", "hello")
-- local world = timesync.pack("pg", "world")
-- timesync.send(hello)
-- timesync.send(world)
-- print(rb:memcpy_buffer(hello))
-- print(rb:memcpy_buffer(world))
-- print(rb:get_string())
-- print(rb:get_string())

local function log(fmt, ...)
    local s = string.format(fmt, ...) .. "\n"
    print(s)
end

-- 测试2
-- 联合xluasocket line
local xluasocket = require "xluasocket"
local timesync = require "xluasocket.timesync"
local function testline(...)
    local map = {}
    local ic
    local cc
    local times = 10000

    local handle = function(t, id, ud, ...)
        if t == xluasocket.SOCKET_DATA then
            if id == ic.id then
                local so = map[id]
                if so then
                    -- print("rev", so.buf)
                    -- so.buf = timesync.cat(so.buf, ud)
                    so.buf = so.buf .. ud
                    -- print("rev", so.buf)
                    local line, left = timesync.unpack("pg", so.buf)
                    -- so.unpack = left
                    print("accept", line, left)
                    so.buf = left
                -- xluasocket.send(id, timesync.pack("line", line))
                end
            elseif id == cc.id then
            -- print("respone", line)
            end
        elseif t == xluasocket.SOCKET_OPEN then
            local subcmd = tostring(...)
            print("subcmd =>", subcmd)
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
                xluasocket.start(id)
                log("sokcet [id = %d][%d] connected [%s]", id, ud, subcmd)
            end
        elseif t == xluasocket.SOCKET_ACCEPT then
            local s = {}
            s.id = ud
            s.ok = false
            s.buf = ""
            map[ud] = s
            ic = s
            xluasocket.start(ud)
            log("sokcet accept [id = %d][acc = %d]", id, ud)
        elseif t == xluasocket.SOCKET_ERROR then
            log("socket error [id = %d][msg = %s]", id, tostring(...))
            map[id] = nil
        end
    end
    local err = xluasocket.init(handle)
    if err ~= 0 then
        error("new err = ", err)
    end

    -- server
    local err = xluasocket.listen("127.0.0.1", 3300)
    if err < 0 then
        error(string.format("id = %d listen failture.", err))
    else
        local s = {}
        s.id = err
        s.ok = false
        map[err] = s
        log("sokcet server [id = %d] do listen", err)
        xluasocket.start(err)
    end

    -- client
    local err = xluasocket.connect("127.0.0.1", 3300)
    if err < 0 then
        error(string.format("id = %d connect failture.", err))
    else
        local s = {}
        s.id = err
        s.ok = false
        s.buf = ""
        map[err] = s
        cc = s
        log(string.format("id = %d do connecting.", err))
    end

    while true do
        xluasocket.poll(1)
        if times > 0 then
            times = times - 1
            if cc and cc.ok then
                local err = xluasocket.send(cc.id, timesync.pack("pg", "hello"))
                if err == -1 then
                    error(string.format("id = %d send failtrue.", cc.id))
                else
                    print("send hello\n", times)
                end
                local err = xluasocket.send(cc.id, timesync.pack("pg", "world"))
                if err == -1 then
                    error(string.format("id = %d send failtrue.", cc.id))
                else
                    print("send world\n", times)
                end
            end
        end
    end
end

local ok, err = xpcall(testline, debug.traceback)
if not ok then
    log(err)
end

xluasocket.exit()
while xluasocket.poll() == 0 do
end
xluasocket.free()
print("over")
