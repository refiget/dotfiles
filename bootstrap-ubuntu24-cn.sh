#!/usr/bin/env bash
set -Eeuo pipefail

# Ubuntu 24.04 LTS bootstrap for this dotfiles repo (CN-network friendly)
#
# Features:
# - apt install with retry/timeouts
# - non-interactive sudo support (SUDO_PASSWORD env)
# - GitHub SSH auth verification (incl. ssh.github.com:443 fallback)
# - clone/update dotfiles repo
# - run deploy.sh
# - optional zimfw/lazy.nvim bootstrap

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_URL_DEFAULT="git@github.com:refiget/dotfiles.git"
TARGET_DIR_DEFAULT="$HOME/dotfiles"
if [[ -f "$SCRIPT_DIR/deploy.sh" && -d "$SCRIPT_DIR/.git" ]]; then
  TARGET_DIR_DEFAULT="$SCRIPT_DIR"
fi
BRANCH_DEFAULT="main"

REPO_URL="$REPO_URL_DEFAULT"
TARGET_DIR="$TARGET_DIR_DEFAULT"
BRANCH="$BRANCH_DEFAULT"
DEPLOY_FORCE=0
SKIP_INSTALL=0
SKIP_GITHUB_CHECK=0
SKIP_ZIMFW=0
SKIP_NVIM_LAZY=0

SUDO_PASSWORD="${SUDO_PASSWORD:-}"

log()  { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[WARN]\033[0m %s\n' "$*"; }
err()  { printf '\033[1;31m[ERR ]\033[0m %s\n' "$*" >&2; }

usage() {
  cat <<'USAGE_EOF'
Usage: bootstrap-ubuntu24-cn.sh [options]

Options:
  --repo <git-url>          Dotfiles repo URL (default: git@github.com:refiget/dotfiles.git)
  --target <dir>            Clone target dir (default: ~/dotfiles)
  --branch <name>           Git branch (default: main)
  --deploy-force            Run deploy.sh with --force
  --skip-install            Skip apt package installation
  --skip-github-check       Skip GitHub SSH verification
  --skip-zimfw              Skip zimfw install/update
  --skip-nvim-lazy          Skip nvim lazy sync
  -h, --help                Show this help

Env:
  SUDO_PASSWORD             Optional sudo password for non-interactive runs

Examples:
  bash bootstrap-ubuntu24-cn.sh
  SUDO_PASSWORD='***' bash bootstrap-ubuntu24-cn.sh --deploy-force
USAGE_EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO_URL="$2"; shift 2 ;;
    --target) TARGET_DIR="$2"; shift 2 ;;
    --branch) BRANCH="$2"; shift 2 ;;
    --deploy-force) DEPLOY_FORCE=1; shift ;;
    --skip-install) SKIP_INSTALL=1; shift ;;
    --skip-github-check) SKIP_GITHUB_CHECK=1; shift ;;
    --skip-zimfw) SKIP_ZIMFW=1; shift ;;
    --skip-nvim-lazy) SKIP_NVIM_LAZY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) err "Unknown arg: $1"; usage; exit 1 ;;
  esac
done

if [[ "$(uname -s)" != "Linux" ]]; then
  err "This bootstrap is for Linux (Ubuntu 24.04 LTS)."
  exit 1
fi

if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  source /etc/os-release
  if [[ "${ID:-}" != "ubuntu" ]]; then
    warn "Detected ID=${ID:-unknown}, not ubuntu. Continue anyway."
  fi
  if [[ "${VERSION_ID:-}" != "24.04" ]]; then
    warn "Detected Ubuntu ${VERSION_ID:-unknown}, expected 24.04. Continue anyway."
  fi
fi

retry() {
  local max_attempts="$1"; shift
  local delay="$1"; shift
  local n=1
  until "$@"; do
    if (( n >= max_attempts )); then
      return 1
    fi
    warn "Attempt $n failed: $*"
    sleep "$delay"
    n=$((n + 1))
    delay=$((delay * 2))
  done
}

run_root() {
  if [[ $EUID -eq 0 ]]; then
    "$@"
    return $?
  fi

  if [[ -n "$SUDO_PASSWORD" ]]; then
    printf '%s\n' "$SUDO_PASSWORD" | sudo -S -p '' "$@"
  else
    sudo "$@"
  fi
}

require_sudo_ready() {
  if [[ $EUID -eq 0 ]]; then
    return 0
  fi

  if [[ -n "$SUDO_PASSWORD" ]]; then
    if ! printf '%s\n' "$SUDO_PASSWORD" | sudo -S -k -v >/dev/null 2>&1; then
      err "sudo validation failed with provided SUDO_PASSWORD"
      return 1
    fi
    log "sudo auth validated via SUDO_PASSWORD"
    return 0
  fi

  if sudo -n true >/dev/null 2>&1; then
    log "sudo available without password prompt"
    return 0
  fi

  err "sudo requires interactive password. Re-run with SUDO_PASSWORD env or configure NOPASSWD."
  return 1
}

