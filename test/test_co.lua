local co1 = coroutine.create(function ()
    for i=1,10 do
        print(i)
    end
end)

local co2 = coroutine.create(function ()
    for i=1,10 do
        print(i)
    end
end)

print('co end')