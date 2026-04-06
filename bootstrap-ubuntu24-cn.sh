#!/usr/bin/env bash
set -Eeuo pipefail

# Ubuntu 24.04 LTS bootstrap for this dotfiles repo (CN-network friendly)
#
# What it does:
# - apt install with retry/timeouts (non-interactive)
# - optional sudo password via SUDO_PASSWORD env
# - GitHub SSH verification (22 + ssh.github.com:443 fallback)
# - clone/update dotfiles to target (default: ~/dotfiles)
# - run deploy.sh
# - set default shell to zsh (unless disabled)
# - optional zimfw + lazy.nvim setup
# - fallback binary install for lazygit / yazi when apt lacks them

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_URL_DEFAULT="git@github.com:refiget/dotfiles.git"
TARGET_DIR_DEFAULT="$HOME/dotfiles"
if [[ -f "$SCRIPT_DIR/deploy.sh" && -d "$SCRIPT_DIR/.git" ]]; then
  TARGET_DIR_DEFAULT="$SCRIPT_DIR"
fi

REPO_URL="$REPO_URL_DEFAULT"
TARGET_DIR="$TARGET_DIR_DEFAULT"
BRANCH="main"
DEPLOY_FORCE=0
SKIP_INSTALL=0
SKIP_GITHUB_CHECK=0
SKIP_ZIMFW=0
SKIP_NVIM_LAZY=0
SKIP_DEFAULT_SHELL=0
SKIP_BIN_TOOLS=0

SUDO_PASSWORD="${SUDO_PASSWORD:-}"
ASSET_DIR="/tmp/bootstrap-assets"

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
  --skip-default-shell      Do not set user's default shell to zsh
  --skip-bin-tools          Skip GitHub binary fallback install (lazygit/yazi)
  -h, --help                Show this help

Env:
  SUDO_PASSWORD             Optional sudo password for non-interactive runs
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
    --skip-default-shell) SKIP_DEFAULT_SHELL=1; shift ;;
    --skip-bin-tools) SKIP_BIN_TOOLS=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) err "Unknown arg: $1"; usage; exit 1 ;;
  esac
done

if [[ "$(uname -s)" != "Linux" ]]; then
  err "This bootstrap is for Linux."
  exit 1
fi

if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  source /etc/os-release
  [[ "${ID:-}" == "ubuntu" ]] || warn "Detected ID=${ID:-unknown}, not ubuntu."
  [[ "${VERSION_ID:-}" == "24.04" ]] || warn "Detected Ubuntu ${VERSION_ID:-unknown}, expected 24.04."
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
  elif [[ -n "$SUDO_PASSWORD" ]]; then
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
  retry 4 2 run_root env DEBIAN_FRONTEND=noninteractive apt-get update \
    -o Acquire::Retries=3 -o Acquire::http::Timeout=20 -o Acquire::https::Timeout=20
}

apt_install_retry() {
  retry 3 2 run_root env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"
}

