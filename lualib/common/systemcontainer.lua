local log = require "skynet.log"

local SystemType = {
	ST_BASE       = (1 << 0),
	ST_SETPOOL    = (1 << 1),
	ST_SETREFPOOL = (1 << 2),
	ST_INIT       = (1 << 3),
	ST_EXEC       = (1 << 4),
	ST_FIXEDEXE   = (1 << 5),
}

for k,v in pairs(SystemType) do
	log.info("%s:%d", k, v)
end

local cls = class("systemcontainer")

function cls:ctor(pool, ... )
	-- body
	self.pool = pool
	self.setpoolsystems = {}
	self.initsystems = {}
	self.execsystems = {}
	self.fixedexecsystems = {}
end

function cls:add(system, ... )
	-- body
	log.info(system:SystemType())
	if (system:SystemType() & SystemType.ST_INIT) > 0 then
		table.insert(self.initsystems, system)
	end
	if (system:SystemType() & SystemType.ST_EXEC) > 0 then
		table.insert(self.execsystems, system)
	end
	if (system:SystemType() & SystemType.ST_FIXEDEXE) > 0 then
		table.insert(self.fixedexecsystems, system)
	end
	if (system:SystemType() & SystemType.ST_SETREFPOOL) > 0 then
		table.insert(self.setpoolsystems, system)
	end
end

function cls:setpool( ... )
	-- body
	for _,v in pairs(self.setpoolsystems) do
		v:SetPool(self.pool)
	end
end

function cls:initialize( ... )
	-- body
	for _,v in pairs(self.initsystems) do
		v:Initialize()
	end
end

function cls:execute( ... )
	-- body
	for _,v in pairs(self.execsystems) do
		v:Execute()
	end
end

function cls:fixedexcute( ... )
	-- body
	for _,v in pairs(self.fixedexecsystems) do
		v:FixedExecute()
	end
end

function cls:activatereactivesystems( ... )
	-- body
	for _,v in pairs(self.execsystems) do
		v:Activate()
		v:ActivateReactiveSystems()
	end
end

function cls:deactivatereactivesystems( ... )
	-- body
	for _,v in pairs(self.execsystems) do
		v:Deactivate()
		v:DeactivateReactiveSystems()
	end
end

function cls:clearreactivesystems( ... )
	-- body
	for _,v in pairs(self.execsystems) do
		v:Clear()
		v:ClearReactiveSystems()
	end
end

return cls