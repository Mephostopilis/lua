local crypt = require "skynet.crypt"
local ps = require "xluasocket"
local log = require "log"

local cls = class("clientlogin")

function cls:ctor(network, ... )
	-- body
	self._network = network
	
	self._login_fd = false
	self._connected = false
	self._login_step = 0

	self._username  = ""
	self._password  = ""
	self._server    = ""
	self._clientkey = ""
	self._challenge = ""
	self._secret    = ""

	return self
end

function cls:login_connected( ... )
	-- body
	-- self._state = state.LOGIN
	-- self._login_step = 1
end

function cls:login_data(line, ... )
	-- body	
	print("step", self._login_step)
	print()
	if self._login_step == 1 then
		local challenge = crypt.base64decode(line)
		local clientkey = crypt.randomkey()
		local g = assert(self._network._g)
		local err = ps.send(g, self._login_fd, crypt.base64encode(crypt.dhexchange(clientkey)))
		assert(err > 0)
		self._challenge = challenge
		self._clientkey = clientkey
		self._login_step = self._login_step + 1
	elseif self._login_step == 2 then
		local secret = crypt.dhsecret(crypt.base64decode(line), self._clientkey)
		print("sceret is", crypt.hexencode(secret))
		local hmac = crypt.hmac64(self._challenge, secret)
		local g = assert(self._network._g)
		local err = ps.send(g, self._login_fd, crypt.base64encode(hmac))
		assert(err > 0)
		self._secret = secret

		print(self._username, self._server, self._password)
		local token = string.format("%s@%s:%s",
			crypt.base64encode(self._username),
			crypt.base64encode(self._server),
			crypt.base64encode(self._password))
		local etoke = crypt.desencode(self._secret, token)
		local err = ps.send(g, self._login_fd, crypt.base64encode(etoke))
		assert(err > 0)
		self._login_step = self._login_step + 1
	elseif self._login_step == 3 then
		local code = tonumber(string.sub(line, 1, 4))
		if code == 200 then
			log.info("handshake code: %d", code)
			local g = assert(self._network._g)
			ps.closesocket(g, self._login_fd)
			local xline = crypt.base64decode(string.sub(line, 5))
			local _1 = string.find(xline, '#')
			local _2 = string.find(xline, '@', _1+1)
			local uid = tonumber(string.sub(xline, 1, _1-1))
			local subid = tonumber(string.sub(xline, _1+1, _2-1))
			local gate = string.sub(xline, _2+1)
			self._login_step = 0     -- close login setp
			print("ok")
			self._network:OnLoginAuthed(code, uid, subid, self._secret)
		else
			print(code)
			self._network:OnLoginAuthed(code, line)
		end
	end
end

function cls:login_disconnected(ok, so, ... )
	-- body
	assert(ok == ps.SOCKET_CLOSE)
	printInfo("login_disconnected")
end

function cls:login_auth(ip, port, u, p, server, ... )
	-- body
	assert(ip and port and u and p and server)
	
	self._username   = u
	self._password   = p
	self._server     = server
	
	local g = assert(self._network._g)
	self._login_fd = ps.socket(g, ps.PROTOCOL_TCP, ps.HEADER_TYPE_LINE, function (code, line, ... )
		-- body
		print("callback", code)
		if code == ps.SOCKET_DATA then
			if line then
				local ok, err = pcall(self.login_data, self, line)
				if not ok then
					print(err)
				end
			end
		elseif code == ps.SOCKET_CLOSE then
		elseif code == ps.SOCKET_ERROR then
		end
	end)
	local err = ps.connect(g, self._login_fd, ip, port)
	if err == 0 then
		self._connected = true
		self._login_step = 1
	end
	return err
end

return cls