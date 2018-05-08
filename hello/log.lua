local string_format = string.format
local debug = debug
local output = 1
if xlua then
	output = 2
end

local _M = {}

-- function _M.trace(fmt, ... )
-- 	-- body
-- 	local msg = string.format(fmt, ...)
-- 	local info = debug.getinfo(2)
-- 	if info then
-- 		msg = string.format("[trace][%s][%s:%d] %s", os.date(), info.short_src, info.currentline, msg)
-- 	end
-- 	if output == 1 then
-- 		print(msg)
-- 	else
-- 		CS.NLog.Log.Debug(msg)
-- 	end
-- end

function _M.debug(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[lua][debug][%s][%s:%d] %s", os.date(), info.short_src, info.currentline, msg)
	end
	if output == 1 then
		print(msg)
	else
		CS.NLog.Log.Debug(msg)
	end
end

function _M.info(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[lua][info][%s][%s:%d] %s", os.date(), info.short_src, info.currentline, msg)
	end
	if output == 1 then
		print(msg)
	else
		CS.NLog.Log.Info(msg)
	end
end

function _M.warning(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[lua][warning][%s][%s:%d] %s", os.date(), info.short_src, info.currentline, msg)
	end
	if output == 1 then
		print(msg)
	else
		CS.NLog.Log.Warn(msg)
	end
end

function _M.error(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[lua][error][%s][%s:%d] %s", os.date(), info.short_src, info.currentline, msg)
	end
	if output == 1 then
		print(msg)
	else
		CS.NLog.Log.Error(msg)
	end
end

function _M.fatal(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[lua][fatal][%s][%s][%s:%d] %s", os.date(), SERVICE_NAME, info.short_src, info.currentline, msg)
	end
	if test or daemon then
		logger.fatal(msg)
	else
		CS.NLog.Log.Fatal(msg)
	end
end

return _M
