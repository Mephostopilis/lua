local string_format = string.format
local debug = debug
local output = 1
if xlua then
	output = 2
end

local _M = {}

function _M.debug(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[debug][%s][%s:%d] %s", os.date(), info.short_src, info.currentline, msg)
	end
	if output == 1 then
		print(msg)
	else
		CS.UnityEngine.Debug.LogDebug(msg)
	end
end

function _M.info(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[info][%s][%s:%d] %s", os.date(), info.short_src, info.currentline, msg)
	end
	if output == 1 then
		print(msg)
	else
		CS.UnityEngine.Debug.Log(msg)
	end
end

function _M.warning(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[warning][%s][%s][%s:%d] %s", os.date(), SERVICE_NAME, info.short_src, info.currentline, msg)
	end
	if test or daemon then
		logger.warning(msg)
	else
		skynet_error(msg)
	end
end

function _M.error(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[error][%s][%s][%s:%d] %s", os.date(), SERVICE_NAME, info.short_src, info.currentline, msg)
	end
	if test or daemon then
		logger.error(msg)
	else
		skynet_error(msg)
	end
end

function _M.fatal(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[fatal][%s][%s][%s:%d] %s", os.date(), SERVICE_NAME, info.short_src, info.currentline, msg)
	end
	if test or daemon then
		logger.fatal(msg)
	else
		skynet_error(msg)
	end
end

return _M