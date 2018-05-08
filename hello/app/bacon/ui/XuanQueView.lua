
local cls = class("XuanQueView")

function cls:ctor( ... )
    -- body
end

function cls:OnEnter(context, ... )
    -- body
            local rectTransform = self.go.transform
            rectTransform.pivot = new Vector2(0.5f, 0.5f);
            rectTransform.anchorMax = new Vector2(0.5f, 0.5f);
            rectTransform.anchorMin = new Vector2(0.5f, 0.5f);
            rectTransform.localScale = Vector3.one;
            rectTransform.anchoredPosition3D = new Vector3(0, 0, 0);
            rectTransform.sizeDelta = new Vector2(256, 256);

            if (not self._Crak.activeSelf) {
                self._Crak.SetActive(true);
            }
            if (not self._Bam.activeSelf) {
                self._Bam.SetActive(true);
            }
            if (not self._Dot.activeSelf) {
                self._Dot.SetActive(true);
            }
end

function cls:OnCrak() 
            if  self._Bam.activeSelf then
                self._Bam:SetActive(false)
            end
            if  self._Dot.activeSelf then
                self._Dot:SetActive(false);
            end

            local transform = self.go.transform
            local tween1 = transform:DOMove(_moveDst, _moveDuration)
            tween1:SetEase(Ease.OutQuint)
            local tween2 = transform:DOScale(_scaleDst, _scaleDuration)
            tween2:SetEase(Ease.OutQuint);

            local sequence = DOTween.Sequence();
            sequence.Append(tween1)
                .Append(tween2)
                .AppendCallback(function ( ... )
                    -- body
                    if self._Crak.activeSelf then
                            self._Crak.SetActive(false);
                        end

                        local msg = CS.maria.event.Message()
                        msg:SetString("cardtype", Card.CardType.Crak)
                        

                        local cmd = new Command(MyEventCmd.EVENT_XUANQUE, gameObject, msg);
                        EventDispatcher:getInstance():Enqueue(cmd)
                end)
end

function cls:OnBam() 
            if (_Crak.activeSelf) {
                _Crak.SetActive(false);
            }
            if (_Dot.activeSelf) {
                _Dot.SetActive(false);
            }

            local transform = self._Bam.transform as RectTransform;
            local tween1 = transform.DOMove(_moveDst, _moveDuration);
            tween1:SetEase(Ease.OutQuint)
            local tween2 = transform.DOScale(_scaleDst, _scaleDuration);
            tween2.SetEase(Ease.OutQuint);

            local sequence = DOTween.Sequence();
            sequence:Append(tween1)
                :Append(tween2)
                :AppendCallback(function ( ... )
                    -- body
                    if (_Bam.activeSelf) {
                            _Bam.SetActive(false);
                        }
                        Message msg = new Message();
                        msg["cardtype"] = Card.CardType.Bam;

                        Command cmd = new Command(MyEventCmd.EVENT_XUANQUE, gameObject, msg);
                        if (Bacon.GL.Util.App.current != null) {
                            Bacon.GL.Util.App.current.Enqueue(cmd);
                        }
                end)
end

function cls:OnDot() 
            if self._Crak.activeSelf then
                self._Crak.SetActive(false);
            }
            if self._Bam.activeSelf then
                self._Bam.SetActive(false);
            }

            local transform = self._Dot.transform as RectTransform;
            local tween1 = transform.DOMove(_moveDst, _moveDuration);
            tween1.SetEase(Ease.OutQuint);
            local tween2 = transform.DOScale(_scaleDst, _scaleDuration);
            tween2.SetEase(Ease.OutQuint);

            local sequence = DOTween.Sequence();
            sequence.Append(tween1)
                .Append(tween2)
                .AppendCallback(function ( ... )
                        if (self._Dot.activeSelf) {
                            self._Dot.SetActive(false);
                        }

                        local msg = CS.maria.event.Message()
                        msg:SetInt32("cardtype", Card.CardType.Dot)
                        
                        local cmd = new Command(MyEventCmd.EVENT_XUANQUE, gameObject, msg);
                        EventDispatcher:getInstance():Enqueue(cmd)
                    
                end)
end

return cls

-- using System;
-- using System.Collections;
-- using System.Collections.Generic;
-- using UnityEngine;
-- using DG.Tweening;
-- using Maria;
-- using Bacon;
-- using Bacon.Game;
-- using Bacon.Event;
-- using Maria.Util;
-- using Maria.UIBase;
-- using Maria.Event;

