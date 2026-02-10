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

# Session pill should be STATIC (no mode color switching).
# Use a neutral background that matches the tab strip / overall UI.
# Allow override via tmux option @session_bg.
active_bg=$(tmux show -gqv '@session_bg')
[[ -z "$active_bg" ]] && active_bg="colour235"

# Neutral, consistent typography
active_fg="colour252"
idx_fg="colour240"

# Session pill styling (keep it clean; avoid powerline arrows)
left_pad=" "
right_pad=" "
max_width=16

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

# Narrow-screen policy: show less to keep the bar calm.
# - If we have an index, show only the index on narrow screens.
# - Otherwise show a shorter name.
if (( is_narrow == 1 )); then
  max_width=12
  if [[ -n "$idx_part" ]]; then
    name_part=""
  fi
fi

# Stable width: truncate name_part relative to idx length.
reserve=$(( ${#idx_part} + ${#left_pad} + ${#right_pad} ))
avail=$(( max_width - reserve ))
if (( avail < 4 )); then
  avail=4
fi
if [[ -n "$name_part" ]] && (( ${#name_part} > avail )); then
  name_part="${name_part:0:avail-1}…"
fi

if [[ -n "$idx_part" && -n "$name_part" ]]; then
  printf '#[fg=%s,bg=%s]%s#[fg=%s,bg=%s]%s#[fg=%s,bg=%s]%s%s#[default]' \
    "$active_fg" "$active_bg" \
    "$left_pad" \
    "$idx_fg" "$active_bg" "$idx_part" \
    "$active_fg" "$active_bg" "$name_part" \
    "$right_pad"
elif [[ -n "$idx_part" ]]; then
  printf '#[fg=%s,bg=%s]%s#[fg=%s,bg=%s]%s%s#[default]' \
    "$active_fg" "$active_bg" \
    "$left_pad" \
    "$idx_fg" "$active_bg" "$idx_part" \
    "$right_pad"
else
  printf '#[fg=%s,bg=%s]%s%s%s#[default]' \
    "$active_fg" "$active_bg" \
    "$left_pad" "$name_part" "$right_pad"
fi
