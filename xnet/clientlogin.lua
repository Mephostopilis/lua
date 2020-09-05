local crypt = require "skynet.crypt"
local ps = require "xluasocket"
local timesync = require "xluasocket.timesync"
local cls = {}

function cls:connected()
	if self.fd ~= 0 then
		self.step = 1
		return true
	else
		return false
	end
end

function cls:data(d)
	self.buf = self.buf .. d
	local line, left = timesync.unpack("line", self.buf)
	self.buf = left
	print(line, left)
	if self.step == 1 then
		local challenge = crypt.base64decode(line)
		local clientkey = crypt.randomkey()
		local err = ps.send(self.fd, timesync.pack("line", crypt.base64encode(crypt.dhexchange(clientkey))))
		if err == -1 then
			print("login send randomkey err")
			self.step = 0
			return
		end
		print("login send randomkey ok.")
		self.challenge = challenge
		self.clientkey = clientkey
		self.step = self.step + 1
	elseif self._step == 2 then
		local secret = crypt.dhsecret(crypt.base64decode(line), self._clientkey)
		print("sceret is %s", crypt.hexencode(secret))
		local hmac = crypt.hmac64(self._challenge, secret)
		local err, bytes = ps.send(self.fd, timesync.pack("line", crypt.base64encode(hmac)))
		if err == -1 then
			self.step = 0
			print("login send error.")
			return
		end
		print("login send challenge ok")
		self._secret = secret
		local token =
			string.format(
			"%s@%s:%s",
			crypt.base64encode(self._username),
			crypt.base64encode(self._server),
			crypt.base64encode(self._password)
		)
		local etoke = crypt.desencode(self._secret, token)
		local err = ps.send(self.fd, timesync.pack("line", crypt.base64encode(etoke)))
		if err == -1 then
			self.step = 0
			print("login send error.")
			return
		end
		log.info("login send etoke ok")
		self.step = self.step + 1
	elseif self.step == 3 then
		ps.closesocket(self.fd)
		local code = tonumber(string.sub(line, 1, 4))
		log.info("login code: %d", code)
		if code == 200 then
			local xline = crypt.base64decode(string.sub(line, 5))
			local _1 = string.find(xline, "#")
			local _2 = string.find(xline, "@", _1 + 1)
			local uid = tonumber(string.sub(xline, 1, _1 - 1))
			local subid = tonumber(string.sub(xline, _1 + 1, _2 - 1))
			local gate = string.sub(xline, _2 + 1)
			self.step = 0 -- close login setp
			local ok, err = pcall(self.network.OnLoginAuthed, self.fd, code, uid, subid, self._secret)
			if not ok then
				log.error(err)
			end
		else
			local ok, err = pcall(self.network.OnLoginAuthed, self.fd, code, line)
			if not ok then
				log.error(err)
			end
		end
	end
end

function cls:disconnected()
	local ok, err = pcall(self.network.OnLoginDisconnected, self.fd)
	if not ok then
		log.error(err)
	end
end

function cls:close()
	ps.closesocket(self.fd)
end

function auth(mgr, ip, port, u, p, server)
	assert(ip and port and u and p and server)
	local err = ps.connect(ip, port)
	if err > 0 then
		local so = {
			network = mgr,
			username = u,
			password = p,
			server = server,
			fd = err,
			step = 0,
			buf = "",
			clientkey = "",
			challenge = "",
			secret = ""
		}
		local mt = {
			__index = cls
		}
		setmetatable(so, mt)
		return so
	else
		return nil
	end
end

return auth
