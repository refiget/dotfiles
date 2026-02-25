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
[[ -z "$segment_fg" ]] && segment_fg="$overlay0"

# Time segment: keep static, calm color (mode accent is reserved for the session pill)
host_bg="$status_bg"
host_fg="$subtext0"
# Time format (C): HH:MM · MM-DD
# Keep this short and consistent to reduce visual jitter.
time_fmt="${TMUX_TIME_FMT:-%H:%M · %m-%d}"
separator=""
right_cap=""
session_segment=""
rainbarf_segment=""

# Rainbarf: keep it low-contrast and width-stable to match minimalist UI.
rainbarf_toggle="${TMUX_RAINBARF:-1}"
rainbarf_min_width="${TMUX_RAINBARF_MIN_WIDTH:-120}"
rainbarf_width="${TMUX_RAINBARF_WIDTH:-18}"

case "$rainbarf_toggle" in
  0|false|FALSE|off|OFF|no|NO)
    rainbarf_toggle="0"
    ;;
  *)
    rainbarf_toggle="1"
    ;;
esac

# Session label on right side (replaces old left block, keeps hierarchy clean)
show_session=1
session_min_width="${TMUX_SESSION_RIGHT_MIN_WIDTH:-105}"
if [[ -n "${width:-}" && "$width" =~ ^[0-9]+$ ]] && (( width < session_min_width )); then
  show_session=0
fi
if (( show_session == 1 )); then
  current_session_name=$(tmux display-message -p '#{session_name}' 2>/dev/null || true)
  # Canonical naming: <index>__<label>
  # Keep index for icon mapping; display only label.
  session_name_clean="$current_session_name"
  session_idx=""
  if [[ "$current_session_name" =~ ^([0-9]+)__(.*)$ ]]; then
    session_idx="${BASH_REMATCH[1]}"
    session_name_clean="${BASH_REMATCH[2]}"
  elif [[ "$current_session_name" =~ ^([0-9]+)[:_-](.*)$ ]]; then
    # Backward compatibility with older names.
    session_idx="${BASH_REMATCH[1]}"
    session_name_clean="${BASH_REMATCH[2]}"
  fi
  session_name_clean=${session_name_clean:-$current_session_name}

  # Icon mapping by session index (1..10):
  # TMUX_SESSION_ICONS="i1,i2,i3,i4,i5,i6,i7,i8,i9,i10"
  # If index missing/out-of-range, fallback icon is used.

  fallback_icon="${TMUX_SESSION_ICON_FALLBACK:-${TMUX_SESSION_ICON:-󰼏}}"
  session_icon="$fallback_icon"

  session_icons_csv="${TMUX_SESSION_ICONS:-}"
  if [[ -n "$session_icons_csv" && -n "$session_idx" && "$session_idx" =~ ^[0-9]+$ ]]; then
    if (( session_idx >= 1 && session_idx <= 10 )); then
      IFS=',' read -r -a session_icons_arr <<< "$session_icons_csv"
      arr_index=$(( session_idx - 1 ))
      if (( arr_index < ${#session_icons_arr[@]} )); then
        mapped_icon="${session_icons_arr[$arr_index]}"
        if [[ -n "$mapped_icon" ]]; then
          session_icon="$mapped_icon"
        fi
      fi
    fi
  fi

  session_fg=$(tmux show -gqv '@session_label_fg')
  [[ -z "$session_fg" ]] && session_fg="$subtext0"
  # Truncate to keep right bar stable.
  max_slen=${TMUX_SESSION_RIGHT_MAXLEN:-12}
  if (( ${#session_name_clean} > max_slen )); then
    session_name_clean="${session_name_clean:0:max_slen-1}…"
  fi
  session_segment=$(printf '#[fg=%s] %s %s #[default]' "$session_fg" "$session_icon" "$session_name_clean")
fi

if [[ "$rainbarf_toggle" == "1" ]] && command -v rainbarf >/dev/null 2>&1; then
  show_rainbarf=1
  if [[ -n "${width:-}" && "$width" =~ ^[0-9]+$ ]] && (( width < rainbarf_min_width )); then
    show_rainbarf=0
  fi

  if (( show_rainbarf == 1 )); then
    # Keep chart monochrome, but tint segment by a smoothed CPU signal.
    # Smoothing avoids abrupt color jumps while keeping runtime overhead tiny.
    cpu_busy=$(top -l 1 -n 0 2>/dev/null | awk -F'[:,% ]+' '/CPU usage/ {print $3; exit}')
    if [[ ! "$cpu_busy" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
      cpu_busy="0"
    fi

    # EMA in tmux global option: ema = a*current + (1-a)*prev
    alpha="${TMUX_RAINBARF_SMOOTHING:-0.30}"  # higher=faster response, lower=smoother
    prev_ema=$(tmux show -gqv '@cpu_ema' 2>/dev/null || true)
    if [[ ! "$prev_ema" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
      prev_ema="$cpu_busy"
    fi
    cpu_ema=$(awk -v a="$alpha" -v c="$cpu_busy" -v p="$prev_ema" 'BEGIN {printf "%.2f", (a*c)+((1-a)*p)}')
    tmux set -gq @cpu_ema "$cpu_ema"

    metric_fg="$segment_fg"
    # More tiers + smoothing => visually silkier transitions.
    if awk "BEGIN {exit !($cpu_ema >= 90)}"; then
      metric_fg="#f38ba8"   # critical
    elif awk "BEGIN {exit !($cpu_ema >= 75)}"; then
      metric_fg="#fab387"   # high
    elif awk "BEGIN {exit !($cpu_ema >= 60)}"; then
      metric_fg="#f9e2af"   # warm
    elif awk "BEGIN {exit !($cpu_ema >= 45)}"; then
      metric_fg="#a6e3a1"   # moderate
    elif awk "BEGIN {exit !($cpu_ema >= 30)}"; then
      metric_fg="#89dceb"   # light
    else
      metric_fg="#6c7086"   # calm
    fi

    rainbarf_output=$(rainbarf --tmux --width "$rainbarf_width" --no-battery --no-remaining --no-bolt --no-rgb --fg colour244 2>/dev/null || true)
    rainbarf_output=${rainbarf_output//$'\n'/}
    if [[ -n "$rainbarf_output" ]]; then
      rainbarf_segment=$(printf '#[fg=%s] %s #[default]' \
        "$metric_fg" "$rainbarf_output")
    fi
  fi
fi

now=$(date +"$time_fmt")
# Pad to a stable width to keep status layout visually stable.
# "HH:MM · MM-DD" is 13 chars.
now_padded=$(printf '%-13s' "$now")
time_text=" ${now_padded}"

# UI: avoid bold for time; keep it as a calm anchor on the right.
host_prefix=$(printf '#[fg=%s,bg=%s]%s#[fg=%s,bg=%s]' \
  "$host_fg" "$host_bg" "$time_text" \
  "$host_bg" "$status_bg")

printf '%s%s%s%s' \
  "$session_segment" \
  "$rainbarf_segment" \
  "$host_prefix" \
  "$right_cap"
