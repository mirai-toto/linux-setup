#!/bin/bash
set -e

SCRIPT_DIR=$(dirname "$(realpath "$0")")
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
