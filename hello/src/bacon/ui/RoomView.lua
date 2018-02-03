local MyEventCmd = require "bacon.event.MyEventCmd"
local EventDispatcher = require "maria.event.EventDispatcher"
local BaseView = require "maria.uibase.BaseView"
local UIContextManager = require "maria.uibase.UIContextManager"
local CreateRoomUIContext = require "bacon.ui.CreateRoomUIContext"
local ABLoader = require "maria.res.ABLoader"

local cls = class("RoomView", BaseView)

function cls:ctor( ... )
    -- body
    self.go = nil

end

function cls:OnEnter(context, ... )
              -- body
       if not self.go then    
              local original = ABLoader:getInstance():LoadGameObject("UI", "RoomView")
              local go = CS.UnityEngine.GameObject.Instantiate(original)
              go.transform:SetParent(UIContextManager:getInstance().buicanvas.transform)
              self.go = go
       end

       local rectTransform = self.go.transform
       rectTransform.pivot = CS.UnityEngine.Vector2(0.5, 0.5)
       rectTransform.anchorMax = CS.UnityEngine.Vector2(0.5, 0.5)
       rectTransform.anchorMin = CS.UnityEngine.Vector2(0.5, 0.5)
       rectTransform.localScale = CS.UnityEngine.Vector3.one
       rectTransform.anchoredPosition3D = CS.UnityEngine.Vector3.zero
       rectTransform.sizeDelta = CS.UnityEngine.Vector2(100, 100)

       local createBtn = rectTransform:Find("Create"):GetComponent("Button")
       createBtn.onClick:AddListener(function ( ... )
              local cmd = CS.maria.event.Command(MyEventCmd.EVENT_MUI_SHOWCREATE)
              EventDispatcher:getInstance():Enqueue(cmd)
       end)

       local joinBtn = rectTransform:Find("Join"):GetComponent("Button")
       joinBtn.onClick:AddListener(function ( ... )
              local cmd = CS.maria.event.Command(MyEventCmd.EVENT_JOIN_SHOW)
              EventDispatcher:getInstance():Enqueue(cmd)
       end)
end


return cls