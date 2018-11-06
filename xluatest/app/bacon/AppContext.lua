local stack = require "chestnut.stack"
local timer = require "timer"
local NetworkMgr = require "maria.network.NetworkMgr"
local notification_center = require "notification_center"
local AppGameSystems = require "bacon.AppGameSystems"
local Context = require "entitas.Context"
local ServiceMgr = require "maria.service.ServiceMgr"
local InitService = require "bacon.service.InitService"
local request = require "bacon.request"
local response = require "bacon.response"
local log = require "log"
local assert = assert
local debug = debug


local cls = class("AppContext")

function cls:ctor(app, ... )
	-- body
	self.app = app
	-- manager scene
	self._stack = stack()
end

function cls:Startup( ... )
	-- body
	timer.timeout(self, "EnterLogin", 1)
end

function cls:Cleanup( ... )
	-- body
end

function cls:Update(delta, ... )
	-- body
	timer.update(delta, function (obj, message, arg, ... )
		-- body
		local traceback = debug.traceback
		local f = obj[message]
		if not f then
			log.error(string.format("%s is nil", message))
			return
		end
		local ok, err = xpcall(f, traceback, obj, arg)
		if not ok then
			log.error(err)
		end
	end)
end

-- entitas = array
-- param
function cls:Push(context, param, ... )
	-- body
	local res
	if #self._stack > 0 then
		local ok, err = pcall(self.app.gameSystems.sceneSystem.OnPause, self.app.gameSystems.sceneSystem, self._stack:peek(), param)
		if not ok then
			log.error(err)
			return
		else
			res = err
		end
	end
	self._stack:push(context)
	local ok, err = pcall(self.gameSystems.sceneSystem.OnEnter, self.gameSystems.sceneSystem, context, res)
	if not ok then
		log.error(err)
		return
	end
	self.gameSystems:SetContext(context)
end

function cls:Pop(param, ... )
	-- body
	local res
	if #self._stack > 0 then
		res = self.gameSystems.sceneSystem:OnExit(self._stack:peek(), param)
		self._stack:pop()
	end
	if #self._stack > 0 then
		self.gameSystems.sceneSystem:OnResume(self._stack:peek(), res)
	end
end

function cls:Peek( ... )
	-- body
	return self._stack:peek()
end

function cls:EnterLogin( ... )
	-- body
	self.app.gameSystems.loginSystem:EnterLogin()
end

return cls