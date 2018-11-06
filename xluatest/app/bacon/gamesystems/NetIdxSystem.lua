local PrimaryEntityIndex = require "entitas.PrimaryEntityIndex"
local Matcher = require "entitas.Matcher"

local PlayerComponent = require "bacon.components.PlayerComponent"

local GameState = require "bacon.game.GameState"

local cls = class("NetIdxSystem")

function cls:ctor(systems, ... )
    -- body
    self._gameSystems = systems
    self._appContext = nil
    self._context = nil
end

function cls:SetAppContext(context, ... )
    -- body
    self._appContext = context
end

function cls:SetContext(context, ... )
    -- body
    self._context = context
end

function cls:FindEntity(netidx, ... )
    -- body
    local  netidxPrimaryIndex = self._context:get_entity_index(PlayerComponent)
    return netidxPrimaryIndex:get_entity(netidx)
end

function cls:SortCards() 
    self._context.rule.oknum = self._context.rule.max
    local playerGroup = context:get_group(Matcher({PlayerComponent}))
    playerGroup.entitas:foreach(function (entity, ... )
        -- body
        self._gameSystems.playerSystem:SortCards(entity)
    end)
    self:RenderSortCardsAfterDeal()
end

function cls:ClearCall()
    local playerGroup = context:get_group(Matcher({PlayerComponent}))
    playerGroup.entitas:foreach(function (entity, ... )
        -- body
        self._gameSystems.playerSystem:ClearCall(entity)
    end)
end

function cls:PlayFlame(idx, cd)
    local playerGroup = context:get_group(Matcher({PlayerComponent}))
    playerGroup.entitas:foreach(function (entity, ... )
        -- body
        if entity.player.idx == idx then
            entity.head.headUIContext:SetFlame(cd)
        else
            entity.head.headUIContext:SetFlame(0)
        end
    end)
end

function cls:ShowHeadFirst()
    -- setui after
    assert(self._context.scene.name == "game")
    local playerGroup = context:get_group(Matcher({PlayerComponent}))
    playerGroup.entitas:foreach(function (entity, ... )
        -- body
        self._appContext.uicontextMgr:Push(entity.head.headUIContext)
    end)
end

