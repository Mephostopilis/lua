local cls = class("user")

function cls:ctor( ... )
	-- body
	self.modules = {}
	self.username = ""
	self.password = ""
	self.server   = ""
	self.uid      = 0
	self.subid    = 0
	self.secret   = ""
end

function cls:AddModule(m, ... )
	-- body
end

function cls:RemoveModule(module, ... )
	-- body
end

-- function cls:OnLoginConnected(connected, ... )
-- 	-- body
-- 	self._l:foreach(function (i, ... )
-- 		-- body
-- 		i:OnLoginConnected(connected)
-- 	end)
-- end

function cls:OnLoginAuthed( ... )
	-- body
end

function cls:OnLoginDisconnected( ... )
	-- body
end

function cls:OnGateAuthed(code, uid, subid, ... )
	-- body
	if code == 200 then
		self.uid = uid
		self.subid = subid
	end
end

function cls:OnGateDisconnected( ... )
	-- body
end

return cls