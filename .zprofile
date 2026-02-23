# Login shell env (keep minimal)

# Homebrew env
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Conda bootstrap (minimal)
if [[ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]]; then
  . "$HOME/miniforge3/etc/profile.d/conda.sh"
fi
