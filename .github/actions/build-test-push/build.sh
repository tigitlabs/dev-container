#!/bin/bash
IMAGE="$1"
IMAGE_TAG="$2"

set -e
export DOCKER_BUILDKIT=1

# Install devcontainer cli if not already installed
# Thats the case when running on GitHub Actions Runner
if ! command -v devcontainer &> /dev/null; then
    echo "(*) Installing @devcontainer/cli"
    npm install -g @devcontainers/cli
else
    echo "(*) @devcontainer/cli already installed"
fi

if [ -z "${VARIANT}" ]; then
    echo "⚠️ No VARIANT specified, using default"
else
    echo "VARIANT set to:${VARIANT}"
fi

if [ -z "${REGISTRY}" ]; then
    echo "⚠️ No REGISTRY specified, using default"
else
    echo "REGISTRY set to:${REGISTRY}"
fi

image_name="${IMAGE}:${IMAGE_TAG}"
id_label=" dev.containers.name=${IMAGE}"

echo "(*) Building image - ${image_name}"
devcontainer build --workspace-folder "src/${IMAGE}/" --image-name "${image_name}"
image_id=$(docker images --format "{{.Repository}}:{{.Tag}} {{.ID}}" | grep ${image_name} | awk '{print $2}')
image_size=$(docker images --format "{{.Repository}}:{{.Tag}} {{.Size}}" | grep ${image_name} | awk '{print $2}')
echo "(*) Image size - ${image_size}"
echo "(*) Image id - ${image_id}"
