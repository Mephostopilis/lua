local function com_tostring(obj)
    local lua = ""
    local t = type(obj)
    if t == "number" then
        lua = lua .. obj
    elseif t == "boolean" then
        lua = lua .. tostring(obj)
    elseif t == "string" then
        lua = lua .. string.format("%q", obj)
    elseif t == "table" then
        lua = lua .. "{"

        local first = true
        for k, v in pairs(obj) do
            if not first  then
                lua = lua .. ","
            end
            lua = lua .. com_tostring(k) .. "=" .. com_tostring(v)
            first = false
        end
        -- local metatable = getmetatable(obj)
        -- if metatable ~= nil and type(metatable.__index) == "table" then
        --     for k, v in pairs(metatable.__index) do
        --         lua = lua ..com_tostring(k) .. "=" .. com_tostring(v) .. ","
        --     end
        -- end
        lua = lua .. "}"
    elseif t == "nil" then
        return nil
    else
        error("can not com_tostring a " .. t .. " type.")
    end
    return lua
end

local function make_component(name, ...)
    local tmp = {}
    tmp.__keys = {...}
    tmp.__comp_name = name
    tmp.__tostring = function(t) return "\t" .. t.__comp_name .. com_tostring(t) end
    tmp.__index = tmp
    tmp.new = function(...)
        local values = {...}
        local tb = {}
        for k, v in pairs(tmp.__keys) do
            if k <= #values then
                tb[v] = values[k]
            end
        end
        return setmetatable(tb, tmp)
    end
    return tmp
end

return make_component
