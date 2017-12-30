using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

namespace Bacon.Game.View {

    public class FlameThrower : MonoBehaviour {

        public GameObject Head;
        public ParticleSystem Flame;

        // Use this for initialization
        void Start() {
            transform.localPosition = Vector3.zero;
            //Play(20.0f);
        }

        // Update is called once per frame
        void Update() {

        }

        public void DoPath(float duration) {
            float linedelta = duration - 3.0f;
            float step = linedelta / 4.0f;

            var rt = Head.GetComponent<RectTransform>();

            // 1.0
            Vector3 tl = new Vector3(-rt.rect.width / 2.0f, rt.rect.height / 2.0f, 0.0f);
            Quaternion tlrot = Quaternion.Euler(0.0f, -90.0f, 0.0f);
            transform.localPosition = tl;
            transform.localRotation = tlrot;

            // 1.0
            Vector3 tr = new Vector3(rt.rect.width / 2.0f, rt.rect.height / 2.0f, 0.0f);
            Tween t1 = transform.DOLocalMove(tr, step);

            Quaternion trrot = Quaternion.Euler(-90.0f, -90.0f, 0.0f);
            Tween t11 = transform.DOLocalRotateQuaternion(trrot, 1f);

            Vector3 br = new Vector3(rt.rect.width / 2.0f, -rt.rect.height / 2.0f, 0.0f);
            Tween t2 = transform.DOLocalMove(br, step);

            Quaternion brrot = Quaternion.Euler(-180.0f, -90.0f, 0.0f);
            Tween t22 = transform.DOLocalRotateQuaternion(brrot, 1f);

            Vector3 bl = new Vector3(-rt.rect.width / 2.0f, -rt.rect.height / 2.0f, 0.0f);
            Tween t3 = transform.DOLocalMove(bl, step);

            Quaternion blrot = Quaternion.Euler(-270.0f, -90.0f, 0.0f);
            Tween t33 = transform.DOLocalRotateQuaternion(blrot, 1f);

            Tween t4 = transform.DOLocalMove(tl, step);

            Sequence mySequence = DOTween.Sequence();
            mySequence.Append(t1).Append(t11)
                .Append(t2).Append(t22)
                .Append(t3).Append(t33)
                .Append(t4).AppendCallback(() => {
                    Flame.Stop();
                });
        }

        public void Play(float duration) {
            Flame.Play();
            DoPath(duration);
        }

        public void Stop() {
            Flame.Stop();
        }
    }
}