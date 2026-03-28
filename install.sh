#!/bin/bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")

source "$SCRIPT_DIR/distro/detect.sh"

DISTRO_SCRIPT="$SCRIPT_DIR/distro/${DISTRO_ID}/setup.sh"
if [ -f "$DISTRO_SCRIPT" ]; then
  source "$DISTRO_SCRIPT"
else
  echo "Unsupported distro: '${DISTRO_ID}'. Skipping distro-specific setup."
  install_build_deps() { echo "Skipping build deps: unsupported distro."; }
  configure_locale() { echo "Skipping locale config: unsupported distro."; }
fi

setup_dotfiles() {
  if [ ! -d "$HOME/dotfiles" ]; then
    echo "Cloning dotfiles..."
    git clone https://github.com/mirai-toto/dotfiles.git "$HOME/dotfiles"
  else
    echo "dotfiles already cloned."
  fi
  bash "$HOME/dotfiles/install.sh"
}

install_npm_globals() {
  echo "Installing npm global packages..."
  npm install -g @commitlint/config-conventional
}

install_rust() {
  echo "Installing Rust toolchain via rustup..."
  if [ ! -d "$HOME/.cargo/bin" ]; then
    "$(brew --prefix rustup)/bin/rustup" default stable
  else
    echo "Rust toolchain already installed."
  fi
}

install_wt_settings() {
  if [ -z "$WSL_DISTRO_NAME" ]; then
    echo "Not running inside WSL. Skipping wt-settings installation."
    return
  fi

  echo "Installing wt-settings..."
  if [ ! -d "$HOME/.local/src/wt-settings" ]; then
    mkdir -p "$HOME/.local/src"
    git clone https://github.com/mirai-toto/wt-settings.git "$HOME/.local/src/wt-settings"
  else
    echo "wt-settings already cloned."
  fi
  uv tool install -e "$HOME/.local/src/wt-settings"
}

import_wt_themes() {
  if [ -z "$WSL_DISTRO_NAME" ]; then
    echo "Not running inside WSL. Skipping Windows Terminal theme import."
    return
  fi

  echo "Importing Windows Terminal themes..."
  for theme_file in "$SCRIPT_DIR/themes/"*.json; do
    [ -f "$theme_file" ] || continue
    wts scheme add "$theme_file"
  done
}

configure_wsl_terminal_profile() {
  if [ -z "$WSL_DISTRO_NAME" ]; then
    echo "Not running inside WSL. Skipping Windows Terminal profile configuration."
    return
  fi

  echo "Configuring Windows Terminal profile '$WSL_DISTRO_NAME'..."
  wts --install-completion
  wts profile font "$WSL_DISTRO_NAME" --face "DroidSansM Nerd Font Mono"
  wts profile opacity "$WSL_DISTRO_NAME" 80 --acrylic
  wts profile bell "$WSL_DISTRO_NAME" --disable
  wts scheme apply "$WSL_DISTRO_NAME" "Dark+"
}

print_completion_message() {
  echo "Setup complete."
  echo -e "\033[33mDon't forget to fill in:\033[0m"
  echo -e "  - \033[33m~/.gitconfig.local\033[0m  (git name and email)"
  echo -e "  - \033[33m~/.secrets\033[0m           (API keys and other secrets)"
  echo -e "\033[31mTo apply the changes:\033[0m"
  echo -e "- Close and reopen your terminal."
}

# Main
install_build_deps
configure_locale
setup_dotfiles
install_npm_globals
install_rust
install_wt_settings
import_wt_themes
configure_wsl_terminal_profile
print_completion_message
