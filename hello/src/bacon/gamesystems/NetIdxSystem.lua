using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using Entitas;
using Maria;

namespace Bacon.GameSystems {
    public class NetIdxSystem : ISystem, ISetContextSystem, IExecuteSystem {

        private GameContext _context;
        private AppContext _appContext;
        private AppGameSystems _gameSystems;
        private Dictionary<long, GameEntity> _entitas = new Dictionary<long, GameEntity>();

        public NetIdxSystem(Contexts contexts) {
            _context = contexts.game;
        }

        public void SetAppContext(AppContext context) {
            _appContext = context;
            _gameSystems = context.GameSystems;
        }


        public void Execute() {

        }

        public void AddEntity(IEntity entity) {
#if (!GEN_COMPONENT)
            var e = entity as GameEntity;
            if (e.hasPlayer) {
                _entitas.Add(e.player.idx, e);
            }
#endif
        }

        public void RemoveEntity(IEntity entity) {
#if (!GEN_COMPONENT)

            var e = entity as GameEntity;
            if (e.hasPlayer) {
                _entitas.Remove(e.player.idx);
            }
            e.Destroy();
#endif
        }

        public GameEntity FindEntity(long index) {
            if (_entitas.ContainsKey(index)) {
                return _entitas[index] as GameEntity;
            }
            return null;
        }

        public void SortCards() {
#if (!GEN_COMPONENT)
            _context.rule.oknum = (int)_context.rule.max;
            foreach (var item in _entitas) {
                var entity = item.Value as GameEntity;
                _gameSystems.PlayerSystem.SortCards(entity);
            }
            _appContext.EnqueueRenderQueue(RenderSortCardsAfterDeal);
#endif
        }

        public void ClearCall() {
            foreach (var item in _entitas) {
                var entity = item.Value as GameEntity;
                //_gameSystems.PlayerSystem.ClearCall();
            }
        }

        public void PlayFlame(long idx, long cd) {
            foreach (var item in _entitas) {
                GameEntity entity = item.Value as GameEntity;
                if (entity.player.idx == idx) {
                    entity.head.headUIController.SetFlame((int)cd);
                } else {
                    entity.head.headUIController.SetFlame(0);
                }
            }
        }

        public void ShowHeadFirst() {
            // setui after
            if (_appContext.Peek().Name == "game" && _appContext.Peek().LoadedUI) {
                foreach (var item in _entitas) {
                    GameEntity entity = item.Value;
                    if (entity.head.headUIController.Counter <= 0) {
                        entity.head.headUIController.Controller = _appContext.Peek();
                        _appContext.UIContextManager.Push(entity.head.headUIController);
                    }
                }
            }
        }

        public void LoadHand() {
            if (_appContext.Peek().Name == "game" && _appContext.Peek().LoadedUI) {
                _appContext.EnqueueRenderQueue(RenderLoadHand);
            }
        }

        public void Ready() {
            if (_appContext.Peek().Name == "game" && _appContext.Peek().LoadedUI) {
                if (_context.rule.gamestate == Game.GameState.READY && !_context.rule.fixedReady) {
                    _context.rule.fixedReady = true;
                    _appContext.EnqueueRenderQueue(RenderReady);
                }
            }
        }

        #region render
        public void RenderLoadHand() {
            foreach (var item in _entitas) {
                GameEntity entity = item.Value;
                if (entity.player.go == null) {
                    _gameSystems.PlayerSystem.RenderLoadHand(entity);
                }
            }
        }

        public void RenderReady() {
            foreach (var item in _entitas) {
                GameEntity entity = item.Value;
                if (entity.player.go == null) {
                    _gameSystems.PlayerSystem.RenderReady(entity);
                }
            }
        }

        public void RenderBoxing() {
            foreach (var item in _entitas) {
                GameEntity entity = item.Value as GameEntity;
                _gameSystems.PlayerSystem.RenderBoxing(entity);
            }
        }

        public void RenderSortCardsAfterDeal() {
            foreach (var item in _entitas) {
                var entity = item.Value as GameEntity;
                _gameSystems.PlayerSystem.RenderSortCardsAfterDeal(entity);
            }
        }

        public void RenderXuanQue() {
            foreach (var item in _entitas) {
                var entity = item.Value as GameEntity;
                _gameSystems.PlayerSystem.RenderXuanQue(entity);
            }
        }
        #endregion

    }
}
