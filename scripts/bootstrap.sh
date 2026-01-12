#!/bin/bash
set -euo pipefail

check_pixi_installed() {
  command -v pixi >/dev/null 2>&1
}

install_pixi() {
  export PIXI_NO_PATH_UPDATE=1
  # pixi is used to install and manage global essential dependencies
  curl -fsSL https://pixi.sh/install.sh | sh
  # shellcheck disable=SC1091
  . "$HOME/.bashrc"
}

if ! check_pixi_installed; then
  echo "Installing pixi..."
  install_pixi
fi
