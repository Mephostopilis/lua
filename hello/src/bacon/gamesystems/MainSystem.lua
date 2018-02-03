local EventDispatcher = require "maria.event.EventDispatcher"
local NetworkMgr = require "maria.event.NetworkMgr"
local UIContextManager = require "maria.uibase.UIContextManager"
local MyIndexComponent = require "bacon.components.MyIndexComponent"
local Provice = require "bacon.game.Provice"
local cls = class("MainSystem")

function cls:ctor( ... )
	-- body
	self._context = nil
	self._appContext = nil
	self._gameSystems = nil
end

function cls:SetAppContext(context, ... )
    -- body
    self._appContext = context
    self._gameSystems = context.gameSystems
end

function cls:SetContext(context, ... )
    -- body
    self._context = context
end

function cls:Initialize( ... )
	-- body
	EventDispatcher:getInstance():AddCmdEventListener(MyEventCmd.EVENT_MUI_SHOWCREATE, function ( ... )
		-- body
		self:OnShowCreate( ... )
	end)
	EventDispatcher:getInstance():AddCmdEventListener(MyEventCmd.EVENT_JOIN_SHOW, function ( ... )
		-- body
		self:OnShowJoin( ... )
	end)

	EventDispatcher:getInstance():AddCmdEventListener(MyEventCmd.EVENT_MUI_MODIFYCREATE, function ( ... )
		-- body
		
	end)

	EventDispatcher:getInstance():AddCmdEventListener(MyEventCmd.EVENT_MUI_JOIN, function ( ... )
		-- body
		self:OnJoin(...)
	end)

	EventDispatcher:getInstance():AddCmdEventListener(MyEventCmd.EVENT_JOIN_CLOSE, function ( ... )
		-- body
		self:OnClose()
	end)

	EventDispatcher:getInstance():AddCmdEventListener(MyEventCmd.EVENT_EXITROOM, function ( ... )
		-- body
	end)

	EventListenerCmd listener1 = new EventListenerCmd(MyEventCmd.EVENT_MUI_JOIN, OnJoin);
            Singleton<EventDispatcher>.Instance.AddCmdEventListener(listener1);

            EventListenerCmd listener2 = new EventListenerCmd(MyEventCmd.EVENT_JOIN_CLOSE, OnClose);
            Singleton<EventDispatcher>.Instance.AddCmdEventListener(listener2);

            EventListenerCmd listener17 = new EventListenerCmd(MyEventCmd.EVENT_EXITROOM, OnEventLeave);
            Singleton<EventDispatcher>.Instance.AddCmdEventListener(listener17);
end

function cls:Cleanup( ... )
	-- body
end

function cls:OnShowCreate( e) 
	local index = self._context:get_unique_component(MyIndexComponent).index
	local entity = self._gameSystems.indexSystem:FindEntity(index)
	-- UIContextManager:getInstance():Push(entity.main.roomUIContext)
end

function cls:OnShowJoin( e, ... )
	-- body
	local index = self._context:get_unique_component(MyIndexComponent).index
	local entity = self._gameSystems.indexSystem:FindEntity(index)
	-- UIContextManager:getInstance():Push(entity.main.roomUIContext)
end

function cls:SendCreate( ... )
	-- body
	local request = {}
	local index = self._context:get_unique_component(MyIndexComponent).index
	local entity = self._gameSystems.indexSystem:FindEntity(index)

            if entity.main.createRoomUIContext._provice == Provice.Sichuan then
                request.provice = _provice;
                request.ju = _ju;
                request.overtype = _overtype;
                request.sc = new C2sSprotoType.crsc();
                request.sc.hujiaozhuanyi = _hujiaozhuanyi;
                request.sc.zimo = _zimo;
                request.sc.dianganghua = _dianganghua;
                request.sc.daiyaojiu = _daiyaojiu;
                request.sc.duanyaojiu = _duanyaojiu;
                request.sc.jiangdui = _jiangdui;
                request.sc.tiandihu = _tiandihu;
                request.sc.top = _top;
            } else if (_provice == Provice.Shaanxi) {
                request.provice = Provice.Shaanxi;
                request.ju = _ju;
                request.overtype = _overtype;
                request.sx = new C2sSprotoType.crsx();
                request.sx.huqidui = _sxqidui;
                request.sx.qingyise = _sxqingyise;
            }
            NetworkMgr:getInstance().client:send_request("create", request)
end

return cls