function cls:LoadHand() {
    -- if (_appContext.Peek().Name == "game" && _appContext.Peek().LoadedUI) {
    --     _appContext.EnqueueRenderQueue(RenderLoadHand);
    -- }
end

function cls:Ready() {
    local playerGroup = context:get_group(Matcher({PlayerComponent}))
    playerGroup.entitas:foreach(function (entity, ... )
        -- body
        if self._context.rule.gamestate == GameState.READY and not self._context.rule.fixedReady then
            self._context.rule.fixedReady = true
        end
        -- self._gameSystems.playerSystem:RenderLoadHand(entity)

    end)

    -- if (_appContext.Peek().Name == "game" && _appContext.Peek().LoadedUI) {
    --     if (_context.rule.gamestate == Game.GameState.READY && !_context.rule.fixedReady) {
    --         _context.rule.fixedReady = true;
    --         _appContext.EnqueueRenderQueue(RenderReady);
    --     }
    -- }
end

function cls:RenderLoadHand()
    local playerGroup = context:get_group(Matcher({PlayerComponent}))
    playerGroup.entitas:foreach(function (entity, ... )
        -- body
        self._gameSystems.playerSystem:RenderLoadHand(entity)
    end)
end

function cls:RenderReady() {
    foreach (var item in _entitas) {
        GameEntity entity = item.Value;
        if (entity.player.go == null) {
            _gameSystems.playerSystem:RenderReady(entity);
        }
    }
}

function cls:RenderBoxing()
    local playerGroup = context:get_group(Matcher({PlayerComponent}))
    playerGroup.entitas:foreach(function (entity, ... )
        -- body
        self._gameSystems.playerSystem:RenderBoxing(entity)
    end)
end

function cls:RenderSortCardsAfterDeal()
    local playerGroup = context:get_group(Matcher({PlayerComponent}))
    playerGroup.entitas:foreach(function (entity, ... )
        -- body
        self._gameSystems.playerSystem:RenderSortCardsAfterDeal(entity)
    end)
end

function cls:RenderXuanQue()
    local playerGroup = context:get_group(Matcher({PlayerComponent}))
    playerGroup.entitas:foreach(function (entity, ... )
        -- body
        self._gameSystems.playerSystem:RenderXuanQue(entity)
    end)
end

return cls

-- using System;
-- using System.Collections.Generic;
-- using System.Linq;
-- using System.Text;
-- using System.Threading.Tasks;
-- using UnityEngine;
-- using Entitas;
-- using Maria;

-- namespace Bacon.GameSystems {
--     public class NetIdxSystem : ISystem, ISetContextSystem, IExecuteSystem {

--         private GameContext _context;
--         private AppContext _appContext;
--         private AppGameSystems _gameSystems;
--         private Dictionary<long, GameEntity> _entitas = new Dictionary<long, GameEntity>();

--         public NetIdxSystem(Contexts contexts) {
--             _context = contexts.game;
--         }

--         function cls:SetAppContext(AppContext context) {
--             _appContext = context;
--             _gameSystems = context.GameSystems;
--         }


--         function cls:Execute() {

--         }

--         function cls:AddEntity(IEntity entity) {
-- #if (!GEN_COMPONENT)
--             var e = entity as GameEntity;
--             if (e.hasPlayer) {
--                 _entitas.Add(e.player.idx, e);
--             }
-- #endif
--         }

--         function cls:RemoveEntity(IEntity entity) {
-- #if (!GEN_COMPONENT)

--             var e = entity as GameEntity;
--             if (e.hasPlayer) {
--                 _entitas.Remove(e.player.idx);
--             }
--             e.Destroy();
-- #endif
--         }

--         public GameEntity FindEntity(long index) {
--             if (_entitas.ContainsKey(index)) {
--                 return _entitas[index] as GameEntity;
--             }
--             return null;
--         }

--         function cls:SortCards() {
-- #if (!GEN_COMPONENT)
--             _context.rule.oknum = (int)_context.rule.max;
--             foreach (var item in _entitas) {
--                 var entity = item.Value as GameEntity;
--                 _gameSystems.playerSystem.SortCards(entity);
--             }
--             _appContext.EnqueueRenderQueue(RenderSortCardsAfterDeal);
-- #endif
--         }

--         function cls:ClearCall() {
--             foreach (var item in _entitas) {
--                 var entity = item.Value as GameEntity;
--                 --_gameSystems.playerSystem.ClearCall();
--             }
--         }

--         function cls:PlayFlame(long idx, long cd) {
--             foreach (var item in _entitas) {
--                 GameEntity entity = item.Value as GameEntity;
--                 if (entity.player.idx == idx) {
--                     entity.head.headUIController.SetFlame((int)cd);
--                 } else {
--                     entity.head.headUIController.SetFlame(0);
--                 }
--             }
--         }

--         function cls:ShowHeadFirst() {
--             -- setui after
--             if (_appContext.Peek().Name == "game" && _appContext.Peek().LoadedUI) {
--                 foreach (var item in _entitas) {
--                     GameEntity entity = item.Value;
--                     if (entity.head.headUIController.Counter <= 0) {
--                         entity.head.headUIController.Controller = _appContext.Peek();
--                         _appContext.UIContextManager.Push(entity.head.headUIController);
--                     }
--                 }
--             }
--         }

--         function cls:LoadHand() {
--             if (_appContext.Peek().Name == "game" && _appContext.Peek().LoadedUI) {
--                 _appContext.EnqueueRenderQueue(RenderLoadHand);
--             }
--         }

--         function cls:Ready() {
--             if (_appContext.Peek().Name == "game" && _appContext.Peek().LoadedUI) {
--                 if (_context.rule.gamestate == Game.GameState.READY && !_context.rule.fixedReady) {
--                     _context.rule.fixedReady = true;
--                     _appContext.EnqueueRenderQueue(RenderReady);
--                 }
--             }
--         }

--         #region render
--         function cls:RenderLoadHand() {
--             foreach (var item in _entitas) {
--                 GameEntity entity = item.Value;
--                 if (entity.player.go == null) {
--                     _gameSystems.playerSystem:RenderLoadHand(entity);
--                 }
--             }
--         }

--         function cls:RenderReady() {
--             foreach (var item in _entitas) {
--                 GameEntity entity = item.Value;
--                 if (entity.player.go == null) {
--                     _gameSystems.playerSystem:RenderReady(entity);
--                 }
--             }
--         }

--         function cls:RenderBoxing() {
--             foreach (var item in _entitas) {
--                 GameEntity entity = item.Value as GameEntity;
--                 _gameSystems.playerSystem:RenderBoxing(entity);
--             }
--         }

--         function cls:RenderSortCardsAfterDeal() {
--             foreach (var item in _entitas) {
--                 var entity = item.Value as GameEntity;
--                 _gameSystems.playerSystem:RenderSortCardsAfterDeal(entity);
--             }
--         }

--         function cls:RenderXuanQue() {
--             foreach (var item in _entitas) {
--                 var entity = item.Value as GameEntity;
--                 _gameSystems.playerSystem:RenderXuanQue(entity);
--             }
--         }
--         #endregion

--     }
-- }
