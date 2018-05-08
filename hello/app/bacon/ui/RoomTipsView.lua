local EventDispatcher = require "event_dispatcher"
local log = require "log"
local res = require "res"
local language = require "language"

local cls = class("RoomTipsView")

function cls:ctor( ... )
    -- body
    self.go = nil
end

function cls:OnEnter(context, ... )
              -- body
    self.context = context
    if not self.go then
        local original = res.LoadGameObject("UI", "RoomTipsWnd")
        if not original then
            log.error("original is nil.")
            return
        end
        local go = CS.UnityEngine.GameObject.Instantiate(original)
        go.transform:SetParent(context.appContext.uicontextMgr.buicanvas.transform)
        self.go = go
    end

    local rectTransform = self.go.transform
    rectTransform.pivot = CS.UnityEngine.Vector2(0.5, 0.5)
    rectTransform.anchorMax = CS.UnityEngine.Vector2(1, 1)
    rectTransform.anchorMin = CS.UnityEngine.Vector2(0, 0)
    rectTransform.localScale = CS.UnityEngine.Vector3.one
    rectTransform.anchoredPosition3D = CS.UnityEngine.Vector3.zero
    rectTransform.sizeDelta = CS.UnityEngine.Vector2(100, 100)

    local content = rectTransform:Find("Content")
    content:GetComponent("Text").text = language(6)

    local ok = rectTransform:Find("OK")
    local okBtn = ok:GetComponent("Button")
    okBtn.onClick:AddListener(function ( ... )
        self.context.appContext.gameSystems.joinSystem:SendRejoin()
        if self.context.visible then
            self.context.appContext.uicontextMgr:Pop()
        end
    end)
    ok:Find("Text"):GetComponent("Text").text = language(7)

    local cancel = rectTransform:Find("Cancel")
    local cancelBtn = cancel:GetComponent("Button")
    cancelBtn.onClick:AddListener(function ( ... )
        if self.context.visible then
            self.context.appContext.uicontextMgr:Pop()
        end  
    end)
    cancel:Find("Text"):GetComponent("Text").text = language(8)
end

function cls:OnExit( ... )
    -- body
    if self.go and self.go.activeSelf then
        self.go:SetActive(false)
    end
end

return cls