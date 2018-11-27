local log = require "log"
local cls = {}

function cls.LoadAsset(path, name, ... )
	-- body
	if type(path) ~= "string" and #path <= 0 then
		log.error("LoadGameObject path is wrong.")
		return
	end
	if type(name) ~= "string" and #name <= 0 then
		log.error("LoadGameObject path is wrong.")
		return
	end
	return CS.Maria.Res.ABLoader.current:LoadAsset(path, name)
end

function cls.LoadGameObject(path, name, ... )
	-- body
	if type(path) ~= "string" and #path <= 0 then
		log.error("LoadGameObject path is wrong.")
		return
	end
	if type(name) ~= "string" and #name <= 0 then
		log.error("LoadGameObject path is wrong.")
		return
	end
	return CS.Maria.Res.ABLoader.current:LoadGameObject(path, name)
end

function cls.LoadTextAsset(path, name, ... )
	-- body
	if type(path) ~= "string" and #path <= 0 then
		log.error("LoadGameObject path is wrong.")
		return
	end
	if type(name) ~= "string" and #name <= 0 then
		log.error("LoadGameObject path is wrong.")
		return
	end
	return CS.Maria.Res.ABLoader.current:LoadTextAsset(path, name)
end

function cls.LoadAssetAsync(path, name, callback, ... )
	-- body
	if type(path) ~= "string" and #path <= 0 then
		log.error("LoadGameObject path is wrong.")
		return
	end
	if type(name) ~= "string" and #name <= 0 then
		log.error("LoadGameObject path is wrong.")
		return
	end
	if type(callback) ~= "function" then
		log.error("LoadGameObject path is wrong.")
		return
	end
	CS.Maria.Res.ABLoader.current:LoadAssetAsync(path, name, callback)
end

return cls