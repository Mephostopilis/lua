local cls = class("ServiceMgr")

function cls:ctor(app, ... )
	-- body
	self.app = app
	self._services = {}
end

function cls:Startup( ... )
	-- body
	for _,v in pairs(self._services) do
		v:Startup(...)
	end
end

function cls:Cleanup( ... )
	-- body
end

function cls:RegService(t, ... )
	-- body
	if not self._services[t] then
		local service = t.new(self.app)
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