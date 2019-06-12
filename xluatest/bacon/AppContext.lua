local stack = require "chestnut.stack"
local timer = require "timer"
local log = require "log"
local objmgr = require "bacon.objmgr"
local assert = assert
local traceback = debug.traceback
local instance

local cls = class("AppContext")

function cls.getInstance( ... )
	-- body
	if not instance then
		instance = cls.new( ... )
	end
	return instance
end

function cls:ctor( ... )
	-- body
	-- manager scene
	self._stack = stack()

	local obj = objmgr.new_obj()
    objmgr.set_myobj(obj)
end

function cls:Startup( ... )
	-- body
end

function cls:Cleanup( ... )
	-- body
end

function cls:Update(delta, ... )
	-- body
	timer.update(delta, function (obj, message, arg, ... )
		-- body
		
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

function cls:Push(context, param, ... )
	-- body
	local res
	if #self._stack > 0 then
		local ok, err = pcall(self.gameSystems.sceneSystem.OnPause, self.gameSystems.sceneSystem, self._stack:peek(), param)
		if not ok then
			log.error(err)
			return
		else
			res = err
		end
	end
	self._stack:push(context)
	self.gameSystems:SetContext(context)
	local ok, err = pcall(self.gameSystems.sceneSystem.OnEnter, self.gameSystems.sceneSystem, context, res)
	if not ok then
		log.error(err)
		return
	end
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
	self.gameSystems.loginSystem:EnterLogin()
end

return cls