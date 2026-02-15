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

status_bg=$(tmux show -gqv status-bg)
[[ -z "$status_bg" || "$status_bg" == "default" ]] && status_bg="default"

# Palette (Catppuccin Mocha-ish)
text="#cdd6f4"
subtext0="#a6adc8"
overlay0="#6c7086"
peach="#fab387"

# Keep segments on the terminal background to avoid color blocks on transparent themes
segment_fg=$(tmux show -gqv '@status_fg')
[[ -z "$segment_fg" ]] && segment_fg="$peach"

# Time segment: keep static, calm color (mode accent is reserved for the session pill)
host_bg="$status_bg"
host_fg="$subtext0"
# Time format (C): HH:MM · MM-DD
# Keep this short and consistent to reduce visual jitter.
time_fmt="${TMUX_TIME_FMT:-%H:%M · %m-%d}"
separator=""
right_cap=""
rainbarf_bg="#2e3440"
rainbarf_segment=""

# UI choice: default OFF to keep the right side stable (no width jitter)
rainbarf_toggle="${TMUX_RAINBARF:-0}"

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

# Pomodoro / timer breathing dot
# State is driven by @pomo_until_epoch (unix seconds). We intentionally keep this
# independent from mode colors; it's a subtle neutral animation.
now_epoch=$(date +%s)
pomo_until=$(tmux show -gqv '@pomo_until_epoch' 2>/dev/null || true)
pomo_dot=""
if [[ -n "${pomo_until:-}" && "${pomo_until}" =~ ^[0-9]+$ ]]; then
  if (( now_epoch < pomo_until )); then
    # Running: stronger "breathing" using a larger dot and a higher-contrast ramp.
    # (tmux status refresh is seconds-granularity; we compensate with more visible steps.)
    phase=$(( now_epoch % 6 ))
    dot_fg="$overlay0"
    dot_attr=""
    case "$phase" in
      0) dot_fg="#45475a";;  # surface1
      1) dot_fg="#585b70";;  # surface2
      2) dot_fg="$overlay0";;
      3) dot_fg="$text"; dot_attr=",bold";;
      4) dot_fg="$overlay0";;
      5) dot_fg="#585b70";;
    esac
    pomo_dot=$(printf '#[fg=%s%s]●#[default] ' "$dot_fg" "$dot_attr")
  elif (( now_epoch < pomo_until + 60 )); then
    # Done (grace): calm orange dot
    pomo_dot=$(printf '#[fg=%s,bold]●#[default] ' "$peach")
  fi
fi

now=$(date +"$time_fmt")
# Pad to a stable width to keep centred tabs visually stable.
# "HH:MM · MM-DD" is 13 chars.
now_padded=$(printf '%-13s' "$now")
time_text=" ${pomo_dot}${now_padded}"

# UI: avoid bold for time; keep it as a calm anchor on the right.
host_prefix=$(printf '#[fg=%s,bg=%s]%s#[fg=%s,bg=%s]' \
  "$host_fg" "$host_bg" "$time_text" \
  "$host_bg" "$status_bg")

printf '%s%s%s' \
  "$rainbarf_segment" \
  "$host_prefix" \
  "$right_cap"
