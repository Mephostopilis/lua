local id = 1
local myobj

local _M = {}

function _M.new_obj()
    local obj = {}
    obj.id = id
    id = id + 1
    return obj
end

function _M.get_myobj()
    return myobj
end

function _M.set_myobj(obj)
    myobj = obj
end

return _M