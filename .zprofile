eval "$(/opt/homebrew/bin/brew shellenv)"
# Auto-start tmux for interactive login shells
if command -v tmux >/dev/null 2>&1; then
    if [[ -z "$TMUX" && -n "$PS1" && "$TERM_PROGRAM" != "Apple_Terminal" ]]; then
        tmux new-session -A -s main
    fi
fi
# tmux new-session -A -s main => build a new-session `-A` means attached if exists, `-s` means new session and `main` means the name of the new session.O
# ---- PATH (最重要) ----
export PATH="$HOME/miniforge3/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"   # pipx

# ---- Conda bootstrap (minimal, safe) ----
if [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
  . "$HOME/miniforge3/etc/profile.d/conda.sh"
fi
