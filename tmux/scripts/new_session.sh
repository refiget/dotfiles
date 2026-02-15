#!/usr/bin/env bash
set -euo pipefail

session_id=$(tmux new-session -d -P -F '#{session_id}' 2>/dev/null || true)
if [[ -z "${session_id:-}" ]]; then
  exit 0
fi

python3 "$HOME/.config/tmux/scripts/session_manager.py" ensure

tmux switch-client -t "$session_id"
