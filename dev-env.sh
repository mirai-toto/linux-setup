#!/bin/bash
set -e

SCRIPT_DIR=$(dirname "$(realpath "$0")")

usage() {
  echo "Usage: ./dev-env.sh --distro <distro> --name <name> [--rm] [--volume <path>]"
  echo ""
  echo "Builds (if needed) and runs a named Docker container with install.sh"
  echo "applied, for use as a dev environment."
  echo ""
  echo "By default the container persists: if a container with the given name"
  echo "already exists, it is started and attached to instead of being rebuilt,"
  echo "preserving anything installed or changed inside it between runs."
  echo ""
  echo "Options:"
  echo "  --distro <distro>  Target distro (e.g. debian, fedora, ubuntu)"
  echo "  --name <name>       Name for the container (container will be linux-setup-<name>)"
  echo "  --rm                Remove the container on exit instead of persisting it"
  echo "                      (image is always rebuilt fresh)"
  echo "  --volume, --dir <host-path>[:<container-path>]"
  echo "                      Bind mount a host directory into the container."
  echo "                      Default container path: /home/testuser/<basename of host-path>."
  echo "                      Can be passed multiple times. Only applied when the"
  echo "                      container is created (ignored if it already exists)."
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

DISTRO=""
NAME=""
RM=false
VOLUMES=()

while [ $# -gt 0 ]; do
  case "$1" in
    --distro)
      DISTRO="$2"
      shift 2
      ;;
    --name)
      NAME="$2"
      shift 2
      ;;
    --rm)
      RM=true
      shift
      ;;
    --volume|--dir)
      VOLUMES+=("$2")
      shift 2
      ;;
    --help|-h)
      usage
      ;;
    *)
      echo "Unknown argument: $1"
      usage
      ;;
  esac
done

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

VOLUME_ARGS=()
for v in "${VOLUMES[@]}"; do
  host_path="${v%%:*}"
  if [[ "$v" == *:* ]]; then
    container_path="${v#*:}"
  else
    container_path="/home/testuser/$(basename "$host_path")"
  fi
  host_path="$(realpath "$host_path")"
  VOLUME_ARGS+=(-v "${host_path}:${container_path}")
done

if [ "$RM" = true ]; then
  echo "Building Docker image for $DISTRO_DIR..."
  docker build -t "$IMAGE_NAME" -f "$DOCKERFILE" "$SCRIPT_DIR"

  echo "Running container '$CONTAINER_NAME' (--rm)..."
  docker run --rm -it --name "$CONTAINER_NAME" "${VOLUME_ARGS[@]}" "$IMAGE_NAME"
elif docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
  if [ ${#VOLUMES[@]} -gt 0 ]; then
    echo "Warning: container '$CONTAINER_NAME' already exists; --volume is ignored (mounts are fixed at creation)."
  fi
  echo "Container '$CONTAINER_NAME' already exists, attaching..."
  docker start -ai "$CONTAINER_NAME"
else
  echo "Building Docker image for $DISTRO_DIR..."
  docker build -t "$IMAGE_NAME" -f "$DOCKERFILE" "$SCRIPT_DIR"

  echo "Creating container '$CONTAINER_NAME'..."
  docker run -it --name "$CONTAINER_NAME" "${VOLUME_ARGS[@]}" "$IMAGE_NAME"
fi
