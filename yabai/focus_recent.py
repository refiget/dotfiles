#!/usr/bin/env python3
import json
import os
import subprocess
import sys
from pathlib import Path

STATE_PATH = Path.home() / ".config" / "yabai" / "recent_window_by_space.json"
LOCK_PATH = Path.home() / ".config" / "yabai" / ".focus_recent.lock"
LOCK_MAX_AGE_SEC = 0.5


def _now():
    return __import__("time").time()


def _lock_recently_set():
    try:
        if not LOCK_PATH.exists():
            return False
        age = _now() - float(LOCK_PATH.read_text().strip() or "0")
        return age >= 0 and age < LOCK_MAX_AGE_SEC
    except Exception:
        return False


def _set_lock():
    LOCK_PATH.parent.mkdir(parents=True, exist_ok=True)
    LOCK_PATH.write_text(str(_now()), encoding="utf-8")


def yabai_query(arg_list):
    """Run `yabai -m query ...` and return stdout.

    NOTE: yabai can transiently return non-zero (e.g. during layout changes / no focused
    window), which would otherwise crash signal handlers.
    """
    try:
        return subprocess.check_output(
            ["/opt/homebrew/bin/yabai", "-m", "query", *arg_list], text=True
        )
    except subprocess.CalledProcessError:
        return ""


def yabai_cmd(arg_list):
    subprocess.call(["/opt/homebrew/bin/yabai", "-m", *arg_list])


def load_state():
    if STATE_PATH.exists():
        try:
            return json.loads(STATE_PATH.read_text(encoding="utf-8"))
        except Exception:
            return {}
    return {}


def save_state(state):
    STATE_PATH.parent.mkdir(parents=True, exist_ok=True)
    tmp = STATE_PATH.with_suffix(".tmp")
    tmp.write_text(json.dumps(state, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    os.replace(tmp, STATE_PATH)


def record():
    # Record the currently focused window id for its space.
    # Guard: when we intentionally refocus during a space change, yabai may
    # briefly focus the "first" window, which would overwrite our stored recent.
    if _lock_recently_set():
        return

    raw = yabai_query(["--windows", "--window"]).strip()
    if not raw:
        return
    try:
        w = json.loads(raw)
    except Exception:
        return

    wid = w.get("id")
    space = w.get("space")
    if not wid or space is None:
        return

    state = load_state()
    state[str(space)] = int(wid)
    save_state(state)


def focus():
    # On space change, focus the most recently focused window we recorded for this space.
    # Set a short-lived lock so the "window_focused" signal triggered by yabai's
    # default focus behavior doesn't overwrite our stored recent.
    _set_lock()

    raw = yabai_query(["--spaces", "--space"]).strip()
    if not raw:
        return
    try:
        space = json.loads(raw)
    except Exception:
        return

    sidx = space.get("index")
    if not sidx:
        return

    state = load_state()
    wid = state.get(str(sidx))
    if not wid:
        return

    # Verify window still exists and is on this space and is visible.
    raw = yabai_query(["--windows", "--window", str(wid)]).strip()
    if not raw:
        # stale id or transient query failure
        state.pop(str(sidx), None)
        save_state(state)
        return

    try:
        w = json.loads(raw)
    except Exception:
        return

    if w.get("space") != sidx:
        return
    if w.get("is-minimized"):
        return

    yabai_cmd(["window", "--focus", str(wid)])


def main():
    if len(sys.argv) != 2 or sys.argv[1] not in ("record", "focus"):
        print("usage: focus_recent.py (record|focus)", file=sys.stderr)
        sys.exit(2)

    if sys.argv[1] == "record":
        record()
    else:
        focus()


if __name__ == "__main__":
    main()
