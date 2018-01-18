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

function cls:OnLoginAuthed(code, uid, subid, secret, ... )
	-- body
	if code == 200 then
		print(uid, subid)
		self.uid = uid
		self.subid = subid
		self.secret = secret
	end
end

function cls:OnLoginDisconnected( ... )
	-- body
end

function cls:OnGateAuthed(code, uid, subid, ... )
	-- body
	
end

function cls:OnGateDisconnected( ... )
	-- body
end

return cls