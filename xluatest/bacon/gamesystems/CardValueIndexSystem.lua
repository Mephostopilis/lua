local NetworkMgr = require "maria.network.NetworkMgr"
local res = require "res"
local log = require "log"
local OpCodes = require "bacon.game.OpCodes"
local Card = require "bacon.game.Card"
local Matcher = require "entitas.Matcher"
local CardComponent = require "bacon.components.CardComponent"

local cls = class("CardValueIndexSystem")

function cls:ctor(systems, ... )
    -- body
    self._gameSystems = systems
    self._appContext = nil
    self._context = nil
    self._entitas = {}
end

function cls:SetContext(context, ... )
    -- body
    self._context =  context
    -- local cardGroup = context:get_group(Matcher({CardComponent}))
    -- cardGroup.on_entity_added:add(function ( ... )
    --     self:OnEntityAdded( ... )
    --     -- body
    -- end)
end

function cls:SetAppContext(context, ... )
    -- body
    self._appContext = context
end

function cls:Initialize( ... )
    -- body
end

function cls:Cleanup( ... )
    -- body
end

function cls:FindEntity(value, ... )
    -- body
    local cardPrimaryIndex = self._context:get_entity_index(CardComponent)
    return cardPrimaryIndex:get_entity(value)
end

function cls:Clear( ... )
    -- body
    local cardGroup = self._context:get_group(Matcher({CardComponent}))
    cardGroup.entities:foreach(function (entity) 
        entity.card.que = false
        entity.card.pos = 0
        entity.card.parent = 0
    end)
end

function cls:LoadMahjong()
    local cards = CS.UnityEngine.GameObject.Find("Root/cards")
    local path = "Prefabs/Mahjongs"
    for i=1,3 do
        local prefix  = ""
        if i == Card.CardType.Crak then
            prefix = prefix .. "Crak_"
        elseif i == Card.CardType.Bam then
            prefix = prefix .. "Bam_"
        elseif i == Card.CardType.Dot then
            prefix = prefix .. "Dot_"
        end
        for j=1,9 do
            local name = prefix .. string.format("%d", j)
            for k=1,4 do
                local entity = self._context:create_entity()
                local value = (i << 8) | (j << 4) | (k)
                local original = res.LoadGameObject(path, name)
                local go = CS.UnityEngine.GameObject.Instantiate(original)
                go.transform:SetParent(cards.transform)
                entity:add(CardComponent, value, i, j, k, 0, false, 0, path, name, go)
            end
        end
    end
end

function cls:SetQueBrightness( ... )
    -- body
    EventDispatcher:getInstance():EnqueueRenderQueue(function ( ... )
        -- body
        self:RenderQueBrightness()
    end)
end

-- render
function cls:RenderLoadMahjong( ... )
    -- body
    local cards = CS.UnityEngine.GameObject.Find("Root/cards")
    for k,v in pairs(self._dict) do
        local entity = v
        local original = ABLoader:getInstance():LoadGameObject(entity.card.path, entity.card.name)
        local go = CS.UnityEngine.GameObject.Instantiate(original)
        go.transform:SetParent(cards.transform)
        local msg = CS.maria.event.Message()
        msg:SetInt32("index", entity.index.index)
        local cmd = CS.maria.event.Command(MyEventCmd.EVENT_LOADEDCARDS, go, msg)
        EventDispatcher:getInstance():Enqueue(cmd)
    end
end

function cls:RenderQueBrightness( ... )
    -- body
    for k,v in pairs(self._dict) do
        local entity = v
        assert(entity.card.go ~= nil)
        if entity.card.que then
            entity.card.go:GetComponent("Renderer").material:SetFloat("Brightness", 0.8)
        else
            entity.card.go:GetComponent("Renderer").material:SetFloat("Brightness", 1.0)
        end
    end
end

return cls



-- using System
-- using System.Collections.Generic
-- using System.Linq
-- using System.Text
-- using System.Threading.Tasks
-- using UnityEngine
-- using Entitas
-- using Maria
-- using Maria.Event
-- using Bacon.Game
-- using Bacon.Event


