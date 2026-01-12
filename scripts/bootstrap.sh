#!/bin/bash
set -euo pipefail

test_command() {
  command -v "$1" >/dev/null 2>&1
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
ghq get https://github.com/chawyehsu/dotfiles

pushd "$(ghq root)/github.com/chawyehsu/dotfiles"
pwsh -nop install.ps1 -AssumeYes
popd
