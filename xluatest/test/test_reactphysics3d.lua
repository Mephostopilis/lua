require "fixmath.reactphysics3d"

local world = rp3d.CollisionWorld()

local trans = {}
trans.position = { x = 0.0, y = 3.0, z = 0.0 }
trans.rotation = rp3d.Quaternion.identity()

local body = world:createCollisionBody(trans)

local newTrans = {}
newTrans.position = { x = 10.999, y = 3.0, z = 0.0 }
newTrans.rotation = rp3d.Quaternion.identity()

body:setTransform(newTrans)

local trans = body:getTransform()
print(trans.position.x, trans.position.y, trans.position.z)


local gravity = { x= 0.0, y = -9.81, z = 0.0}
local world = rp3d.DynamicsWorld(gravity)
world:setNbIterationsVelocitySolver(15)
world:setNbIterationsPositionSolver(8)
world:enableSleeping(false)
local listerner

function xx( ... )
	-- body
	listerner = rp3d.lEventListener()
	listerner:lregister(function (collisionInfo)
		-- body
		local body1 = collisionInfo.body1
		local trans = body1:getTransform()
		print("collisionInfo", trans.position.x, trans.position.y, trans.position.z)
	end)
	world:setEventListener(listerner)
end
xx()



local trans = {}
trans.position = { x = 0.0, y = 3.0, z = 0.0 }
trans.rotation = rp3d.Quaternion.identity()

local body = world:createRigidBody(trans)
body:setType(2)
body:setMass(4)

local boxShape = rp3d.BoxShape({ x = 1.0, y = 1.0, z = 1.0})
local proxyShape = body:addCollisionShape(boxShape, rp3d.Transform.identity())


local ground = world:createRigidBody(rp3d.Transform.identity())
local groundBoxShape = rp3d.BoxShape({ x = 10.0, y = 10.0, z = 10.0})
local proxyShape = ground:addCollisionShape(groundBoxShape, rp3d.Transform.identity())

local timeStep = 1.0 / 60.0

for i=1,100 do
	world:update(timeStep)
	local trans = body:getTransform()
	print(trans.position.x, trans.position.y, trans.position.z)
	local trans = ground:getTransform()
	print(trans.position.x, trans.position.y, trans.position.z)
end