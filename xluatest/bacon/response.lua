local assert = assert
local log = require "log"
local errorcode = require "bacon.errorcode"
local AppContext = require "bacon.AppContext"

local cls = class("response")

function cls:ctor(cs, ... )
	-- body
	cs:register_response("handshake", cls.handshake, self)
	cs:register_response("inituser", cls.inituser, self)
	cs:register_response("first", cls.first, self)
	cs:register_response("create", cls.create, self)
	cs:register_response("room_info", cls.room_info, self)
	cs:register_response("join", cls.join, self)
	cs:register_response("rejoin", cls.rejoin, self)
	cs:register_response("ready", cls.ready, self)
end

function cls:handshake( ... )
	-- body
	-- log.info("handshake")
end

function cls:inituser(responseObj, ... )
	-- body
	AppContext:getInstance().gameSystems.loginSystem:InitUser(responseObj)
end

function cls:first(responseObj)
	-- body
	AppContext:getInstance().gameSystems.mainSystem:First(responseObj)
end

function cls:create(responseObj, ... )
	-- body
	AppContext:getInstance().gameSystems.joinSystem:Create(responseObj)
end

function cls:room_info(responseObj, ... )
	-- body
	AppContext:getInstance().gameSystems.loginSystem:RoomInfo(responseObj)
end

function cls:join(responseObj)
	-- body
	log.info("response join")
	AppContext:getInstance().gameSystems.joinSystem:Join(responseObj)
end

function cls:rejoin(responseObj)
	AppContext:getInstance().gameSystems.joinSystem:Rejoin(responseObj)
end

function cls:ready(responseObj)
	if responseObj.errorcode ~= 0 then
		log.error('errorcode is %d', responseObj.errorcode)
	end
end

return cls
