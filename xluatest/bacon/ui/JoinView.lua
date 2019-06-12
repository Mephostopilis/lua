local BaseView = require "maria.uibase.BaseView"
local NetworkMgr = require "maria.network.NetworkMgr"
local UIContextManager = require "maria.uibase.UIContextManager"
local MyEventCmd = require "bacon.event.MyEventCmd"
local res = require 'res'
local log = require 'log'

local cls = class("JoinView")

function cls:ctor( ... )
    -- body
    self.context = nil
    self.go = nil
    self._RoomNum = ""
    self._count = 0
    self._max = 6
    self._num = 0
    self._sended = false
    self._tips = "请输入六位数字"
end

function cls:OnEnter(context, ... )
	-- body
	self.context = context
	if not self.go then
        local original = res.LoadGameObject("UI", "JoinView")
        if not original then
            log.error("LoadGameObject UI/JoinView failture.")
            return
        end
        local go = CS.UnityEngine.GameObject.Instantiate(original)
        go.transform:SetParent(context.app.uicontextMgr.buicanvas.transform)
        self.go = go
    else
        self.go:SetActive(true)
    end

    -- 获取各个组件
    local text = self.go.transform:Find("NumBg"):Find("Text")
    self._RoomNum = text:GetComponent("Text")
    self._RoomNum.text = self._tips
    self._count = 0
    self._num = 0
    self._sended = false

    local rectTransform = self.go.transform
    rectTransform.pivot = CS.UnityEngine.Vector2(0.5, 0.5)
    rectTransform.anchorMax = CS.UnityEngine.Vector2(0.5, 0.5)
    rectTransform.anchorMin = CS.UnityEngine.Vector2(0.5, 0.5)
    rectTransform.localScale = CS.UnityEngine.Vector3.one
    rectTransform.anchoredPosition3D = CS.UnityEngine.Vector3.zero

    local close = rectTransform:Find("Close")
    close:GetComponent("Button").onClick:AddListener(function ( ... )
        -- body
        self:OnClose()
    end)
    local ok = rectTransform:Find('Ok')
    ok:GetComponent('Button').onClick:AddListener(function () self:OnJoin() end)

    local bgGo = rectTransform:Find('Bg')
    local bgTransform = bgGo.transform
    local btn0Go = bgTransform:Find('Btn0')
    btn0Go:GetComponent('Button').onClick:AddListener(function () self:OnBtn0() end)
    local btn1Go = bgTransform:Find('Btn1')
    btn1Go:GetComponent('Button').onClick:AddListener(function () self:OnBtn1() end)
    local btn2Go = bgTransform:Find('Btn2')
    btn2Go:GetComponent('Button').onClick:AddListener(function () self:OnBtn2() end)
    local btn3Go = bgTransform:Find('Btn3')
    btn3Go:GetComponent('Button').onClick:AddListener(function () self:OnBtn3() end)
    local btn4Go = bgTransform:Find('Btn4')
    btn4Go:GetComponent('Button').onClick:AddListener(function () self:OnBtn4() end)
    local btn5Go = bgTransform:Find('Btn5')
    btn5Go:GetComponent('Button').onClick:AddListener(function () self:OnBtn5() end)
    local btn6Go = bgTransform:Find('Btn6')
    btn6Go:GetComponent('Button').onClick:AddListener(function () self:OnBtn6() end)
    local btn7Go = bgTransform:Find('Btn7')
    btn7Go:GetComponent('Button').onClick:AddListener(function () self:OnBtn7() end)
    local btn8Go = bgTransform:Find('Btn8')
    btn8Go:GetComponent('Button').onClick:AddListener(function () self:OnBtn8() end)
    local btn9Go = bgTransform:Find('Btn9')
    btn9Go:GetComponent('Button').onClick:AddListener(function () self:OnBtn9() end)
    local btnClearGo = bgTransform:Find('BtnClear')
    btnClearGo:GetComponent('Button').onClick:AddListener(function () self:OnBtnClr() end)
    local btnDelGo = bgTransform:Find('BtnDel')
    btnDelGo:GetComponent('Button').onClick:AddListener(function () self:OnBtnDel() end)
end

function cls:OnExit( ... )
	-- body
	if self.go and self.go.activeSelf then
		self.go:SetActive(false)
	end
end

function cls:OnClose( ... )
    -- body
	if self.context.visible then
		UIContextManager:getInstance():Pop()
	end
end

function cls:AddNum(num)
    if self._count >= self._max then
        return
    end
    self._num = self._num * 10 + num

    self._RoomNum.text = string.format("%d", self._num)
    self._count = self._count + 1
end

function cls:OnBtn1() 
    self:AddNum(1)
end

function cls:OnBtn2() 
    self:AddNum(2)
end

function cls:OnBtn3() 
    self:AddNum(3)
end

function cls:OnBtn4() 
    self:AddNum(4)
end

function cls:OnBtn5() 
    self:AddNum(5)
end

function cls:OnBtn6() 
    self:AddNum(6)
end

function cls:OnBtn7() 
    self:AddNum(7)
end

function cls:OnBtn8() 
    self:AddNum(8)
end

function cls:OnBtn9() 
    self:AddNum(9)
end

function cls:OnBtn0() 
    self:AddNum(0)
end

function cls:OnBtnDel() 
    if self._count > 0 then
        self._num = math.floor(self._num / 10)
        self._RoomNum.text = string.format("%d", self._num)
        self._count = self._count - 1
        if self._count <= 0 then
            self._RoomNum.text = self._tips
        end
    end
end

function cls:OnBtnClr() 
    self._RoomNum.text = self._tips
    self._count = 0
    self._num = 0
end

function cls:OnJoin()
    if self._sended then
        return
    end
    if self._count == self._max then
        self._sended = true
        local request = {}
        request.roomid = self._num
        NetworkMgr:getInstance().client:send_request("join", request)
        UIContextManager:getInstance():Pop()
    end
end

return cls