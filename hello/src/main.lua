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
local log = require "log"
local pcall = pcall
-- local list_test = require "list_test"
-- local stack_test = require "stack_test"


-- xlua.hotfix(CS.Maria.Application, 'XluaTest', function (self) 
-- 	CS.UnityEngine.Debug.Log('xlua hello world')
-- end)
local app

function main( ... )
	-- body
	local ok, err = pcall(App.new)
	if ok then
		app = err
	else
		log.error(err)
	end
end

function Startup( ... )
	-- body
	local ok, err = pcall(App.Startup, app)
	if not ok then
		log.error(err)
	end
end

function Cleanup( ... )
	-- body
	app:Cleanup()
end
