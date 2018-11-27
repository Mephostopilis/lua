local _M = {}

function _M.LoadScene(name, cb, ... )
	-- body
	CS.Maria.Util.SceneMgr.current:LoadScene(name, cb)
end

return _M