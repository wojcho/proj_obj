podman build . -t fp_array_utilities:latest
podman images
podman login docker.io
podman tag localhost/fp_array_utilities:latest docker.io/wojcho/pascal_array_utilities:latest
podman push docker.io/wojcho/pascal_array_utilities:latest
podman images
