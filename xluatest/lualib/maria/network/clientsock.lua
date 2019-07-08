local ps = require "xluasocket"
local crypt = require "skynet.crypt"
local sproto = require "sproto"
local parser = require "sprotoparser"
local core = require "sproto.core"
local FileUtils = require "FileUtils"
local log = require "log"
local res = require "res"
local traceback = debug.traceback
local assert = assert
local debug = debug
local XLua = false

local cls = class("clientsock")

function cls:ctor(network, server, uid, subid, secret)
	-- body
	self._network = network
	self._server  = server
	self._uid     = uid
	self._subid   = subid
	self._secret  = secret

	self.fd   = 0
	self._gate_step = 0
	
	self._index     = 0
	self._version   = 0
	
	self._RESPONSE_SESSION_NAME = {}
	self._response_session = 0

	-- sproto
	local proto = {}
	local utils = FileUtils:getInstance()
	if XLua then
		proto.c2s = res.LoadTextAsset("XLua/app/proto", "c2s.sproto").text
	else
		proto.c2s = utils:getStringFromFile("proto/c2s.sproto")
	end
	assert(type(proto.c2s) == "string")
	if XLua then
		proto.s2c = res.LoadTextAsset("XLua/app/proto", "s2c.sproto").text
	else
		proto.s2c = utils:getStringFromFile("proto/s2c.sproto")
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
		self._REQUEST[name] = { cb = cb, ud = ud }
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
		if appendix then
			local pac = self._RESPONSE[name]
			if pac then
				pac.appendix = appendix
			end
		end

		local v = self._send_request(name, args, self._response_session)
		local err = ps.send(self.fd, v)
		if err == -1 then
			self._login_step = 0
			log.error("login send error.")
			return
		else
			-- log.info("send request %s: %d", name, self._response_session)
			-- log.info("login send bytes = %d", bytes)
		end
	else
		log.error("clientsock not auted, you cann't send request")
	end
end

function cls:_response(session, args, ... )
	-- body
	local name = self._RESPONSE_SESSION_NAME[session]
	local RESPONSE = self._RESPONSE
	local pac = RESPONSE[name]
	if pac then
		local func = assert(pac.cb)
		local ud = assert(pac.ud)
		local ok, err = xpcall(func, traceback, ud, args, pac.appendix, ...)
		if not ok then
			log.error(err)
		end
	else
		log.error("response [%s]: [session = %s] is nil.", name, session)
	end
end

function cls:_request(name, args, response, ... )
	-- body
	-- log.info("request %s.", name)
	local REQUEST = self._REQUEST
	local pac = REQUEST[name]
	if pac then
		local cb = pac.cb
		local ud = pac.ud
		local ok, err = pcall(cb, ud, args)
		if ok then
			return response(err)
		else
			log.error(err)
		end
	else
		log.error("request name = %s is nil", name)
	end
end

function cls:_dispatch(type, ... )
	-- body
	if type == "REQUEST" then
		local ok, result = pcall(cls._request, self, ...)
		if ok then
			if result then
				local err = ps.send(self.fd, result)
				if err == -1 then
					log.error('send result error.')
				end
			else
				log.error("request result is nil")
			end
		end
	elseif type == "RESPONSE" then
		local ok, err = pcall(cls._response, self, ... )
		if not ok then
			log.error(err)
		end
	end
end

function cls:connected( ... )
	-- body
	-- err = ps.start(g, self.fd)
	-- if err ~= 0 then
	-- 	log.error("clientsock start failture.")
	-- 	return
	-- end
	self._index = 1
	local handshake = string.format("%s@%s#%s:%d", 
		crypt.base64encode(self._uid), 
		crypt.base64encode(self._server),
		crypt.base64encode(self._subid), self._index)
	local hmac = crypt.hmac64(crypt.hashkey(handshake), self._secret)

	-- send handshake
	local err = ps.send(self.fd, handshake .. ":" .. crypt.base64encode(hmac))
	if err == -1 then
		self._login_step = 0
		log.error("clientsock send error.")
		return
	end
	self._gate_step = 1
end

function cls:open( ... )
	-- body
end

function cls:data(package, ... )
	-- body
	if self._gate_step == 1 then
		local code = tonumber(string.sub(package, 1, 3))
		if code == 200 then
			log.info("gate auth ok.")
			self._gate_step = 2
		else
			self._gate_step = 0
		end
		local ok, err = pcall(self._network.OnGateAuthed, self.fd, code)
		if not ok then
			log.error(err)
		end
	elseif self._gate_step == 2 then
		self:_dispatch(self._host:dispatch(package))
	end
end

function cls:disconnected( ... )
	-- body
	self._gate_step = 0
	self._network.OnGateDisconnected(self.fd)
end

function auth(mgr, ip, port, server, uid, subid, secret)
	-- body
	assert(ip and port and server and uid and subid and secret)
	local err = ps.connect(ip, port)
	if err ~= 0 then
		ps.pack(err, ps.HEADER_TYPE_PG)
		ps.unpack(err, ps.HEADER_TYPE_PG)
		local so = cls.new(mgr, server, uid, subid, secret)
		so.fd = err		
		return so
	end
end

return auth