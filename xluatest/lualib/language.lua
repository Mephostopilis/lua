
local function getLanguage(id, ... )
	-- body
	return CS.Maria.Utils.LanguageMgr.current:Get(id)
end

return getLanguage