local IndexSystem = require "bacon.gamesystems.IndexSystem"
local SceneSystem = require "bacon.gamesystems.SceneSystem"
local LoginSystem = require "bacon.gamesystems.LoginSystem"
local MainSystem = require "bacon.gamesystems.MainSystem"
local JoinSystem = require "bacon.gamesystems.JoinSystem"
local GameSystem = require "bacon.gamesystems.GameSystem"
local PlayerSystem = require "bacon.gamesystems.PlayerSystem"
local DeskSystem = require "bacon.gamesystems.DeskSystem"
local NetIdxSystem = require "bacon.gamesystems.NetIdxSystem"
local CardValueIndexSystem = require "bacon.gamesystems.CardValueIndexSystem"
local log = require "log"
local table_insert = table.insert


local _initialize_systems = {}
local _execute_systems = {}
local _cleanup_systems = {}
local _tear_down_systems = {}

local cls = {}

function cls.Startup()
    -- for _, system in pairs(self._initialize_systems) do
    --     system:Initialize()
    -- end
    LoginSystem.Startup()
end

function cls.Update(delta)
    -- for _, system in pairs(self._execute_systems) do
    --     system:Execute()
    -- end
    LoginSystem.Update(delta)
end

function cls.Cleanup()
    -- for _, system in pairs(self._cleanup_systems) do
    --     system:Cleanup()
    -- end
    LoginSystem.Cleanup()
end

return cls