install_pkg_list() {
  local label="$1"; shift
  local pkgs=("$@")
  local missing=()
  local p

  for p in "${pkgs[@]}"; do
    dpkg -s "$p" >/dev/null 2>&1 || missing+=("$p")
  done

  if (( ${#missing[@]} == 0 )); then
    log "$label packages already installed"
    return 0
  fi

  log "Installing $label packages: ${missing[*]}"
  apt_install_retry "${missing[@]}"
}

ensure_nvim_compatible() {
  command -v nvim >/dev/null 2>&1 || return 0

  local req cur
  req="0.11.2"
  cur="$(nvim --version 2>/dev/null | awk 'NR==1{print $2}' | sed 's/^v//')"

  if [[ -z "$cur" ]]; then
    warn "Cannot detect Neovim version"
    return 0
  fi

  if [[ "$(printf '%s\n' "$req" "$cur" | sort -V | head -n1)" == "$req" ]]; then
    log "Neovim version OK: $cur"
    return 0
  fi

  warn "Neovim $cur < $req, trying PPA upgrade"
  if ! run_root add-apt-repository -y ppa:neovim-ppa/unstable >/dev/null 2>&1; then
    warn "Cannot add neovim PPA; skip Lazy sync"
    SKIP_NVIM_LAZY=1
    return 0
  fi

  apt_update_retry
  if ! apt_install_retry neovim; then
    warn "Neovim upgrade failed; skip Lazy sync"
    SKIP_NVIM_LAZY=1
    return 0
  fi

  cur="$(nvim --version 2>/dev/null | awk 'NR==1{print $2}' | sed 's/^v//')"
  if [[ "$(printf '%s\n' "$req" "$cur" | sort -V | head -n1)" != "$req" ]]; then
    warn "Neovim still < $req after upgrade attempt ($cur); skip Lazy sync"
    SKIP_NVIM_LAZY=1
  else
    log "Neovim upgraded to $cur"
  fi
}

install_bin_tools_if_needed() {
  (( SKIP_BIN_TOOLS == 1 )) && return 0

  mkdir -p "$ASSET_DIR" "$HOME/.local/bin"

  # lazygit fallback
  if ! command -v lazygit >/dev/null 2>&1; then
    log "Installing lazygit from GitHub release"
    local lg_ver
    lg_ver="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | jq -r .tag_name | sed 's/^v//')"
    retry 3 3 curl -fL "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${lg_ver}_Linux_x86_64.tar.gz" -o "$ASSET_DIR/lazygit.tar.gz"
    tar -xzf "$ASSET_DIR/lazygit.tar.gz" -C "$ASSET_DIR" lazygit
    install -m 0755 "$ASSET_DIR/lazygit" "$HOME/.local/bin/lazygit"
  fi

  # yazi fallback
  if ! command -v yazi >/dev/null 2>&1; then
    log "Installing yazi from GitHub release"
    retry 3 3 curl -fL "https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip" -o "$ASSET_DIR/yazi.zip"
    rm -rf "$ASSET_DIR/yazi_ex" && mkdir -p "$ASSET_DIR/yazi_ex"
    python3 - <<PY
import zipfile
zipfile.ZipFile('${ASSET_DIR}/yazi.zip').extractall('${ASSET_DIR}/yazi_ex')
PY
    install -m 0755 "$ASSET_DIR/yazi_ex/yazi-x86_64-unknown-linux-gnu/yazi" "$HOME/.local/bin/yazi"
    install -m 0755 "$ASSET_DIR/yazi_ex/yazi-x86_64-unknown-linux-gnu/ya" "$HOME/.local/bin/ya"
  fi
}

ensure_base_packages() {
  log "Installing base packages..."
  require_sudo_ready
  apt_update_retry

  local required=(
    ca-certificates curl wget git openssh-client gnupg lsb-release jq unzip
    zsh tmux neovim ripgrep fzf fd-find bat xclip xsel
    build-essential python3 python3-venv python3-pip software-properties-common
  )
  install_pkg_list "required" "${required[@]}"

  mkdir -p "$HOME/.local/bin"
  if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi
  if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
  fi

  ensure_nvim_compatible

  # try apt first for optional tools
  local p
  for p in lazygit yazi; do
    if command -v "$p" >/dev/null 2>&1; then
      continue
    fi
    if apt-cache policy "$p" 2>/dev/null | grep -q 'Candidate:' && ! apt-cache policy "$p" 2>/dev/null | grep -q 'Candidate: (none)'; then
      apt_install_retry "$p" || warn "Optional apt install failed: $p"
    else
      warn "Optional package unavailable in apt: $p"
    fi
  done

  install_bin_tools_if_needed
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
  local out
  out=$(ssh -T -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=8 git@github.com 2>&1 || true)
  grep -qi "successfully authenticated" <<< "$out"
}

github_ssh_ok_443() {
  local out
  out=$(ssh -T -p 443 -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=8 git@ssh.github.com 2>&1 || true)
  grep -qi "successfully authenticated" <<< "$out"
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
    log "GitHub SSH auth OK on 443"
    ensure_ssh_443_config
    return 0
  fi

  err "GitHub SSH auth failed on both 22 and 443"
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

set_default_shell_if_needed() {
  (( SKIP_DEFAULT_SHELL == 1 )) && return 0

  local zsh_path current_user current_shell
  zsh_path="$(command -v zsh || true)"
  [[ -n "$zsh_path" ]] || return 0

  current_user="${SUDO_USER:-$USER}"
  current_shell="$(getent passwd "$current_user" | cut -d: -f7 || true)"
  if [[ "$current_shell" == "$zsh_path" ]]; then
    log "Default shell already $zsh_path"
    return 0
  fi

  log "Setting default shell for $current_user -> $zsh_path"
  run_root chsh -s "$zsh_path" "$current_user" || warn "Failed to set default shell, you can run: chsh -s $zsh_path"
}

setup_zimfw() {
  (( SKIP_ZIMFW == 1 )) && return 0

  if [[ ! -f "$HOME/.zim/zimfw.zsh" ]]; then
    warn "zimfw not found; skip auto-install to avoid interactive chsh prompts"
    return 0
  fi

  set +e
  zsh -lc 'source ~/.zim/zimfw.zsh && zimfw install && zimfw update'
  local rc=$?
  set -e
  (( rc == 0 )) || warn "zimfw install/update failed"
}

setup_nvim_lazy() {
  (( SKIP_NVIM_LAZY == 1 )) && return 0
  command -v nvim >/dev/null 2>&1 || return 0

  local req cur
  req="0.11.2"
  cur="$(nvim --version 2>/dev/null | awk 'NR==1{print $2}' | sed 's/^v//')"
  if [[ -n "$cur" && "$(printf '%s\n' "$req" "$cur" | sort -V | head -n1)" != "$req" ]]; then
    warn "Skip Lazy sync: Neovim version $cur < $req"
    return 0
  fi

  log "Syncing Neovim plugins (lazy.nvim)"
  set +e
  nvim --headless '+Lazy sync' +qa
  local rc=$?
  set -e
  (( rc == 0 )) || warn "Lazy sync failed; retry later"
}

main() {
  (( SKIP_INSTALL == 0 )) && ensure_base_packages
  (( SKIP_GITHUB_CHECK == 0 )) && verify_github_ssh

  clone_or_update_repo
  run_deploy
  set_default_shell_if_needed
  setup_zimfw
  setup_nvim_lazy

  cat <<'DONE_EOF'

✅ Bootstrap finished.

Quick checks:
- dotfiles: ~/dotfiles
- shell now: getent passwd "$USER" | cut -d: -f7
- reload shell: exec zsh
- reload tmux: tmux source-file ~/.tmux.conf
DONE_EOF
}

main "$@"
