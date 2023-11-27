#!/bin/bash
IMAGE="$1"

set -e

export DOCKER_BUILDKIT=1
echo "(*) Installing @devcontainer/cli"
npm install -g @devcontainers/cli

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

echo "(*) Building image - ${IMAGE}"
id_label="test-container=${IMAGE}"
devcontainer up --id-label ${id_label} --workspace-folder "src/${IMAGE}/"
