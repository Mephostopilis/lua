package.path = "?.lua;app/?.lua;app/lualib/?.lua;" .. package.path
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

local AppConfig = require "AppConfig"
local log = require "log"
local pcall = pcall
local xpcall = xpcall
local debug = debug
-- local list_test = require "list_test"
-- local stack_test = require "stack_test"

-- xlua.hotfix(CS.Maria.Application, 'XluaTest', function (self) 
-- 	CS.UnityEngine.Debug.Log('xlua hello world')
-- end)
local config
local uicontextmgr
local app


-- setup config
function SetupConfig( ... )
	-- body
	local ok, err = pcall(AppConfig.new)
	if ok then
		config = err
	else
		log.error(err)
	end
	return config
end

function CheckConfig( ... )
	-- body
	if config then
		config:LoadFile()
		if config:CheckConfig() then
			return true
		end
	end
	return false
end


-- setup app
function main( ... )
	-- body
	local UIContextManager = require "maria.uibase.UIContextManager"
	local ok, err = pcall(UIContextManager.new)
	if ok then
		app = err
		app.config = assert(config)
	else
		log.error(err)
	end

	local App = require "bacon.App"
	local ok, err = pcall(App.new)
	if ok then
		app = err
		app.config = assert(config)
	else
		log.error(err)
	end
end

function Startup( ... )
	-- body
	local App = require "bacon.App"
	local traceback = debug.traceback
	local ok, err = xpcall(App.Startup, traceback, app)
	if not ok then
		log.error(err)
	end
end

function Cleanup( ... )
	-- body
	app:Cleanup()
end

function Update(delta, ... )
	-- body
	local App = require "bacon.App"
	local traceback = debug.traceback
	local ok, err = xpcall(App.Update, traceback, app, delta)
	if not ok then
		log.error(err)
	end
end