apt_update_retry() {
  retry 4 2 run_root apt-get update -o Acquire::Retries=3 -o Acquire::http::Timeout=20 -o Acquire::https::Timeout=20
}

apt_install_retry() {
  retry 3 2 run_root apt-get install -y --no-install-recommends "$@"
}

install_pkg_list() {
  local label="$1"; shift
  local pkgs=("$@")
  local missing=()
  local p

  for p in "${pkgs[@]}"; do
    if dpkg -s "$p" >/dev/null 2>&1; then
      continue
    fi
    missing+=("$p")
  done

  if (( ${#missing[@]} == 0 )); then
    log "$label packages already installed"
    return 0
  fi

  log "Installing $label packages: ${missing[*]}"
  apt_install_retry "${missing[@]}"
}

ensure_base_packages() {
  log "Installing base packages..."
  require_sudo_ready
  apt_update_retry

  local required_pkgs=(
    ca-certificates curl wget git openssh-client gnupg lsb-release
    zsh tmux neovim ripgrep fzf fd-find bat jq unzip xclip xsel
    build-essential python3 python3-venv python3-pip software-properties-common
  )
  install_pkg_list "required" "${required_pkgs[@]}"

  local optional_pkgs=(yazi lazygit)
  local p
  for p in "${optional_pkgs[@]}"; do
    if dpkg -s "$p" >/dev/null 2>&1; then
      continue
    fi
    if apt-cache policy "$p" 2>/dev/null | grep -q 'Candidate:' && ! apt-cache policy "$p" 2>/dev/null | grep -q 'Candidate: (none)'; then
      log "Installing optional package: $p"
      apt_install_retry "$p" || warn "Optional package install failed: $p"
    else
      warn "Optional package unavailable in current apt sources: $p"
    fi
  done

  mkdir -p "$HOME/.local/bin"
  if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi
  if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
  fi

  ensure_nvim_compatible
}


ensure_nvim_compatible() {
  command -v nvim >/dev/null 2>&1 || return 0

  local cur req
  req="0.11.2"
  cur="$(nvim --version 2>/dev/null | awk 'NR==1{print $2}' | sed 's/^v//')"
  if [[ -z "$cur" ]]; then
    warn "Cannot detect Neovim version; skip version enforcement"
    return 0
  fi

  if [[ "$(printf '%s
' "$req" "$cur" | sort -V | head -n1)" == "$req" ]]; then
    log "Neovim version OK: $cur"
    return 0
  fi

  warn "Neovim $cur is older than required $req; trying upgrade from PPA"
  set +e
  run_root add-apt-repository -y ppa:neovim-ppa/unstable >/dev/null 2>&1
  local ppa_rc=$?
  set -e
  if (( ppa_rc != 0 )); then
    warn "Failed to add neovim PPA; will skip LazyVim sync"
    SKIP_NVIM_LAZY=1
    return 0
  fi

  apt_update_retry
  if ! apt_install_retry neovim; then
    warn "Failed to upgrade Neovim; will skip LazyVim sync"
    SKIP_NVIM_LAZY=1
    return 0
  fi

  cur="$(nvim --version 2>/dev/null | awk 'NR==1{print $2}' | sed 's/^v//')"
  if [[ "$(printf '%s
' "$req" "$cur" | sort -V | head -n1)" != "$req" ]]; then
    warn "Neovim still <$req after upgrade attempt ($cur); skip LazyVim sync"
    SKIP_NVIM_LAZY=1
  else
    log "Neovim upgraded to $cur"
  fi
}

ensure_known_hosts() {
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  touch "$HOME/.ssh/known_hosts"
  chmod 600 "$HOME/.ssh/known_hosts"

  ssh-keygen -F github.com >/dev/null 2>&1 || ssh-keyscan -t rsa,ecdsa,ed25519 github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null || true
  ssh-keygen -F ssh.github.com >/dev/null 2>&1 || ssh-keyscan -p 443 -t rsa,ecdsa,ed25519 ssh.github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null || true
}

github_ssh_ok_22() {
  local out rc
  set +e
  out=$(ssh -T -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=8 git@github.com 2>&1)
  rc=$?
  set -e
  grep -qi "successfully authenticated" <<< "$out" && return 0
  return $rc
}

github_ssh_ok_443() {
  local out rc
  set +e
  out=$(ssh -T -p 443 -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=8 git@ssh.github.com 2>&1)
  rc=$?
  set -e
  grep -qi "successfully authenticated" <<< "$out" && return 0
  return $rc
}

ensure_ssh_443_config() {
  mkdir -p "$HOME/.ssh"
  touch "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config"

  if ! grep -q "Host github.com" "$HOME/.ssh/config" 2>/dev/null; then
    cat >> "$HOME/.ssh/config" <<'SSH_EOF'
Host github.com
  HostName ssh.github.com
  Port 443
  User git
SSH_EOF
    log "Added ~/.ssh/config fallback for github.com via ssh.github.com:443"
  else
    warn "~/.ssh/config already has Host github.com entry, skip auto-edit."
  fi
}

verify_github_ssh() {
  ensure_known_hosts

  log "Checking GitHub SSH auth (port 22)..."
  if github_ssh_ok_22; then
    log "GitHub SSH auth OK on port 22"
    return 0
  fi

  warn "Port 22 auth failed, trying ssh.github.com:443 ..."
  if github_ssh_ok_443; then
    log "GitHub SSH auth OK on 443; configuring SSH fallback"
    ensure_ssh_443_config
    return 0
  fi

  err "GitHub SSH auth failed on both 22 and 443."
  cat <<'ERR_EOF' >&2
Please check:
1) ssh key exists: ls -al ~/.ssh
2) public key is added to GitHub account
3) run manually: ssh -T git@github.com
4) if blocked in CN network, ensure ~/.ssh/config routes github.com to ssh.github.com:443
ERR_EOF
  return 1
}

clone_or_update_repo() {
  if [[ -d "$TARGET_DIR/.git" ]]; then
    log "Repo exists, updating: $TARGET_DIR"
    retry 3 2 git -C "$TARGET_DIR" fetch --all --prune
    git -C "$TARGET_DIR" checkout "$BRANCH"
    retry 3 2 git -C "$TARGET_DIR" pull --ff-only
    return 0
  fi

  if [[ -e "$TARGET_DIR" && ! -d "$TARGET_DIR/.git" ]]; then
    err "Target exists but is not a git repo: $TARGET_DIR"
    return 1
  fi

  log "Cloning dotfiles into $TARGET_DIR"
  retry 3 2 git clone --depth=1 -b "$BRANCH" "$REPO_URL" "$TARGET_DIR"
}

run_deploy() {
  local deploy_script="$TARGET_DIR/deploy.sh"
  [[ -x "$deploy_script" ]] || chmod +x "$deploy_script"

  log "Running deploy.sh"
  if (( DEPLOY_FORCE == 1 )); then
    bash "$deploy_script" --force
  else
    bash "$deploy_script"
  fi
}

setup_zimfw() {
  (( SKIP_ZIMFW == 1 )) && return 0

  log "Bootstrapping zimfw (best effort)"

  if [[ ! -f "$HOME/.zim/zimfw.zsh" ]]; then
    warn "zimfw not found; skip auto-install to avoid interactive chsh prompts."
    warn "Install later manually if needed: curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh"
    return 0
  fi

  set +e
  zsh -lc 'source ~/.zim/zimfw.zsh && zimfw install && zimfw update'
  local rc=$?
  set -e
  (( rc == 0 )) || warn "zimfw install/update failed. Retry later with better network."
}

setup_nvim_lazy() {
  (( SKIP_NVIM_LAZY == 1 )) && return 0
  command -v nvim >/dev/null 2>&1 || return 0

  local cur req
  req="0.11.2"
  cur="$(nvim --version 2>/dev/null | awk 'NR==1{print $2}' | sed 's/^v//')"
  if [[ -n "$cur" ]] && [[ "$(printf '%s
' "$req" "$cur" | sort -V | head -n1)" != "$req" ]]; then
    warn "Skip Lazy sync: Neovim version $cur < $req"
    return 0
  fi

  log "Syncing Neovim plugins (lazy.nvim, best effort)"
  set +e
  nvim --headless '+Lazy sync' +qa
  local rc=$?
  set -e
  (( rc == 0 )) || warn "Lazy sync failed; retry later in a better network"
}

main() {
  (( SKIP_INSTALL == 0 )) && ensure_base_packages
  (( SKIP_GITHUB_CHECK == 0 )) && verify_github_ssh

  clone_or_update_repo
  run_deploy
  setup_zimfw
  setup_nvim_lazy

  cat <<'DONE_EOF'

✅ Bootstrap finished.

Next steps:
1) Reload shell: exec zsh
2) Reload tmux: tmux source-file ~/.tmux.conf
3) If GitHub pull/push still fails in CN network:
   - test: ssh -T git@github.com
   - check: ~/.ssh/config (github.com -> ssh.github.com:443)
DONE_EOF
}

main "$@"
