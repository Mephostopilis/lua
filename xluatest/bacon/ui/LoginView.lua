local BaseView = require "maria.uibase.BaseView"
local MyEventCmd = require "bacon.event.MyEventCmd"
local log = require "log"
local res = require "res"
local EventDispatcher = require "event_dispatcher"
local UIContextMgr = require "maria.uibase.UIContextManager"

local cls = class("LoginView", BaseView)

function cls:ctor(context, ... )
	-- body
	self.context = context
	self.go = nil
end

function cls:OnEnter(context, ... )
	-- body'
	self.context = context
	if not self.go then
		local original = res.LoadGameObject("UI", "LoginPanel")
		local go = CS.UnityEngine.GameObject.Instantiate(original)
		go.transform:SetParent(UIContextMgr.getInstance().buicanvas.transform)
		self.go	= go
	end

	local transform = self.go.transform
	transform.pivot = CS.UnityEngine.Vector2(0.5, 0.5)
	transform.anchorMax = CS.UnityEngine.Vector2(0.5, 0.5)
	transform.anchorMin = CS.UnityEngine.Vector2(0.5, 0.5)
	transform.localScale = CS.UnityEngine.Vector3.one
	transform.localPosition = CS.UnityEngine.Vector3(0, 0, 0)

	local username = transform:Find("Username"):GetComponent("InputField")
	local password = transform:Find("Password"):GetComponent("InputField")

	local wxBtn = transform:Find("Weixin"):GetComponent("Button")
	wxBtn.onClick:AddListener(function ( ... )
		-- body
		-- local username = self.context.appContext.config.config.app.username
		-- assert(username)
		local u = username.text
		if #u > 0 then
			local msg = CS.Maria.Event.Message()
			msg:AddString("username", u)
			msg:AddString("password", "Password")
			msg:AddString("server", "sample1")
			local cmd = CS.Maria.Event.Command(MyEventCmd.EVENT_LOGIN, msg)
			EventDispatcher.Enqueue(cmd)
		end
	end)
end

function cls:OnPause( ... )
	-- body
	if self.go then
		self.go:SetActive(false)
	end
end

return cls