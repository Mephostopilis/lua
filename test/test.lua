local a = "abc"
local b = "def"
local c = "msn"
a = a .. b .. c

local function function_name(a, b, ... )
	-- body
	return a + b
end

for i=1,10 do
	print(i)
end

for i,v in ipairs(table_name) do
	print(i,v)
end

for k,v in pairs(table_name) do
	print(k,v)
end

return "ok"