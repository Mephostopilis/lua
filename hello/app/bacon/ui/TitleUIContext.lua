local UIContext = require "maria.uibase.UIContext"
local TitleView = require "bacon.ui.TitleView"
local log = require "log"

local cls = class("MainBgUIContext", UIContext)

function cls:ctor(app)
	-- body
	self.app = app
	self.view = TitleView.new()
	self.visible = false
	self.state = 0
	self.nickname = ""
	self.nameid = ""
	self.rcard = 0
end

function cls:OnEnter()
	self.view:OnEnter(self)
end

function cls:OnPause()
	-- body
	self.visible = true
end

function cls:OnExit()
	-- body
	self.view:OnExit(self)
end

function cls:Shaking()
	-- body
	self.view:OnShaking(self)
end

function cls:SetNickname(value)
	-- body
	if type(value) ~= 'string' then
		log.error('value is not string.')
		return
	end
	if #value <= 0 then
		log.error('length of value less than 0.')
		return
	end
	self.state = self.state | ( 1 << 0)
	self.nickname = value
end

function cls:SetNameid(value)
	-- body
	if type(value) ~= 'string' then
		log.error('value is not string.')
		return
	end
	if #value <= 0 then
		log.error('length of value less than 0.')
		return
	end
	self.state = self.state | ( 1 << 1)
	self.nameid = value
end

function cls:SetRcard(value)
	-- body
	if value < 0 then
		log.error('length of value less than 0.')
		return
	end
	self.state = self.state | ( 1 << 1)
	self.rcard = value
end

return cls