local BaseView = require "maria.uibase.BaseView"
local MyEventCmd = require "bacon.event.MyEventCmd"
local log = require "log"
local res = require "res"

local cls = class("BottomView", BaseView)

function cls:ctor(context, ... )
	-- body
	self.context = context
	self.go = nil
end

function cls:OnEnter(context, go, ... )
	-- body
	local original = res.LoadGameObject("UI", "bottom")
	local go = CS.UnityEngine.GameObject.Instantiate(original)
	go.transform:SetParent(context.app.uicontextMgr.buicanvas.transform)
	self.go	= go
	local transform = self.go.transform
	transform.pivot = CS.UnityEngine.Vector2(0.5, 0.5)
	transform.anchorMax = CS.UnityEngine.Vector2(0.5, 0.5)
	transform.anchorMin = CS.UnityEngine.Vector2(0.5, 0.5)
	transform.localScale = CS.UnityEngine.Vector3.one
	transform.localPosition = CS.UnityEngine.Vector3(0, -375, 0)

	-- local wxBtn = transform:Find("Weixin"):GetComponent("Button")
	-- wxBtn.onClick:AddListener(function ( ... )
	-- 	-- body
	-- 	local msg = CS.Maria.Event.Message()
	-- 	msg:AddString("username", 12342)
	-- 	msg:AddString("password", "Password")
	-- 	msg:AddString("server", "sample1")
	-- 	local cmd = CS.Maria.Event.Command(MyEventCmd.EVENT_LOGIN, msg)
	-- 	EventDispatcher:getInstance():Enqueue(cmd)

	-- end)
end

function cls:OnExit()
	-- body
	log.info('***************************BottomView')
	if self.go then
		self.go:SetActive(false)
	end
end

return cls