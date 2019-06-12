
local cls = class('TopPlayerSystem')

function cls:ctor( ... )
    -- body
end

public TopPlayer(Context ctx, GameController controller) : base(ctx, controller) {
    _upv = Quaternion.AngleAxis(180.0f, Vector3.up);
//    _uph = Quaternion.AngleAxis(90.0f, Vector3.up);
//    _downv = Quaternion.AngleAxis(180.0f, Vector3.up) * Quaternion.AngleAxis(180.0f, Vector3.forward);
//    _backv = Quaternion.AngleAxis(180.0f, Vector3.up) * Quaternion.AngleAxis(-90.0f, Vector3.right);

//    _ori = Orient.TOP;
//    _takeleftoffset = 0.5f;
//    _takebottomoffset = 0.405f - (Card.Length / 2.0f);

//    _leftoffset = 0.5f;
//    _bottomoffset = 1.72f;

//    _leadcardoffset = new Vector3(-0.05f, 0.0f, 0.0f);
//    _leadleftoffset = 0.8f;
//    _leadbottomoffset = 0.8f;

//    _putbottomoffset = 0.1f - Card.Length / 2.0f;
//    _putrightoffset = 0.55f - Card.Width / 2.0f;

//    // 手
//    _rhandinitpos = new Vector3(1.6f, -1.8f, 3.0f);
//    _rhandinitrot = Quaternion.Euler(0.0f, 180.0f, 0.0f);
//    _rhandleadoffset = new Vector3(0.597f, -1.967f, 1.124f);
//    _rhandtakeoffset = new Vector3(0.399f, -2.034f, 0.497f);
//    _rhandnaoffset = new Vector3(0.43f, -2.136f, 0.4299f);
//    _rhandpgoffset = Vector3.zero;
//    _rhandhuoffset = Vector3.zero;

//    _lhandinitpos = new Vector3(1.6f, -1.8f, 3.0f);
//    _lhandinitrot = Quaternion.Euler(0.0f, 180.0f, 0.0f);
//    _lhandhuoffset = Vector3.zero;

//    EventListenerCmd listener1 = new EventListenerCmd(MyEventCmd.EVENT_SETUP_TOPPLAYER, OnSetup);
//    _ctx.EventDispatcher.AddCmdEventListener(listener1);
//end

-- //public override void Init() {
-- //    base.Init();
-- //    if (_sex == 1) { // 男
-- //        _rhandleadoffset = new Vector3(0.103f, -2.113f, 1.013f);
-- //        _rhandtakeoffset = new Vector3(0.502f, -2.052f, 0.516f);
-- //        _rhandnaoffset = new Vector3(0.502f, -2.083f, 0.49f);
-- //        _rhandpgoffset = new Vector3(0.828f, -1.978f, 0.766f);
-- //        _rhandpgoffset = new Vector3(0.188f, -2.13f, 0.652f);
-- //    end
-- //end

function cls:RenderPlayFlameCountdown()
    _com.Head.PlayFlameCountdown(_cd)
end

function cls:RenderStopFlame() {
    _com.Head.StopFlame();
end

private void OnSetup(EventCmd e) {
    _go = e.Orgin;
    _ctx.EnqueueRenderQueue(RenderSetup);
end

private void RenderSetup() {
    _com = _go.GetComponent<Bacon.GL.Game.TopPlayer>();
    _com.ShowUI();
    _com.Head.SetGold(_chip);
end

-- protected override Vector3 CalcPos(int pos) {
--     Desk desk = ((GameController)_controller).Desk;
--     float x = desk.Width - (_leftoffset + Card.Width * pos + Card.Width / 2.0f);
--     float y = Card.Length / 2.0f + Card.HeightMZ;
--     float z = _bottomoffset;
--     return new Vector3(x, y, z);
-- end

-- //protected override Vector3 CalcLeadPos(int pos) {
-- //    Desk desk = ((GameController)_controller).Desk;
-- //    int row = pos / 6;
-- //    int col = pos % 6;

-- //    float x = desk.Width - (_leadleftoffset + (Card.Width * col) + (Card.Width / 2.0f));
-- //    float y = Card.Height / 2.0f + Card.HeightMZ;
-- //    float z = desk.Length - (_leadbottomoffset - (Card.Length * row) - Card.Length / 2.0f);

-- //    return new Vector3(x, y, z);
-- //end

//function cls:RenderFixDirMark() {
//    if (_idx == 1) {
//        ((GameController)_controller).Desk.RenderSetDongAtTop();
//    end else if (_idx == 2) {
//        ((GameController)_controller).Desk.RenderSetNanAtTop();
//    end else if (_idx == 3) {
//        ((GameController)_controller).Desk.RenderSetXiAtTop();
//    end else if (_idx == 4) {
//        ((GameController)_controller).Desk.RenderSetBeiAtTop();
//    end else {
//        UnityEngine.Debug.Assert(false);
//    end

        //    if (_sex == 1) {
        //        GameObject rori = ABLoader.current.LoadAsset<GameObject>("Prefabs/Hand", "boyrhand");
        //        _rhand = GameObject.Instantiate<GameObject>(rori);

        //        GameObject lori = ABLoader.current.LoadAsset<GameObject>("Prefabs/Hand", "boylhand");
        //        _lhand = GameObject.Instantiate<GameObject>(lori);
        //    end else {
        //        GameObject rori = ABLoader.current.LoadAsset<GameObject>("Prefabs/Hand", "girlrhand");
        //        _rhand = GameObject.Instantiate<GameObject>(rori);

        //        GameObject lori = ABLoader.current.LoadAsset<GameObject>("Prefabs/Hand", "girllhand");
        //        _lhand = GameObject.Instantiate<GameObject>(lori);
        //    end

        //    _rhand.transform.SetParent(_go.transform);
        //    _rhand.transform.localPosition = _rhandinitpos;
        //    _rhand.transform.localRotation = _rhandinitrot;

        //    _lhand.transform.SetParent(_go.transform);
        //    _lhand.transform.localPosition = _lhandinitpos;
        //    _lhand.transform.localRotation = _lhandinitrot;

        //end

        //function cls:RenderBoxing() {
        //    try {
        //        int count = 0;
        //        Desk desk = ((GameController)_controller).Desk;
        //        desk.RenderShowTopSlot(() => {
        //        end);

        //        for (int i = 0; i < _takecards.Count; i++) {
        //            int idx = i / 2;
        //            float x = _takeleftoffset + idx * Card.Width + Card.Width / 2.0f;
        //            float y = Card.HeightMZ + Card.Height / 2.0f;
        //            float z = desk.Length - (_takebottomoffset + Card.Length / 2.0f);
        //            if (i % 2 == 0) {
        //                y = Card.HeightMZ + Card.Height + Card.Height / 2.0f;
        //            end else if (i % 2 == 1) {
        //                y = Card.HeightMZ + Card.Height / 2.0f;
        //            end
        //            Card card = _takecards[i];
        //            card.Go.transform.localRotation = _downv;

        //            card.Go.transform.localPosition = new UnityEngine.Vector3(x, y - _takemove, z);
        //            Tween t = card.Go.transform.DOLocalMoveY(y, _takemovedelta);

        //            Sequence mySequence = DOTween.Sequence();
        //            mySequence.Append(t)
        //            .AppendCallback(() => {
        //                count++;
        //                if (count == _takecards.Count) {
        //                    Maria.Command cmd = new Maria.Command(MyEventCmd.EVENT_BOXINGCARDS);
        //                    _ctx.Enqueue(cmd);
        //                end
        //            end);
        //        end

        //        desk.RenderCloseTopSlot(() => {
        //        end);
        //    end catch (Exception ex) {
        //        UnityEngine.Debug.LogException(ex);
        //    end
        //end

        //function cls:RenderThrowDice() {
        //    // 1.0 伸手
        //    Animator animator = _rhand.GetComponent<Animator>();
        //    Tween t;
        //    if (_sex == 1) {
        //        Vector3 dst = new Vector3(1.858f, -1.914f, 1.799f);
        //        Vector3 offset = dst - _rhandinitpos;
        //        Vector3[] path = new Vector3[] {
        //            _rhandinitpos,
        //            _rhandinitpos + new Vector3(_rhandinitpos.x + offset.x * 0.1f, _rhandinitpos.y, _rhandinitpos.z + offset.z * 0.1f ),
        //            _rhandinitpos + new Vector3(_rhandinitpos.x + offset.x * 0.2f, _rhandinitpos.y, _rhandinitpos.z + offset.z * 0.2f),
        //            _rhandinitpos + new Vector3(_rhandinitpos.x + offset.x * 0.4f, _rhandinitpos.y, _rhandinitpos.z + offset.z * 0.4f),
        //            _rhandinitpos + new Vector3(_rhandinitpos.x + offset.x * 0.6f, _rhandinitpos.y + offset.y * 0.5f, _rhandinitpos.z + offset.z * 0.6f),
        //            dst,
        //        end;
        //        t = _rhand.transform.DOLocalPath(path, _diushaizishendelta);
        //    end else {
        //        Vector3 dst = new Vector3(1.858f, -1.914f, 1.799f);
        //        Vector3 offset = dst - _rhandinitpos;
        //        Vector3[] path = new Vector3[] {
        //            _rhandinitpos,
        //            _rhandinitpos + new Vector3(_rhandinitpos.x + offset.x * 0.1f, _rhandinitpos.y, _rhandinitpos.z + offset.z * 0.1f ),
        //            _rhandinitpos + new Vector3(_rhandinitpos.x + offset.x * 0.2f, _rhandinitpos.y, _rhandinitpos.z + offset.z * 0.2f),
        //            _rhandinitpos + new Vector3(_rhandinitpos.x + offset.x * 0.4f, _rhandinitpos.y, _rhandinitpos.z + offset.z * 0.4f),
        //            _rhandinitpos + new Vector3(_rhandinitpos.x + offset.x * 0.6f, _rhandinitpos.y + offset.y * 0.5f, _rhandinitpos.z + offset.z * 0.6f),
        //            dst,
        //        end;
        //        t = _rhand.transform.DOLocalPath(path, _diushaizishendelta);
        //    end

        //    Sequence mySequence = DOTween.Sequence();
        //    mySequence.Append(t)
        //        .AppendCallback(() => {
        //            // 2.0 丢色子
        //            Bacon.GL.Game.Hand hand = _rhand.GetComponent<Bacon.GL.Game.Hand>();
        //            hand.Rigster(Bacon.GL.Game.Hand.EVENT.DIUSHAIZI_COMPLETED, () => {
        //                // 3.1
        //                UnityEngine.Debug.Log("top diu saizi ");
        //                ((GameController)_controller).RenderThrowDice(_d1, _d2);
        //                // 3.2, 收手
        //                Tween t32;
        //                if (_sex == 1) {
        //                    Vector3 src = new Vector3(1.858f, -1.914f, 1.799f);
        //                    Vector3 offset = _rhandinitpos - src;
        //                    Vector3[] path = {
        //                        src,
        //                        _rhandinitpos + new Vector3(src.x + offset.x * 0.6f, src.y + offset.y + 0.5f, src.z + offset.z * 0.6f ),
        //                        _rhandinitpos + new Vector3(src.x + offset.x * 0.4f, _rhandinitpos.y, src.z + offset.z * 0.3f),
        //                        _rhandinitpos + new Vector3(src.x + offset.x * 0.2f, _rhandinitpos.y, src.z + offset.z * 0.2f),
        //                        _rhandinitpos + new Vector3(src.x + offset.x * 0.1f, _rhandinitpos.y, src.z + offset.z * 0.1f),
        //                        _rhandinitpos,
        //                    end;
        //                    t32 = _rhand.transform.DOLocalPath(path, _diushaizishendelta);
        //                end else {
        //                    Vector3 src = new Vector3(1.858f, -1.914f, 1.799f);
        //                    Vector3 offset = _rhandinitpos - src;
        //                    Vector3[] path = {
        //                        src,
        //                        _rhandinitpos + new Vector3(src.x + offset.x * 0.6f, src.y + offset.y + 0.5f, src.z + offset.z * 0.6f ),
        //                        _rhandinitpos + new Vector3(src.x + offset.x * 0.4f, _rhandinitpos.y, src.z + offset.z * 0.3f),
        //                        _rhandinitpos + new Vector3(src.x + offset.x * 0.2f, _rhandinitpos.y, src.z + offset.z * 0.2f),
        //                        _rhandinitpos + new Vector3(src.x + offset.x * 0.1f, _rhandinitpos.y, src.z + offset.z * 0.1f),
        //                        _rhandinitpos,
        //                    end;
        //                    t32 = _rhand.transform.DOLocalPath(path, _diushaizishendelta);
        //                end

        //                Sequence mySequence32 = DOTween.Sequence();
        //                mySequence32.Append(t32).
        //                AppendCallback(() => {
        //                    // 4.0 归原
        //                    animator.SetBool("Idle", true);
        //                end);
        //            end);
        //            animator.SetBool("Diushaizi", true);
        //        end);
        //end

//function cls:RenderDeal() {
//    _oknum = 0;
//    int count = 0;
//    int i = 0;
//    if (_cards.Count == 13) {
//        i = 12;
//        count = 1;
//    end else {
//        i = _cards.Count - 4;
//        count = 4;
//    end
//    for (; i < _cards.Count; i++) {
//        Vector3 dst = CalcPos(i);
//        var card = _cards[i];
//        card.Go.transform.localPosition = dst;
//        card.Go.transform.localRotation = Quaternion.AngleAxis(180.0f, Vector3.up) * Quaternion.AngleAxis(-115.0f, Vector3.right);
//        Tween t = card.Go.transform.DOLocalRotateQuaternion(_backv, _dealcarddelta);
//        Sequence mySequence = DOTween.Sequence();
//        mySequence.Append(t)
//            .AppendCallback(() => {
//                _oknum++;
//                if (_oknum >= count) {
//                    _oknum = 0;
//                    Command cmd = new Command(MyEventCmd.EVENT_TAKEDEAL);
//                    _ctx.Enqueue(cmd);
//                end
//            end);
//    end
//end

        //function cls:RenderSortCards() {
        //    int count = 0;
        //    int i = 0;
        //    for (; i < _cards.Count; i++) {
        //        Sequence mySequence = DOTween.Sequence();
        //        mySequence.Append(_cards[i].Go.transform.DORotateQuaternion(Quaternion.AngleAxis(180.0f, Vector3.up) * Quaternion.AngleAxis(-120.0f, Vector3.right), _sortcardsdelta))
        //            .AppendCallback(() => {
        //                for (int j = 0; j < _cards.Count; j++) {
        //                    Vector3 dst = CalcPos(j);
        //                    _cards[j].Go.transform.localPosition = dst;
        //                end
        //            end)
        //            .Append(_cards[i].Go.transform.DORotateQuaternion(Quaternion.AngleAxis(180.0f, Vector3.up) * Quaternion.AngleAxis(-90.0f, Vector3.right), _sortcardsdelta))
        //            .AppendCallback(() => {
        //                count++;
        //                if (count >= _cards.Count) {
        //                    UnityEngine.Debug.LogFormat("player top send sort cards");
        //                    Command cmd = new Command(MyEventCmd.EVENT_SORTCARDSAFTERDEAL);
        //                    _ctx.Enqueue(cmd);
        //                end
        //            end);
        //    end
        //end

        //function cls:RenderTakeXuanPao() {
        //    _go.GetComponent<Bacon.GL.Game.TopPlayer>().Head.ShowMark(string.Format("{0end", _fen));
        //end

        //function cls:RenderXuanPao() {
        //end

        //function cls:RenderTakeFirstCard() {
        //    UnityEngine.Debug.Assert(_takefirst);
        //    RenderTakeCard(() => {
        //        Command cmd = new Command(MyEventCmd.EVENT_TAKEFIRSTCARD);
        //        _ctx.Enqueue(cmd);
        //    end);
        //end

        //function cls:RenderTakeXuanQue() {

        //end

        //function cls:RenderXuanQue() {
        //    if (_que == Card.CardType.Bam) {
        //        _go.GetComponent<Bacon.GL.Game.TopPlayer>().Head.ShowMark("条");
        //    end else if (_que == Card.CardType.Crak) {
        //        _go.GetComponent<Bacon.GL.Game.TopPlayer>().Head.ShowMark("万");
        //    end else if (_que == Card.CardType.Dot) {
        //        _go.GetComponent<Bacon.GL.Game.TopPlayer>().Head.ShowMark("同");
        //    end
        //    RenderSortCardsToDo(_sortcardsdelta, () => {
        //    end);
        //end

        //function cls:RenderTakeTurn() {
        //    base.RenderTakeTurn();

        //    if (_turntype == 1) {
        //        RenderTakeCard(() => { end);
        //    end else if (_turntype == 0) {
        //        Vector3 dst = CalcPos(_cards.Count + 1);
        //        _holdcard.Go.transform.localRotation = _backv;

        //        Sequence mySequence = DOTween.Sequence();
        //        mySequence.Append(_holdcard.Go.transform.DOLocalMove(dst, _holddowndelta));
        //    end
        //end

        //function cls:RenderInsert(Action cb) {
        //    base.RenderInsert(cb);
        //end

        //function cls:RenderSortCardsAfterFly(Action cb) {
        //    base.RenderSortCardsAfterFly(cb);
        //end

        //function cls:RenderFly(Action cb) {
        //    base.RenderFly(cb);
        //end

        //function cls:RenderLead() {
        //    base.RenderLead();

        //    RenderLead1(RenderLead1Cb);
        //end

        //function cls:RenderClearCall() {
        //    _com.Head.CloseWAL();
        //end

        //function cls:RenderPeng() {
        //    base.RenderPeng();

        //    Desk desk = ((GameController)_controller).Desk;
        //    PGCards pg = _putcards[_putidx];
        //    UnityEngine.Debug.Assert(pg.Cards.Count == 3);
        //    float offset = _putrightoffset;
        //    for (int i = 0; i < _putidx; i++) {
        //        UnityEngine.Debug.Assert(_putcards[i].Width > 0.0f);
        //        offset += _putcards[i].Width + _putmargin;
        //    end

        //    _putmove = new Vector3(-1.0f, 0.0f, 0.0f);
        //    for (int i = 0; i < pg.Cards.Count; i++) {
        //        float x = 0.0f;
        //        float y = Card.Height / 2.0f + Card.HeightMZ;
        //        float z = _putbottomoffset;
        //        if (i == pg.Hor) {
        //            x = offset + Card.Length / 2.0f;
        //            z = desk.Length - (_putbottomoffset + Card.Width / 2.0f);
        //            offset += Card.Length;
        //            pg.Width += Card.Length;
        //            pg.Cards[i].Go.transform.localRotation = _uph;
        //        end else {
        //            x = offset + Card.Width / 2.0f;
        //            z = desk.Length - (_putbottomoffset + Card.Length / 2.0f);
        //            offset += Card.Width;
        //            pg.Width += Card.Width;
        //            pg.Cards[i].Go.transform.localRotation = _upv;
        //        end
        //        pg.Cards[i].Go.transform.localPosition = new Vector3(x, y, z) + _putmove;
        //    end

        //    RenderPeng1();
        //end

        //function cls:RenderGang() {
        //    base.RenderGang();

        //    Desk desk = ((GameController)_controller).Desk;
        //    PGCards pg = _putcards[_putidx];
        //    UnityEngine.Debug.Assert(pg.Cards.Count == 4);

        //    float offset = _putrightoffset;
        //    for (int i = 0; i < _putidx; i++) {
        //        UnityEngine.Debug.Assert(_putcards[i].Width > 0.0f);
        //        offset += _putcards[i].Width + _putmargin;
        //    end

        //    _putmove = new Vector3(-1.0f, 0.0f, 0.0f);
        //    if (pg.Opcode == OpCodes.OPCODE_ZHIGANG) {
        //        for (int i = 0; i < pg.Cards.Count; i++) {
        //            float x = 0.0f;
        //            float y = Card.Height / 2.0f + Card.HeightMZ;
        //            float z = _putbottomoffset;
        //            if (i == pg.Hor) {
        //                x = offset + Card.Length / 2.0f;
        //                z = desk.Length - (_putbottomoffset + Card.Width / 2.0f);
        //                offset += Card.Length;
        //                pg.Width += Card.Length;
        //                pg.Cards[i].Go.transform.localRotation = _uph;
        //            end else {
        //                x = offset + Card.Width / 2.0f;
        //                z = desk.Length - (_putbottomoffset + Card.Length / 2.0f);
        //                offset += Card.Width;
        //                pg.Width += Card.Width;
        //                pg.Cards[i].Go.transform.localRotation = _upv;
        //            end
        //            pg.Cards[i].Go.transform.localPosition = new Vector3(x, y, z) - _putmove;
        //        end
        //        RenderGang1(() => {
        //            RenderSortCardsToDo(_pgsortcardsdelta, () => {
        //                Command cmd = new Command(MyEventCmd.EVENT_GANGCARD);
        //                _ctx.Enqueue(cmd);
        //            end);
        //        end);
        //    end else if (pg.Opcode == OpCodes.OPCODE_ANGANG) {
        //        for (int i = 0; i < pg.Cards.Count; i++) {
        //            float x = offset + Card.Width / 2.0f;
        //            float y = Card.Height / 2.0f + Card.HeightMZ;
        //            float z = desk.Length - (_putbottomoffset + Card.Length / 2.0f);
        //            offset += Card.Width;
        //            pg.Width += Card.Width;

        //            if (i == pg.Hor) {
        //                pg.Cards[i].Go.transform.localRotation = _upv;
        //            end else {
        //                pg.Cards[i].Go.transform.localRotation = _backv;
        //            end
        //            pg.Cards[i].Go.transform.localPosition = new Vector3(x, y, z) - _putmove;
        //        end
        //        RenderGang1(() => {
        //            if (pg.Cards[3].Value == _holdcard.Value) {
        //                RenderSortCardsToDo(_pgsortcardsdelta, () => {
        //                    Command cmd = new Command(MyEventCmd.EVENT_GANGCARD);
        //                    _ctx.Enqueue(cmd);
        //                end);
        //            end else {
        //                if (_holdcard.Pos == (_cards.Count - 1)) {
        //                    RenderSortCardsToDo(_pgsortcardsdelta, () => {
        //                        Command cmd = new Command(MyEventCmd.EVENT_GANGCARD);
        //                        _ctx.Enqueue(cmd);
        //                    end);
        //                end else {
        //                    RenderFly(() => {
        //                        Command cmd = new Command(MyEventCmd.EVENT_GANGCARD);
        //                        _ctx.Enqueue(cmd);
        //                    end);
        //                end
        //            end
        //        end);
        //    end else if (true) {

        //        float x = offset + Card.Width * pg.Hor + Card.Width / 2.0f;
        //        float y = Card.Height / 2.0f + Card.HeightMZ;
        //        float z = desk.Length - (_putbottomoffset + Card.Width / 2.0f + Card.Width);
        //        pg.Cards[3].Go.transform.localPosition = new Vector3(x, y, z) - _putmove;
        //        pg.Cards[3].Go.transform.localRotation = _uph;

        //        RenderGang1(() => {
        //            if (_holdcard.Value == pg.Cards[3].Value) {
        //                _holdcard = null;
        //                Command cmd = new Command(MyEventCmd.EVENT_GANGCARD);
        //                _ctx.Enqueue(cmd);
        //            end else {
        //                RenderFly(() => {
        //                    Command cmd = new Command(MyEventCmd.EVENT_GANGCARD);
        //                    _ctx.Enqueue(cmd);
        //                end);
        //            end
        //        end);
        //    end
        //end

        //function cls:RenderGangSettle() {
        //    long chip = 0;
        //    long left = 0;
        //    if (_settle.Count > 0) {
        //        for (int i = 0; i < _settle.Count; i++) {
        //            chip = _settle[i].Chip;
        //            left = _settle[i].Left > left ? _settle[i].Left : left;
        //        end
        //        _com.Head.SetGold((int)left);
        //        _com.Head.ShowWAL(string.Format("{0end", chip));
        //    end
        //end

        //function cls:RenderHu() {
        //    base.RenderHu();

        //    int idx = _hucards.Count - 1;
        //    Card card = _hucards[idx];

        //    Desk desk = ((GameController)_controller).Desk;
        //    float x = _hurightoffset + Card.Width / 2.0f + Card.Width * idx;
        //    float y = Card.Height / 2.0f;
        //    float z = desk.Length - (_hubottomoffset + Card.Length / 2.0f);
        //    card.Go.transform.localPosition = new Vector3(x, y, z);

        //    _com.Head.SetHu(true);

        //    Sequence mySequence = DOTween.Sequence();
        //    mySequence.AppendInterval(1.0f)
        //        .AppendCallback(() => {
        //            Command cmd = new Command(MyEventCmd.EVENT_HUCARD);
        //            _ctx.Enqueue(cmd);
        //        end);
        //end

        //function cls:RenderHuSettle() {
        //    long chip = 0;
        //    long left = 0;
        //    if (_settle.Count > 0) {
        //        for (int i = 0; i < _settle.Count; i++) {
        //            chip = _settle[i].Chip;
        //            left = _settle[i].Left > left ? _settle[i].Left : left;
        //        end
        //        _com.Head.SetGold((int)left);
        //        _com.Head.ShowWAL(string.Format("{0end", chip));
        //    end
        //end

        //function cls:RenderOver() {
        //    Desk desk = ((GameController)_controller).Desk;
        //    for (int i = 0; i < _cards.Count; i++) {
        //        float x = desk.Width - (_leftoffset + Card.Width * i + Card.Width / 2.0f);
        //        float y = Card.Height / 2.0f;
        //        float z = desk.Length - (_bottomoffset + Card.Length / 2.0f);

        //        _cards[i].Go.transform.localPosition = new Vector3(x, y, z);
        //        _cards[i].Go.transform.localRotation = _upv;
        //    end
        //end

        //function cls:RenderSettle() {
        //    long chip = 0;
        //    long left = 0;
        //    if (_settle.Count > 0) {
        //        SettlementItem item = _settle[0];
        //        if (item.TuiSui == 1) {
        //            _com.Head.SetGold((int)left);
        //            _com.Head.ShowWAL("退税");

        //            Sequence mySequence = DOTween.Sequence();
        //            mySequence.AppendInterval(1.0f)
        //                .AppendCallback(() => {
        //                    _com.Head.ShowWAL(string.Format("{0end", chip));
        //                end)
        //            .AppendInterval(1.0f)
        //            .AppendCallback(() => {
        //                Command cmd = new Command(MyEventCmd.EVENT_SETTLE_NEXT);
        //                _ctx.Enqueue(cmd);
        //            end);
        //        end else {
        //            Sequence mySequence = DOTween.Sequence();
        //            mySequence.AppendInterval(1.0f)
        //                .AppendCallback(() => {
        //                    Command cmd = new Command(MyEventCmd.EVENT_SETTLE_NEXT);
        //                    _ctx.Enqueue(cmd);
        //                end);
        //        end
        //    end
        //end

        //function cls:RenderFinalSettle() {
        //    _com.Head.SetHu(false);
        //    _com.Head.CloseWAL();
        //    int max = (int)_ctx.QueryService<GameService>(GameService.Name).Max;
        //    _com.OverWnd.SettleLeft(_idx, max, _settle);
        //end

        //function cls:RenderRestart() {
        //    _com.Head.SetHu(false);
        //    _com.Head.CloseWAL();
        //    _com.Head.SetReady(true);
        //end

        //function cls:RenderTakeRestart() {
        //    _com.Head.SetReady(false);
        //end

        //function cls:RenderSay() {
        //    _com.Say(_say);
        //end
