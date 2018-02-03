local ps = require "xluasocket"
local crypt = require "skynet.crypt"
local sproto = require "sproto.sproto"
local parser = require "sproto.sprotoparser"
local core = require "sproto.core"
local FileUtils = require "FileUtils"
local ABLoader = require "maria.res.ABLoader"
local log = require "log"
local assert = assert

local cls = class("clientsock")

function cls:ctor(network, ... )
	-- body
	self._network = network

	self._gate_fd   = 0
	self._gate_step = 0
	
	self._index     = 0
	self._version   = 0
	
	self._RESPONSE_SESSION_NAME = {}
	self._response_session = 0

	-- sproto
	local proto = {}
	local utils = FileUtils:getInstance()
	-- proto.c2s = utils:getStringFromFile("./src/proto/proto.c2s.sproto")
	if true then
		proto.c2s = ABLoader:getInstance():LoadTextAsset("XLua/src/proto", "proto.c2s.sproto").text
	else
		proto.c2s = utils:getStringFromFile("proto/proto.c2s.sproto")
	end
	assert(type(proto.c2s) == "string")
	-- proto.s2c = utils:getStringFromFile("./src/proto/proto.s2c.sproto")
	if true then
		proto.s2c = ABLoader:getInstance():LoadTextAsset("XLua/src/proto", "proto.s2c.sproto").text
	else
		proto.s2c = utils:getStringFromFile("proto/proto.s2c.sproto")
	end
	assert(type(proto.s2c) == "string")
	local s2c_sp = core.newproto(parser.parse(proto.s2c))
	local host = sproto.sharenew(s2c_sp):host "package"
	local c2s_sp = core.newproto(parser.parse(proto.c2s))
	local send_request = host:attach(sproto.sharenew(c2s_sp))

	self._host = host
	self._send_request = send_request

	self._REQUEST = {}
	self._RESPONSE = {}
	return self
end

function cls:regiseter_request(name, cb, ud, ... )
	-- body
	local pac = self._REQUEST[name]
	if pac then
		pac.cb = cb
		pac.ud = ud
	else
		self._RESPONSE[name] = { cb = cb, ud = ud }
	end
end

function cls:register_response(name, cb, ud, ... )
 	-- body
 	local pac = self._RESPONSE[name]
	if pac then
		pac.cb = cb
		pac.ud = ud
	else
		self._RESPONSE[name] = { cb = cb, ud = ud }
	end
end 

function cls:send_request(name, args, appendix, ... )
	-- body
	if self._gate_step == 2 then
		local max = 1000000
		self._response_session = self._response_session + 1 % max
		self._RESPONSE_SESSION_NAME[self._response_session] = name
		local pac = self._RESPONSE[name]
		if pac then
			pac.appendix = appendix
		else
			self._RESPONSE[name] = { name = name, appendix = appendix }
		end

		local v = self._send_request(name, args, self._response_session)
		ps.send(self._g, self._gate_fd, v)
		log.info("send request %s: %d", name, self._response_session)
	else
		log.error("clientsock not auted, you cann't send request")
	end
end

function cls:_response(session, args, ... )
	-- body
	local name = self._RESPONSE_SESSION_NAME[session]
	local RESPONSE = self._RESPONSE
	local pac = RESPONSE[name]
	local ok, err = pcall(pac.cb, pac.ud, args, pac.appendix, ...)
	if not ok then
		log.error(err)
	end
	log.info("response %s: %s", name, session)
end

function cls:_request(name, args, response, ... )
	-- body
	log.info("request %s.", name)
	local REQUEST = self._REQUEST
	local f = REQUEST[name]
	local ok, err = pcall(f, REQUEST, args)
	if ok then
		return response(err)
	else
		log.error(err)
	end
end

function cls:_dispatch(type, ... )
	-- body
	if type == "REQUEST" then
		local ok, result = pcall(cls._request, self, ...)
		if ok then
			ps.send(self._g, self._gate_fd, result)
		end
	elseif type == "RESPONSE" then
		pcall(cls._response, self, ... )
	end
end

function cls:gate_auth(ip, port, server, uid, subid, secret, ... )
	-- body
	assert(ip and port and server and uid and subid and secret)
	local g = self._network._g
	self._gate_fd = ps.socket(g, ps.PROTOCOL_TCP, ps.HEADER_TYPE_PG, function (code, pg, ... )
		-- body
		if code == ps.SOCKET_DATA then
			if pg then
				local ok, err = pcall(self.gate_data, self, pg)
				if not ok then
					print(err)
				end
			end
		elseif code == ps.SOCKET_CLOSE then
		elseif code == ps.SOCKET_ERROR then
		end
	end)
	local err = ps.connect(g, self._gate_fd, ip, port)
	if err == 0 then
		self._index = 1
		local handshake = string.format("%s@%s#%s:%d", 
			crypt.base64encode(uid), 
			crypt.base64encode(server),
			crypt.base64encode(subid), self._index)
		local hmac = crypt.hmac64(crypt.hashkey(handshake), secret)

		-- send handshake
		print("handshake")
		ps.send(g, self._gate_fd, handshake .. ":" .. crypt.base64encode(hmac))

	
		self._gate_step = 1
	end
	return err
end

function cls:gate_connected( ... )
	-- body
	self._index = 1
	self._version = 1
	local handshake = string.format("%s@%s#%s:%d", 
		crypt.base64encode(self._uid), 
		crypt.base64encode(self._server),
		crypt.base64encode(self._subid), self._index)
	local hmac = crypt.hmac64(crypt.hashkey(handshake), self._secret)

	-- send handshake
	log.info("handshake")
	ps.send(self._g, self._gate_fd, handshake .. ":" .. crypt.base64encode(hmac))

	self._state = state.GATE
	self._gate_step = 1
end

function cls:gate_data(package, ... )
	-- body
	if self._gate_step == 1 then
		local code = tonumber(string.sub(package, 1, 3))
		if code == 200 then
			log.info("gate auth ok.")
			self._gate_step = 2
		end
		self._network:OnGateAuthed(code)
	elseif self._gate_step == 2 then
		self:_dispatch(self._host:dispatch(package))
	end
end

function cls:gate_disconnected( ... )
	-- body
	self._gate_step = 0
	self._network:OnGateDisconnected()
end

return cls