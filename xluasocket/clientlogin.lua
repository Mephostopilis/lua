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
	if #line <= 0 then
		return
	end
	if self.step == 1 then
		local challenge = crypt.base64decode(line)
		local clientkey = crypt.randomkey()
		local hex = crypt.base64encode(crypt.dhexchange(clientkey))
		local err = ps.send(self.fd, timesync.pack("line", hex))
		if err == -1 then
			print("err: login send randomkey, err = ", err)
			self.step = 0
			local f = assert(self.OnError)
			f(self.fd)
			return
		end
		self.challenge = challenge
		self.clientkey = clientkey
		self.step = self.step + 1
	elseif self.step == 2 then
		self.secret = crypt.dhsecret(crypt.base64decode(line), self.clientkey)
		local hmac = crypt.hmac64(self.challenge, self.secret)
		local err, bytes = ps.send(self.fd, timesync.pack("line", crypt.base64encode(hmac)))
		if err == -1 then
			print("err: login send error.")
			self.step = 0
			local f = assert(self.OnError)
			f(self.fd)
			return
		end
		print("login send challenge ok")
		local token =
			string.format(
			"%s@%s:%s",
			crypt.base64encode(self.username),
			crypt.base64encode(self.server),
			crypt.base64encode(self.password)
		)
		local etoke = crypt.desencode(self.secret, token)
		local err = ps.send(self.fd, timesync.pack("line", crypt.base64encode(etoke)))
		if err == -1 then
			self.step = 0
			print("err: login send error.")
			local f = assert(self.OnError)
			f(self.fd)
			return
		end
		print("login send etoke ok")
		self.step = self.step + 1
	elseif self.step == 3 then
		self.step = 0 -- close login setp
		local f = assert(self.network.OnLoginAuthed)
		local code = tonumber(string.sub(line, 1, 4))
		if code == 200 then
			local xline = crypt.base64decode(string.sub(line, 5))
			local _1 = string.find(xline, "#")
			local _2 = string.find(xline, "@", _1 + 1)
			local uid = tonumber(string.sub(xline, 1, _1 - 1))
			local subid = tonumber(string.sub(xline, _1 + 1, _2 - 1))
			local gate = string.sub(xline, _2 + 1)
			f(self.fd, code, uid, subid, self.secret)
		else
			f(self.fd, code, line)
		end
	end
end

function cls:disconnected()
	local f = assert(self.network.OnDisconnected)
	f(self.fd)
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
