#!/usr/bin/env bash
set -euo pipefail

# hide entire right status if terminal width is below threshold
min_width=${TMUX_RIGHT_MIN_WIDTH:-90}
width=$(tmux display-message -p '#{client_width}' 2>/dev/null || true)
if [[ -z "${width:-}" || "$width" == "0" ]]; then
  width=$(tmux display-message -p '#{window_width}' 2>/dev/null || true)
fi
if [[ -z "${width:-}" || "$width" == "0" ]]; then
  width=${COLUMNS:-}
fi
if [[ -n "${width:-}" && "$width" =~ ^[0-9]+$ ]]; then
  if (( width < min_width )); then
    exit 0
  fi
fi

# Colors derived from tmux/style/env with safe fallbacks
status_bg=$(tmux show -gqv status-bg)
[[ -z "$status_bg" ]] && status_bg="default"
[[ "$status_bg" == "default" ]] && status_bg="default"
segment_bg="#3b4252"
segment_fg="#eceff4"

# theme color from env (session > global), fallback dracula accent
theme_line=$(tmux show-environment TMUX_THEME_COLOR 2>/dev/null || true)
if [[ "$theme_line" == TMUX_THEME_COLOR=* ]]; then
  theme_color="${theme_line#TMUX_THEME_COLOR=}"
else
  theme_line=$(tmux show-environment -g TMUX_THEME_COLOR 2>/dev/null || true)
  if [[ "$theme_line" == TMUX_THEME_COLOR=* ]]; then
    theme_color="${theme_line#TMUX_THEME_COLOR=}"
  else
    theme_color="#bd93f9"
  fi
fi

# Ensure theme color looks like a color; otherwise fall back
if [[ ! "$theme_color" =~ ^[#a-zA-Z0-9]+$ ]]; then
  theme_color="#bd93f9"
fi

time_bg="$theme_color"
time_fg="#282a36"
separator=""
right_cap="█"
rainbarf_bg="#2e3440"
rainbarf_segment=""
rainbarf_toggle="${TMUX_RAINBARF:-1}"

case "$rainbarf_toggle" in
  0|false|FALSE|off|OFF|no|NO)
    rainbarf_toggle="0"
    ;;
  *)
    rainbarf_toggle="1"
    ;;
esac

if [[ "$rainbarf_toggle" == "1" ]] && command -v rainbarf >/dev/null 2>&1; then
  rainbarf_output=$(rainbarf --no-battery --no-remaining --no-bolt --tmux --rgb 2>/dev/null || true)
  rainbarf_output=${rainbarf_output//$'\n'/}
  if [[ -n "$rainbarf_output" ]]; then
    rainbarf_segment=$(printf '#[fg=%s,bg=%s]%s#[fg=%s,bg=%s]%s' \
      "$rainbarf_bg" "$status_bg" "$separator" \
      "$segment_fg" "$rainbarf_bg" "$rainbarf_output")
  fi
fi

# Build a connector into the time segment using derived colors
time_connector_bg="$status_bg"
if [[ -n "$rainbarf_segment" ]]; then
  time_connector_bg="$rainbarf_bg"
fi
# network rates (mono) to avoid ANSI/hex; fall back to time on failure
net_cmd="$HOME/scripts/tmux-status/net.sh"
if [[ -x "$net_cmd" ]]; then
  net_output=$(bash "$net_cmd" 2>/dev/null || true)
else
  net_output=""
fi

if [[ -z "$net_output" ]]; then
  net_output=$(date '+%Y-%m-%d %H:%M')
fi

time_prefix=$(printf '#[fg=%s,bg=%s]%s#[fg=%s,bg=%s] ' \
  "$time_bg" "$time_connector_bg" "$separator" \
  "$time_fg" "$time_bg")

printf '%s%s%s #[fg=%s,bg=%s]%s' \
  "$rainbarf_segment" \
  "$time_prefix" \
  "$net_output" \
  "$time_bg" "$status_bg" "$right_cap"
