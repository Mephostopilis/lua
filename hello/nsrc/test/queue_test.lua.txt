print("test queue")

local queue = require "chestnut.queue"
local timer = require "maria.timer"
timer.init()

timer.timeout(1, nil, function ( ... )
	-- body
	print("1 out")
end)

local q = queue()

local now = timer.now()
print(now)

for i=1,10000000 do
	q:enqueue(i)
end

for i=1,10000000 do
	q:dequeue()
end

timer.update()
local now = timer.now()
print(now)
