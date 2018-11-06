local BaseView = require "maria.uibase.BaseView"
local log = require "log"
local res = require "res"

local cls = class("TitleView", BaseView)

function cls:ctor(context, ... )
	-- body
	self.context = context
	self.go = nil
	self.nickname = nil
	self.nameid   = nil
	self.rcard    = nil
end

function cls:OnEnter(context, ... )
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

function cls:OnPause( ... )
	-- body
end

function cls:OnShaking(context, ... )
	-- body
	if context.state & 1 > 0 then
		self.nickname:GetComponent("Text").text = context.nickname
	end
	if context.state & 2 > 0 then
		self.nameid:GetComponent("Text").text = context.nameid
	end
	if context.state & 4 > 0 then
		print(context.rcard)
		self.rcard:GetComponent("Text").text = string.format("%d", context.rcard)
	end
end

return cls