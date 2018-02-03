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

function cls:Startup( ... )
	-- body
	for _,v in pairs(self._services) do
		v:Startup(...)
	end
end

function cls:RegService(t, ... )
	-- body
	if not self._services[t] then
		local service = t.new()
		self._services[t] = service
	end
end

function cls:UnrService(t, ... )
	-- body
	if self._services[t] then
		self._services[t] = nil
	end
end

function cls:QueryService(t, ... )
	-- body
	return self._services[t]
end

return cls