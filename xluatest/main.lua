package.path = "?.lua;.\\lualib\\?.lua;" .. package.path
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

local configmgr = require "configs.config_mgr"
local log = require "log"
local tableDump = require "luaTableDump"
local traceback = debug.traceback
local pcall = pcall
local xpcall = xpcall
local debug = debug
-- local list_test = require "list_test"
-- local stack_test = require "stack_test"

local app
local uicontextmgr

-- setup config
function SetupConfig( ... )
	-- body
	local ok, err = pcall(configmgr.LoadFile)
	if not ok then
		log.error(err)
	end
	return configmgr
end

function CheckConfig( ... )
	-- body
	if configmgr.CheckConfig() then
		return true
	end
	return false
end


-- setup app
function main( ... )
	-- body
	-- local UIContextManager = require "maria.uibase.UIContextManager"
	-- local ok, err = pcall(UIContextManager.new)
	-- if ok then
	-- 	app = err
	-- 	app.config = assert(config)
	-- else
	-- 	log.error(err)
	-- end
	log.info('lua main')
	local App = require "bacon.App"
	local ok, err = pcall(App.new)
	if ok then
		app = err
	else
		log.error(err)
	end
end

function Startup( ... )
	-- body
	log.info('Startup')
	local ok, err = xpcall(app.Startup, traceback, app)
	if not ok then
		log.error(err)
	end
end

function Cleanup( ... )
	-- body
	local ok, err = xpcall(app.Cleanup, traceback, app)
	if not ok then
		log.error(err)
	end
end

function Update(delta, ... )
	-- body
	local ok, err = xpcall(app.Update, traceback, app, delta)
	if not ok then
		log.error(err)
	end
end