-- namespace Bacon.Model.GameUI {

--     public class XuanQueView : BaseView {

--         public GameObject _Crak;
--         public GameObject _Bam;
--         public GameObject _Dot;

--         private Vector3 _moveDst = new Vector3(-88.5f, -26.9f, 100);
--         private Vector3 _scaleDst = new Vector3(0.2f, 0.2f, 0.2f);
--         private float _moveDuration = 0.6f;
--         private float _scaleDuration = 0.4f;

--         public override void OnEnter(IBaseContext context) {
--             base.OnEnter(context);

--             RectTransform rectTransform = transform as RectTransform;
--             rectTransform.pivot = new Vector2(0.5f, 0.5f);
--             rectTransform.anchorMax = new Vector2(0.5f, 0.5f);
--             rectTransform.anchorMin = new Vector2(0.5f, 0.5f);
--             rectTransform.localScale = Vector3.one;
--             rectTransform.anchoredPosition3D = new Vector3(0, 0, 0);
--             rectTransform.sizeDelta = new Vector2(256, 256);

--             if (!_Crak.activeSelf) {
--                 _Crak.SetActive(true);
--             }
--             if (!_Bam.activeSelf) {
--                 _Bam.SetActive(true);
--             }
--             if (!_Dot.activeSelf) {
--                 _Dot.SetActive(true);
--             }
--         }

--         public void OnCrak() {
--             if (_Bam.activeSelf) {
--                 _Bam.SetActive(false);
--             }
--             if (_Dot.activeSelf) {
--                 _Dot.SetActive(false);
--             }

--             RectTransform transform = _Crak.transform as RectTransform;
--             Tween tween1 = transform.DOMove(_moveDst, _moveDuration);
--             tween1.SetEase(Ease.OutQuint);
--             Tween tween2 = transform.DOScale(_scaleDst, _scaleDuration);
--             tween2.SetEase(Ease.OutQuint);

--             Sequence sequence = DOTween.Sequence();
--             sequence.Append(tween1)
--                 .Append(tween2)
--                 .AppendCallback(() => {
--                     try {
--                         if (_Crak.activeSelf) {
--                             _Crak.SetActive(false);
--                         }

--                         Message msg = new Message();
--                         msg["cardtype"] = Card.CardType.Crak;

--                         Command cmd = new Command(MyEventCmd.EVENT_XUANQUE, gameObject, msg);
--                         if (Bacon.GL.Util.App.current != null) {
--                             Bacon.GL.Util.App.current.Enqueue(cmd);
--                         }
--                     } catch (System.Exception ex) {
--                         UnityEngine.Debug.LogException(ex);
--                     }
--                 });
--         }

--         public void OnBam() {
--             if (_Crak.activeSelf) {
--                 _Crak.SetActive(false);
--             }
--             if (_Dot.activeSelf) {
--                 _Dot.SetActive(false);
--             }

--             RectTransform transform = _Bam.transform as RectTransform;
--             Tween tween1 = transform.DOMove(_moveDst, _moveDuration);
--             tween1.SetEase(Ease.OutQuint);
--             Tween tween2 = transform.DOScale(_scaleDst, _scaleDuration);
--             tween2.SetEase(Ease.OutQuint);

--             Sequence sequence = DOTween.Sequence();
--             sequence.Append(tween1)
--                 .Append(tween2)
--                 .AppendCallback(() => {
--                     try {
--                         if (_Bam.activeSelf) {
--                             _Bam.SetActive(false);
--                         }
--                         Message msg = new Message();
--                         msg["cardtype"] = Card.CardType.Bam;

--                         Command cmd = new Command(MyEventCmd.EVENT_XUANQUE, gameObject, msg);
--                         if (Bacon.GL.Util.App.current != null) {
--                             Bacon.GL.Util.App.current.Enqueue(cmd);
--                         }
--                     } catch (System.Exception ex) {
--                         UnityEngine.Debug.LogException(ex);
--                     }
--                 });
--         }

--         public void OnDot() {
--             if (_Crak.activeSelf) {
--                 _Crak.SetActive(false);
--             }
--             if (_Bam.activeSelf) {
--                 _Bam.SetActive(false);
--             }

--             RectTransform transform = _Dot.transform as RectTransform;
--             Tween tween1 = transform.DOMove(_moveDst, _moveDuration);
--             tween1.SetEase(Ease.OutQuint);
--             Tween tween2 = transform.DOScale(_scaleDst, _scaleDuration);
--             tween2.SetEase(Ease.OutQuint);

--             Sequence sequence = DOTween.Sequence();
--             sequence.Append(tween1)
--                 .Append(tween2)
--                 .AppendCallback(() => {
--                     try {
--                         if (_Dot.activeSelf) {
--                             _Dot.SetActive(false);
--                         }

--                         Message msg = new Message();
--                         msg["cardtype"] = Card.CardType.Dot;

--                         Command cmd = new Command(MyEventCmd.EVENT_XUANQUE, gameObject, msg);
--                         if (Bacon.GL.Util.App.current != null) {
--                             Bacon.GL.Util.App.current.Enqueue(cmd);
--                         }
--                     } catch (System.Exception ex) {
--                         UnityEngine.Debug.LogException(ex);
--                     }
--                 });

--         }

--     }
-- }