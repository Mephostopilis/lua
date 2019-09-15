local crypt = require "skynet.crypt"
local ps = require "xluasocket"
local log = require "log"

local cls = class("clientlogin")

function cls:ctor(network, u, p, server)
	-- body
	assert(network)
	self._network = network
	self._username = u
	self._password = p
	self._server = server

	self.fd = false
	self._login_step = 0

	self._clientkey = ""
	self._challenge = ""
	self._secret = ""

	return self
end

function cls:connected()
	-- body
	-- local err = ps.start(self.fd)
	-- if err == 0 then
	-- end
	self._login_step = 1
end

function cls:open()
end

function cls:data(line)
	if self._login_step == 1 then
		local challenge = crypt.base64decode(line)
		local clientkey = crypt.randomkey()
		local err = ps.send(self.fd, crypt.base64encode(crypt.dhexchange(clientkey)))
		if err == -1 then
			log.error("login send randomkey")
			self._login_step = 0
			return
		end
		log.info("login send randomkey ok.")
		self._challenge = challenge
		self._clientkey = clientkey
		self._login_step = self._login_step + 1
	elseif self._login_step == 2 then
		local secret = crypt.dhsecret(crypt.base64decode(line), self._clientkey)
		log.info("sceret is %s", crypt.hexencode(secret))
		local hmac = crypt.hmac64(self._challenge, secret)
		local err, bytes = ps.send(self.fd, crypt.base64encode(hmac))
		if err == -1 then
			self._login_step = 0
			log.error("login send error.")
			return
		end
		log.info("login send challenge ok")
		self._secret = secret
		log.info("%s:%s:%s", self._username, self._server, self._password)
		local token =
			string.format(
			"%s@%s:%s",
			crypt.base64encode(self._username),
			crypt.base64encode(self._server),
			crypt.base64encode(self._password)
		)
		local etoke = crypt.desencode(self._secret, token)
		local err = ps.send(self.fd, crypt.base64encode(etoke))
		if err == -1 then
			self._login_step = 0
			log.error("login send error.")
			return
		end
		log.info("login send etoke ok")
		self._login_step = self._login_step + 1
	elseif self._login_step == 3 then
		local code = tonumber(string.sub(line, 1, 4))
		log.info("login code: %d", code)
		if code == 200 then
			local xline = crypt.base64decode(string.sub(line, 5))
			local _1 = string.find(xline, "#")
			local _2 = string.find(xline, "@", _1 + 1)
			local uid = tonumber(string.sub(xline, 1, _1 - 1))
			local subid = tonumber(string.sub(xline, _1 + 1, _2 - 1))
			local gate = string.sub(xline, _2 + 1)
			self._login_step = 0 -- close login setp
			local ok, err = pcall(self._network.OnLoginAuthed, self.fd, code, uid, subid, self._secret)
			if not ok then
				log.error(err)
			end
		else
			local ok, err = pcall(self._network.OnLoginAuthed, self.fd, code, line)
			if not ok then
				log.error(err)
			end
		end
	end
end

function cls:disconnected()
	local ok, err = pcall(self._network.OnLoginDisconnected, self.fd)
	if not ok then
		log.error(err)
	end
end

function auth(mgr, ip, port, u, p, server)
	assert(ip and port and u and p and server)
	local err = ps.connect(ip, port)
	if err > 0 then
		ps.pack(err, ps.HEADER_TYPE_LINE)
		ps.unpack(err, ps.HEADER_TYPE_LINE)
		local so = cls.new(mgr, u, p, server)
		so.fd = err
		return so
	end
end

return auth
