local rapidjson = require('rapidjson')

print(rapidjson.encode({}))     -- '{}'

print(rapidjson.encode(rapidjson.object())) --> '{}'
print(rapidjson.encode(rapidjson.array())) --> '[]'

print(rapidjson.encode(setmetatable({}, {__jsontype='object'}))) --> '{}'
print(rapidjson.encode(setmetatable({}, {__jsontype='array'}))) --> '[]'

print(rapidjson.encode(true)) --> 'true'
print(rapidjson.encode(rapidjson.null)) --> 'null'
print(rapidjson.encode(123)) --> '123.0' or '123' in Lua 5.3.


print(rapidjson.encode({true, false})) --> '[true, false]'

print(rapidjson.encode({a=true, b=false})) --> '{"a":true,"b":false]'
