local BaseView = require "maria.uibase.BaseView"
local UIContextManager = require "maria.uibase.UIContextManager"
local MyEventCmd = require "bacon.event.MyEventCmd"
local log = require "log"
local res = require "res"
local EventDispatcher = require "event_dispatcher"

local cls = class("TitleView", BaseView)

function cls:ctor(context, ... )
	-- body
	self.context = context
	self.go = nil
	self.nickname = nil
	self.nameid   = nil
	self.rcard    = nil
end

function cls:OnEnter(context)
	-- body
	if not self.go then
        local original = res.LoadGameObject("UI", "TitleView")
        if not original then
            log.error("LoadGameObject UI/TitleView failture.")
            return
        end
        local go = CS.UnityEngine.GameObject.Instantiate(original)
        go.transform:SetParent(context.app.uicontextMgr.buicanvas.transform)
        self.go = go
    else
        self.go:SetActive(true)
    end

	local transform = self.go.transform
	transform.pivot = CS.UnityEngine.Vector2(0.5, 0.5)
	transform.anchorMax = CS.UnityEngine.Vector2(0.5, 0.5)
	transform.anchorMin = CS.UnityEngine.Vector2(0.5, 0.5)
	transform.localScale = CS.UnityEngine.Vector3.one
	transform.localPosition = CS.UnityEngine.Vector3(0, 295, 0)

	local avatarTransform = transform:Find("Avatar")
	self.nickname = avatarTransform:Find("Name").gameObject
	self.nameid   = avatarTransform:Find("NameID").gameObject
	self.rcard    = avatarTransform:Find("FangKaBg"):Find("Room").gameObject
end

function cls:OnExit()
	-- body
	if self.go then
		self.go:SetActive(false)
	end
end

function cls:OnShaking(context, ... )
	-- body
	if context.state >> 0 & 1 then
		self.nickname:GetComponent("Text").text = context.nickname
	end
	if context.state >> 1 & 1 then
		self.nameid:GetComponent("Text").text = context.nameid
	end
	if context.state >> 2 & 1 then
		self.rcard:GetComponent("Text").text = string.format("%d", context.rcard)
	end
end

return cls