-- namespace Bacon.GameSystems {
--     public class CardValueIndexSystem : ISystem, ISetContextSystem, IInitializeSystem, ICleanupSystem {
--         private GameContext _context
--         private AppContext _appContext
--         private AppGameSystems _gameSystems
--         private Dictionary<long, GameEntity> _dict = new Dictionary<long, GameEntity>()

--         public CardValueIndexSystem(Contexts contexts) {
--             _context = contexts.game
--         }

--         public void SetAppContext(AppContext context) {
--             _appContext = context
--             _gameSystems = _appContext.GameSystems
--         }

--         public void Initialize() {
--             EventListenerCmd listener2 = new EventListenerCmd(MyEventCmd.EVENT_LOADEDCARDS, OnLoadCard)
--             _appContext.EventDispatcher.AddCmdEventListener(listener2)

--             LoadMahjong()
--         }

--         public void Cleanup() { }

--         public GameEntity FindEntity(long value) {
--             if (_dict.ContainsKey(value)) {
--                 return _dict[value]
--             }
--             return null
--         }

--         public void Clear() {
-- #if (!GEN_COMPONENT)
--             foreach (var item in _dict) {
--                 item.Value.card.que = false
--                 item.Value.card.pos = 0
--                 item.Value.card.parent = 0
--             }
-- #endif
--         }

--         public void LoadMahjong() {
--             string path = "Prefabs/Mahjongs"
--             for (int i = 1 i < 4 i++) {
--                 string prefix = string.Empty
--                 if (i == (int)Card.CardType.Crak) {
--                     prefix = "Crak_"
--                 } else if (i == (int)Card.CardType.Bam) {
--                     prefix = "Bam_"
--                 } else if (i == (int)Card.CardType.Dot) {
--                     prefix = "Dot_"
--                 }
--                 for (int j = 1 j < 10 j++) {
--                     string name = prefix + string.Format("{0}", j)
--                     for (int k = 1 k < 5 k++) {
--                         GameEntity entity = _context.CreateEntity()
--                         long value = (i << 8) | (j << 4) | (k)
--                         entity.AddCard(value, (Card.CardType)i, j, k, 0, false, 0, path, name, null)
--                         _dict.Add(value, entity)
--                     }
--                 }
--             }
--         }

--         public void SetQueBrightness() {
--             _appContext.EnqueueRenderQueue(RenderQueBrightness)
--         }

--         #region event
--         private void OnLoadCard(EventCmd e) {
--             int index = Convert.ToInt32(e.Msg["index"])
--             GameEntity entity = _gameSystems.IndexSystem.FindEntity(index)
--             entity.card.go = e.Orgin
--         }
--         #endregion

--         #region render
--         public void RenderLoadMahjong() {
--             GameObject cards = GameObject.Find("cards")
--             foreach (var item in _dict) {
--                 GameEntity entity = item.Value as GameEntity
--                 if (entity.hasCard) {
--                     GameObject original = Maria.Res.ABLoader.current.LoadAsset<GameObject>(entity.card.path, entity.card.name)
--                     GameObject go = GameObject.Instantiate<GameObject>(original)
--                     go.transform.SetParent(cards.transform)
--                     Message msg = new Message()
--                     msg["index"] = entity.index.index
--                     Command cmd = new Command(MyEventCmd.EVENT_LOADEDCARDS, go, msg)
--                     Bacon.GL.Util.App.current.Enqueue(cmd)
--                 }
--             }
--         }

--         private void RenderQueBrightness() {
--             foreach (var item in _dict) {
--                 if (item.Value.card.que && item.Value.card.go != null) {
--                     item.Value.card.go.GetComponent<Renderer>().material.SetFloat("Brightness", 0.8f)
--                 } else {
--                     item.Value.card.go.GetComponent<Renderer>().material.SetFloat("Brightness", 1.0f)
--                 }
--             }
--         }
--         #endregion
--     }
-- }
