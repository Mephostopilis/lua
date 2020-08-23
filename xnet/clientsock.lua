local ps = require "xluasocket"
local crypt = require "skynet.crypt"
local core = require "sproto.core"
local sproto = require "lib.sproto"
local parser = require "lib.sprotoparser"
local log = require "lib.log"
local res = require "lib.res"
local stp = require "lib.StackTracePlus"
local traceback = stp.stacktrace
local assert = assert
local max = 1000000
local cls = class("clientsock")

function cls:ctor(manager, server, uid, subid, secret)
	self._network = manager
	self._server = server
	self._uid = uid
	self._subid = subid
	self._secret = secret

	self.fd = 0
	self._index = 0
	self._version = 0
	self._step = 0

	self._RESPONSE_SESSION_NAME = {}
	self._response_session = 0

	-- sproto
	local proto = {}
	proto.c2s = res.LoadTextAsset("Assets/Art/proto/c2s.sproto")
	proto.s2c = res.LoadTextAsset("Assets/Art/proto/s2c.sproto")

	assert(type(proto.s2c) == "string")
	assert(type(proto.c2s) == "string")
	local s2c_sp = core.newproto(parser.parse(proto.s2c))
	local host = sproto.sharenew(s2c_sp):host "package"
	local c2s_sp = core.newproto(parser.parse(proto.c2s))
	local send_request = host:attach(sproto.sharenew(c2s_sp))

	self._host = host
	self._send_request = send_request

	return self
end

function cls:send_request(name, args)
	if self._step == 2 then
		-- if err == -1 then
		-- 	self._login_step = 0
		-- 	log.error("login send error.")
		-- 	return
		-- else
		-- 	-- log.info("send request %s: %d", name, self._response_session)
		-- 	-- log.info("login send bytes = %d", bytes)
		-- end
		log.info("-------------------send:%s", name)
		self._response_session = (self._response_session + 1) % max
		self._RESPONSE_SESSION_NAME[self._response_session] = name
		local v = self._send_request(name, args, self._response_session)
		local err = ps.send(self.fd, v)
	else
		log.error("clientsock not authed, you cann't send request")
	end
end

function cls:_response(session, args, ...)
	local name = self._RESPONSE_SESSION_NAME[session]
	local pac = assert(self._network.OnGateData)
	local ok, err = xpcall(pac, traceback, self.fd, "response", name, args, ...)
	if not ok then
		log.error("response [%s]: [session = %s] [err = %s].", name, session, err)
	end
end

function cls:_request(name, args, response, ...)
	local pac = assert(self._network.OnGateData)
	local ok, err = xpcall(pac, traceback, self.fd, "request", name, args)
	if ok then
		if err then
			return response(err)
		end
	else
		log.error(err)
	end
end

function cls:_dispatch(type, ...)
	if type == "REQUEST" then
		local ok, result = xpcall(cls._request, traceback, self, ...)
		if ok then
			if result then
				local err = ps.send(self.fd, result)
				if err == -1 then
					log.error("send result error.")
				end
			end
		end
	elseif type == "RESPONSE" then
		local ok, err = xpcall(cls._response, traceback, self, ...)
		if not ok then
			log.error(err)
		end
	end
end

function cls:connected(...)
	self._index = 1
	local handshake =
		string.format(
		"%s@%s#%s:%d",
		crypt.base64encode(self._uid),
		crypt.base64encode(self._server),
		crypt.base64encode(self._subid),
		self._index
	)
	local hmac = crypt.hmac64(crypt.hashkey(handshake), self._secret)

	-- send handshake
	local err = ps.send(self.fd, handshake .. ":" .. crypt.base64encode(hmac))
	if err == -1 then
		self._login_step = 0
		log.error("clientsock send error.")
		return
	end
	self._step = 1
end

function cls:open(...)
end

function cls:data(package, ...)
	if self._step == 1 then
		local code = tonumber(string.sub(package, 1, 3))
		if code == 200 then
			log.info("gate auth ok.")
			self._step = 2
		else
			self._step = 0
		end
		local ok, err = xpcall(self._network.OnGateAuthed, traceback, self.fd, code)
		if not ok then
			log.error(err)
		end
	elseif self._step == 2 then
		self:_dispatch(self._host:dispatch(package))
	end
end

function cls:disconnected()
	self._step = 0
	self._network.OnGateDisconnected(self.fd)
end

function cls:close()
	ps.closesocket(self.fd)
end

function auth(mgr, ip, port, server, uid, subid, secret)
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
