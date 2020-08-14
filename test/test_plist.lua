local plist = require "plist"

local fd = io.open('data/3.plist')
local all = fd:read('a')
local node = plist.from_xml(all)
local node1 =  plist.dict_get_item(node, "Boolean")
