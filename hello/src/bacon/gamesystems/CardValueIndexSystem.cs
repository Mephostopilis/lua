using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using Entitas;
using Maria;
using Maria.Event;
using Bacon.Game;
using Bacon.Event;


namespace Bacon.GameSystems {
    public class CardValueIndexSystem : ISystem, ISetContextSystem, IInitializeSystem, ICleanupSystem {
        private GameContext _context;
        private AppContext _appContext;
        private AppGameSystems _gameSystems;
        private Dictionary<long, GameEntity> _dict = new Dictionary<long, GameEntity>();

        public CardValueIndexSystem(Contexts contexts) {
            _context = contexts.game;
        }

        public void SetAppContext(AppContext context) {
            _appContext = context;
            _gameSystems = _appContext.GameSystems;
        }

        public void Initialize() {
            EventListenerCmd listener2 = new EventListenerCmd(MyEventCmd.EVENT_LOADEDCARDS, OnLoadCard);
            _appContext.EventDispatcher.AddCmdEventListener(listener2);

            LoadMahjong();
        }

        public void Cleanup() { }

        public GameEntity FindEntity(long value) {
            if (_dict.ContainsKey(value)) {
                return _dict[value];
            }
            return null;
        }

        public void Clear() {
#if (!GEN_COMPONENT)
            foreach (var item in _dict) {
                item.Value.card.que = false;
                item.Value.card.pos = 0;
                item.Value.card.parent = 0;
            }
#endif
        }

        public void LoadMahjong() {
            string path = "Prefabs/Mahjongs";
            for (int i = 1; i < 4; i++) {
                string prefix = string.Empty;
                if (i == (int)Card.CardType.Crak) {
                    prefix = "Crak_";
                } else if (i == (int)Card.CardType.Bam) {
                    prefix = "Bam_";
                } else if (i == (int)Card.CardType.Dot) {
                    prefix = "Dot_";
                }
                for (int j = 1; j < 10; j++) {
                    string name = prefix + string.Format("{0}", j);
                    for (int k = 1; k < 5; k++) {
                        GameEntity entity = _context.CreateEntity();
                        long value = (i << 8) | (j << 4) | (k);
                        entity.AddCard(value, (Card.CardType)i, j, k, 0, false, 0, path, name, null);
                        _dict.Add(value, entity);
                    }
                }
            }
        }

        public void SetQueBrightness() {
            _appContext.EnqueueRenderQueue(RenderQueBrightness);
        }

        #region event
        private void OnLoadCard(EventCmd e) {
            int index = Convert.ToInt32(e.Msg["index"]);
            GameEntity entity = _gameSystems.IndexSystem.FindEntity(index);
            entity.card.go = e.Orgin;
        }
        #endregion

        #region render
        public void RenderLoadMahjong() {
            GameObject cards = GameObject.Find("cards");
            foreach (var item in _dict) {
                GameEntity entity = item.Value as GameEntity;
                if (entity.hasCard) {
                    GameObject original = Maria.Res.ABLoader.current.LoadAsset<GameObject>(entity.card.path, entity.card.name);
                    GameObject go = GameObject.Instantiate<GameObject>(original);
                    go.transform.SetParent(cards.transform);
                    Message msg = new Message();
                    msg["index"] = entity.index.index;
                    Command cmd = new Command(MyEventCmd.EVENT_LOADEDCARDS, go, msg);
                    Bacon.GL.Util.App.current.Enqueue(cmd);
                }
            }
        }

        private void RenderQueBrightness() {
            foreach (var item in _dict) {
                if (item.Value.card.que && item.Value.card.go != null) {
                    item.Value.card.go.GetComponent<Renderer>().material.SetFloat("Brightness", 0.8f);
                } else {
                    item.Value.card.go.GetComponent<Renderer>().material.SetFloat("Brightness", 1.0f);
                }
            }
        }
        #endregion
    }
}
