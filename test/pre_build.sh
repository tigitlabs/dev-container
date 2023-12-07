#!/bin/bash
# IMAGE: The name of the Docker image to be built.
# IMAGE_TAG: The tag to be applied to the Docker image.
# BASE_IMAGE_NAME: The base Docker image to be used for building the new image.
# # If not provided, the default image will be used.
IMAGE="$1"
IMAGE_TAG="$2"
BASE_IMAGE_NAME="$3"
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

image_name="${IMAGE}:${IMAGE_TAG}"
id_label=" dev.containers.name=${IMAGE}"
if [[ -z "${BASE_IMAGE_NAME}" ]]; then
    echo "⚠️  No base image provided, using default"
else
    export BASE_IMAGE="${BASE_IMAGE_NAME}"
    echo "(*) Using base image - ${BASE_IMAGE}"
fi

echo "(*) Building image - ${image_name}"

devcontainer build --workspace-folder "src/${IMAGE}/" --image-name "${image_name}"
image_id=$(docker images --format "{{.Repository}}:{{.Tag}} {{.ID}}" | grep ${image_name} | awk '{print $2}')
image_size=$(docker images --format "{{.Repository}}:{{.Tag}} {{.Size}}" | grep ${image_name} | awk '{print $2}')
echo "(*) Image size - ${image_size}"
echo "(*) Image id - ${image_id}"
