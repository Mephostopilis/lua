require "fixmath.bounce"

 -- Create a b3World object.
local m_world = bounce.b3World()
local gravity = { x= 0.0, y = -9.8, z = 0.0}
m_world:SetGravity(gravity)

local timeStep = 1.0 / 60.0
local velocityIterations = 8
local positionIterations = 2

local groundDef = {}
local ground = m_world:CreateBody(groundDef)

local groundBox = bounce.b3BoxHull()
local scale = {}
scale.position = { x = 0, y = 0, z = 0}
scale.rotation = bounce.b3Mat33.b3Diagonal(10.0, 1.0, 10.0)
groundBox:SetTransform(scale)

local groundShape = bounce.b3HullShape()
groundShape.m_hull = groundBox

local groundBoxDef = {}
groundBoxDef.shape = groundShape
ground:CreateShape(groundBoxDef)


-- create box
local bodydef = {}
bodydef.type = 3
bodydef.position = { x = 0, y = 10, z = 0 }
-- bodydef.orientation = { a = 0, b = 0, c = 0, d = 1}
-- bodydef.linearVelocity = { x = 0, y = 0, z = 0}
bodydef.angularVelocity = { x = 0, y = bounce.b3R32.PI(), z = 0}
-- bodydef.gravityScale = 1
local body = m_world:CreateBody(bodydef)
local position = body:GetPosition()
print(string.format("x = %f, y = %f, z = %f", bounce.b3R32.ToFloat32(position.x), bounce.b3R32.ToFloat32(position.y), bounce.b3R32.ToFloat32(position.z)))
print("----------------------")

-- hull
local bodyBox = bounce.b3BoxHull()
bodyBox:SetIdentity()

local bodyShape = bounce.b3HullShape()
bodyShape.m_hull = bodyBox
local shapedef = { shape = bodyShape }
shapedef.density = 1
body:CreateShape( shapedef )


-- body:ApplyForceToCenter({ x = 0, y = 10, z = 0}, false)
-- body:SetLinearVelocity({ x = 100, y = 0, z = 100 })
for i=1,10 do
	-- // Call the function below to simulate a single physics step.
	m_world:Step(timeStep, velocityIterations, positionIterations)
	local position = body:GetPosition()
	print(string.format("x = %f, y = %f, z = %f", bounce.b3R32.ToFloat32(position.x), bounce.b3R32.ToFloat32(position.y), bounce.b3R32.ToFloat32(position.z)))
	-- local trans = body:GetTransform()
	-- for k,v in pairs(trans.translation) do
	-- 	print(k,v)
	-- end
end

