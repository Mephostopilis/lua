local timer = require("timer")
local log = require "log"
local AppConfig = require "AppConfig"
local DeskComponent = require "bacon.components.DeskComponent"
local IndexComponent = require "bacon.components.IndexComponent"
local SceneComponent = require "bacon.components.SceneComponent"
local RoomComponent = require "bacon.components.RoomComponent"
local MyIndexComponent = require "bacon.components.MyIndexComponent"

local cls = class('DeskSystem')

function  cls:ctor(systems, ... )
    -- body
    self._context = nil
    self._appContext = nil
    self._gameSystems = systems
    self._desk = nil
    self.deskEntity = nil
end

-- 所有系统接口
function cls:SetAppContext(context)
    assert(context)
    self._appContext = context
end

function cls:SetContext(context)
    -- body
    assert(context)
    self._context = context
end

function cls:Initialize( ... )
    -- body
    -- EventListenerCmd listener1 = new EventListenerCmd(MyEventCmd.EVENT_SETUP_BOARD, SetupBoard)
    -- _appContext.EventDispatcher.AddCmdEventListener(listener1)

    -- local deskItem = DataSetManager.Instance.Say.Desk
end

function cls:Reset( ... )
    -- body
end

function cls:Cleanup( ... )
    -- body
end

-- 场景接口
function cls:OnEnter(context, param, ... )
    -- body
    local scene = context:get_unique_component(SceneComponent)
    if scene.name == "game" then
        log.info("OnEnter scene name = %s", context.scene.name)
        self._context = context
        local deskItem = AppConfig:getInstance().config['desk']['1']
        local entity = self._context:create_entity()
        entity:add(DeskComponent, deskItem.Width, deskItem.Length, deskItem.Height, deskItem.CurorMH, 0, 10, nil)
        self._desk = self._gameSystems.indexSystem:NextIndex()
        entity:add(IndexComponent, self._desk)
        self.deskEntity = entity
    end
end

function cls:SetIndex(index)
    self._desk = index
end

function cls:SetupBoard()
    local boardGo = CS.UnityEngine.GameObject.Find('Root/Board')
    self.deskEntity:get(DeskComponent).go = boardGo
end

function cls:FindEntity()
    return self._gameSystems.indexSystem:FindEntity(self._desk)
end

function cls:UpdateClock(left)
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.clockleft = left
    self:RenderUpdateClock()
end

function cls:RenderUpdateClock()
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):ShowCountdown(e.desk.clockleft)
end

function cls:ShowCountdown(cd)
    local e = self._gameSystems.indexSystem.FindEntity(_desk)
    e.desk.clockleft = cd

    Timer.Register(cd, null, UpdateClock)

    _appContext.EnqueueRenderQueue(RenderShowCountdown)
end

function cls:RenderShowCountdown()
    local e = self._gameSystems.indexSystem.FindEntity(_desk)
    e.desk.go.GetComponent("Board").ShowCountdown()
end

function cls:RenderChangeCursor(pos)
    local e = self._gameSystems.indexSystem.FindEntity(_desk)
    e.desk.go:GetComponent("Board"):ChangeCursor(pos)
end

function cls:RenderThrowDice()
    local e = self._gameSystems.indexSystem.FindEntity(_desk)
    e.desk.go:GetComponent("Board"):ThrowDice(self._context.rule.dice1, self._context.rule.dice2)
end

function cls:RenderShowBottomSlot(cb)
    local e = self._gameSystems.indexSystem.FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):ShowBottomSlot(cb)
end

function cls:RenderCloseBottomSlot(cd)
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent('Board'):CloseBottomSlot(cd)
end

function cls:RenderShowRightSlot(cd)
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):ShowRightSlot(cd)
end

function cls:RenderCloseRightSlot(cb)
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):CloseRightSlot(cb)
end

function cls:RenderShowTopSlot(cd)
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):ShowTopSlot(cd)
end

function cls:RenderCloseTopSlot(cb)
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):CloseTopSlot(cb)
end

function cls:RenderShowLeftSlot(cb)
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):ShowLeftSlot(cb)
end

function cls:RenderCloseLeftSlot(cb)
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):CloseLeftSlot(cb)
end

function cls:RenderSetDongAtRight()
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):SetDongAtRight()
end

function cls:RenderSetDongAtTop()
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):SetDongAtTop()
end

function cls:RenderSetDongAtLeft()
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):SetDongAtLeft()
end

function cls:RenderSetDongAtBottom()
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):SetDongAtBottom()
end

function cls:RenderSetNanAtRight()
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):SetNanAtRight()
end

function cls:RenderSetNanAtTop()
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):SetNanAtTop()
end

function cls:RenderSetNanAtLeft()
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):SetNanAtLeft()
end

function cls:RenderSetNanAtBottom()
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):SetNanAtBottom()
end

function cls:RenderSetXiAtRight()
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):SetXiAtRight()
end

function cls:RenderSetXiAtTop()
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):SetXiAtTop()
end

function cls:RenderSetXiAtLeft()
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):SetXiAtLeft()
end

function cls:RenderSetXiAtBottom()
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):SetXiAtBottom()
end

function cls:RenderSetBeiAtTop()
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):SetBeiAtTop()
end
function cls:RenderSetBeiAtLeft()
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):SetBeiAtLeft()
end

function cls:RenderSetBeiAtBottom()
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):SetBeiAtBottom()
end

function cls:RenderSetBeiAtRight()
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):SetBeiAtRight()
end

function cls:RenderTakeOnDong()
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):TakeOnDong(false)
end

function cls:RenderTakeOffDong()
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):TakeOffDong()
end

function cls:RenderTakeTurnDong()
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):TakeTurnDong()
end

function cls:RenderTakeOnNan()
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board").TakeOnNan(false)
end

function cls:RenderTakeOffNan()
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):TakeOffNan()
end

function cls:RenderTakeTurnNan()
    local e = self._gameSystems.indexSystem.FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):TakeTurnNan()
end

function cls:RenderTakeOnXi()
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):TakeOnXi(false)
end

function cls:RenderTakeOffXi()
    local e = _gameSystems.indexSystem.FindEntity(self._desk)
    e.desk.go:GetComponent("Board").TakeOffXi()
end

function cls:RenderTakeTurnXi()
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go.GetComponent("Board").TakeTurnXi()
end

function cls:RenderTakeOnBei()
    local e = self._gameSystems.indexSystem.FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):TakeOnBei(false)
end

function cls:RenderTakeOffBei()
    local e = self._gameSystems.indexSystem:FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):TakeOffBei()
end

function cls:RenderTakeTurnBei()
    local e = self._gameSystems.indexSystem.FindEntity(self._desk)
    e.desk.go:GetComponent("Board"):TakeTurnBei()
end

-- //function cls:InitUI(int id)
-- //    string name = string.Format("房间号:0:000000end", id)
-- //    if (_RoomId != null)
-- //        _RoomId.GetComponent<TextMesh>().text = name
-- //    end
-- //end

function cls:SetRoomId()
    local myIdxComp = self._context:get_unique_component(MyIndexComponent)
    local indexEntityIndex = self._context:get_entity_index(IndexComponent)
    local entity = indexEntityIndex:get_entity(myIdxComp.index)
    local roomComp = entity:get(RoomComponent)
    -- 修改
    local entity = self._gameSystems.indexSystem:FindEntity(self._desk)
    local roomidGo = entity.desk.go.transform:Find('RoomId')
    local textMeshComp = roomidGo:GetComponent('TextMesh')
    textMeshComp.text = string.format( "房间号: %d", roomComp.roomid )
end

return cls