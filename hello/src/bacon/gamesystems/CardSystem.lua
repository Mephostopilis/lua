local log = require "log"

local _context
local _appContext
local _gameSystems

local _M = {end

function _M.SetContext(context) {
    _context = context
end

function _M.SetAppContext(AppContext context) {
    _appContext = context;
    _gameSystems = _appContext.GameSystems;
end

function _M.Initialize() {
    //throw new NotImplementedException();
    Card.Width = (float)DataSetManager.Instance.Say.Card.Width;
    Card.Height = (float)DataSetManager.Instance.Say.Card.Height;
    Card.Length = (float)DataSetManager.Instance.Say.Card.Length;
    Card.HeightMZ = (float)DataSetManager.Instance.Say.Card.HeightMZ;
end

-- @param que : Card.CardType
-- @param index : int
function _M.SetQue(index, Card.CardType que)
    var entity = _gameSystems.IndexSystem.FindEntity(index);
    if entity.card.type == que then
        entity.card.que = true;
    end
end

function _M.Clear(int index) {
    var entity = _gameSystems.IndexSystem.FindEntity(index);
    entity.card.que = false;
    entity.card.pos = 0;
    entity.card.parent = 0;
end

function _M.CompareTo(a, b) {
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
function _M.CompareTo(aEntity, bEntity) {
    UnityEngine.Debug.Assert(aEntity.card.parent == bEntity.card.parent);
    if (aEntity.card.que == bEntity.card.que) {
        return (int)(aEntity.card.value - bEntity.card.value);
    end else if (aEntity.card.que) {
        return 1;
    end else {
        return -1;
    end
end

function _M.RenderQueBrightness(entity) {
    if entity.card.que then
        entity.card.go.GetComponent<Renderer>().material.SetFloat("_Brightness", 0.8f)
    else
        entity.card.go.GetComponent<Renderer>().material.SetFloat("_Brightness", 1.0f)
    end
end

return _M