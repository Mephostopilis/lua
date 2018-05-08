local BaseView = require "maria.uibase.BaseView"
local UIContextManager = require "maria.uibase.UIContextManager"
local MyEventCmd = require "bacon.event.MyEventCmd"
local log = require "log"
local res = require "res"
local EventDispatcher = require "event_dispatcher"

local cls = class("MainBgView", BaseView)

function cls:ctor(context, ... )
	-- body
	self.context = context
	self.go = nil
end

function cls:OnEnter(context, ... )
	-- body
	assert(context.app)
	if not self.go then
        local original = res.LoadGameObject("UI", "MainBg")
        if not original then
            log.error("LoadGameObject UI/MainBgView failture.")
            return
        end
        local go = CS.UnityEngine.GameObject.Instantiate(original)
        go.transform:SetParent(context.app.uicontextMgr.auicanvas.transform)
        self.go = go
    else
        self.go:SetActive(true)
    end

	local transform = self.go.transform
	transform.pivot = CS.UnityEngine.Vector2(0.5, 0.5)
	transform.anchorMax = CS.UnityEngine.Vector2(0.5, 0.5)
	transform.anchorMin = CS.UnityEngine.Vector2(0.5, 0.5)
	transform.localScale = CS.UnityEngine.Vector3.one
	transform.localPosition = CS.UnityEngine.Vector3(0, 0, 0)
end

function cls:OnExit()
	-- body
	if self.go then
		self.go:SetActive(false)
	end
end

return cls