#!/usr/bin/env bash
set -euo pipefail

index="${1:-}"
if [[ -z "$index" || ! "$index" =~ ^[0-9]+$ ]]; then
  exit 0
fi

python3 "$HOME/.config/tmux/scripts/session_manager.py" ensure
python3 "$HOME/.config/tmux/scripts/session_manager.py" switch "$index"
