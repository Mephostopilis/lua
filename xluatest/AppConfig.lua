
local cls = class("AppConfig")

function cls:ctor()
	-- body
	self.config = {}
	self.data = {}
end

function cls:LoadFile()
	-- body
	if package.loaded["configs.abConfig"] then
		package.loaded["configs.abConfig"] = nil
	end
	if package.loaded["configs.appConfig"] then
		package.loaded["configs.appConfig"] = nil
	end
	if package.loaded["configs.cardConfig"] then
		package.loaded["configs.cardConfig"] = nil
	end
	if package.loaded["configs.constsConfig"] then
		package.loaded["configs.constsConfig"] = nil
	end
	if package.loaded["configs.deskConfig"] then
		package.loaded["configs.deskConfig"] = nil
	end
	if package.loaded["configs.errorcodeConfig"] then
		package.loaded["configs.errorcodeConfig"] = nil
	end
	if package.loaded["configs.handConfig"] then
		package.loaded["configs.handConfig"] = nil
	end
	if package.loaded["configs.hutypeConfig"] then
		package.loaded["configs.hutypeConfig"] = nil
	end
	if package.loaded["configs.itemConfig"] then
		package.loaded["configs.itemConfig"] = nil
	end
	if package.loaded["configs.languageConfig"] then
		package.loaded["configs.languageConfig"] = nil
	end
	if package.loaded["configs.noticeConfig"] then
		package.loaded["configs.noticeConfig"] = nil
	end
	if package.loaded["configs.playConfig"] then
		package.loaded["configs.playConfig"] = nil
	end

	local ab = require "configs.abConfig"
	local app = require "configs.appConfig"
	local card = require "configs.cardConfig"
	local consts = require "configs.constsConfig"
	local desk = require "configs.deskConfig"
	local errorcode = require "configs.errorcodeConfig"
	local hand = require "configs.handConfig"
	local hutype = require "configs.hutypeConfig"
	local item = require "configs.itemConfig"
	local language = require "configs.languageConfig"
	local notice = require "configs.noticeConfig"
	local play = require "configs.playConfig"

	self.config['ab'] = ab
	self.config['app'] = app
	self.config['card'] = card
	self.config['consts'] = consts
	self.config['desk'] = desk
	self.config['errorcode'] = errorcode
	self.config['hand'] = hand
	self.config['hutype'] = hutype
	self.config['item'] = item
	self.config['language'] = language
	self.config['notice'] = notice
	self.config['play'] = play
end

function cls:CheckConfig()
	-- body
	return true
end

function cls:CheckCard()
	-- body
end

return cls

