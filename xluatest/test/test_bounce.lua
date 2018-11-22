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


-- // Call the function below to simulate a single physics step.
m_world:Step( m_step )