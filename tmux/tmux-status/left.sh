#!/usr/bin/env bash
set -euo pipefail

current_session_id="${1:-}"
current_session_name="${2:-}"

detect_current_session_id=$(tmux display-message -p '#{session_id}')
detect_current_session_name=$(tmux display-message -p '#{session_name}')

if [[ -z "$current_session_id" ]]; then
  current_session_id="$detect_current_session_id"
fi

if [[ -z "$current_session_name" ]]; then
  current_session_name="$detect_current_session_name"
fi

status_bg=$(tmux show -gqv status-bg)
if [[ -z "$status_bg" ]]; then
  status_bg="default"
fi

tmux_mode="normal"
mode_line=$(tmux show-environment TMUX_MODE 2>/dev/null || tmux show-environment -g TMUX_MODE 2>/dev/null || true)
if [[ "$mode_line" == TMUX_MODE=* ]]; then
  tmux_mode="${mode_line#TMUX_MODE=}"
fi

theme_color=$(tmux show -gqv '@theme_color')
[[ -z "$theme_color" ]] && theme_color="#bd93f9"
default_active_bg="$theme_color"
insert_active_bg="$theme_color"
# override color on non-Darwin (cloud): use Hatsune blue for active segment
sysname=$(uname 2>/dev/null || echo unknown)
if [[ "$sysname" != "Darwin" ]]; then
  default_active_bg="#1793d1"
  insert_active_bg="#1793d1"
fi
inactive_bg="#373b41"
inactive_fg="#c5c8c6"
active_bg="$default_active_bg"
active_fg="#1d1f21"

# Session pill styling (keep it clean; avoid powerline arrows)
# Use thin edge glyphs to make the pill feel intentional.
pill_left="▏"
pill_right="▕"
max_width=18

# width-based label policy: when narrow (<80 cols by default),
# show title for active session and only the numeric index for inactive ones.
left_narrow_width=${TMUX_LEFT_NARROW_WIDTH:-80}
term_width=$(tmux display-message -p '#{client_width}' 2>/dev/null || true)
if [[ -z "${term_width:-}" || "$term_width" == "0" ]]; then
  term_width=$(tmux display-message -p '#{window_width}' 2>/dev/null || true)
fi
if [[ -z "${term_width:-}" || "$term_width" == "0" ]]; then
  term_width=${COLUMNS:-}
fi
is_narrow=0
if [[ -n "${term_width:-}" && "$term_width" =~ ^[0-9]+$ ]]; then
  if (( term_width < left_narrow_width )); then
    is_narrow=1
  fi
fi

normalize_session_id() {
  local value="$1"
  value="${value#\$}"
  printf '%s' "$value"
}

trim_label() {
  local value="$1"
  if [[ "$value" =~ ^[0-9]+[:_-](.*)$ ]]; then
    printf '%s' "${BASH_REMATCH[1]}"
  else
    printf '%s' "$value"
  fi
}

extract_index() {
  local value="$1"
  if [[ "$value" =~ ^([0-9]+)[:_-].*$ ]]; then
    printf '%s' "${BASH_REMATCH[1]}"
  else
    printf ''
  fi
}

sessions=$(tmux list-sessions -F '#{session_id}::#{session_name}' 2>/dev/null || true)
if [[ -z "$sessions" ]]; then
  exit 0
fi

# UI choice: show ONLY the current session to reduce noise.
current_session_id_norm=$(normalize_session_id "$current_session_id")
label=""
while IFS= read -r entry; do
  [[ -z "$entry" ]] && continue
  session_id="${entry%%::*}"
  name="${entry#*::}"
  [[ -z "$session_id" ]] && continue

  session_id_norm=$(normalize_session_id "$session_id")
  if [[ "$session_id" == "$current_session_id" || "$session_id_norm" == "$current_session_id_norm" ]]; then
    trimmed_name=$(trim_label "$name")
    idx=$(extract_index "$name")

    if [[ -n "$idx" ]]; then
      # Deemphasize the index by separating it; styling is handled in printf below.
      label="${idx}:${trimmed_name}"
    else
      label="$trimmed_name"
    fi

    if (( ${#label} > max_width )); then
      label="${label:0:max_width-1}…"
    fi
    break
  fi
done <<< "$sessions"

if [[ -z "$label" ]]; then
  exit 0
fi

# Render as a compact pill with consistent padding.
# If the label is "<idx>:<name>", we show idx a bit dimmer for hierarchy.
idx_part=""
name_part="$label"
if [[ "$label" =~ ^([0-9]+):(.*)$ ]]; then
  idx_part="${BASH_REMATCH[1]}:"
  name_part="${BASH_REMATCH[2]}"
fi

if [[ -n "$idx_part" ]]; then
  printf '#[fg=%s,bg=%s]%s #[fg=colour236,bg=%s]%s#[fg=%s,bg=%s]%s %s#[default]' \
    "$active_fg" "$active_bg" \
    "$pill_left" \
    "$active_bg" "$idx_part" \
    "$active_fg" "$active_bg" \
    "$name_part" "$pill_right"
else
  printf '#[fg=%s,bg=%s]%s %s %s#[default]' \
    "$active_fg" "$active_bg" \
    "$pill_left" "$name_part" "$pill_right"
fi
