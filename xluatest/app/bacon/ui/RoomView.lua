local BaseView = require "maria.uibase.BaseView"
local UIContextManager = require "maria.uibase.UIContextManager"
local MyEventCmd = require "bacon.event.MyEventCmd"
local CreateRoomUIContext = require "bacon.ui.CreateRoomUIContext"
local EventDispatcher = require "event_dispatcher"
local log = require "log"
local res = require "res"

local cls = class("RoomView", BaseView)

function cls:ctor( ... )
    -- body
    self.go = nil
end

function cls:OnEnter(context, ... )
              -- body
   if not self.go then    
          local original = res.LoadGameObject("UI", "RoomView")
          if not original then
            log.error("original is nil.")
            return
          end
          local go = CS.UnityEngine.GameObject.Instantiate(original)
          go.transform:SetParent(context.app.uicontextMgr.buicanvas.transform)
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
          local cmd = CS.Maria.Event.Command(MyEventCmd.EVENT_MUI_SHOWCREATE)
          EventDispatcher.Enqueue(cmd)
   end)

   local joinBtn = rectTransform:Find("Join"):GetComponent("Button")
   joinBtn.onClick:AddListener(function ( ... )
          local cmd = CS.Maria.Event.Command(MyEventCmd.EVENT_JOIN_SHOW)
          EventDispatcher.Enqueue(cmd)
   end)
end


return cls