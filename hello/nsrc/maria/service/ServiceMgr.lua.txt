local cls = class("ServiceMgr")

local instance

function cls.getInstance( ... )
	-- body
	if not instance then
		instance = cls.new( ... )
	end
	return instance
end

function cls:ctor( ... )
	-- body
	self._services = {}
end

function cls:RegService(s, ... )
	-- body
	local name = s.name
	self._services[name] = s
end

function cls:UnrService(s, ... )
	-- body
	local name = s.name
	self._services[name] = nil
end

function cls:QueryService(name, ... )
	-- body
	return self._services[name]
end

return cls