using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using Entitas;
using Maria;
using Bacon.Game;
using Bacon.Model.Room;
using Maria.Controller;

namespace Bacon.GameSystems {
    public class SceneSystem : ISystem, ISetContextSystem, IInitializeSystem, ISceneController {
        private GameContext _context;
        private AppContext _appContext;
        private AppGameSystems _gameSystems;

        public SceneSystem(Contexts contexts) {
            _context = contexts.game;
        }

        public void SetAppContext(AppContext context) {
            _appContext = context;
            _gameSystems = _appContext.GameSystems;
        }

        public void Initialize() {
            Director.Instance.ControllerMgr.RegController(this);
        }

        public void OnControllerEnter(Controller controller) {
        }

        public void OnControllerEnterLoadDidFinish(Controller controller) {
            if (controller.Name == "game") {
            }
        }

        public void OnControllerExitUnloadDidStart(Controller controller) {
        }

        public void OnControllerExit(Controller controller) {
        }

        public void OnControllerPause(Controller controller) {
        }

        public void OnControllerPauseUnloadDidStart(Controller controller) {
        }

        public void OnControllerResumeLoadDidFinish(Controller controller) {
        }

        public void OnControllerResume(Controller controller) {
        }

        public void OnControllerEnterSetupUI(Controller controller) {
            if (controller.Name == GameController.Name) {
                _appContext.EnqueueRenderQueue(_gameSystems.CardValueIndexSystem.RenderLoadMahjong);
                _gameSystems.NetIdxSystem.ShowHeadFirst();
                _gameSystems.NetIdxSystem.LoadHand();
                _gameSystems.NetIdxSystem.Ready();

                RoomModule roomModule = _appContext.U.GetModule<RoomModule>();
                _appContext.GameSystems.DeskSystem.SetRoomId(roomModule.RoomId);
            }
        }
    }
}
