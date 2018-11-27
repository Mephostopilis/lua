require "fixmath.bounce"

 -- Create a b3World object.
local m_world = bounce.b3World()

-- // Create a b3TimeStep object to define the configuration of a single
-- simulation step.
local m_step = {}


-- // Setup the simulation frequency (here 60 Hz).
m_step.dt = 1.0 / 60.0


-- // Setup the number of LCP Solver iterations.
m_step.velocityIterations = 10


-- // Optionally allow rigid bodies to sleep under unconsiderable motion.
-- // This increases the performance of the application substantially.
 -- m_step.allowSleeping = true;
 m_step.allowSleeping = false


local hull = bounce.b3Hull()
hull:SetAsBox({ x = 1, y = 1, z = 1})
local polyhedron = bounce.b3Polyhedron()
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


body:CreateShape( { shape = polyhedron }, polyhedron )



for i=1,10 do
	-- // Call the function below to simulate a single physics step.
	m_world:Step( m_step )
end

