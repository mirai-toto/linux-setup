#!/bin/bash

install_build_deps() {
  echo "Installing build-essential (Debian/Ubuntu)..."
  sudo apt-get update -qq
  sudo apt-get install -y build-essential pkg-config libssl-dev
}

configure_locale() {
  echo "Configuring locale (Debian/Ubuntu)..."
  if ! locale -a 2>/dev/null | grep -q "en_US.utf8"; then
    sudo apt-get install -y locales
    sudo locale-gen en_US.UTF-8
    sudo update-locale LANG=en_US.UTF-8
    echo "Locale en_US.UTF-8 configured successfully."
  else
    echo "Locale en_US.UTF-8 is already configured."
  fi
}
