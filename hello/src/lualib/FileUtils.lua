local cls = class("FileUtils")

local instance = nil

function cls.getInstance( ... )
	-- body
	if not instance then
		instance = cls.new( ... )
	end
	return instance
end

function cls:ctor( ... )
	-- body
end

function cls:getStringFromFile(path) 
	if xlua then
	else
		return io.readfile(path)
	end
end

return cls