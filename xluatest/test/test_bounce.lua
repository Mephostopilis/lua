require "fixmath.bouncelite"

 -- Create a b3World object.
local m_world = bouncelite.b3World()
m_world:SetGravityDirection({ x = 0, y = -1, z = 0})

-- // Create a b3TimeStep object to define the configuration of a single
-- simulation step.
local m_step = {}


-- // Setup the simulation frequency (here 60 Hz).
m_step.dt = 1.0 / 60.0


-- // Setup the number of LCP Solver iterations.
m_step.velocityIterations = 10


-- // Optionally allow rigid bodies to sleep under unconsiderable motion.
-- // This increases the performance of the application substantially.
 m_step.allowSleeping = true


local hull = bouncelite.b3Hull()
hull:SetAsBox({ x = 1, y = 1, z = 1})
local polyhedron = bouncelite.b3Polyhedron()
polyhedron:SetHull(hull)

local bodydef = {}
bodydef.type = 3
bodydef.awake = true
bodydef.position = { x = 5, y = 2, z = 5 }
bodydef.orientation = { a = 0, b = 0, c = 0, d = 1}
bodydef.linearVelocity = { x = 0, y = 0, z = 0}
bodydef.angularVelocity = { x = 0, y = 0, z = 0}
bodydef.gravityScale = 1
local body = m_world:CreateBody(bodydef)


local shapedef = { shape = polyhedron }
shapedef.sensor = false
shapedef.density = 1
body:CreateShape( shapedef )


body:ApplyForceToCenter({ x = 0, y = 10, z = 0}, false)
body:SetLinearVelocity({ x = 100, y = 0, z = 100 })
for i=1,10 do
	-- // Call the function below to simulate a single physics step.
	m_world:Step( m_step )
	local trans = body:GetTransform()
	for k,v in pairs(trans.translation) do
		print(k,v)
	end
end

