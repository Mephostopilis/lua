print("test queue")

local queue = require "chestnut.queue"
local array = require "chestnut.array"
local vector = require "chestnut.vector"
local stack = require "chestnut.stack"

local timer = require "maria.timer"
timer.init()

timer.timeout(1,  function ( ... )
	-- body
	print("1 out")
end)

-- timer.timeout(2,  function ( ... )
-- 	-- body
-- 	local q = queue()

-- 	local now = timer.now()
-- 	print(now)

-- 	for i=1,100 do
-- 		q:enqueue(i)
-- 	end

-- 	for i=1,100 do
-- 		q:dequeue()
-- 	end


-- 	local now = timer.now()
-- 	print(now)	
-- end)

timer.timeout(2, function ( ... )
	-- body
	local q = array(10)(1, 2, 3, 4)

	for i,v in ipairs(q) do
		print(i,v)
	end

	for i=1,#q do
		print(q[i])
	end

	print("test vector")
	local p = vector()
	p:push_back(1)

	for i=1,10 do
		p:push_back(i)
	end

	for i=1,10 do
		print(p[i])
	end

	p:sort(function (a, b, ... )
		-- body
		if a < b then
			return 1
		else
			return -1
		end
	end)

	for i=1,10 do
		print(p[i])
	end

	local now = timer.now()
	print(now)	
end)

while true do
	timer.update()	
end








