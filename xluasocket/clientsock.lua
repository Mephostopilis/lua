local ps = require "xluasocket"
local timesync = require "xluasocket.timesync"
local crypt = require "skynet.crypt"
local core = require "sproto.core"
local sproto = require "sproto"
local parser = require "sprotoparser"
local traceback = debug.traceback
local string_pack = timesync.pack
local string_unpack = timesync.unpack
local assert = assert
local max = 1000000
local cls = {}

function cls:send_request(name, args)
	if self.step == 2 then
		print("-------------------send:", name)
		self._response_session = (self._response_session + 1) % max
		self._RESPONSE_SESSION_NAME[self._response_session] = name
		local v = self._send_request(name, args, self._response_session)
		local err = ps.send(self.fd, string_pack("pg", v))
		return err
	else
		print("clientsock not authed, you cann't send request")
	end
end

function cls:_response(session, args, ...)
	local name = self._RESPONSE_SESSION_NAME[session]
	local f = assert(self.network.OnData)
	f(self.fd, "response", name, args, ...)
end

function cls:_request(name, args, response, ...)
	local f = assert(self.network.OnData)
	local r = f(self.fd, "request", name, args)
	if r then
		return response(r)
	end
end

function cls:_dispatch(type, ...)
	if type == "REQUEST" then
		local ok, result = xpcall(cls._request, traceback, self, ...)
		if ok then
			if result then
				local err = ps.send(self.fd, string_pack("pg", result))
				if err == -1 then
					print("err: send result error.")
					local f = assert(self.OnError)
					f(self.fd)
				end
			end
		end
	elseif type == "RESPONSE" then
		self:_response(...)
	end
end

function cls:connected()
	self.index = 1
	local handshake =
		string.format(
		"%s@%s#%s:%d",
		crypt.base64encode(self.uid),
		crypt.base64encode(self.server),
		crypt.base64encode(self.subid),
		self.index
	)
	local hmac = crypt.hmac64(crypt.hashkey(handshake), self.secret)

	-- send handshake
	local err = ps.send(self.fd, timesync.pack("pg", handshake .. ":" .. crypt.base64encode(hmac)))
	if err == -1 then
		self.step = 0
		local f = assert(self.OnError)
		f(self.fd)
		return
	end
	self.step = 1
end

function cls:data(d)
	self.buf = self.buf .. d
	if self.step == 1 then
		local package, left = timesync.unpack("pg", self.buf)
		self.buf = left
		if #package <= 0 then
			return
		end
		local code = tonumber(string.sub(package, 1, 3))
		if code == 200 then
			self.step = 2
		else
			self.step = 0
		end
		self.network.OnGateAuthed(self.fd, code)
	elseif self.step == 2 then
		while #self.buf > 0 do
			local package, left = timesync.unpack("pg", self.buf)
			self.buf = left
			if #package <= 0 then
				return
			end
			self:_dispatch(self._host:dispatch(package))
		end
	end
end

function cls:disconnected()
	self.step = 0
	self.network.OnDisconnected(self.fd)
end

function cls:close()
	ps.closesocket(self.fd)
end

function auth(mgr, ip, port, server, uid, subid, secret)
	assert(ip and port and server and uid and subid and secret)
	local err = ps.connect(ip, port)
	if err > 0 then
		local so = {}
		so.network = mgr
		so.server = server
		so.uid = uid
		so.subid = subid
		so.secret = secret

		so.fd = err
		so.index = 0
		so.version = 0
		so.step = 0
		so.buf = ""
		so.ty = "client"

		so._RESPONSE_SESSION_NAME = {}
		so._response_session = 0

		-- sproto
		local proto = {}
		if res then
			proto.c2s = res.LoadTextAsset("Assets/Art/proto/c2s.sproto")
			proto.s2c = res.LoadTextAsset("Assets/Art/proto/s2c.sproto")
		else
			local fd = io.open("./proto/c2s.sproto")
			proto.c2s = fd:read("*a")
			fd:close()
			local fd = io.open("./proto/s2c.sproto")
			proto.s2c = fd:read("*a")
			fd:close()
		end

		assert(type(proto.s2c) == "string")
		assert(type(proto.c2s) == "string")
		local s2c_sp = core.newproto(parser.parse(proto.s2c))
		local host = sproto.sharenew(s2c_sp):host "package"
		local c2s_sp = core.newproto(parser.parse(proto.c2s))
		local send_request = host:attach(sproto.sharenew(c2s_sp))

		so._host = host
		so._send_request = send_request

		setmetatable(so, {__index = cls})
		return so
	else
		return nil
	end
end

return auth
