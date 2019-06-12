local stack = require "chestnut.stack"
local log = require "log"

local cls = class("UIContextManager")

function cls:ctor( ... )
	-- body
	self.buicanvas = nil
	self.auicanvas = nil
	self._contextStack = stack()
end

function cls:Startup( ... )
    -- body
    self.buicanvas = CS.UnityEngine.GameObject.Find("BUICanvas")
    self.auicanvas = CS.UnityEngine.GameObject.Find("AUICanvas")
end

function cls:Cleanup( ... )
    -- body
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
        if curContext.visible then
            local ok, err = pcall(curContext.OnPause, curContext)
            if not ok then
                log.error(err)
            end
            curContext.visible = false
        else
            log.error("curContext is not visible.")
        end
    end

    for _,v in pairs(self._contextStack) do
        if v == nextContext then
            log.error("_contextStack contains nextContext %s.", nextContext.__cname)
            return
        end
    end

    if not nextContext.visible then
        self._contextStack:push(nextContext)
        local ok, err = pcall(nextContext.OnEnter, nextContext)
        if not ok then
            log.error(err)
        end
        nextContext.visible = true
    else
        log.error("push nextContext wrong. nextContext visible is true.")
    end
end

function cls:Pop() 
    if #self._contextStack > 0 then
        local curContext = self._contextStack:peek()
        if curContext.visible then
            local ok, err = pcall(curContext.OnExit, curContext)
            if not ok then
                log.error(err)
            end
            curContext.visible = false
        end
        self._contextStack:pop()
    end

    if #self._contextStack > 0 then
        local lastContext = self._contextStack:peek()
        if not lastContext.visible then 
            local ok, err = pcall(lastContext.OnResume, lastContext)
            if not ok then
                log.error(err)
            end
            lastContext.visible = true
        end
    end
end

function cls:PopAll() 
    while #self._contextStack > 0 do
        local curContext = self._contextStack:peek()
        if curContext.visible then
            local ok, err = pcall(curContext.OnExit, curContext)
            if not ok then
                log.error(err)
            end
            curContext.visible = false
        end
        -- curContext.Counter--;
        -- curContext.IsTop = false;
        self._contextStack:pop();
    end
end

function cls:PeekOrNull() 
    if #self._contextStack > 0 then
        return self._contextStack:peek()
    end
    return nil
end

return cls