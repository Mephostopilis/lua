local cls = class("ABLoader")

local instance

function cls:getInstance( ... )
	-- body
	if not instance then
		instance = cls.new()
	end
	return instance
end

function cls:ctor( ... )
	-- body
end

function cls:LoadAsset(path, name, ... )
	-- body
	return CS.Maria.Res.ABLoader.current:LoadAsset(path, name)
end

function cls:LoadGameObject(path, name, ... )
	-- body
	return CS.Maria.Res.ABLoader.current:LoadGameObject(path, name)
end

function cls:LoadTextAsset(path, name, ... )
	-- body
	return CS.Maria.Res.ABLoader.current:LoadTextAsset(path, name)
end

function cls:LoadAssetAsync(path, name, callback, ... )
	-- body
	CS.Maria.Res.ABLoader.current:LoadAssetAsync(path, name, callback)
end

return cls