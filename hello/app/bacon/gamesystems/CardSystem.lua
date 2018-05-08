local Card = require "bacon.game.Card"
local log = require "log"

local cls = class("CardSystem")

function cls:ctor( ... )
    -- body
    self._context = nil
    self._appContext = nil
    self._gameSystems = nil
end

function cls:SetContext(context) 
    self._context = context
end

function cls:SetAppContext(context) 
    self._appContext = context
    self._gameSystems = self._appContext.gameSystems
end

function cls:Initialize() 
    //throw new NotImplementedException();
    Card.Width = (float)DataSetManager.Instance.Say.Card.Width;
    Card.Height = (float)DataSetManager.Instance.Say.Card.Height;
    Card.Length = (float)DataSetManager.Instance.Say.Card.Length;
    Card.HeightMZ = (float)DataSetManager.Instance.Say.Card.HeightMZ;
end

-- @param que : Card.CardType
-- @param index : int
function cls:SetQue(index, que)
    local entity = self._gameSystems.indexSystem:FindEntity(index)
    if entity.card.type == que then
        entity.card.que = true
    end
end

function cls:Clear(index) {
    local entity = self._gameSystems.indexSystem:FindEntity(index)
    entity.card.que = false
    entity.card.pos = 0
    entity.card.parent = 0
end

function cls:CompareTo(a, b) {
    var aEntity = _gameSystems.IndexSystem.FindEntity(a);
    var bEntity = _gameSystems.IndexSystem.FindEntity(b);
    UnityEngine.Debug.Assert(aEntity.card.parent != 0 && aEntity.card.parent == bEntity.card.parent);
    if (aEntity.card.que == bEntity.card.que) {
        return (int)(aEntity.card.value - bEntity.card.value);
    end else if (aEntity.card.que) {
        return -1;
    end else {
        return 1;
    end
end

-- @param aEntity : GameEntity
function cls:CompareTo(aEntity, bEntity) {
    UnityEngine.Debug.Assert(aEntity.card.parent == bEntity.card.parent);
    if (aEntity.card.que == bEntity.card.que) {
        return (int)(aEntity.card.value - bEntity.card.value);
    end else if (aEntity.card.que) {
        return 1;
    end else {
        return -1;
    end
end

function cls:RenderQueBrightness(entity) {
    if entity.card.que then
        entity.card.go.GetComponent<Renderer>().material.SetFloat("_Brightness", 0.8f)
    else
        entity.card.go.GetComponent<Renderer>().material.SetFloat("_Brightness", 1.0f)
    end
end

return cls