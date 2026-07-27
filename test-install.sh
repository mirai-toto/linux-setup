#!/bin/bash
set -e

SCRIPT_DIR=$(dirname "$(realpath "$0")")

usage() {
  echo "Usage: ./test-install.sh [distro]"
  echo ""
  echo "Builds a Docker image for the given distro and drops into an interactive"
  echo "shell after install.sh completes. The container is removed on exit."
  echo ""
  echo "Arguments:"
  echo "  distro    Target distro (default: debian)"
  echo ""
  echo "Available distros:"
  for d in "$SCRIPT_DIR/distro"/*/; do
    echo "  $(basename "$d")"
  done
  exit 0
}

[ "${1}" = "--help" ] || [ "${1}" = "-h" ] && usage

DISTRO="${1:-debian}"

exec "$SCRIPT_DIR/dev-env.sh" --distro "$DISTRO" --name "test-${DISTRO}" --rm
