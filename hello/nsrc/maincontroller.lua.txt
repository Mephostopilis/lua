-- xlua.hotfix(CS.Bacon.MainController, "First", function (self, obj, ... )
-- 	-- body
-- 	-- for k,v in pairs(CS.Bacon.InitService) do
-- 	-- 	print(k,v)
-- 	-- end
-- 	local service = self.Ctx:QueryService(CS.Bacon.InitService.Name)

-- 	local u = service.User
-- 	u.Name = obj.name
-- 	u.NameId = obj.nameid
-- 	u.RCard = obj.rcard
-- 	u.Sex = obj.sex

-- 	print("u.Name = ", u.Name)

-- 	service.Board = obj.board
-- 	service.Adver = obj.adver

-- 	-- local func = CS.Bacon.MainController.RenderFirst
-- 	-- assert(func)

-- 	-- self.Ctx:EnqueueRenderQueue(func)
-- 	-- self.Ctx:EnqueueRenderQueue(self.RenderFirst)

-- 	self.Ctx:EnqueueRenderQueue(function ( ... )
-- 		-- body
-- 		self:RenderFirst()
-- 	end)
-- end)