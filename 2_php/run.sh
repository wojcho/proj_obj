#!/usr/bin/bash

IMAGE="docker.io/kprzystalski/projobj-php:latest"
CONTAINER_NAME="my_php_container"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Remove existing container if it exists
if podman ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Removing existing container..."
  podman rm -f "$CONTAINER_NAME"
fi

# Run container in detached interactive mode
podman run -dit \
  -p 45173:45173 \
  --name "$CONTAINER_NAME" \
  "$IMAGE" \
  bash

podman cp "$PROJECT_DIR/." "$CONTAINER_NAME:/home/student/projobj/"

podman exec -it "$CONTAINER_NAME" bash -c "symfony server:start --port=45173"

# Attach interactively
# podman exec -it "$CONTAINER_NAME" bash
