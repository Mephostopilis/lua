package.path = "./lualib/?.lua;./sproto/?.lua;" .. package.path
package.cpath = "./luaclib/?.dll;" .. package.cpath
local math3d = require "math3d"
local physx = require "physxadapter"

local staticFriction = 0.5
local dynamicFriction = 0.5
local restitution = 0.6
local scene
local boxes = {}
local defaultMaterial
local VEC = {}
VEC.ZERO = math3d.ref()
VEC.ZERO.v = math3d.vector(0, 0, 0, 1)

local QUAT_UP = math3d.ref()
QUAT_UP.q = math3d.quaternion {axis = math3d.vector {0, 1, 0}, r = 0.0}

local MAT_ZERO = math3d.ref()
MAT_ZERO.m = {s = 1, r = {0, 0, 0}, t = {0, 0, 0}}

function createStack(t, size, halfExtent)
	local shape = physx.create_shape_box(halfExtent, halfExtent, halfExtent, defaultMaterial)
	for i = 1, size do
		for j = 1, size - 1 do
			local ref = math3d.ref()
			ref.m = t

			local p = math3d.vector((j * 2) - (size - i), i * 2 + 1, 0, 0)
			ref.t = math3d.add(ref.t, p)

			local body = physx.create_static(ref)
			physx.body_attachShape(body, shape)
			-- physx.body_updateMassAndInertia(body, 10.0)
			physx.scene_add_actor(scene, body)
			table.insert(boxes, body)
		end
	end
	physx.release(shape)
end

physx.init()

defaultMaterial = physx.create_material(staticFriction, dynamicFriction, restitution)
scene = physx.create_scene(math3d.vector(0.0, -9.81, 0.0, 0.0))

local t = math3d.vector(0.0, 1.0, 0.0, 0.0)
local groundPlane = physx.create_plane(defaultMaterial, 0.0, t)
physx.scene_add_actor(scene, groundPlane)

local PT = math3d.ref()
PT.m = {s = 1, r = {0, 0, 0}, t = {0, 20, 0}}
createStack(PT, 5, 1)

while true do
	print("------step")
	physx.scene_step(scene, true)
end

physx.release(groundPlane)
for i = 1, #boxes do
	local body = boxes[i]
	physx.release(body)
end
physx.release(defaultMaterial)
-- physx.release(scene)
physx.cleanup()
