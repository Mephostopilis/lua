package.path = "src/?.lua.txt;" .. package.path
local timer = require "maria.timer"

timer.init()

for i=1,10000000 do
	timer.update()
end