#!/usr/bin/env bash
set -euo pipefail

direction="${1:-}"
if [[ "$direction" != "left" && "$direction" != "right" ]]; then
  exit 0
fi

python3 "$HOME/.config/tmux/scripts/session_manager.py" move-window "$direction"
