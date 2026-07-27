#!/bin/bash
set -e

SCRIPT_DIR=$(dirname "$(realpath "$0")")

usage() {
  echo "Usage: ./dev-env.sh <distro> <name> [--rm]"
  echo ""
  echo "Builds (if needed) and runs a named Docker container with install.sh"
  echo "applied, for use as a dev environment."
  echo ""
  echo "By default the container persists: if a container with the given name"
  echo "already exists, it is started and attached to instead of being rebuilt,"
  echo "preserving anything installed or changed inside it between runs."
  echo ""
  echo "With --rm, the container is removed automatically on exit (like"
  echo "'docker run --rm') and is always rebuilt fresh."
  echo ""
  echo "Arguments:"
  echo "  distro    Target distro (e.g. debian, fedora)"
  echo "  name      Name for the container (container will be linux-setup-<name>)"
  echo ""
  echo "Options:"
  echo "  --rm      Remove the container on exit instead of persisting it"
  echo ""
  echo "Available distros:"
  for d in "$SCRIPT_DIR/distro"/*/; do
    echo "  $(basename "$d")"
  done
  echo "  ubuntu (alias for debian)"
  exit 0
}

# Map an OS name to its distro family folder, mirroring distro/detect.sh's
# DISTRO_ID grouping (Ubuntu shares the debian family's setup.sh).
resolve_distro_dir() {
  case "$1" in
    ubuntu) echo "debian" ;;
    *) echo "$1" ;;
  esac
}

RM=false
ARGS=()
for arg in "$@"; do
  case "$arg" in
    --help|-h) usage ;;
    --rm) RM=true ;;
    *) ARGS+=("$arg") ;;
  esac
done

DISTRO="${ARGS[0]}"
NAME="${ARGS[1]}"

if [ -z "$DISTRO" ] || [ -z "$NAME" ]; then
  usage
fi

DISTRO_DIR=$(resolve_distro_dir "$DISTRO")
CONTAINER_NAME="linux-setup-${NAME}"
IMAGE_NAME="linux-setup-${DISTRO_DIR}"
DOCKERFILE="$SCRIPT_DIR/distro/${DISTRO_DIR}/Dockerfile"

if [ ! -f "$DOCKERFILE" ]; then
  echo "No Dockerfile found for distro: $DISTRO"
  echo "Available: $(ls "$SCRIPT_DIR/distro/") ubuntu"
  exit 1
fi

if [ "$RM" = true ]; then
  echo "Building Docker image for $DISTRO_DIR..."
  docker build -t "$IMAGE_NAME" -f "$DOCKERFILE" "$SCRIPT_DIR"

  echo "Running container '$CONTAINER_NAME' (--rm)..."
  docker run --rm -it --name "$CONTAINER_NAME" "$IMAGE_NAME"
elif docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
  echo "Container '$CONTAINER_NAME' already exists, attaching..."
  docker start -ai "$CONTAINER_NAME"
else
  echo "Building Docker image for $DISTRO_DIR..."
  docker build -t "$IMAGE_NAME" -f "$DOCKERFILE" "$SCRIPT_DIR"

  echo "Creating container '$CONTAINER_NAME'..."
  docker run -it --name "$CONTAINER_NAME" "$IMAGE_NAME"
fi
