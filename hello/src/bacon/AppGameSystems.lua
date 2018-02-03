local IndexSystem = require "bacon.gamesystems.IndexSystem"
local SceneSystem = require "bacon.gamesystems.SceneSystem"
local LoginSystem = require "bacon.gamesystems.LoginSystem"
local log = require "log"
local table_insert = table.insert

local cls = class("AppGameSystems")

local instance = nil

function cls.getInstance( ... )
	-- body
	if not instance then
		instance = cls.new( ... )
	end
	return instance
end

function cls:ctor( ... )
	-- body
	self._setappcontext_systems = {}
	self._setcontext_systems = {}
	self._initialize_systems = {}
    self._execute_systems = {}
    self._cleanup_systems = {}
    self._tear_down_systems = {}

    self.indexSystem = IndexSystem.new()
    self.sceneSystem = SceneSystem.new()
    self.loginSystem = LoginSystem.new()

    -- systems
    self:Add(self.indexSystem)
    self:Add(self.sceneSystem)
    self:Add(self.loginSystem)

end

function cls:Add(system, ... )
	-- body
	if system.SetContext then
		table_insert(self._setcontext_systems, system)
	end

	if system.SetAppContext then
		table_insert(self._setappcontext_systems, system)
	end

	if system.Initialize then
        table_insert(self._initialize_systems, system)
    end

    if system.Execute then
        table_insert(self._execute_systems, system)
    end

    if system.Cleanup then
        table_insert(self._cleanup_systems, system)
    end

    -- if system.tear_down then
    --     table_insert(self._tear_down_systems, system)
    -- end
end

function cls:SetContext(context, ... )
	-- body
    log.info("AppGameSystems SetContext")
	for _,v in pairs(self._setcontext_systems) do
		v:SetContext(context)
	end
end

function cls:SetAppContext(context, ... )
	-- body
	for _,v in pairs(self._setappcontext_systems) do
		v:SetAppContext(context)
	end
end

function cls:Initialize()
    for _, system in pairs(self._initialize_systems) do
        system:Initialize()
    end
end

function cls:Execute()
    for _, system in pairs(self._execute_systems) do
        system:Execute()
    end
end

function cls:Cleanup()
    for _, system in pairs(self._cleanup_systems) do
        system:Cleanup()
    end
end

function cls:TearDown()
    for _, system in pairs(self._tear_down_systems) do
        system:TearDown()
    end
end

return cls