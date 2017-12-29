﻿
local cls = class("PlayerSystem")

function cls:ctor( ... )
    -- body
    self._appContext = nil
    self._context = nil
    self._gameSystems = nil
end


function cls:SetContext(context, ... )
    -- body
    self._context = context
end
        
function cls:SetAppContext(AppContext context) 
    self. _appContext = context;
end

function cls:SetAppGameSystem(system, ... )
    -- body
    self._gameSystems = system
end

        public virtual void Initialize() {
            EventListenerCmd listener2 = new EventListenerCmd(MyEventCmd.EVENT_SETUP_HAND, OnSetupHand);
            _appContext.EventDispatcher.AddCmdEventListener(listener2);
        }

#if (!GEN_COMPONENT)
        #region commom public
        public void SetXuanQue(long idx, bool value) {
            GameEntity entity = _gameSystems.NetIdxSystem.FindEntity(idx);
            entity.playerCard.hasXuanQue = value;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="who">网络索引</param>
        /// <param name="nx"></param>
        /// <returns>是否拿到牌</returns>
        public bool TakeCard(long who, out int index) {
            var player = _gameSystems.NetIdxSystem.FindEntity(who);
            if (player.takeCards.takecardscnt > 0) {
                if (player.takeCards.takecardsidx >= player.takeCards.takecardslen) {
                    player.takeCards.takecardsidx = 0;
                    index = 0;
                    return false;
                }

                var cardEntity = player.takeCards.takecards[player.takeCards.takecardsidx];
                cardEntity.card.pos = 0;
                cardEntity.card.parent = 0;
                index = cardEntity.index.index;

                player.takeCards.takecardscnt--;
                player.takeCards.takecards.Remove(player.takeCards.takecardsidx);
                player.takeCards.takecardsidx++;

                return true;
            } else {
                index = 0;
                return false;
            }
        }

        public Vector3 CalcPos(GameEntity entity, int pos) {
            GameEntity deskEntity = _gameSystems.DeskSystem.FindEntity();
            if (entity.player.orient == Player.Orient.BOTTOM) {
                float x = entity.handCards.leftoffset + Card.Width * pos + Card.Width / 2.0f;
                float y = Card.Length / 2.0f + Card.HeightMZ;
                y = 0.1f;
                float z = entity.handCards.bottomoffset + Card.Height / 2.0f;
                z = 0.235f;
                return new Vector3(x, y, z);
            } else if (entity.player.orient == Player.Orient.RIGHT) {
                float x = deskEntity.desk.width - (entity.handCards.bottomoffset + Card.Height / 2.0f);
                x = entity.handCards.bottomoffset;
                float y = Card.Length / 2.0f + Card.HeightMZ;
                float z = entity.handCards.leftoffset + Card.Width * pos + Card.Width / 2.0f;
                return new Vector3(x, y, z);
            } else if (entity.player.orient == Player.Orient.TOP) {
                float x = deskEntity.desk.width - (entity.handCards.leftoffset + Card.Width * pos + Card.Width / 2.0f);
                float y = Card.Length / 2.0f + Card.HeightMZ;
                float z = entity.handCards.bottomoffset;
                return new Vector3(x, y, z);
            } else {
                float x = entity.handCards.bottomoffset + Card.Height / 2.0f;
                float y = Card.Length / 2.0f + Card.HeightMZ;
                float z = deskEntity.desk.length - (entity.handCards.leftoffset + Card.Width * pos + Card.Width / 2.0f);
                return new Vector3(x, y, z);
            }
        }

        public Vector3 CalcLeadPos(GameEntity entity, int pos) {
            var deskEntity = _gameSystems.DeskSystem.FindEntity();

            //int row = (pos + 1) / 6;
            //int col = (pos + 1) % 6;
            int row = (pos) / 6;
            int col = (pos) % 6;

            float x = entity.leadCards.leadleftoffset + (Card.Width * col) + (Card.Width / 2.0f);
            float y = Card.Height / 2.0f + Card.HeightMZ;
            float z = entity.leadCards.leadbottomoffset - (Card.Length * row) - (Card.Length / 2.0f);

            return new Vector3(x, y, z);
        }

        public Vector3 CalcHuPos(GameEntity entity, int pos) {
            GameEntity deskEntity = _gameSystems.DeskSystem.FindEntity();
            if (entity.player.orient == Player.Orient.BOTTOM) {
                float x = deskEntity.desk.width - (entity.huCards.hurightoffset + (Card.Width / 2.0f) + (Card.Width * pos));
                float y = Card.Height / 2.0f;
                float z = entity.huCards.hubottomoffset + Card.Length / 2.0f;
                return new Vector3(x, y, z);
            } else if (entity.player.orient == Player.Orient.RIGHT) {
                float x = deskEntity.desk.width - (entity.huCards.hubottomoffset + Card.Length / 2.0f);
                float y = Card.Height / 2.0f;
                float z = deskEntity.desk.length - (entity.huCards.hurightoffset + Card.Width / 2.0f + Card.Width * pos);
                return new Vector3(x, y, z);
            } else if (entity.player.orient == Player.Orient.TOP) {
                float x = entity.huCards.hurightoffset + Card.Width / 2.0f + Card.Width * pos;
                float y = Card.Height / 2.0f;
                float z = deskEntity.desk.length - (deskEntity.huCards.hubottomoffset + Card.Length / 2.0f);
                return new Vector3(x, y, z);
            } else {
                float x = entity.huCards.hubottomoffset + Card.Length / 2.0f;
                float y = Card.Height / 2.0f;
                float z = entity.huCards.hurightoffset + Card.Width / 2.0f + (Card.Width * pos);
                return new Vector3(x, y, z);
            }
        }

        public Vector3 CalcPGPos(GameEntity entity, int pos) {
            if (entity.player.orient == Player.Orient.BOTTOM) {

            } else if (entity.player.orient == Player.Orient.RIGHT) {

            } else if (entity.player.orient == Player.Orient.TOP) {

            } else {

            }
            return Vector3.zero;
        }

        public void Insert(GameEntity entity, GameEntity cardEntity) {
            UnityEngine.Debug.Assert(entity.handCards.cards.Count > 0);

            entity.handCards.cards.Add(cardEntity);
            int last = entity.handCards.cards.Count - 1;
            cardEntity.card.pos = last;
            cardEntity.card.parent = entity.index.index;
            UnityEngine.Debug.Assert(entity.handCards.cards[last].card.value == cardEntity.card.value);

            for (int i = last - 1; i >= 0; i--) {
                if (_gameSystems.CardSystem.CompareTo(entity.handCards.cards[i + 1], entity.handCards.cards[i]) < 0) {

                    GameEntity tmpEntity = entity.handCards.cards[i + 1];
                    entity.handCards.cards[i + 1] = entity.handCards.cards[i];
                    entity.handCards.cards[i + 1].card.pos = i + 1;
                    entity.handCards.cards[i] = tmpEntity;
                    entity.handCards.cards[i].card.pos = i;
                }
            }
        }

        public void Remove(GameEntity entity, GameEntity cardEntity) {
            int last = entity.handCards.cards.Count - 1;
            for (int i = cardEntity.card.pos; i < last; i++) {
                entity.handCards.cards[i] = entity.handCards.cards[i + 1];
                entity.handCards.cards[i].card.pos = i;
            }
            cardEntity.card.pos = -1;
            cardEntity.card.parent = -1;
            entity.handCards.cards.RemoveAt(last);
        }

        public void RemovePG(GameEntity entity, GameEntity cardEntity) {
            PGCards pg = entity.putCards.putcards[entity.putCards.putidx];
            if (pg.cards[0].card == cardEntity.card) {
                pg.cards.Remove(cardEntity);
            } else {
                foreach (var item in entity.putCards.putcards) {

                }
            }
        }

        public void AppendLead(GameEntity entity, GameEntity cardEntity) {
            entity.leadCards.leadcards.Add(cardEntity);
            cardEntity.card.pos = entity.leadCards.leadcards.Count - 1;
            cardEntity.card.parent = entity.index.index;
        }

        public void RemoveLead(GameEntity whoEntity, GameEntity cardEntity) {
            UnityEngine.Debug.Assert(whoEntity.leadCards.leadcards.Count > 0);
            GameEntity otherEntity = whoEntity.leadCards.leadcards[whoEntity.leadCards.leadcards.Count - 1];
            UnityEngine.Debug.Assert(cardEntity.card.value == otherEntity.card.value);
            cardEntity.card.pos = -1;
            cardEntity.card.parent = -1;
            whoEntity.leadCards.leadcards.Remove(cardEntity);
        }

        public void AppendHu(GameEntity entity, GameEntity cardEntity) {
            entity.huCards.hucards.Add(cardEntity);
            cardEntity.card.pos = entity.huCards.hucards.Count - 1;
            cardEntity.card.parent = entity.index.index;
        }
        #endregion

        public void TakeXuanPao() {
            _appContext.EnqueueRenderQueue(RenderTakeXuanPao);
        }

        public void XuanPao() {
            _appContext.EnqueueRenderQueue(RenderXuanPao);
        }

        /// <summary>
        /// 洗牌后玩家砌一长条
        /// </summary>
        /// <param name="cs"></param>
        /// <param name="cards"></param>
        public void Boxing(GameEntity entity, List<long> cs) {
            try {
                for (int i = 0; i < cs.Count; i++) {
                    long value = cs[i];
                    var cardEntity = _gameSystems.CardValueIndexSystem.FindEntity(value);
                    UnityEngine.Debug.Assert(cardEntity.card.parent == 0);
                    cardEntity.card.parent = entity.index.index;
                    if (entity.takeCards.takecards.ContainsKey(i)) {
                        UnityEngine.Debug.LogFormat("entity idx {0} boxing card {1} repeate.", entity.player.idx, cardEntity.card.ToString());
                    } else {
                        entity.takeCards.takecards[i] = cardEntity;
                        cardEntity.card.pos = i;
                    }
                }

                entity.takeCards.takecardsidx = 0;
                entity.takeCards.takecardscnt = cs.Count;
                entity.takeCards.takecardslen = cs.Count;
                UnityEngine.Debug.Assert(cs.Count == 28 || cs.Count == 26);
            } catch (Exception ex) {
                UnityEngine.Debug.LogException(ex);
            }
        }

        public void ThrowDice(GameEntity entity, long d1, long d2) {
            _appContext.EnqueueRenderQueue(RenderThrowDice);
        }

        /// <summary>
        /// 拿牌，每个人拿十三张
        /// </summary>
        /// <param name="entity"></param>
        public void Deal(GameEntity entity) {
            List<int> cards = _gameSystems.GameSystem.TakeBlock();
            UnityEngine.Debug.Assert((cards.Count == 4 || cards.Count == 1));

            for (int i = 0; i < cards.Count; i++) {
                GameEntity cardEntity = _gameSystems.IndexSystem.FindEntity(cards[i]);
                entity.handCards.cards.Add(cardEntity);
                cardEntity.card.parent = entity.index.index;
                cardEntity.card.pos = i;
            }
            _appContext.EnqueueRenderQueue(RenderDeal);
        }

        private void QuickSort(List<GameEntity> cards, int low, int high) {
            if (low >= high) {
                return;
            }
            int first = low;
            int last = high;
            var keyEntity = cards[first];
            while (first < last) {
                while (first < last) {
                    var dstEntity = cards[last];
                    if (_gameSystems.CardSystem.CompareTo(dstEntity, keyEntity) > 0) {  // dstEntity > keyEntity
                        dstEntity.card.pos = last;
                        --last;
                    } else {  // dstEntity < keyEntity
                        cards[first] = dstEntity;
                        cards[first].card.pos = first;
                        break;
                    }
                }
                while (first < last) {
                    var dstEntity = cards[first];
                    if (_gameSystems.CardSystem.CompareTo(dstEntity, keyEntity) < 0) {
                        dstEntity.card.pos = first;
                        ++first;
                    } else {
                        cards[last] = dstEntity;
                        cards[last].card.pos = last;
                        break;
                    }
                }
            }
            cards[first] = keyEntity;
            cards[first].card.pos = first;

            QuickSort(cards, low, first - 1);
            QuickSort(cards, first + 1, high);
        }

        /// <summary>
        /// 整理自己拿到的牌
        /// </summary>
        public void SortCards(GameEntity entity) {
            QuickSort(entity.handCards.cards, 0, entity.handCards.cards.Count - 1);
            for (int i = 0; i < entity.handCards.cards.Count; i++) {
                if (entity.handCards.cards[i].card.pos != i) {
                    UnityEngine.Debug.Assert(false);
                }
            }
        }

        public void TakeFirsteCard(GameEntity entity, long c) {
            UnityEngine.Debug.Assert(_context.rule.curidx == _context.rule.firstidx);
            int card;  // 本地索引
            if (_gameSystems.GameSystem.TakeCard(out card)) {
                entity.holdCard.holdCardEntity = _gameSystems.IndexSystem.FindEntity(card);
                UnityEngine.Debug.Assert(entity.holdCard.holdCardEntity.card.value == c);
                _appContext.EnqueueRenderQueue(RenderTakeFirstCard);
            }
        }

        public void TakeXuanQue() {
            _appContext.EnqueueRenderQueue(RenderTakeXuanQue);
        }

        public void ShowQue(long who, Card.CardType cardType) {
            GameEntity entity = _gameSystems.NetIdxSystem.FindEntity(who);
            entity.head.headUIController.SetQue(cardType);
            entity.head.headUIController.Shaking();
        }

        public void XuanQue(long who, long que) {
            // 由于在选择的时候动画已经做过，所以这里不需要对自己做
            GameEntity entity = _gameSystems.NetIdxSystem.FindEntity(who);
            if (_context.rule.myidx != who) {
                entity.playerCard.que = (Card.CardType)que;
                entity.head.headUIController.SetQue(entity.playerCard.que);
                entity.head.headUIController.Shaking();
            } else {
                if (!entity.playerCard.hasXuanQue) {
                    GameUIModule module = _appContext.U.GetModule<GameUIModule>();
                    if (module.XuanQueUIController.Counter > 0 && module.XuanQueUIController.IsTop) {
                        _appContext.UIContextManager.Pop();
                    }
                    entity.playerCard.que = (Card.CardType)que;
                    entity.head.headUIController.SetQue(entity.playerCard.que);
                    entity.head.headUIController.Shaking();
                }
            }

            foreach (var item in entity.handCards.cards) {
                _gameSystems.CardSystem.SetQue(item.index.index, (Card.CardType)que);
            }
            if (_context.rule.firstidx == who) {
                _gameSystems.CardSystem.SetQue(entity.holdCard.holdCardEntity.index.index, (Card.CardType)que);
            }
            QuickSort(entity.handCards.cards, 0, entity.handCards.cards.Count - 1);
        }

        public void TakeTakeCard(GameEntity entity, long c) {
            int card;
            if (_gameSystems.GameSystem.TakeCard(out card)) {
                entity.holdCard.holdCardEntity = _gameSystems.IndexSystem.FindEntity(card);
                _gameSystems.CardSystem.SetQue(entity.holdCard.holdCardEntity.index.index, entity.playerCard.que);

                UnityEngine.Debug.Assert(entity.holdCard.holdCardEntity.card.value == c);
                _appContext.EnqueueRenderQueue(RenderTakeTakeCard);
            }
        }

        public void TakeTurn(GameEntity entity, long cd) {
            _appContext.EnqueueRenderQueue(RenderTakeTurn);
        }

        public void Lead(GameEntity entity, long c, bool isHoldcard) {
            UnityEngine.Debug.Assert(entity.holdCard.holdCardEntity != null);
            if (isHoldcard) {
                UnityEngine.Debug.Assert(entity.holdCard.holdCardEntity.card.value == c);
                _gameSystems.CardSystem.Clear(entity.holdCard.holdCardEntity.index.index);
                AppendLead(entity, entity.holdCard.holdCardEntity);
                entity.leadCards.leadcard = entity.holdCard.holdCardEntity.index.index;
                entity.leadCards.isHoldCard = true;
                entity.holdCard.holdCardEntity = null;

            } else {
                var cardEntity = _gameSystems.CardValueIndexSystem.FindEntity(c);
                if (cardEntity != null) {
                    UnityEngine.Debug.Assert(cardEntity.card.value == c);
                    Remove(entity, cardEntity);
                    AppendLead(entity, cardEntity);
                    entity.leadCards.isHoldCard = false;
                    entity.leadCards.leadcard = cardEntity.index.index;

                    // insert holdcard
                    Insert(entity, entity.holdCard.holdCardEntity);
                    // 必须保留此变量作为后面移动表现
                    //entity.holdCard.holdCardEntity = null;
                } else {
                    UnityEngine.Debug.LogErrorFormat("card value {0} not found.", c);
                }
            }

            _appContext.EnqueueRenderQueue(RenderLead);
        }

        public void SetupCall(GameEntity entity) {
            _appContext.EnqueueRenderQueue(RenderCall);
        }

        public void Peng(GameEntity whoEntity, GameEntity dianEntity, GameEntity cardEntity, long hor) {
            List<GameEntity> cards = new List<GameEntity>();
            for (int i = 0; i < whoEntity.handCards.cards.Count; i++) {
                if (whoEntity.handCards.cards[i].card == cardEntity.card) {
                    cards.Add(whoEntity.handCards.cards[i]);
                }
                if (cards.Count == 2) {
                    break;
                }
            }
            UnityEngine.Debug.Assert(cards.Count == 2);
            for (int i = 0; i < cards.Count; i++) {
                Remove(whoEntity, cards[i]);
            }

            RemoveLead(dianEntity, cardEntity);
            cards.Add(cardEntity);
            UnityEngine.Debug.Assert(cards.Count == 3);

            PGCards pgcards = new PGCards();
            pgcards.opcode = OpCodes.OPCODE_NONE;
            pgcards.opcode |= OpCodes.OPCODE_PENG;
            pgcards.hor = hor;
            pgcards.width = 0.0f;
            pgcards.cards = cards;

            whoEntity.putCards.putcards.Add(pgcards);
            whoEntity.putCards.putidx = whoEntity.putCards.putcards.Count - 1;

            _context.rule.curidx = whoEntity.player.idx;
            _appContext.EnqueueRenderQueue(RenderPeng);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="entity"></param>
        /// <param name="code">杠的类型</param>
        /// <param name="dian"></param>
        /// <param name="c"></param>
        /// <param name="hor"></param>
        /// <param name="isHoldcard"></param>
        /// <param name="isHoldcardInsLast"></param>
        public void Gang(GameEntity entity, long code, long dian, long c, long hor, bool isHoldcard, bool isHoldcardInsLast) {
            GameEntity cardEntity = _gameSystems.CardValueIndexSystem.FindEntity(c);
            if (code == (long)GangType.ZHIGANG) {
                List<GameEntity> cards = new List<GameEntity>();
                for (int i = 0; i < entity.handCards.cards.Count; i++) {
                    if (cardEntity == entity.handCards.cards[i]) {
                        cards.Add(entity.handCards.cards[i]);
                    }
                    if (cards.Count == 3) {
                        break;
                    }
                }

                UnityEngine.Debug.Assert(cards.Count == 3);
                for (int i = 0; i < cards.Count; i++) {
                    Remove(entity, cards[i]);
                }

                GameEntity dianEntity = _gameSystems.NetIdxSystem.FindEntity(dian);
                RemoveLead(dianEntity, cardEntity);
                cards.Add(cardEntity);
                UnityEngine.Debug.Assert(cards.Count == 4);

                PGCards pg = new PGCards();
                pg.cards = cards;
                pg.opcode = OpCodes.OPCODE_GANG;
                pg.gangtype = code;
                pg.hor = hor;
                pg.width = 0.0f;
                pg.isHoldcard = isHoldcard;
                pg.isHoldcardInsLast = isHoldcardInsLast;
                entity.putCards.putcards.Add(pg);
                entity.putCards.putidx = entity.putCards.putcards.Count - 1;
                UnityEngine.Debug.Assert(!pg.isHoldcard && !pg.isHoldcardInsLast);
            } else if (code == (long)GangType.ANGANG) {
                UnityEngine.Debug.Assert(entity.holdCard.holdCardEntity != null);
                List<GameEntity> cards = new List<GameEntity>();
                PGCards pg = new PGCards();
                if (isHoldcard) {
                    UnityEngine.Debug.Assert(entity.holdCard.holdCardEntity.card == cardEntity.card);
                    for (int i = 0; i < entity.handCards.cards.Count; i++) {
                        if (cardEntity.card == entity.handCards.cards[i].card) {
                            cards.Add(entity.handCards.cards[i]);
                            entity.handCards.cards[i].card.pos = cards.Count - 1;
                        }
                        if (cards.Count == 3) {
                            break;
                        }
                    }
                    UnityEngine.Debug.Assert(cards.Count == 3);
                    for (int i = 0; i < cards.Count; i++) {
                        Remove(entity, cards[i]);
                    }
                    cards.Add(entity.holdCard.holdCardEntity);
                    entity.holdCard.holdCardEntity.card.pos = cards.Count - 1;
                    entity.holdCard.holdCardEntity = null;
                    pg.isHoldcard = isHoldcard;
                    pg.isHoldcardInsLast = false;
                } else {
                    for (int i = 0; i < entity.handCards.cards.Count; i++) {
                        if (cardEntity.card == entity.handCards.cards[i].card) {
                            cards.Add(entity.handCards.cards[i]);
                            entity.handCards.cards[i].card.pos = cards.Count - 1;
                        }
                        if (cards.Count == 4) {
                            break;
                        }
                    }
                    UnityEngine.Debug.Assert(cards.Count == 4);
                    for (int i = 0; i < cards.Count; i++) {
                        Remove(entity, cards[i]);
                    }
                    Insert(entity, entity.holdCard.holdCardEntity);
                    if (entity.holdCard.holdCardEntity.card.pos == entity.handCards.cards.Count - 1) {
                        pg.isHoldcardInsLast = true;
                    }
                    entity.holdCard.holdCardEntity = null;
                    pg.isHoldcard = false;
                }

                UnityEngine.Debug.Assert(cards.Count == 4);
                pg.cards = cards;
                pg.opcode = OpCodes.OPCODE_GANG;
                pg.gangtype = code;
                pg.hor = hor;
                pg.width = 0.0f;
                entity.putCards.putcards.Add(pg);
                entity.putCards.putidx = entity.putCards.putcards.Count - 1;
            } else if (code == (long)GangType.BUGANG) {
                PGCards pg = null;
                for (int i = 0; i < entity.putCards.putcards.Count; i++) {
                    pg = entity.putCards.putcards[i];
                    if (pg.opcode == OpCodes.OPCODE_PENG && pg.cards[0].card == cardEntity.card) {
                        UnityEngine.Debug.Assert(pg.cards.Count == 3);
                        entity.putCards.putidx = i;
                        break;
                    }
                }
                UnityEngine.Debug.Assert(pg != null);

                pg.gangtype = code;

                if (isHoldcard) {
                    UnityEngine.Debug.Assert(cardEntity.card == entity.holdCard.holdCardEntity.card);
                    entity.holdCard.holdCardEntity = null;
                    pg.cards.Add(cardEntity);
                    cardEntity.card.pos = pg.cards.Count - 1;
                    pg.isHoldcard = isHoldcard;
                    pg.isHoldcardInsLast = false;
                } else {
                    Remove(entity, cardEntity);
                    pg.cards.Add(cardEntity);
                    cardEntity.card.pos = pg.cards.Count - 1;
                    pg.isHoldcard = isHoldcard;
                    pg.isHoldcardInsLast = false;
                }

            } else {
                UnityEngine.Debug.Assert(false);
            }

            _appContext.EnqueueRenderQueue(RenderGang);
        }

        public void Hu(GameEntity entity, long c, long dian, long jiao, long hutype) {
            GameEntity cardEntity = _gameSystems.CardValueIndexSystem.FindEntity(c);
            if (jiao == JiaoType.PINGFANG) {
                GameEntity dianEntity = _gameSystems.NetIdxSystem.FindEntity(dian);
                RemoveLead(dianEntity, cardEntity);
                entity.huCards.hucards.Add(cardEntity);
            } else if (jiao == JiaoType.GANGSHANGPAO) {
                GameEntity dianEntity = _gameSystems.NetIdxSystem.FindEntity(dian);
                RemoveLead(dianEntity, cardEntity);
                entity.huCards.hucards.Add(cardEntity);
            } else if (jiao == JiaoType.QIANGGANGHU) {
                GameEntity dianEntity = _gameSystems.NetIdxSystem.FindEntity(dian);
                RemovePG(dianEntity, cardEntity);
                entity.huCards.hucards.Add(cardEntity);
            } else if (jiao == JiaoType.DIANGANGHUA) {
                UnityEngine.Debug.Assert(c == entity.holdCard.holdCardEntity.card.value);
                entity.huCards.hucards.Add(entity.holdCard.holdCardEntity);
                entity.holdCard.holdCardEntity = null;
            } else if (jiao == JiaoType.ZIGANGHUA) {
                UnityEngine.Debug.Assert(c == entity.holdCard.holdCardEntity.card.value);
                entity.huCards.hucards.Add(entity.holdCard.holdCardEntity);
                entity.holdCard.holdCardEntity = null;
            } else if (jiao == JiaoType.ZIMO) {
                UnityEngine.Debug.Assert(c == entity.holdCard.holdCardEntity.card.value);
                entity.huCards.hucards.Add(cardEntity);
                entity.holdCard.holdCardEntity = null;
            }

            //if (!_hashu) {
            //    _hashu = true;
            //}

            //((GameController)_controller).CurIdx = _idx;
            _appContext.EnqueueRenderQueue(RenderHu);
        }

        //public void HuSettle() {
        //    UnityEngine.Debug.Assert(_settle.Count >= 1);
        //    _ctx.EnqueueRenderQueue(RenderHuSettle);
        //}

        //protected virtual void RenderHuSettle() { }

        //protected virtual void RenderOver() { }

        //protected virtual void RenderOverShen(Action<Action> act31, Action cb) {
        //    // 1.0 伸手
        //    Animator ranimator = _rhand.GetComponent<Animator>();
        //    ranimator.SetTrigger("BeforeHupai");

        //    _lhand.SetActive(true);
        //    Animator lanimator = _rhand.GetComponent<Animator>();
        //    lanimator.SetTrigger("BeforeHupai");

        //    // 5.0
        //    Action act5 = delegate () {
        //        // 发事件
        //        cb();
        //    };

        //    // 3.0 放到牌
        //    Action act3 = delegate () {
        //        act31(() => {
        //            // 4.0 收手
        //            _oknum = 0;
        //            Sequence mySequence4r = DOTween.Sequence();
        //            mySequence4r.Append(_rhand.transform.DOLocalMove(_rhandinitpos, _hupaishoudelta))
        //            .AppendCallback(() => {
        //                _oknum++;
        //                if (_oknum >= 2) {
        //                    act5();
        //                }
        //            });

        //            Sequence mySequence4l = DOTween.Sequence();
        //            mySequence4l.Append(_lhand.transform.DOLocalMove(_lhandinitpos, _hupaishoudelta))
        //            .AppendCallback(() => {
        //                _oknum++;
        //                if (_oknum >= 2) {
        //                    act5();
        //                }
        //            });
        //        });
        //    };

        //    // 2.0
        //    Action act2 = delegate () {
        //        _oknum = 0;
        //        Hand rhand = _rhand.GetComponent<Hand>();
        //        rhand.Rigster(Hand.EVENT.HUPAI_COMPLETED, () => {
        //            _oknum++;
        //            if (_oknum >= 2) {
        //                // 3.0
        //                act3();
        //            }
        //        });
        //        ranimator.SetBool("Hupai", true);

        //        Hand lhand = _lhand.GetComponent<Hand>();
        //        lhand.Rigster(Hand.EVENT.HUPAI_COMPLETED, () => {
        //            _oknum++;
        //            if (_oknum >= 2) {
        //                // 3.0
        //                act3();
        //            }
        //        });
        //        lanimator.SetBool("Hupai", true);
        //    };

        //    _oknum = 0;
        //    Tween t1r = _rhand.transform.DOLocalMove(_cards[_cards.Count - 1].Go.transform.localPosition, _hupaishendelta);
        //    Sequence mySequence1r = DOTween.Sequence();
        //    mySequence1r.Append(t1r)
        //        .AppendCallback(() => {
        //            _oknum++;
        //            if (_oknum >= 2) {
        //                // 2.0
        //                act2();
        //            }
        //        });

        //    Tween t1l = _lhand.transform.DOLocalMove(_cards[0].Go.transform.localPosition, _hupaishendelta);
        //    Sequence mySequence1l = DOTween.Sequence();
        //    mySequence1l.Append(t1l)
        //        .AppendCallback(() => {
        //            _oknum++;
        //            if (_oknum >= 2) {
        //                // 2.0
        //                act2();
        //            }
        //        });
        //}

        //public void Settle() { }

        //protected virtual void RenderSettle() { }

        //public void FinalSettle() { }

        //protected virtual void RenderFinalSettle() { }

        //public void Restart() {
        //    _ctx.EnqueueRenderQueue(RenderRestart);
        //}

        //protected virtual void RenderRestart() { }

        //public void TakeRestart() {
        //    UnityEngine.Debug.LogFormat("player {0} take restart", _idx);
        //    _d1 = 0;
        //    _d2 = 0;

        //    _takecardsidx = 0;
        //    _takecardscnt = 0;
        //    _takecardslen = 0;
        //    _takecards = new Dictionary<int, Card>();

        //    _takefirst = false;                 // 庄家
        //    _cards = new List<Card>();
        //    _leadcards = new List<Card>();

        //    _putidx = 0;
        //    _putcards = new List<PGCards>();
        //    _hucards = new List<Card>();

        //    _holdcard = null;
        //    _leadcard = null;

        //    _turntype = 0;
        //    _fen = 0;
        //    _que = 0;
        //    _hashu = false;

        //    _wal = 0;         // 赢的钱或者输的钱
        //    _say = 0;
        //}

        //protected virtual void RenderTakeRestart() { }

        //public void Say(long code) {
        //    _say = code;
        //}

        //protected virtual void RenderSay() { }

        //public void ClearSettle() {
        //    _settle.Clear();
        //}

        //public void AddSettle(SettlementItem item) {
        //    _settle.Add(item);
        //}
        #region event
        private void OnSetupHand(EventCmd e) {
            long idx = Convert.ToInt64(e.Msg["idx"]);
            GameObject rhand = e.Msg["rhand"] as GameObject;
            GameObject lhand = e.Msg["lhand"] as GameObject;
            GameObject go = e.Msg["go"] as GameObject;
            var entity = _gameSystems.NetIdxSystem.FindEntity(idx);
            entity.hand.rhand = rhand;
            entity.hand.lhand = lhand;
            entity.player.go = go;
        }
        #endregion

        #region render

        public void RenderLoadHand(GameEntity entity) {
            GameObject root = GameObject.Find("Root");

            GameObject go = new GameObject();
            go.AddComponent<AudioSource>();
            go.name = string.Format("NetIdx_{0}", entity.player.idx);
            go.transform.SetParent(root.transform);
            if (entity.player.orient == Player.Orient.BOTTOM) {
                go.AddComponent<BottomPlayer>();
            }

            GameObject rhand, lhand;
            if (entity.player.sex == 1) {
                GameObject rhandOriginal = ABLoader.current.LoadAsset<GameObject>("Prefabs/Hand", "boyrhand");
                rhand = GameObject.Instantiate<GameObject>(rhandOriginal);

                GameObject lhandOriginal = ABLoader.current.LoadAsset<GameObject>("Prefabs/Hand", "boylhand");
                lhand = GameObject.Instantiate<GameObject>(lhandOriginal);
            } else {
                GameObject rori = ABLoader.current.LoadAsset<GameObject>("Prefabs/Hand", "girlrhand");
                rhand = GameObject.Instantiate<GameObject>(rori);

                GameObject lori = ABLoader.current.LoadAsset<GameObject>("Prefabs/Hand", "girllhand");
                lhand = GameObject.Instantiate<GameObject>(lori);
            }

            rhand.transform.SetParent(root.transform);
            rhand.transform.localPosition = entity.hand.rhandinitpos;
            rhand.transform.localRotation = entity.hand.rhandinitrot;

            lhand.transform.SetParent(root.transform);
            lhand.transform.localPosition = entity.hand.lhandinitpos;
            lhand.transform.localRotation = entity.hand.lhandinitrot;

            Message msg = new Message();
            msg["idx"] = entity.player.idx;
            msg["rhand"] = rhand;
            msg["lhand"] = lhand;
            msg["go"] = go;
            Command cmd = new Command(MyEventCmd.EVENT_SETUP_HAND, msg);
            GL.Util.App.current.Enqueue(cmd);
        }

        public void RenderReady(GameEntity entity) {
            //if (entity.player.idx == 1) {
            //    if (entity.player.orient == Player.Orient.BOTTOM) {
            //        _gameSystems.DeskSystem.RenderSetDongAtBottom();
            //    } else if (entity.player.orient == Player.Orient.RIGHT) {
            //        _gameSystems.DeskSystem.RenderSetDongAtRight();
            //    } else if (entity.player.orient == Player.Orient.TOP) {
            //        _gameSystems.DeskSystem.RenderSetDongAtTop();
            //    } else if (entity.player.orient == Player.Orient.LEFT) {
            //        _gameSystems.DeskSystem.RenderSetDongAtLeft();
            //    }
            //} else if (entity.player.idx == 2) {
            //    if (entity.player.orient == Player.Orient.BOTTOM) {
            //        _gameSystems.DeskSystem.RenderSetNanAtBottom();
            //    } else if (entity.player.orient == Player.Orient.RIGHT) {
            //        _gameSystems.DeskSystem.RenderSetNanAtRight();
            //    } else if (entity.player.orient == Player.Orient.TOP) {
            //        _gameSystems.DeskSystem.RenderSetNanAtTop();
            //    } else if (entity.player.orient == Player.Orient.LEFT) {
            //        _gameSystems.DeskSystem.RenderSetNanAtLeft();
            //    }
            //} else if (entity.player.idx == 3) {
            //    if (entity.player.orient == Player.Orient.BOTTOM) {
            //        _gameSystems.DeskSystem.RenderSetXiAtBottom();
            //    } else if (entity.player.orient == Player.Orient.RIGHT) {
            //        _gameSystems.DeskSystem.RenderSetXiAtRight();
            //    } else if (entity.player.orient == Player.Orient.TOP) {
            //        _gameSystems.DeskSystem.RenderSetXiAtTop();
            //    } else if (entity.player.orient == Player.Orient.LEFT) {
            //        _gameSystems.DeskSystem.RenderSetXiAtLeft();
            //    }
            //} else if (entity.player.idx == 4) {
            //    if (entity.player.orient == Player.Orient.BOTTOM) {
            //        _gameSystems.DeskSystem.RenderSetBeiAtBottom();
            //    } else if (entity.player.orient == Player.Orient.RIGHT) {
            //        _gameSystems.DeskSystem.RenderSetBeiAtRight();
            //    } else if (entity.player.orient == Player.Orient.TOP) {
            //        _gameSystems.DeskSystem.RenderSetBeiAtTop();
            //    } else if (entity.player.orient == Player.Orient.LEFT) {
            //        _gameSystems.DeskSystem.RenderSetBeiAtLeft();
            //    }
            //} else {
            //    UnityEngine.Debug.Assert(false);
            //}
        }

        public void RenderXuanPao() { }

        public void RenderBoxing(GameEntity entity) {
            try {
                int counter = 0;
                GameEntity deskEntity = _gameSystems.DeskSystem.FindEntity();
                if (entity.player.orient == Player.Orient.BOTTOM) {
                    _gameSystems.DeskSystem.RenderShowBottomSlot(() => { });
                } else if (entity.player.orient == Player.Orient.RIGHT) {
                    _gameSystems.DeskSystem.RenderShowRightSlot(() => { });
                } else if (entity.player.orient == Player.Orient.TOP) {
                    _gameSystems.DeskSystem.RenderShowTopSlot(() => { });
                } else if (entity.player.orient == Player.Orient.LEFT) {
                    _gameSystems.DeskSystem.RenderShowLeftSlot(() => { });
                }

                for (int i = 0; i < entity.takeCards.takecards.Count; i++) {
                    int idx = i / 2;
                    float x, y, z;
                    if (entity.player.orient == Player.Orient.BOTTOM) {
                        x = deskEntity.desk.width - (entity.takeCards.takeleftoffset + idx * Card.Width + Card.Width / 2.0f);
                        z = entity.takeCards.takebottomoffset;
                    } else if (entity.player.orient == Player.Orient.RIGHT) {
                        x = deskEntity.desk.width - (entity.takeCards.takebottomoffset);
                        z = deskEntity.desk.length - (entity.takeCards.takeleftoffset + idx * Card.Width + Card.Width / 2.0f);
                    } else if (entity.player.orient == Player.Orient.TOP) {
                        x = entity.takeCards.takeleftoffset + idx * Card.Width + Card.Width / 2.0f;
                        z = deskEntity.desk.length - (entity.takeCards.takebottomoffset + Card.Length / 2.0f);
                    } else {
                        x = entity.takeCards.takebottomoffset;
                        z = entity.takeCards.takeleftoffset + idx * Card.Width + Card.Width / 2.0f;
                    }
                    if (i % 2 == 0) {
                        y = Card.HeightMZ + Card.Height + Card.Height / 2.0f;
                    } else {
                        y = Card.HeightMZ + Card.Height / 2.0f;
                    }

                    GameEntity cardEntity = entity.takeCards.takecards[i];
                    cardEntity.card.go.transform.localRotation = entity.playerCard.downv;
                    cardEntity.card.go.transform.localPosition = new Vector3(x, y - entity.takeCards.takemove, z);
                    Tween t = cardEntity.card.go.transform.DOLocalMoveY(y, entity.takeCards.takemovedelta);

                    Sequence mySequence = DOTween.Sequence();
                    mySequence.Append(t)
                    .AppendCallback(() => {
                        counter++;
                        if (counter == entity.takeCards.takecards.Count) {
                            Maria.Command cmd = new Maria.Command(MyEventCmd.EVENT_BOXINGCARDS);
                            _appContext.Enqueue(cmd);
                        }
                    });
                }
            } catch (Exception ex) {
                UnityEngine.Debug.LogException(ex);
            }
        }

        public void RenderThrowDice() {
            // 1.0 浼告墜
            GameEntity deskEntity = _gameSystems.DeskSystem.FindEntity();
            GameEntity entity = _gameSystems.NetIdxSystem.FindEntity(_context.rule.firstidx);

            Animator animator = entity.hand.rhand.GetComponent<Animator>();
            entity.hand.rhand.transform.localRotation = Quaternion.Euler(0.0f, 0.0f, 0.0f);
            Tween t = entity.hand.rhand.transform.DOLocalMove(entity.hand.rhanddiuszoffset, entity.hand.diushaizishendelta);
            Sequence mySequence = DOTween.Sequence();
            mySequence.Append(t)
                .AppendCallback(() => {
                    // 2.0 涓㈠暐瀛?
                    Hand hand = entity.hand.rhand.GetComponent<Hand>();
                    hand.Rigster(Hand.EVENT.DIUSHAIZI_COMPLETED, () => {
                        // 3.1
                        _gameSystems.DeskSystem.RenderThrowDice();

                        // 3.2 鏀舵墜
                        Tween t32 = entity.hand.rhand.transform.DOLocalMove(entity.hand.rhandinitpos, entity.hand.diushaizishoudelta);
                        Sequence mySequence32 = DOTween.Sequence();
                        mySequence32.Append(t32)
                        .AppendCallback(() => {
                            // 4.0
                            animator.SetBool("Idle", true);
                        });
                    });
                    animator.SetBool("Diushaizi", true);
                });
        }

        public void RenderDeal() {
            int counter = 0;
            int i = 0;
            GameEntity entity = _gameSystems.NetIdxSystem.FindEntity(_context.rule.curidx);
            if (entity.handCards.cards.Count == 13) {
                counter = 1;
                i = entity.handCards.cards.Count - counter;
            } else {
                counter = 4;
                i = entity.handCards.cards.Count - counter;
            }

            for (; i < entity.handCards.cards.Count; i++) {
                var cardEntity = entity.handCards.cards[i];
                Vector3 dst = CalcPos(entity, i);

                cardEntity.card.go.transform.localPosition = dst;
                cardEntity.card.go.transform.localRotation = entity.playerCard.backvst;
                Tween t = cardEntity.card.go.transform.DOLocalRotateQuaternion(entity.playerCard.backv, entity.handCards.dealcarddelta);
                Sequence mySequence = DOTween.Sequence();
                mySequence.Append(t)
                    .AppendCallback(() => {
                        counter--;
                        if (counter <= 0) {
                            Command cmd = new Command(MyEventCmd.EVENT_TAKEDEAL);
                            GL.Util.App.current.Enqueue(cmd);
                        }
                    });
            }
        }

        public void RenderSortCardsAfterDeal(GameEntity entity) {
            int counter = entity.handCards.cards.Count;
            for (int i = 0; i < entity.handCards.cards.Count; i++) {
                var cardEntity = entity.handCards.cards[i];
                Sequence mySequence = DOTween.Sequence();
                mySequence.Append(cardEntity.card.go.transform.DORotateQuaternion(entity.playerCard.backvst, entity.handCards.sortcardsdelta))
                    .AppendCallback(() => {
                        Vector3 dst = CalcPos(entity, cardEntity.card.pos);
                        cardEntity.card.go.transform.localPosition = dst;
                    })
                    .Append(cardEntity.card.go.transform.DORotateQuaternion(entity.playerCard.backv, entity.handCards.sortcardsdelta))
                    .AppendCallback(() => {
                        counter--;
                        if (counter <= 0) {
                            UnityEngine.Debug.LogFormat("bottom player send event sortcards");
                            Command cmd = new Command(MyEventCmd.EVENT_SORTCARDSAFTERDEAL);
                            _appContext.Enqueue(cmd);
                        }
                    });
            }
        }

        public void RenderTakeXuanPao() { }

        public void RenderTakeFirstCard() {
            GameEntity entity = _gameSystems.NetIdxSystem.FindEntity(_context.rule.curidx);
            RenderTakeCard(entity, () => {
                Command cmd = new Command(MyEventCmd.EVENT_TAKEFIRSTCARD);
                _appContext.Enqueue(cmd);
            });
        }

        public void RenderTakeCard(GameEntity entity, Action cb) {
            Vector3 cdst = CalcPos(entity, entity.handCards.cards.Count + 1);
            Vector3 hdst = cdst + entity.hand.rhandtakeoffset;
            Vector3 cdst1 = new Vector3(cdst.x, cdst.y + Card.Length, cdst.z);
            Vector3 hdst1 = cdst1 + entity.hand.rhandtakeoffset;

            // 1.0 伸手
            Animator animator = entity.hand.rhand.GetComponent<Animator>();
            animator.SetTrigger("BeforeFangpai");
            Tween t1 = entity.hand.rhand.transform.DOLocalMove(hdst1, entity.hand.napaishendelta);
            Sequence mySequence1 = DOTween.Sequence();
            mySequence1.Append(t1)
                .AppendCallback(() => {

                    // 2.1 牌下移
                    entity.holdCard.holdCardEntity.card.go.transform.localPosition = cdst1;
                    entity.holdCard.holdCardEntity.card.go.transform.localRotation = entity.playerCard.backv;

                    Sequence mySequence21 = DOTween.Sequence();
                    mySequence21.Append(entity.holdCard.holdCardEntity.card.go.transform.DOLocalMove(cdst, entity.holdCard.holddowndelta))
                        .AppendCallback(() => {
                            cb();
                        });

                    // 2.2 手下移
                    Sequence mySequence22 = DOTween.Sequence();
                    mySequence22.Append(entity.hand.rhand.transform.DOLocalMove(hdst, entity.holdCard.holddowndelta))
                    .AppendCallback(() => {
                        // 3.0 放手
                        Hand hand = entity.hand.rhand.GetComponent<Hand>();
                        hand.Rigster(Hand.EVENT.FANGPAI_COMPLETED, () => {
                            // 4.0 收手
                            Tween t4 = entity.hand.rhand.transform.DOLocalMove(entity.hand.rhandinitpos, entity.hand.fangpaishoudelta);
                            Sequence mySequence4 = DOTween.Sequence();
                            mySequence4.Append(t4)
                            .AppendCallback(() => {

                                //cb();

                                // 5.0 归位
                                animator.SetBool("Idle", true);
                            });
                        });
                        animator.SetBool("Fangpai", true);
                    });
                });
        }

        public void RenderTakeXuanQue() { }

        public void RenderXuanQue(GameEntity entity) {
            int counter = entity.handCards.cards.Count;
            for (int i = 0; i < entity.handCards.cards.Count; i++) {
                var cardEntity = entity.handCards.cards[i];
                Vector3 dst = CalcPos(entity, cardEntity.card.pos);
                cardEntity.card.go.transform.localPosition = dst;
                if (_context.rule.myidx == entity.player.idx) {
                    _gameSystems.CardSystem.RenderQueBrightness(cardEntity);
                }
            }

            if (_context.rule.firstidx == entity.player.idx) {
                UnityEngine.Debug.Assert(entity.holdCard.holdCardEntity != null);
                _gameSystems.CardSystem.RenderQueBrightness(entity.holdCard.holdCardEntity);
            }

            Command cmd = new Command(MyEventCmd.EVENT_SORTCARDSAFTERXUANQUE);
            _appContext.Enqueue(cmd);
        }

        public void RenderTakeTurnDir(GameEntity entity) {
            if (entity.player.idx == 1) {
                _gameSystems.DeskSystem.RenderTakeTurnDong();
            } else if (entity.player.idx == 2) {
                _gameSystems.DeskSystem.RenderTakeTurnNan();
            } else if (entity.player.idx == 3) {
                _gameSystems.DeskSystem.RenderTakeTurnXi();
            } else if (entity.player.idx == 4) {
                _gameSystems.DeskSystem.RenderTakeTurnBei();
            } else {
                UnityEngine.Debug.Assert(false);
            }
        }

        public void RenderTakeTakeCard() {
            GameEntity entity = _gameSystems.NetIdxSystem.FindEntity(_context.rule.curidx);
            RenderTakeCard(entity, () => {
                //Command cmd = new Command(MyEventCmd.)
            });
        }

        /// <summary>
        /// take turn 的时候需要下方玩家做出选择
        /// </summary>
        public void RenderTakeTurn() {
            GameEntity entity = _gameSystems.NetIdxSystem.FindEntity(_context.rule.curidx);
            RenderTakeTurnDir(entity);
            if (entity.player.orient == Player.Orient.BOTTOM) {
                Dictionary<long, GameObject> cards = new Dictionary<long, GameObject>();
                for (int i = 0; i < entity.handCards.cards.Count; i++) {
                    GameEntity cardEntiy = entity.handCards.cards[i];
                    cards[cardEntiy.card.value] = cardEntiy.card.go;
                }
                UnityEngine.Debug.Assert(entity.holdCard.holdCardEntity != null);

                var bottomPlayer = entity.player.go.GetComponent<BottomPlayer>();
                bottomPlayer.cards = cards;
                bottomPlayer.holdcard = entity.holdCard.holdCardEntity.card.go;
                bottomPlayer.holdcardValue = entity.holdCard.holdCardEntity.card.value;
                bottomPlayer.touch = true;
            }
        }

        public void RenderLead() {
            GameEntity entity = _gameSystems.NetIdxSystem.FindEntity(_context.rule.curidx);
            string prefix = "Sound/scmj/";
            string path = prefix;
            string name = string.Empty;
            if (entity.player.sex == 1) {
                path += "male";
            } else {
                path += "female";
            }

            if (entity.leadCards.leadcard == -1) {
                return;
            }
            var leadCardEntity = _gameSystems.IndexSystem.FindEntity(entity.leadCards.leadcard);
            if (leadCardEntity.card.type == Card.CardType.Bam) {
                name = "s_";
            } else if (leadCardEntity.card.type == Card.CardType.Crak) {
                name = "w_";
            } else if (leadCardEntity.card.type == Card.CardType.Dot) {
                name = "t_";
            }
            name += string.Format("{0}_", leadCardEntity.card.num);
            if (leadCardEntity.card.type == Card.CardType.Bam && leadCardEntity.card.num == 1) {
                name += string.Format("{0}", _appContext.Range(1, 3));
            } else if (leadCardEntity.card.type == Card.CardType.Bam && leadCardEntity.card.num == 2) {
                name += string.Format("{0}", _appContext.Range(1, 2));
            } else if (leadCardEntity.card.type == Card.CardType.Bam && leadCardEntity.card.num == 4) {
                name += string.Format("{0}", _appContext.Range(1, 2));
            } else {
                name += string.Format("{0}", 1);
            }

            ABLoader.current.LoadAssetAsync<AudioClip>(path, name, (AudioClip clip) => {
                SoundMgr.current.PlaySound(leadCardEntity.card.go, clip);
            });

            RenderLead1(entity, RenderLead1Cb);
        }

        public void RenderLead1(GameEntity entity, Action cb) {

            UnityEngine.Debug.Assert(entity.leadCards.leadcards.Count > 0);
            GameEntity cardEntity = _gameSystems.IndexSystem.FindEntity(entity.leadCards.leadcard);

            Vector3 cdst = CalcLeadPos(entity, cardEntity.card.pos);
            Vector3 hdst = cdst + entity.hand.rhandleadoffset;

            Vector3 csrc = cdst + entity.leadCards.leadcardMove;
            Vector3 hsrc = hdst + entity.leadCards.leadcardMove;

            // 1.0 伸手
            Animator animator = entity.hand.rhand.GetComponent<Animator>();
            animator.SetTrigger("BeforeChupai");
            animator.SetBool("Chupai", true);

            Sequence mySequence1 = DOTween.Sequence();
            mySequence1.Append(entity.hand.rhand.transform.DOLocalMove(hsrc, entity.hand.chupaishendelta))
                .AppendCallback(() => {
                    // 21. 牌向前移

                    var leadCardEntity = _gameSystems.IndexSystem.FindEntity(entity.leadCards.leadcard);
                    leadCardEntity.card.go.transform.localPosition = csrc;
                    leadCardEntity.card.go.transform.localRotation = entity.playerCard.upv;

                    Tween t21 = leadCardEntity.card.go.transform.DOLocalMove(cdst, entity.leadCards.leadcardMoveDelta);
                    Sequence mySequence21 = DOTween.Sequence();
                    mySequence21.Append(t21)
                    .AppendCallback(() => {
                        var deskEntity = _gameSystems.DeskSystem.FindEntity();
                        _gameSystems.DeskSystem.RenderChangeCursor(new Vector3(cdst.x, cdst.y + deskEntity.desk.curorMH, cdst.z));
                    });

                    Tween t22 = entity.hand.rhand.transform.DOLocalMove(hdst, entity.leadCards.leadcardMoveDelta);
                    Sequence mySequence22 = DOTween.Sequence();
                    mySequence22.Append(t22)
                    .AppendCallback(() => {
                        // 
                        //3.0 收手
                        Sequence mySequence4 = DOTween.Sequence();
                        mySequence4.Append(entity.hand.rhand.transform.DOLocalMove(entity.hand.rhandinitpos, entity.hand.chupaishoudelta))
                        .AppendCallback(() => {
                            // 4.1 归为
                            animator.SetBool("Idle", true);

                            entity.hand.rhand.transform.localRotation = entity.hand.rhandinitrot;

                            // 4.2 整理手上的牌
                            cb();
                        });
                    });
                });
        }

        public void RenderLead1Cb() {
            GameEntity entity = _gameSystems.NetIdxSystem.FindEntity(_context.rule.curidx);
            if (entity.leadCards.isHoldCard) {
                Command cmd = new Command(MyEventCmd.EVENT_LEADCARD);
                _appContext.Enqueue(cmd);
            } else {
                RenderFly(entity, () => {
                    Command cmd = new Command(MyEventCmd.EVENT_LEADCARD);
                    _appContext.Enqueue(cmd);
                });
            }
        }

        public void RenderSortCardsToDo(GameEntity entity, float duration, Action cb) {
            int oknum = 0;
            for (int i = 0; i < entity.handCards.cards.Count; i++) {
                Vector3 dst = CalcPos(entity, i);
                Sequence s = DOTween.Sequence();
                s.Append(entity.handCards.cards[i].card.go.transform.DOLocalMove(dst, duration))
                    .AppendCallback(() => {
                        oknum++;
                        if (oknum >= entity.handCards.cards.Count) {
                            cb();
                        }
                    });
            }
        }

        public void RenderInsert(GameEntity entity, Action cb) {
            // 1.0
            Vector3 to = CalcPos(entity, entity.holdCard.holdCardEntity.card.pos);

            Vector3 cdst = to;
            Vector3 hdst = to + entity.hand.rhandnaoffset;

            Animator animator = entity.hand.rhand.GetComponent<Animator>();

            // 1.1 牌下放
            Tween t11 = entity.holdCard.holdCardEntity.card.go.transform.DOLocalMove(cdst, entity.holdCard.holddowndelta);
            Sequence mySequence11 = DOTween.Sequence();
            mySequence11.Append(t11)
            .AppendCallback(() => {
                entity.holdCard.holdCardEntity = null;
                entity.leadCards.leadcard = 0;
                cb();
            });

            // 1.2 手下放
            Tween t12 = entity.hand.rhand.transform.DOLocalMove(hdst, entity.holdCard.holddowndelta);
            Sequence mySequence12 = DOTween.Sequence();
            mySequence12.Append(t12)
                .AppendCallback(() => {
                    // 2.0 放手
                    Hand hand = entity.hand.rhand.GetComponent<Hand>();
                    hand.Rigster(Hand.EVENT.FANGPAI_COMPLETED, () => {
                        // 3.0 收手
                        Tween t31 = entity.hand.rhand.transform.DOLocalMove(entity.hand.rhandinitpos, entity.hand.fangpaishoudelta);
                        Sequence mySequence31 = DOTween.Sequence();
                        mySequence31.Append(t31)
                        .AppendCallback(() => {
                            animator.SetBool("Idle", true);
                            //cb();
                        });
                    });
                    animator.SetBool("Fangpai", true);
                });
        }

        public void RenderSortCardsAfterFly(GameEntity entity, Action cb) {
            int counter = entity.handCards.cards.Count - 1;
            for (int i = 0; i < entity.handCards.cards.Count; i++) {
                GameEntity cardEntity = entity.handCards.cards[i];
                UnityEngine.Debug.Assert(cardEntity.card.pos == i);
                if (cardEntity == entity.holdCard.holdCardEntity) {
                    continue;
                }
                Vector3 dst = CalcPos(entity, cardEntity.card.pos);
                Sequence s = DOTween.Sequence();
                s.Append(cardEntity.card.go.transform.DOLocalMove(dst, entity.holdCard.holdinsortcardsdelta))
                    .AppendCallback(() => {
                        counter--;
                        if (counter <= 0) {
                            RenderInsert(entity, cb);
                        }
                    });
            }
        }

        public void RenderFly(GameEntity entity, Action cb) {
            Vector3 cfrom = entity.holdCard.holdCardEntity.card.go.transform.localPosition;
            Vector3 hfrom = cfrom + entity.hand.rhandnaoffset;

            // 1.0
            Animator animator = entity.hand.rhand.GetComponent<Animator>();
            animator.SetTrigger("BeforeNapai");
            Tween t1 = entity.hand.rhand.transform.DOLocalMove(hfrom, entity.hand.napaishendelta);
            Sequence mySequence1 = DOTween.Sequence();
            mySequence1.Append(t1)
                .AppendCallback(() => {

                    // 2.0 拿牌
                    Hand hand = entity.hand.rhand.GetComponent<Hand>();
                    hand.Rigster(Hand.EVENT.NAPAI_COMPLETED, () => {

                        // 3.1 上提到目标位置
                        Vector3 cdst1 = cfrom + entity.holdCard.holdNaMove;
                        Vector3 hdst1 = hfrom + entity.holdCard.holdNaMove;
                        entity.holdCard.holdCardEntity.card.go.transform.DOLocalMove(cdst1, entity.holdCard.holdNaMovedelta);

                        // 3.2 
                        Sequence mySequence32 = DOTween.Sequence();
                        Tween t32 = entity.hand.rhand.transform.DOLocalMove(hdst1, entity.holdCard.holdNaMovedelta);
                        mySequence32.Append(t32)
                        .AppendCallback(() => {
                            Vector3 to = CalcPos(entity, entity.holdCard.holdCardEntity.card.pos);

                            Vector3 cdst2 = to + entity.holdCard.holdNaMove;
                            Vector3 hdst2 = to + entity.hand.rhandnaoffset + entity.holdCard.holdNaMove;
                            // 4.1 移动到目标位置
                            entity.holdCard.holdCardEntity.card.go.transform.DOLocalMove(cdst2, entity.holdCard.holdflydelta);

                            // 4.2 移动手
                            Tween t42 = entity.hand.rhand.transform.DOLocalMove(hdst2, entity.holdCard.holdflydelta);
                            Sequence mySequence42 = DOTween.Sequence();
                            mySequence42.Append(t42)
                            .AppendCallback(() => {
                                RenderSortCardsAfterFly(entity, cb);
                            });
                        });

                        //float h = 0.05f;
                        //to.y = to.y + Card.Length + h;
                        //Vector3[] waypoints = new[] {
                        //    from,
                        //    new Vector3(from.x, (to.y - from.y) * 0.2f + from.y, (to.z - from.z) * 0.2f + from.z),
                        //    new Vector3(from.x, (to.y - from.y) * 0.3f + from.y, (to.z - from.z) * 0.3f + from.z),
                        //    new Vector3(from.x, (to.y - from.y) * 0.5f + from.y, (to.z - from.z) * 0.5f + from.z),
                        //    new Vector3(from.x, (to.y - from.y) * 0.8f + from.y, (to.z - from.z) * 0.8f + from.z),
                        //    to,
                        //};

                        //Tween t = _holdcard.Go.transform.DOPath(waypoints, _holdflydelta).SetOptions(false);
                        //Sequence mySequence = DOTween.Sequence();
                        //mySequence.Append(t).AppendCallback(() => {
                        //    RenderSortCardsAfterFly(cb);
                        //});

                        //_rhand.transform.DOPath(waypoints, _holdflydelta).SetOptions(false);
                    });
                    animator.SetBool("Napai", true);
                });
        }

        public void RenderCall() { }

        public void RenderPeng() {
            GameEntity entity = _gameSystems.NetIdxSystem.FindEntity(_context.rule.curidx);
            string prefix = "Sound/scmj/";
            string path = prefix;
            string name = string.Empty;
            if (entity.player.sex == 1) {
                path += "male";
            } else {
                path += "female";
            }

            name = "peng_" + string.Format("{0}", _appContext.Range(1, 3));

            ABLoader.current.LoadAssetAsync<AudioClip>(path, name, (AudioClip clip) => {
                if (entity.player.go != null) {
                    SoundMgr.current.PlaySound(entity.player.go, clip);
                }
            });

            GameEntity deskEntity = _gameSystems.DeskSystem.FindEntity();
            PGCards pg = entity.putCards.putcards[entity.putCards.putidx];
            UnityEngine.Debug.Assert(pg.cards.Count == 3);

            float offset = entity.putCards.putrightoffset;
            for (int i = 0; i < entity.putCards.putidx; i++) {
                UnityEngine.Debug.Assert(entity.putCards.putcards[i].width > 0.0f);
                offset += entity.putCards.putcards[i].width + entity.putCards.putmargin;
            }

            for (int i = 0; i < pg.cards.Count; i++) {

                float x, y, z;
                y = Card.Height / 2.0f + Card.HeightMZ;
                if (i == pg.hor) {
                    if (entity.player.orient == Player.Orient.BOTTOM) {
                        x = deskEntity.desk.width - (offset + Card.Length / 2.0f);
                        z = entity.putCards.putbottomoffset + Card.Width / 2.0f;
                    } else if (entity.player.orient == Player.Orient.RIGHT) {
                        x = deskEntity.desk.width - (entity.putCards.putbottomoffset + Card.Width / 2.0f);
                        z = deskEntity.desk.length - (offset + Card.Length / 2.0f);
                    } else if (entity.player.orient == Player.Orient.TOP) {
                        x = offset + Card.Length / 2.0f;
                        z = deskEntity.desk.length - (entity.putCards.putbottomoffset + Card.Width / 2.0f);
                    } else {
                        x = entity.putCards.putbottomoffset + Card.Width / 2.0f;
                        z = offset + Card.Length / 2.0f;
                    }
                    x = entity.putCards.putbottomoffset + Card.Width / 2.0f;
                    z = offset + Card.Length / 2.0f;

                    offset += Card.Length;
                    pg.width += Card.Length;
                    pg.cards[i].card.go.transform.localRotation = entity.playerCard.uph;
                } else {
                    if (entity.player.orient == Player.Orient.BOTTOM) {
                        x = deskEntity.desk.width - (offset + Card.Width / 2.0f);
                        z = deskEntity.putCards.putbottomoffset + Card.Length / 2.0f;
                    } else if (entity.player.orient == Player.Orient.RIGHT) {
                        x = deskEntity.desk.width - (entity.putCards.putbottomoffset + Card.Length / 2.0f);
                        z = deskEntity.desk.length - (offset + Card.Width / 2.0f);
                    } else if (entity.player.orient == Player.Orient.TOP) {
                        x = offset + Card.Length / 2.0f;
                        z = deskEntity.desk.length - (entity.putCards.putbottomoffset + Card.Length / 2.0f);
                    } else {
                        x = entity.putCards.putbottomoffset + Card.Length / 2.0f;
                        z = offset + Card.Width / 2.0f;
                    }

                    x = entity.putCards.putbottomoffset + Card.Length / 2.0f;
                    z = offset + Card.Width / 2.0f;
                    offset += Card.Width;
                    pg.width += Card.Width;
                    pg.cards[i].card.go.transform.localRotation = entity.playerCard.upv;
                }
                pg.cards[i].card.go.transform.localPosition = new Vector3(x, y, z) - entity.putCards.putmove;
            }

            RenderPeng1();
        }

        public void RenderPeng1() {

            GameEntity entity = _gameSystems.NetIdxSystem.FindEntity(_context.rule.curidx);
            PGCards pg = entity.putCards.putcards[entity.putCards.putidx];

            Vector3 cdst = pg.cards[2].card.go.transform.localPosition;
            Vector3 hdst = cdst + entity.hand.rhandpgoffset;

            // 1.0 伸手
            Animator animator = entity.hand.rhand.GetComponent<Animator>();
            animator.SetTrigger("BeforePenggang");
            animator.SetBool("Penggang", true);
            Tween t1 = entity.hand.rhand.transform.DOLocalMove(hdst, entity.hand.penggangshendelta);
            Sequence mySequence1 = DOTween.Sequence();
            mySequence1.Append(t1)
                .AppendCallback(() => {
                    // 2.0
                    _context.rule.oknum = 0;

                    // 2.1 牌移动
                    for (int i = 0; i < pg.cards.Count; i++) {
                        Tween t2 = pg.cards[i].card.go.transform.DOLocalMove(cdst + entity.putCards.putmove, entity.putCards.putmovedelta);
                        Sequence mySequence21 = DOTween.Sequence();
                        mySequence21.Append(t2)
                            .AppendCallback(() => {
                                _context.rule.oknum++;
                                if (_context.rule.oknum >= pg.cards.Count) {
                                    // 3.0 收手
                                    Vector3 c2pos = pg.cards[2].card.go.transform.localPosition;
                                    GameEntity deskEntity = _gameSystems.DeskSystem.FindEntity();
                                    _gameSystems.DeskSystem.RenderChangeCursor(new Vector3(c2pos.x, c2pos.y + deskEntity.desk.curorMH, c2pos.z));
                                }
                            });
                    }

                    // 2.2 手移动                    
                    Tween t22 = entity.hand.rhand.transform.DOLocalMove(hdst + entity.putCards.putmove, entity.putCards.putmovedelta);
                    Sequence mySequence22 = DOTween.Sequence();
                    mySequence22.Append(t22)
                    .AppendCallback(() => {

                        // 3.0 收手
                        Tween t3 = entity.hand.rhand.transform.DOLocalMove(entity.hand.rhandinitpos, entity.hand.penggangshoudelta);
                        Sequence mySequence3 = DOTween.Sequence();
                        mySequence3.Append(t3)
                        .AppendCallback(() => {
                            RenderSortCardsToDo(entity, entity.handCards.sortcardsdelta, () => {
                                // 4.0 归为
                                animator.SetBool("Idle", true);

                                Command cmd = new Command(MyEventCmd.EVENT_PENGCARD);
                                _appContext.Enqueue(cmd);
                            });
                        });
                    });
                });
        }

        public void RenderGang1(GameEntity entity, Action cb) {
            GameEntity deskEntity = _gameSystems.DeskSystem.FindEntity();
            PGCards pg = entity.putCards.putcards[entity.putCards.putidx];

            // 1.0 伸手
            Animator animator = entity.hand.rhand.GetComponent<Animator>();
            animator.SetTrigger("BeforePenggang");
            Tween t1 = entity.hand.rhand.transform.DOMove(pg.cards[3].card.go.transform.position, entity.hand.penggangshendelta);
            Sequence mySequence1 = DOTween.Sequence();
            mySequence1.Append(t1)
                .AppendCallback(() => {
                    // 2.0
                    _context.rule.oknum = 0;

                    // 2.1 牌移动
                    if (pg.gangtype == (long)GangType.BUGANG) {
                        Sequence mySequence21 = DOTween.Sequence();
                        mySequence1.Append(pg.cards[3].card.go.transform.DOMove(pg.cards[3].card.go.transform.position + entity.putCards.putmove, entity.putCards.putmovedelta))
                        .AppendCallback(() => {
                            Vector3 c2pos = pg.cards[3].card.go.transform.position;
                            _gameSystems.DeskSystem.RenderChangeCursor(new Vector3(c2pos.x, c2pos.y + deskEntity.desk.curorMH, c2pos.z));
                        });
                    } else {
                        for (int i = 0; i < pg.cards.Count; i++) {
                            Tween t2 = pg.cards[i].card.go.transform.DOMove(pg.cards[i].card.go.transform.position + entity.putCards.putmove, entity.putCards.putmovedelta);
                            Sequence mySequence21 = DOTween.Sequence();
                            mySequence21.Append(t2)
                                .AppendCallback(() => {
                                    _context.rule.oknum++;
                                    if (_context.rule.oknum >= pg.cards.Count) {
                                        // 3.0 收手
                                        Vector3 c2pos = pg.cards[3].card.go.transform.position;
                                        _gameSystems.DeskSystem.RenderChangeCursor(new Vector3(c2pos.x, c2pos.y + deskEntity.desk.curorMH, c2pos.z));
                                    }
                                });
                        }
                    }


                    // 2.2 手移动                    
                    Tween t22 = entity.hand.rhand.transform.DOLocalMove(entity.hand.rhand.transform.localPosition + entity.putCards.putmove, entity.putCards.putmovedelta);
                    Sequence mySequence22 = DOTween.Sequence();
                    mySequence22.Append(t22)
                    .AppendCallback(() => {

                        // 3.0 收手
                        Tween t3 = entity.hand.rhand.transform.DOMove(entity.hand.rhandinitpos, entity.hand.penggangshoudelta);
                        Sequence mySequence3 = DOTween.Sequence();
                        mySequence3.Append(t3)
                        .AppendCallback(() => {
                            RenderSortCardsToDo(entity, entity.handCards.sortcardsdelta, () => {
                                // 4.0 归为
                                animator.SetBool("Idle", true);

                                cb();
                            });
                        });
                    });
                });
        }

        public void RenderZhiGang(GameEntity entity, GameEntity deskEntity, PGCards pg, float offset) {
            for (int i = 0; i < pg.cards.Count; i++) {
                float x, y, z;
                y = Card.Height / 2.0f + Card.HeightMZ;
                if (i == pg.hor) {
                    if (entity.player.orient == Player.Orient.BOTTOM) {
                        x = deskEntity.desk.width - (offset + Card.Length / 2.0f);
                        z = entity.putCards.putbottomoffset + Card.Width / 2.0f;
                    } else if (entity.player.orient == Player.Orient.RIGHT) {
                        x = deskEntity.desk.width - (entity.putCards.putbottomoffset + Card.Width / 2.0f);
                        z = deskEntity.desk.length - (offset + Card.Length / 2.0f);
                    } else if (entity.player.orient == Player.Orient.TOP) {
                        x = offset + Card.Length / 2.0f;
                        z = deskEntity.desk.length - (entity.putCards.putbottomoffset + Card.Width / 2.0f);
                    } else {
                        x = entity.putCards.putbottomoffset + Card.Width / 2.0f;
                        z = offset + Card.Length / 2.0f;
                    }
                    x = entity.putCards.putbottomoffset + Card.Width / 2.0f;
                    z = offset + Card.Length / 2.0f;

                    offset += Card.Length;
                    pg.width += Card.Length;
                    pg.cards[i].card.go.transform.localRotation = entity.playerCard.uph;
                } else {
                    if (entity.player.orient == Player.Orient.BOTTOM) {
                        x = deskEntity.desk.width - (offset + Card.Width / 2.0f);
                        z = deskEntity.putCards.putbottomoffset + Card.Length / 2.0f;
                    } else if (entity.player.orient == Player.Orient.RIGHT) {
                        x = deskEntity.desk.width - (entity.putCards.putbottomoffset + Card.Length / 2.0f);
                        z = deskEntity.desk.length - (offset + Card.Width / 2.0f);
                    } else if (entity.player.orient == Player.Orient.TOP) {
                        x = offset + Card.Length / 2.0f;
                        z = deskEntity.desk.length - (entity.putCards.putbottomoffset + Card.Length / 2.0f);
                    } else {
                        x = entity.putCards.putbottomoffset + Card.Length / 2.0f;
                        z = offset + Card.Width / 2.0f;
                    }

                    x = entity.putCards.putbottomoffset + Card.Length / 2.0f;
                    z = offset + Card.Width / 2.0f;
                    offset += Card.Width;
                    pg.width += Card.Width;
                    pg.cards[i].card.go.transform.localRotation = entity.playerCard.upv;
                }
                pg.cards[i].card.go.transform.localPosition = new Vector3(x, y, z) - entity.putCards.putmove;
            }

            RenderGang1(entity, () => {
                RenderSortCardsToDo(entity, entity.handCards.pgsortcardsdelta, () => {
                    Command cmd = new Command(MyEventCmd.EVENT_GANGCARD);
                    GL.Util.App.current.Enqueue(cmd);
                });
            });
        }

        public void RenderAnGang(GameEntity entity, GameEntity deskEntity, PGCards pg, float offset) {
            for (int i = 0; i < pg.cards.Count; i++) {
                float x, y, z;
                y = Card.Height / 2.0f + Card.HeightMZ;
                if (entity.player.orient == Player.Orient.BOTTOM) {
                    x = deskEntity.desk.width - (offset + Card.Width / 2.0f);
                    z = entity.putCards.putbottomoffset + Card.Length / 2.0f;
                } else if (entity.player.orient == Player.Orient.RIGHT) {
                    x = entity.putCards.putbottomoffset + Card.Length / 2.0f;
                    z = deskEntity.desk.length - (offset + Card.Width / 2.0f);
                } else if (entity.player.orient == Player.Orient.TOP) {
                    x = offset + Card.Width / 2.0f;
                    z = deskEntity.desk.length - (entity.putCards.putbottomoffset + Card.Length / 2.0f);
                } else {
                    x = entity.putCards.putbottomoffset + Card.Length / 2.0f;
                    z = offset + Card.Width / 2.0f;
                }

                offset += Card.Width;
                pg.width += Card.Width;

                if (i == 0) {
                    pg.cards[i].card.go.transform.localRotation = entity.playerCard.upv;
                } else {
                    pg.cards[i].card.go.transform.localRotation = entity.playerCard.downv;
                }
                pg.cards[i].card.go.transform.localPosition = new Vector3(x, y, z) - entity.putCards.putmove;
            }

            RenderGang1(entity, () => {
                if (pg.isHoldcard) {
                    RenderSortCardsToDo(entity, entity.handCards.pgsortcardsdelta, () => {
                        Command cmd = new Command(MyEventCmd.EVENT_GANGCARD);
                        GL.Util.App.current.Enqueue(cmd);
                    });
                } else {
                    if (pg.isHoldcardInsLast) {
                        RenderSortCardsToDo(entity, entity.handCards.pgsortcardsdelta, () => {
                            Command cmd = new Command(MyEventCmd.EVENT_GANGCARD);
                            GL.Util.App.current.Enqueue(cmd);
                        });
                    } else {
                        RenderFly(entity, () => {
                            Command cmd = new Command(MyEventCmd.EVENT_GANGCARD);
                            GL.Util.App.current.Enqueue(cmd);
                        });
                    }
                }
            });
        }

        public void RenderBuGang(GameEntity entity, GameEntity deskEntity, PGCards pg, float offset) {
            float x, y, z;
            y = Card.Height / 2.0f + Card.HeightMZ;
            if (entity.player.orient == Player.Orient.BOTTOM) {
                x = deskEntity.desk.width - (offset + (Card.Width * pg.hor) + (Card.Length / 2.0f));
                z = entity.putCards.putbottomoffset + Card.Width + Card.Width / 2.0f;
            } else if (entity.player.orient == Player.Orient.RIGHT) {
                x = entity.putCards.putbottomoffset + Card.Width / 2.0f + Card.Width;
                z = deskEntity.desk.length - (offset + Card.Width * pg.hor + Card.Width / 2.0f);
            } else if (entity.player.orient == Player.Orient.TOP) {
                x = offset + Card.Width * pg.hor + Card.Width / 2.0f;
                z = deskEntity.desk.length - (entity.putCards.putbottomoffset + Card.Width / 2.0f + Card.Width);
            } else {
                x = entity.putCards.putbottomoffset + Card.Width / 2.0f + Card.Width;
                z = offset + Card.Width * pg.hor + Card.Length / 2.0f;
            }
            pg.cards[3].card.go.transform.localPosition = new Vector3(x, y, z) - entity.putCards.putmove;
            pg.cards[3].card.go.transform.localRotation = entity.playerCard.uph;

            RenderGang1(entity, () => {
                if (pg.isHoldcard) {
                    Command cmd = new Command(MyEventCmd.EVENT_GANGCARD);
                    GL.Util.App.current.Enqueue(cmd);
                } else {
                    RenderFly(entity, () => {
                        Command cmd = new Command(MyEventCmd.EVENT_GANGCARD);
                        GL.Util.App.current.Enqueue(cmd);
                    });
                }
            });
        }

        public void RenderGang() {
            GameEntity entity = _gameSystems.NetIdxSystem.FindEntity(_context.rule.curidx);
            string prefix = "Sound/scmj/";
            string path = prefix;
            string name = string.Empty;
            if (entity.player.sex == 1) {
                path += "male";
            } else {
                path += "female";
            }

            name = "minggang_2";

            ABLoader.current.LoadAssetAsync<AudioClip>(path, name, (AudioClip clip) => {
                SoundMgr.current.PlaySound(entity.player.go, clip);
            });

            GameEntity deskEntity = _gameSystems.DeskSystem.FindEntity();
            PGCards pg = entity.putCards.putcards[entity.putCards.putidx];
            pg.width = 0;
            UnityEngine.Debug.Assert(pg.cards.Count == 4);

            float offset = entity.putCards.putrightoffset;
            for (int i = 0; i < entity.putCards.putidx; i++) {
                UnityEngine.Debug.Assert(entity.putCards.putcards[i].width > 0.0f);
                offset += entity.putCards.putcards[i].width + entity.putCards.putmargin;
            }

            if (pg.gangtype == (long)GangType.ZHIGANG) {
                RenderZhiGang(entity, deskEntity, pg, offset);
            } else if (pg.gangtype == (long)GangType.ANGANG) {
                RenderAnGang(entity, deskEntity, pg, offset);
            } else if (pg.gangtype == (long)GangType.BUGANG) {
                RenderBuGang(entity, deskEntity, pg, offset);
            } else {
                UnityEngine.Debug.Assert(false);
            }
        }

        //public void GangSettle() {
        //    _ctx.EnqueueRenderQueue(RenderGangSettle);
        //}

        //protected virtual void RenderGangSettle() { }

        protected virtual void RenderHu() {
            GameEntity entity = _gameSystems.NetIdxSystem.FindEntity(_context.rule.curidx);
            string prefix = "Sound/";
            string path = prefix;
            string name = string.Empty;
            if (entity.player.sex == 1) {
                path += "male";
            } else {
                path += "female";
            }

            name = "hu";

            ABLoader.current.LoadAssetAsync<AudioClip>(path, name, (AudioClip clip) => {
                SoundMgr.current.PlaySound(entity.player.go, clip);
            });

            int idx = entity.huCards.hucards.Count - 1;
            GameEntity cardEntity = entity.huCards.hucards[idx];
            Vector3 dst = CalcHuPos(entity, cardEntity.card.pos);
            cardEntity.card.go.transform.localPosition = dst;
            cardEntity.card.go.transform.localRotation = entity.playerCard.upv;

            GameEntity deskEntity = _gameSystems.DeskSystem.FindEntity();
            _gameSystems.DeskSystem.RenderChangeCursor(new Vector3(dst.x, dst.y + deskEntity.desk.curorMH, dst.z));

            Sequence mySequence = DOTween.Sequence();
            mySequence.AppendInterval(1.0f)
                .AppendCallback(() => {
                    Command cmd = new Command(MyEventCmd.EVENT_HUCARD);
                    GL.Util.App.current.Enqueue(cmd);
                });
        }

        #endregion
#endif
    }
}
