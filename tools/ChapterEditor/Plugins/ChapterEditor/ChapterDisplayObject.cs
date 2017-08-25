using System;
using UnityEditor;
using UnityEngine;
using System;
using System.Collections.Generic;

public class ChapterDisplayObject : MonoBehaviour {
    protected bool _isLocked = false;
    public virtual void customRender() {
	}

    public void lockNode() {
        _isLocked = true;
    }

    public void unlockNode() {
        _isLocked = false;
    }

    public void lockOrUnlockNode() {
        _isLocked = !_isLocked;
    }

    public LockState loclState {
        get {
			return _isLocked ? LockState.LOCK : LockState.UNLOCK;

			/*
            if (_isLocked) {
                return LockState.LOCK;
            } else {
                bool locked = false;
                Transform p = transform.parent;
                while (p != null) {
                    ChapterDisplayObject cdo = p.GetComponent<ChapterDisplayObject>();
                    if (cdo == null) {
                        p = p.parent;
                    } else {
                        locked = cdo.loclState != LockState.UNLOCK;
                        break;
                    }
                }

                return locked ? LockState.INDIRECT_LOCK : LockState.UNLOCK;
            }
			*/
        }
    }
}
