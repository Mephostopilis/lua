using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

namespace Bacon.Game.View {

    public class Dice : MonoBehaviour {

        private Action _complted;
        private Animator _animator;

        // Use this for initialization
        void Start() {
            //GetComponent<Rigidbody>().AddForce(new Vector3(1.0f, 0.0f, 0.0f));
            //GetComponent<Rigidbody>().AddForce(new Vector3(200.0f, 0.0f, 200.0f));
            _animator = GetComponent<Animator>();
        }

        // Update is called once per frame
        void Update() {
            if (_animator != null) {
                AnimatorStateInfo si = _animator.GetCurrentAnimatorStateInfo(0);
                if (si.IsName("Base Layer.dice1")) {
                    if (_animator.GetBool("Throw")) {
                        _animator.SetBool("Throw", false);
                    }
                } else if (si.IsName("Base Layer.dice2")) {
                    if (_animator.GetBool("Throw")) {
                        _animator.SetBool("Throw", false);
                    }
                }
            }
        }

        public void Play(Action cb) {
            _complted = cb;
            gameObject.GetComponent<Animator>().SetBool("Throw", true);
        }

        public void OnThrowDiceCompleted() {
            _complted();
        }
    }
}