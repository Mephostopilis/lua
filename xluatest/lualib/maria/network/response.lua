local log = require "log"
local assert = assert
local _M = {}

function _M:handshake(...)
	-- body
	-- log.info("handshake")
end

function _M:inituser(responseObj, ...)
	-- body
	AppContext:getInstance().gameSystems.loginSystem:InitUser(responseObj)
end

function _M:first(responseObj)
	-- body
	AppContext:getInstance().gameSystems.mainSystem:First(responseObj)
end

function _M:create(responseObj, ...)
	-- body
	AppContext:getInstance().gameSystems.joinSystem:Create(responseObj)
end

function _M:room_info(responseObj, ...)
	-- body
	AppContext:getInstance().gameSystems.loginSystem:RoomInfo(responseObj)
end

function _M:join(responseObj)
	-- body
	log.info("response join")
	AppContext:getInstance().gameSystems.joinSystem:Join(responseObj)
end

function _M:rejoin(responseObj)
	AppContext:getInstance().gameSystems.joinSystem:Rejoin(responseObj)
end

function _M:ready(responseObj)
	if responseObj.errorcode ~= 0 then
		log.error("errorcode is %d", responseObj.errorcode)
	end
end

return _M
