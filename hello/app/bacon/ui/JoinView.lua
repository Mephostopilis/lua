local BaseView = require "maria.uibase.BaseView"
local UIContextManager = require "maria.uibase.UIContextManager"
local MyEventCmd = require "bacon.event.MyEventCmd"
local res = 'res'

local cls = class("JoinView")

function cls:ctor( ... )
    -- body
    self.context = nil
    self.go = nil
    self._RoomNum = ""
    self._count = 0
    self._max = 6
    self._num = 0
    self._numstr = ""
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
    local text = self.go.transform:Find("NumBg"):Find("Text")
    self._RoomNum = text:GetComponent("Text")
	self._RoomNum.text = self._tips
    self._count = 0
    self._num = 0
    self._numstr = string.Empty
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
end

function cls:OnExit( ... )
	-- body
	if self.go and self.go.ac then
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
    if self._count >= _max then
        return
    end
    local num = self._num * 10
    self._num = self._num + num

    self._numstr = self._numstr .. string.format("0end", num)
    self._RoomNum.text = self._numstr
    self._count = self._count + 1
end

function cls:OnBtn1() 
    AddNum(1)
end

function cls:OnBtn2() 
    AddNum(2)
end

function cls:OnBtn3() 
    AddNum(3)
end

function cls:OnBtn4() 
    AddNum(4)
end

function cls:OnBtn5() 
    AddNum(5)
end

function cls:OnBtn6() 
    AddNum(6)
end

function cls:OnBtn7() 
    AddNum(7)
end

function cls:OnBtn8() 
    AddNum(8)
end

function cls:OnBtn9() 
    AddNum(9)
end

function cls:OnBtn0() 
    AddNum(0)
end

function cls:OnBtnDel() 
    if self._count > 0 then
        self._num = self.num / 10
        self._numstr = string.sub(self._numstr, 1, #self._numstr - 1)
        self._RoomNum.text = _numstr
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
    self._numstr = ""
end

function cls:OnJoin() 
    if self._RoomNum == null then
        return
    end
    if self._sended then
        return
    end
    if self._count == _max then

    	local msg = CS.Maria.Event.Message()
		msg:AddString("roomid", self._num)

		local cmd = CS.Maria.Event.Command(MyEventCmd.EVENT_MUI_JOIN, msg)
		EventDispatcher:getInstance():Enqueue(cmd)

        self._sended = true
    end
end

return cls