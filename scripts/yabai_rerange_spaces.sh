#!/usr/bin/env bash
set -euo pipefail

# Re-arrange target apps into fixed spaces and enforce layouts.
# space1: iTerm2 (bsp)
# space2: ChatGPT (bsp)
# space3: WeChat/微信 (float)

YABAI_BIN="${YABAI_BIN:-$(command -v yabai)}"
JQ_BIN="${JQ_BIN:-$(command -v jq)}"

if [[ -z "${YABAI_BIN}" || -z "${JQ_BIN}" ]]; then
  echo "yabai/jq not found" >&2
  exit 1
fi

run_yabai() { "$YABAI_BIN" -m "$@" >/dev/null 2>&1 || true; }

# Keep user's current space so we don't disrupt focus too much.
CURRENT_SPACE="$($YABAI_BIN -m query --spaces --space 2>/dev/null | $JQ_BIN -r '.index // empty' || true)"

# Enforce layouts (idempotent)
run_yabai space 1 --layout bsp
run_yabai space 2 --layout bsp
run_yabai space 3 --layout float

# Optional labels for easier debugging/commands
run_yabai space 1 --label term
run_yabai space 2 --label chatgpt
run_yabai space 3 --label wechat

move_app_to_space() {
  local app_regex="$1"
  local target_space="$2"

  "$YABAI_BIN" -m query --windows \
    | "$JQ_BIN" -r --arg re "$app_regex" '.[] | select(.app | test($re)) | .id' \
    | while read -r wid; do
        [[ -n "$wid" ]] || continue
        run_yabai window "$wid" --space "$target_space"
      done
}

# iTerm2 -> space 1
move_app_to_space '^iTerm2$' 1

# ChatGPT -> space 2 (cover common app names)
move_app_to_space '^(ChatGPT|ChatGPT Desktop)$' 2

# WeChat / 微信 -> space 3
move_app_to_space '^(WeChat|微信)$' 3

# If WeChat doesn't exist, leave space3 empty (no-op by design)

# Restore previous space focus
if [[ -n "${CURRENT_SPACE}" ]]; then
  run_yabai space --focus "$CURRENT_SPACE"
fi

echo "yabai rerange done"