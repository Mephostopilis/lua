local physx = require "physx"
local math3d = require "math3d"
local adapter = require "math3d.adapter"

local _M = {}

_M.init = physx.init
_M.cleanup = physx.cleanup
_M.release = physx.release
_M.is_releasable = physx.is_releasable
_M.create_scene = adapter.vector(physx.create_scene, 1)
_M.create_material = physx.create_material
_M.create_shape_box = physx.create_shape_box
_M.create_shape_sphere = physx.create_shape_sphere
_M.create_dynamic = adapter.matrix(physx.create_dynamic, 1)
_M.create_static = adapter.matrix(physx.create_static, 1)
_M.create_plane = adapter.vector(physx.create_plane, 3)

_M.scene_add_actor = physx.scene_add_actor
_M.scene_remove_actor = physx.scene_remove_actor
_M.scene_step = physx.scene_step

_M.body_updateMassAndInertia = physx.body_updateMassAndInertia
_M.body_attachShape = physx.body_attachShape
_M.body_detachShape = physx.body_detachShape
_M.body_setAngularDamping = physx.body_setAngularDamping
_M.body_setLinearVelocity = physx.body_setLinearVelocity

return _M
