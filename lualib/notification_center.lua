local assert = assert
local instance

local cls = class("notification_center")

function cls.getInstance(...)
	-- body
	if not instance then
		instance = cls.new(...)
	end
	return instance
end

function cls:ctor(...)
	-- body
	self._observers = {}
	return self
end

function cls:add_observer(handler, name, ud, ...)
	-- body
	assert(func and name)
	local notification = {}
	notification.name = name
	notification.handler = handler
	notification.ud = ud
	self._observers[name] = notification
end

function cls:remove_observer(name, ...)
	-- body
	self._observers[name] = nil
end

function cls:post_notification_name(name, appendix, ...)
	-- body
	local notification = self._observers[name]
	if notification then
		local handler = assert(notification.handler)
		handler(ud, appendix)
	end
end

function cls:sub_notification(handler, name, ud, ...)
end

function cls:pub_notification(name, appendix, ...)
end

return cls
