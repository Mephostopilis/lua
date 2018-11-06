local typeid = require "typeid"
local context = require "context"
local clientsock = require "clientsock"
local gamecontroller = require "gamecontroller"

local cls = class("pool")

function cls:ctor( ... )
	-- body
end

function cls:CreateContext( ... )
	-- body
	return context.new( ... )
end

function cls:CreateClientSock( ... )
	-- body
	return clientsock.new( ... )
end

function cls:CreateGameController( ... )
	-- body
	return gamecontroller.new( ... )
end

return cls