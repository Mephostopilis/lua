local assert = assert
local log = require "log"
local errorcode = require "bacon.errorcode"

local cls = class("response")

function cls:ctor(ctx, cs, ... )
	-- body
	self._appContext = ctx

	cs:register_response("handshake", cls.handshake, self)
end

function cls:handshake( ... )
	-- body
	log.info("handshake")
end

return cls
