#!/bin/bash
set -e

SCRIPT_DIR=$(dirname "$(realpath "$0")")

usage() {
  echo "Usage: ./test-install.sh [distro]"
  echo ""
  echo "Builds a Docker image for the given distro and drops into an interactive"
  echo "shell after install.sh completes."
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
IMAGE_NAME="linux-setup-test-${DISTRO}"
DOCKERFILE="$SCRIPT_DIR/distro/${DISTRO}/Dockerfile"

if [ ! -f "$DOCKERFILE" ]; then
  echo "No Dockerfile found for distro: $DISTRO"
  echo "Available: $(ls "$SCRIPT_DIR/distro/")"
  exit 1
fi

echo "Building Docker image for $DISTRO..."
docker build -t "$IMAGE_NAME" -f "$DOCKERFILE" "$SCRIPT_DIR"

echo "Running container..."
docker run --rm -it "$IMAGE_NAME"
