local string_format = string.format
local debug = debug
local output = 1
if xlua then
	output = 2
end

local _M = {}

function _M.trace(fmt, ... )
	-- body
end

function _M.debug(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[debug][%s][%s:%d] %s", os.date(), info.short_src, info.currentline, msg)
	end
	if output == 1 then
		print(msg)
	else
		-- CS.UnityEngine.Debug.LogDebug(msg)
		CS.NLog.Log.Debug(msg)
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
		-- CS.UnityEngine.Debug.Log(msg)
		CS.NLog.Log.Info(msg)
	end
end

function _M.warning(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[warning][%s][%s:%d] %s", os.date(), info.short_src, info.currentline, msg)
	end
	if output == 1 then
		print(msg)
	else
		-- CS.UnityEngine.Debug.LogWarning(msg)
		CS.NLog.Log.Warn(msg)
	end
end

function _M.error(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[error][%s][%s:%d] %s", os.date(), info.short_src, info.currentline, msg)
	end
	if output == 1 then
		print(msg)
	else
		CS.NLog.Log.Error(debug.traceback())
		CS.NLog.Log.Error(msg)

		-- CS.UnityEngine.Debug.LogError(debug.traceback())
		-- CS.UnityEngine.Debug.LogError(msg)
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
		CS.NLog.Log.Fatal(debug.traceback())
		CS.NLog.Log.Fatal(msg)
		-- skynet_error(msg)
	end
end

return _M
