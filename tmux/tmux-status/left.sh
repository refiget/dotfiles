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

# TMUX_MODE is handled elsewhere (kept out of this left segment to keep it static).

# Session label should be visually DISTINCT from window tabs.
# Keep it as plain text (no block background) to avoid hierarchy confusion.
# Palette (Catppuccin Mocha-ish)
text="#cdd6f4"
overlay0="#6c7086"
# Session label gets a distinct cool accent so it won't blend with window tabs.
session_accent=$(tmux show -gqv '@session_label_fg')
[[ -z "$session_accent" ]] && session_accent="#a6adc8"

active_fg="$session_accent"
idx_fg="$overlay0"
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
    # Keep session navigation naming (e.g. "3_cootron") intact internally,
    # but display only the human-readable label in the bar.
    label=$(trim_label "$name")

    if (( ${#label} > max_width )); then
      label="${label:0:max_width-1}…"
    fi
    break
  fi
done <<< "$sessions"

if [[ -z "$label" ]]; then
  exit 0
fi

# Render as plain text prefix to separate session-vs-window hierarchy.
# Use Nerd Font icon (override via TMUX_SESSION_ICON).
session_icon="${TMUX_SESSION_ICON:-}"
name_part="$label"

# Narrow-screen policy: keep it concise.
if (( is_narrow == 1 )); then
  max_width=12
fi

reserve=6 # "<icon> ses:" approx visible width budget
avail=$(( max_width - reserve ))
if (( avail < 4 )); then
  avail=4
fi
if [[ -n "$name_part" ]] && (( ${#name_part} > avail )); then
  name_part="${name_part:0:avail-1}…"
fi

printf '#[fg=%s]%s ses:%s#[default] ' \
  "$active_fg" "$session_icon" "$name_part"
