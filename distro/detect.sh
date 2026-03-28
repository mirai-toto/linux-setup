#!/bin/bash
# Detects the current Linux distribution and exports DISTRO_ID.
# Values: debian | fedora | arch | unknown

detect_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
      ubuntu|debian|linuxmint|pop) echo "debian" ;;
      fedora|rhel|centos|almalinux|rocky) echo "fedora" ;;
      arch|manjaro|endeavouros) echo "arch" ;;
      *) echo "unknown" ;;
    esac
  else
    echo "unknown"
  fi
}

DISTRO_ID=$(detect_distro)
export DISTRO_ID
