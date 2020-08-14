local skynet = require "skynet"
local skynet_queue = require "skynet.queue"
local log = require "chestnut.skynet.log"
local queue = require "chestnut.queue"

local cls = class("waiting_queue")

function cls:ctor( ... )
	-- body

	self._id = 0
	self._rooms = queue()  -- freelist

	self._queues = {}

	self._urooms = {}

	self._cs1 = skynet_queue()
	self._cs2 = skynet_queue()

	-- pre gen rooms
	for i=1,10 do
		local room = self:_create_room()
		self:enqueue_room(room)
	end
end

function cls:enqueue_agent(t, agent, ... )
	-- body
	local function func(q, i, ... )
		-- body
		q:enqueue(i)
	end
	local q = self._queues[t]
	if type(q) ~= "table" then
		q = queue()
	end
	assert(q)
	return self._cs1(func, q, agent)
end

function cls:dequeue_agent(t, ... )
	-- body
	local function func(q, ... )
		-- body
		if #q > 0 then
			return q:dequeue()
		end
		return nil
	end
	local q = self._queues[t]
	if q then
		return self._cs1(func, q)
	end
	return nil
end

function cls:remove_agent(t, agent, ... )
	-- body
	local function func(q, i, ... )
		-- body
		q:remove(i)
	end
	local q = self._queues[t]
	if q then
		self._cs1(func, q, agent)
	end
end

function cls:get_agent_queue_sz(t, ... )
	-- body
	local q = self._queues[t]
	if q then
		return #q
	else
		return 0
	end
end

function cls:_create_room( ... )
	-- body
	self._id = self._id + 1
	local addr = skynet.newservice("room/room", self._id)

	local x = {
		id = self._id,
		addr = addr,
	}
	return x
end

-- manager room
function cls:enqueue_room(room, ... )
	-- body
	assert(room and room.id)
	if self._urooms[room.id] then
		self._urooms[room.id] = nil
	end
	local function func1(q, r, ... )
		-- body
		q:enqueue(r)
	end
	return self._cs2(func1, self._rooms, room)
end

function cls:dequeue_room( ... )
	-- body
	local function func1(q, ... )
		-- body
		if #q > 0 then
			return q:dequeue()
		else
			return self:_create_room()
		end
	end
	local room = assert(self._cs2(func1, self._rooms))
	log.info("dequeue room room id: %d ", room.id)
	assert(room.id)
	assert(self._urooms[room.id] == nil)
	self._urooms[room.id] = room
	return room
end

function cls:get(id, ... )
	-- body
	assert(id)
	return self._urooms[id]
end

return cls