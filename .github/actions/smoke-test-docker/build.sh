#!/bin/bash
IMAGE="$1"

set -e

export DOCKER_BUILDKIT=1

echo "(*) Building image - ${IMAGE}"
image_tag="ci-image-${IMAGE}"
docker build --tag $image_tag --file "src/${IMAGE}/.devcontainer/Dockerfile" "src/${IMAGE}/.devcontainer/"
