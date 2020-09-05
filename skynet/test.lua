package.cpath = "./luaclib/?.dll;" .. package.cpath
local crypt = require "skynet.crypt"

local challenge = crypt.base64decode("tR0ykQc9reA=")
print(challenge)
