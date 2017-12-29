local Processors = require "entitas.Processors"
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
	self.processors = Processors.new()
	self.setappcontexts = {}
	self.setcontexts = {}
end

function cls:Add(system, ... )
	-- body
end

function cls:SetAppContext( ... )
	-- body
end

function cls:SetContext( ... )
	-- body
end

function Processors:initialize()
    for _, processor in pairs(self._initialize_processors) do
        processor:initialize()
    end
end

function Processors:execute()
    for _, processor in pairs(self._execute_processors) do
        processor:execute()
    end
end

function Processors:cleanup()
    for _, processor in pairs(self._cleanup_processors) do
        processor:cleanup()
    end
end

function Processors:tear_down()
    for _, processor in pairs(self._tear_down_processors) do
        processor:tear_down()
    end
end

return cls