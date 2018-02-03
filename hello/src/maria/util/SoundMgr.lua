local cls = class("SoundMgr")

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

function cls:SetMusic(value, ... )
	-- body
	CS.Maria.Util.SoundMgr.current:SetMusic(value)
end

function cls:SetSound(value, ... )
	-- body
	CS.Maria.Util.SoundMgr.current:SetSound(value)
end

function cls:PlayMusic(clip, ... )
	-- body
	CS.Maria.Util.SoundMgr.current:PlayMusic(clip)
end

function cls:StopMusic( ... )
	-- body
	CS.Maria.Util.SoundMgr.current:StopMusic()
end

function cls:PlaySound(go, path, name, ... )
	-- body
	CS.Maria.Util.SoundMgr.current:PlaySound(go, path, name)
end

return cls