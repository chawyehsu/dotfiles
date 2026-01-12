#!/bin/bash
set -euo pipefail

DOTFILES_REPO_URL="https://github.com/chawyehsu/dotfiles"

test_command() {
  command -v "$1" >/dev/null 2>&1
}

MIN_FREE_KB=$((3 * 1024 * 1024))

# Enable minimal mode when free space on $HOME is below 3 GiB
check_disk_space() {
  if [[ "${MINIMAL_MODE:-}" == "1" || "${MINIMAL_MODE:-}" == "true" ]]; then
    MINIMAL_MODE=1
    return
  fi

  local avail_kb
  avail_kb=$(df -Pk "$HOME" | awk 'NR==2 {print $4}')
  if [[ -n "$avail_kb" && "$avail_kb" -lt "$MIN_FREE_KB" ]]; then
    echo "Less than 3GB free disk space, enabling minimal mode."
    MINIMAL_MODE=1
  else
    MINIMAL_MODE=0
  fi
}

minimal_install() {
  if ! test_command git; then
    echo "git is required for minimal mode but was not found." >&2
    exit 1
  fi

  local dest="$HOME/workspace/repos/github.com/chawyehsu/dotfiles"
  if ! [[ -d "$dest/.git" ]]; then
    mkdir -p "$(dirname "$dest")"
    git clone "$DOTFILES_REPO_URL" "$dest"
  fi
}

install_pixi() {
  # Disable telemetry for pixi installer
  export PIXI_NO_TELEMETRY=1
  # pixi is used to install and manage global essential dependencies
  curl -fsSL https://pixi.sh/install.sh | sh

  # Disable unset variable checking temporarily to source .bashrc
  set +u
  # shellcheck disable=SC1091
  . "$HOME/.bashrc"
  set -u
}

install_os_prerequisites() {
  # Check the distribution and call the appropriate function
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    case "$ID" in
      fedora)
        # `ncurses` for `clear` command
        sudo dnf update -y && sudo dnf install -y ncurses
        ;;
      *)
        echo "Unknown Linux distribution: $ID"
        ;;
    esac
  fi
}

check_disk_space

if [[ "$MINIMAL_MODE" == "1" ]]; then
  minimal_install
  exit 0
fi

install_os_prerequisites

if ! test_command pixi; then
  echo "Installing pixi..."
  install_pixi
fi

if ! test_command nano; then
  echo "Installing nano..."
  pixi global install nano
fi

if ! test_command git; then
  echo "Installing git..."
  pixi global install git
fi

pixi global install go-ghq powershell bat

# update ghq.root
cat > "$HOME/.gitconfig" << EOF
[ghq]
  root = ~/workspace/repos
EOF
# clone dotfiles repo
ghq get "$DOTFILES_REPO_URL"

pushd "$(ghq root)/github.com/chawyehsu/dotfiles"
pwsh -nop install.ps1 -AssumeYes
popd
