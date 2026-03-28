#!/usr/bin/env bash
set -euo pipefail

# iPad/remote friendly tmux mode:
# - disable rainbarf
# - optionally hide status-right
# - increase status-interval to reduce flicker
#
# Usage:
#   tmux_ipad_mode.sh off      # enable low-flicker mode
#   tmux_ipad_mode.sh on       # restore previous settings
#   tmux_ipad_mode.sh toggle   # toggle by marker
#   tmux_ipad_mode.sh status   # print current values

cmd="${1:-off}"

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux not found" >&2
  exit 1
fi

if ! tmux info >/dev/null 2>&1; then
  echo "No tmux server/session detected. Start tmux first." >&2
  exit 1
fi

key_prefix="@ipad_mode_prev"

show_status() {
  echo "status-interval=$(tmux show -gqv status-interval)"
  echo "status-right=$(tmux show -gqv status-right)"
  echo "TMUX_RAINBARF=$(tmux show-environment -g 2>/dev/null | sed -n 's/^TMUX_RAINBARF=//p')"
  echo "marker=$(tmux show -gqv @ipad_mode_enabled)"
}

enable_off_mode() {
  # save current values once
  if [[ "$(tmux show -gqv @ipad_mode_enabled)" != "1" ]]; then
    tmux set -gq "${key_prefix}_status_interval" "$(tmux show -gqv status-interval)"
    tmux set -gq "${key_prefix}_status_right" "$(tmux show -gqv status-right)"
    tmux set -gq "${key_prefix}_rainbarf" "$(tmux show-environment -g 2>/dev/null | sed -n 's/^TMUX_RAINBARF=//p')"
  fi

  tmux set-environment -g TMUX_RAINBARF 0
  tmux set -g status-interval 60
  tmux set -g status-right ""
  tmux set -gq @ipad_mode_enabled 1
  tmux refresh-client -S
  echo "iPad mode ON: rainbarf=0, status-right='', status-interval=60"
}

restore_on_mode() {
  local prev_interval prev_right prev_rainbarf
  prev_interval="$(tmux show -gqv "${key_prefix}_status_interval")"
  prev_right="$(tmux show -gqv "${key_prefix}_status_right")"
  prev_rainbarf="$(tmux show -gqv "${key_prefix}_rainbarf")"

  [[ -n "$prev_interval" ]] && tmux set -g status-interval "$prev_interval"
  tmux set -g status-right "$prev_right"

  if [[ -n "$prev_rainbarf" ]]; then
    tmux set-environment -g TMUX_RAINBARF "$prev_rainbarf"
  else
    tmux set-environment -gu TMUX_RAINBARF
  fi

  tmux set -gu "${key_prefix}_status_interval" || true
  tmux set -gu "${key_prefix}_status_right" || true
  tmux set -gu "${key_prefix}_rainbarf" || true
  tmux set -gu @ipad_mode_enabled || true
  tmux refresh-client -S
  echo "iPad mode OFF: restored previous tmux values"
}

case "$cmd" in
  off)
    enable_off_mode
    ;;
  on)
    restore_on_mode
    ;;
  toggle)
    if [[ "$(tmux show -gqv @ipad_mode_enabled)" == "1" ]]; then
      restore_on_mode
    else
      enable_off_mode
    fi
    ;;
  status)
    show_status
    ;;
  *)
    echo "Usage: $0 {off|on|toggle|status}" >&2
    exit 2
    ;;
esac
