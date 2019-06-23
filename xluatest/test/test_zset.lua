local zset = require 'zset'
local random = require 'random'

local rand1 = random(0)
local zs = zset.new()

for i=1,1000000 do
    local score = rand1()
    zs:add(score, i)
end

