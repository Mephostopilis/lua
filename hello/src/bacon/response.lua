local assert = assert
local errorcode = require "errorcode"
local _M = {}

function _M.handshake(env, args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
	print("handshake")
end

return _M