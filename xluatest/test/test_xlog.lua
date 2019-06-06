local lu = require "luaunit"
local xlog = require "xlog.host"

TestXlog = {}

function TestXlog:setUp( ... )
    -- body
    self.logger = xlog('logs/../logs/default', 1024, 0, 0)
end

function TestXlog:tearDown()
    self.logger:flush()
    self.logger:close()
end

function TestXlog:test1_log( ... )
    -- body
    for i=1,100000 do
        self.logger:log('test info\n')
    end
end


-- logger:debug('test debug')
-- logger:warning('test warning')
-- logger:error('test error')
-- logger:fatal('test fatal')
local runner = lu.LuaUnit.new()
runner:setOutputType("tap")
os.exit( runner:runSuite() )