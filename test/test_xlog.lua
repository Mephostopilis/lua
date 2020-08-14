local lu = require "luaunit"
local xlog = require "xlog.host"
-- require "signal"
-- signal.signal("SIGTERM", function() print('hell') end);

TestXlog = {}

function TestXlog:setUp( ... )
    -- body
    self.logger = xlog('logs/../logs/default', 1024, 0, 0)
end

function TestXlog:tearDown()
    for i=1,100000000 do
        self.logger:check()
        self.logger:flush()
    end
end

function TestXlog:test1_log( ... )
    -- body
    self.logger()
    for i=1,100000 do
        self.logger:log(1, 'test info\n')
    end
end

-- function TestXlog:test1_check( ... )
--     -- body
--     -- for i=1,100000 do
--     --     self.logger:check()
--     -- end
-- end

-- logger:debug('test debug')
-- logger:warning('test warning')
-- logger:error('test error')
-- logger:fatal('test fatal')
local runner = lu.LuaUnit.new()
runner:setOutputType("tap")
runner:runSuite()
-- os.exit(  )