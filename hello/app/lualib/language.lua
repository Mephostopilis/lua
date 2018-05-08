
local function getLanguage(id, ... )
	-- body
	return CS.Maria.Util.LanguageMgr.current:Get(id)
end

return getLanguage