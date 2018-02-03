local stack = require "chestnut.stack"
local log = require "log"

local cls = class("UIContextManager")

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
	self.buicanvas = CS.UnityEngine.GameObject.Find("BUICanvas")
	self.auicanvas = CS.UnityEngine.GameObject.Find("AUICanvas")
	self._contextStack = stack()

end

function cls:CleanStartPanel( ... )
    -- body
    log.info("CleanStartPanel")
    local startpanel = self.buicanvas.transform:Find("StartPanel")
    startpanel.gameObject:SetActive(false)
end

function cls:Clean( ... )
    -- body
    -- self.auicanvas
end

function cls:Push(nextContext) 
    if #self._contextStack > 0 then
        local curContext = self._contextStack:peek()
        curContext:OnPause()
        curContext.visible = false
    end

    self._contextStack:push(nextContext)
    nextContext:OnEnter()
    nextContext.visible = true
end

function cls:Pop() 
    if #_contextStack > 0 then
        local curContext = self._contextStack:peek()
        curContext:OnExit()
        curContext.visible = false
        self._contextStack:Pop()
    end

    if #_contextStack > 0 then
        local lastContext = self._contextStack:peek()
        lastContext:OnResume()
        lastContext.visible = true
    end
end

function cls:PopAll() 
    while #_contextStack > 0 do
        local curContext = _contextStack:peek();
        curContext:OnExit()
        -- curContext.Counter--;
        -- curContext.IsTop = false;
        _contextStack.Pop();
    end
end

function cls:PeekOrNull() 
    if #_contextStack > 0 then
        return _contextStack:peek()
    end
    return null;
end

return cls