local physx = require "physx"
local math3d = require "math3d"
local adapter = require "math3d.adapter"

local _M = {}

_M.init = physx.init
_M.cleanup = physx.cleanup
_M.createScene = adapter.vector(physx.create_scene)
_M.createMaterial = physx.create_material
_M.createPlane = physx.createPlane

return _M
