local assert = assert
local log = require "log"
local errorcode = require "bacon.errorcode"

local cls = class("response")

function cls:ctor(appContext, cs, ... )
	-- body
	self.appContext = appContext

	cs:register_response("handshake", cls.handshake, self)
	cs:register_response("inituser", cls.inituser, self)
	cs:register_response("first", cls.first, self)
	cs:register_response("create", cls.create, self)
	cs:register_response("room_info", cls.room_info, self)
	cs:register_response("join", cls.join, self)
	cs:register_response("rejoin", cls.rejoin, self)
end

function cls:handshake( ... )
	-- body
	-- log.info("handshake")
end

function cls:inituser(responseObj, ... )
	-- body
	self.appContext.gameSystems.loginSystem:InitUser(responseObj)
end

function cls:first(responseObj)
	-- body
	self.appContext.gameSystems.mainSystem:First(responseObj)
end

function cls:create(responseObj, ... )
	-- body
	self.appContext.gameSystems.joinSystem:Create(responseObj)
end

function cls:room_info(responseObj, ... )
	-- body
	self.appContext.gameSystems.loginSystem:RoomInfo(responseObj)
end

function cls:join(responseObj)
	-- body
	log.info("response join")
	self.appContext.gameSystems.joinSystem:Join(responseObj)
end

function cls:rejoin(responseObj)
	-- body
	self.appContext.gameSystems.joinSystem:Rejoin(responseObj)
end

return cls
