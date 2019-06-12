
using Maria;
using Maria.Controller;
using Maria.Event;
using Bacon.Event;
using Bacon.Helper;
using Bacon.Service;
using Bacon.Model.GameUI;
using Bacon.Model.Join;
using Bacon.Model.Room;


namespace Bacon.Game {
    public class GameController : Controller {

        public static readonly string Name = "game";

        public GameController() {
            _name = Name;

            EventListenerCmd listener7 = new EventListenerCmd(MyEventCmd.EVENT_SETUP_UI3D, SetupUI);
            Director.Instance.EventDispatcher.AddCmdEventListener(listener7);

            EventListenerCmd listener10 = new EventListenerCmd(MyEventCmd.EVENT_SETUP_BUICANVAS, OnSetupBuiCanvas);
            Director.Instance.EventDispatcher.AddCmdEventListener(listener10);

            //EventListenerCmd listener11 = new EventListenerCmd(MyEventCmd.EVENT_SETUP_AUICANVAS, OnSetupAuiCanvas);
            //_ctx.EventDispatcher.AddCmdEventListener(listener11);

            EventListenerCmd listener12 = new EventListenerCmd(MyEventCmd.EVENT_SETUP_SCENE, OnSetupScene);
            Director.Instance.EventDispatcher.AddCmdEventListener(listener12);
        }

        public override void OnEnter() {
            base.OnEnter();
            InitService service = Director.Instance.ServiceMgr.QueryService<InitService>();
            SMActor actor = service.SMActor;
            actor.LoadScene("game");
        }

        public override void OnExit() {
            base.OnExit();
        }

        public override void OnCreateLua() {
        }

        public override void OnDestroyLua() {
        }

        #region event
        private void OnSetupScene(EventCmd e) {
            if (e.Msg["name"].ToString() == _name) {
                _loaded = true;
                foreach (var M in Director.Instance.ControllerMgr.List) {
                    if (_mode == EnterMode.Enter) {
                        M.OnControllerEnterLoadDidFinish(this);
                    } else if (_mode == EnterMode.Resume) {
                        M.OnControllerResumeLoadDidFinish(this);
                    }
                }
            }
        }

        private void OnSetupBuiCanvas(EventCmd e) {
            Message msg = e.Msg;
            string sceneName = msg["sceneName"].ToString();
            if (sceneName == _name) {
                this.BuiCanvas = e.Orgin;
            }
        }

        private void SetupUI(EventCmd e) {
            Message msg = e.Msg;
            string sceneName = msg["sceneName"].ToString();
            if (sceneName == _name) {
                Ui3D = e.Orgin;
                this._loadedui = true;

                foreach (var M in Director.Instance.ControllerMgr.List) {
                    M.OnControllerEnterSetupUI(this);
                }
            }
        }

        #endregion
    }
}
