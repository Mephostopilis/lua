

local _M = {}

_M.cards = {}

-- @ type : GameObject
_M.holdcard           
-- @ type : GameObject   
_M.holdcardValue
_M.touch = false          -- 总是true
_M.test = false

_M._hitGo

-- type : GameObject
_M._selectedGo;
        private float _start = 0;
        private float _timeMax = 1;

#if UNITY_STANDALONE_WIN || UNITY_EDITOR_WIN
        private Vector3 _lastMousePostion;
#elif UNITY_IOS || UNITY_ANDROID
#endif

        // Use this for initialization
        void Start() {
            if (test) {
                if (cards == null) {
                    cards = new Dictionary<long, GameObject>();
                }
                Transform bam1 = transform.Find("Bam_1");
                cards.Add(1, bam1.gameObject);
            }
        }

        // Update is called once per frame
        void Update() {
            if (touch) {
#if UNITY_STANDALONE_WIN || UNITY_EDITOR_WIN
                if (Input.GetMouseButtonDown(0)) {
                    Ray r = Camera.main.ScreenPointToRay(Input.mousePosition);
                    RaycastHit hitInfo;
                    if (Physics.Raycast(r, out hitInfo, 20)) {
                        GameObject hitGo = hitInfo.transform.gameObject;
                        Vector3 lastMousePostion = Input.mousePosition;
                        if (hitGo != null) {
                            _hitGo = hitGo;
                            _start = Time.realtimeSinceStartup;
                        }
                    }
                } else if (Input.GetMouseButton(0)) {
                    if (_hitGo != null) {
                        UnityEngine.Debug.LogFormat(Input.mousePosition.ToString());
                        Vector3 delta = Input.mousePosition - _lastMousePostion;
                        //_hitGo.transform.localPosition = _hitGo.transform.localPosition + new Vector3(delta.x / 1000.0f, 0.0f, delta.y / 1000.0f);
                    }
                } else if (Input.GetMouseButtonUp(0)) {
                    if (_hitGo != null) {
                        long value = 0;
                        bool isHoldcard = false;
                        if (FindGo(_hitGo, out value, out isHoldcard)) {
                            if (_selectedGo != null) {
                                if (_selectedGo == _hitGo) {
                                    Message msg = new Message();
                                    msg["value"] = value;
                                    msg["isHoldcard"] = isHoldcard;
                                    Command cmd = new Command(MyEventCmd.EVENT_LEAD, null, msg);
                                    GL.Util.App.current.Enqueue(cmd);
                                    touch = false;
                                    _selectedGo = null;
                                } else {
                                    // 缩回原来的选择
                                    Vector4 q = _selectedGo.transform.worldToLocalMatrix.MultiplyVector(new Vector3(0.0f, -0.025f, 0.0f));
                                    _selectedGo.transform.Translate(q);


                                    _selectedGo = _hitGo;
                                    q = _selectedGo.transform.worldToLocalMatrix.MultiplyVector(new Vector3(0.0f, 0.025f, 0.0f));
                                    _selectedGo.transform.Translate(q);
                                }
                            } else {
                                _selectedGo = _hitGo;
                                Vector4 q = _selectedGo.transform.worldToLocalMatrix.MultiplyVector(new Vector3(0.0f, 0.025f, 0.0f));
                                _selectedGo.transform.Translate(q);

                                //Matrix4x4 mat = _selectedGo.transform.worldToLocalMatrix * Matrix4x4.Translate(new Vector3(0.0f, 1f, 0.0f));
                                //Vector4 right = mat.GetRow(0);
                                //Vector4 up = mat.GetRow(1);
                                //Vector4 forward = mat.GetRow(2);
                                //_selectedGo.transform.right = right;
                                //_selectedGo.transform.up = up;
                                //_selectedGo.transform.forward = forward;
                            }
                        } else {
                            if (_selectedGo != null) {
                                Vector4 q = _selectedGo.transform.worldToLocalMatrix.MultiplyVector(new Vector3(0.0f, -0.025f, 0.0f));
                                _selectedGo.transform.Translate(q);
                                _selectedGo = null;
                            }
                        }
                        _hitGo = null;
                    } else {
                        if (_selectedGo != null) {
                            Vector4 q = _selectedGo.transform.worldToLocalMatrix.MultiplyVector(new Vector3(0.0f, -0.025f, 0.0f));
                            _selectedGo.transform.Translate(q);
                            _selectedGo = null;
                        }
                    }
                }

#elif UNITY_IOS || UNITY_ANDROID
                           if (Input.touchCount > 0) {
                    if (Input.touches[0].phase == TouchPhase.Began) {
                        Ray r = Camera.main.ScreenPointToRay(Input.touches[0].position);
                        RaycastHit hitInfo;
                        Physics.Raycast(r, out hitInfo, 50);


                        //hitInfo.transform.gameObject;

                    }
                }
#endif
            }
        }

        private bool FindGo(GameObject go, out long value, out bool isHoldcard) {
            foreach (var item in cards) {
                if (item.Value == go) {
                    value = item.Key;
                    isHoldcard = false;
                    return true;
                }
            }
            if (holdcard == go) {
                value = holdcardValue;
                isHoldcard = true;
                return true;
            }
            value = 0;
            isHoldcard = false;
            return false;
        }
    }
}