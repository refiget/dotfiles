#!/usr/bin/env bash
set -euo pipefail

# Re-arrange target apps into fixed spaces and enforce layouts/features.
# Default policy:
# - Only relocate 3 apps: kitty, ChatGPT, WeChat
# - Unify Space 3 window features (float/sub-layer/sticky policy)
#
# Mapping:
# - space1: kitty (bsp)
# - space2: ChatGPT (bsp)
# - space3: WeChat + any other window in this space (float + unified features)

YABAI_BIN="${YABAI_BIN:-$(command -v yabai)}"
JQ_BIN="${JQ_BIN:-$(command -v jq)}"

if [[ -z "${YABAI_BIN}" || -z "${JQ_BIN}" ]]; then
  echo "yabai/jq not found" >&2
  exit 1
fi

# -----------------------------
# Tunables (env-overridable)
# -----------------------------
SPACE_TERM="${SPACE_TERM:-1}"
SPACE_CHATGPT="${SPACE_CHATGPT:-2}"
SPACE_WECHAT="${SPACE_WECHAT:-3}"

APP_TERM_RE='^kitty$'
APP_CHATGPT_RE='^(ChatGPT|ChatGPT Desktop)$'
APP_WECHAT_RE='^(WeChat|微信)$'

# Space3 unified features
# FLOAT: always on (enforced)
# SUB_LAYER: auto|below|normal|above
# STICKY: enforced off by default (can disable enforcement)
SPACE3_SUB_LAYER="${SPACE3_SUB_LAYER:-normal}"
SPACE3_ENFORCE_UNSTICKY="${SPACE3_ENFORCE_UNSTICKY:-on}"

run_yabai() { "$YABAI_BIN" -m "$@" >/dev/null 2>&1 || true; }

current_space() {
  "$YABAI_BIN" -m query --spaces --space 2>/dev/null | "$JQ_BIN" -r '.index // empty' || true
}

list_window_ids_by_app() {
  local app_regex="$1"
  "$YABAI_BIN" -m query --windows \
    | "$JQ_BIN" -r --arg re "$app_regex" '.[] | select(.app | test($re)) | .id'
}

list_space_window_ids() {
  local space_index="$1"
  "$YABAI_BIN" -m query --windows \
    | "$JQ_BIN" -r --argjson s "$space_index" '.[] | select(.space == $s) | .id'
}

ensure_window_float_on() {
  local wid="$1"
  local is_floating
  is_floating="$("$YABAI_BIN" -m query --windows --window "$wid" 2>/dev/null | "$JQ_BIN" -r '."is-floating" // false' || echo false)"
  if [[ "$is_floating" != "true" ]]; then
    run_yabai window "$wid" --toggle float
  fi
}

ensure_window_sticky_off() {
  local wid="$1"
  local is_sticky
  is_sticky="$("$YABAI_BIN" -m query --windows --window "$wid" 2>/dev/null | "$JQ_BIN" -r '."is-sticky" // false' || echo false)"
  if [[ "$is_sticky" == "true" ]]; then
    run_yabai window "$wid" --toggle sticky
  fi
}

apply_space3_features() {
  local wid
  while read -r wid; do
    [[ -n "$wid" ]] || continue

    # Force floating behavior for all windows in space3
    ensure_window_float_on "$wid"

    # Unify stacking behavior (valid yabai command is --sub-layer)
    run_yabai window "$wid" --sub-layer "$SPACE3_SUB_LAYER"

    # Optional: prevent sticky windows from causing cross-space overlay confusion
    if [[ "$SPACE3_ENFORCE_UNSTICKY" == "on" ]]; then
      ensure_window_sticky_off "$wid"
    fi
  done < <(list_space_window_ids "$SPACE_WECHAT")
}

move_app_to_space() {
  local app_regex="$1"
  local target_space="$2"
  local wid

  while read -r wid; do
    [[ -n "$wid" ]] || continue
    run_yabai window "$wid" --space "$target_space"
  done < <(list_window_ids_by_app "$app_regex")
}

main() {
  local original_space
  original_space="$(current_space)"

  # Enforce layouts (idempotent)
  run_yabai space "$SPACE_TERM" --layout bsp
  run_yabai space "$SPACE_CHATGPT" --layout bsp
  run_yabai space "$SPACE_WECHAT" --layout float

  # Optional labels for easier debugging/commands
  run_yabai space "$SPACE_TERM" --label term
  run_yabai space "$SPACE_CHATGPT" --label chatgpt
  run_yabai space "$SPACE_WECHAT" --label wechat

  # Default: only move these 3 apps
  move_app_to_space "$APP_TERM_RE" "$SPACE_TERM"
  move_app_to_space "$APP_CHATGPT_RE" "$SPACE_CHATGPT"
  move_app_to_space "$APP_WECHAT_RE" "$SPACE_WECHAT"

  # Unify all window features inside space3 (not only WeChat)
  apply_space3_features

  # Restore previous space focus
  if [[ -n "${original_space}" ]]; then
    run_yabai space --focus "$original_space"
  fi

  echo "yabai rerange done: only moved kitty/ChatGPT/WeChat, unified space3 features"
}

main "$@"
