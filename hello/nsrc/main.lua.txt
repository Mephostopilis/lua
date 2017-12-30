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

local App = require "bacon.App"


-- xlua.hotfix(CS.Maria.Application, 'XluaTest', function (self) 
-- 	CS.UnityEngine.Debug.Log('xlua hello world')
-- end)
local app

function main( ... )
	-- body
	app = App.new()
end

function Startup( ... )
	-- body
	
	app:Startup()
end

function Cleanup( ... )
	-- body
	app:Cleanup()
end

if true then
	main()
	Startup()
end