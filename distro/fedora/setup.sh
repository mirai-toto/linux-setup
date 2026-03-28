#!/bin/bash

install_build_deps() {
  echo "Installing build tools (Fedora/RHEL)..."
  sudo dnf groupinstall -y "Development Tools"
  sudo dnf install -y pkgconfig openssl-devel
}

configure_locale() {
  echo "Configuring locale (Fedora/RHEL)..."
  if ! locale -a 2>/dev/null | grep -q "en_US.utf8"; then
    sudo dnf install -y glibc-langpack-en
    sudo localectl set-locale LANG=en_US.UTF-8
    echo "Locale en_US.UTF-8 configured successfully."
  else
    echo "Locale en_US.UTF-8 is already configured."
  fi
}
