local assert = assert
local _M = {}

function _M.new( ... )
	-- body
	local node = {}
	node.size = 0
	node.head = nil
	node.tail = nil
	setmetatable(node, { __index = _M })
	return node
end

function _M.push_front(L, node, ... )
	-- body
	assert(type(ele) == "table")
	node.__prev__ = nil
	node.__next__ = nil
	
	if L.size == 0 then
		L.head = node
		L.tail = node
	else 
		node.__next__ = L.head
		L.head.__prev__ = node
		L.head = node
	end
	L.size = L.size + 1
end

function _M.push_back(L, node, ... )
	-- body
	
	node.__prev__ = nil
	node.__next__ = nil

	if L.size == 0 then
		L.tail = node
		L.head = node
	else
		L.tail.__next__ = node
		node.__prev__ = L.tail
		L.tail = node
	end
	L.size = L.size + 1
end

function _M.remove(L, node, ... )
	-- body
	assert(L and node)
	if L.size == 0 then
	elseif L.size == 1 then
		if L.head == ele then
			L.head = nil
			L.tail = nil
			L.size = L.size - 1
		end
	else
		local p = L.head
		while p do
			if p == node then
				local prev = p.__prev__
				prev.__next__ = p.__next__
				p.__next__.__prev__ = prev
				break
			end
			p = p.__next__
		end
	end
end

function _M.pop_front(L, ... )
	-- body
	assert(L)
	if L.size == 0 then
	elseif L.size == 1 then
		local p = L.head
		L.head = nil
		L.tail = nil
		L.size = L.size - 1
		return p
	elseif L.size > 1 then
		local p = L.head
		L.head = L.head.__next__
		L.size = L.size - 1
		return p
	end
	return
end

function _M.pop_back(L, ... )
	-- body
	assert(L)
	if L.size == 0 then
		return false
	elseif L.size == 1 then
		local p = L.tail
		L.head = nil
		L.tail = nil
		L.size = L.size - 1
		return p
	elseif L.size > 1 then
		local p = L.tail
		p.__prev__.__next__ = nil
		L.tail = p.__prev__
		L.size = L.size - 1
		return p
	end
	return
end

function _M.foreach(L, func, ... )
	-- body
	assert(L)
	local node = L.head
	while node do
		if func then
			func(node.data)
		end
		node = node.next
	end
end

function _M.sort(L, comp, ... )
	-- body
	assert(L and comp)	
end

function _M.head(L, ... )
	-- body
	return L.head
end

function _M.tail(L, ... )
	-- body
	return L.tail
end

function _M.size(L, ... )
	-- body
	return L.size
end

return _M