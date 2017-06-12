package.path = "E:\\lua\\test\\?.lua;" .. package.path
-- local test = require "test"

-- print(test)

print("col begin")

-- local co = coroutine.create(function ( ... )
-- 	-- body
-- 	print("co2 begin");
-- 	cotest.func1(function ( ... )
-- 		-- body
-- 		print("yield")
-- 		coroutine.yield()

-- 		print("co 1")
-- 	end)
-- 	print("co2 end")
-- end)

cotest.func2(function ( ... )
	-- body
	print("co2 begin");
	cotest.func1(function ( ... )
		-- body
		print("yield")
		coroutine.yield()

		print("co 1")
	end)
	print("co2 end")
end)

coroutine.resume(co)

print("co1 end")

coroutine.resume(co)