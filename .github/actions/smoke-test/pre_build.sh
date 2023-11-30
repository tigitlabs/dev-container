#!/bin/bash
IMAGE="$1"
IMAGE_TAG="$2"
# PULL defines if the base image is expected to be available locally
PULL="$3"

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


# Run and test container
echo "(*) Run and Test container - ${image_name}"

docker rm --force "${IMAGE}" || true
docker run \
--sig-proxy=false \
--name "${IMAGE}" \
--detach \
--mount type=bind,source=/workspaces/dev-container,target=/workspaces/dev-container \
--label ${id_label} \
--entrypoint /bin/sh ${image_name} -c 'trap "exit 0" 15; exec "$@"; while sleep 1 & wait $!; do :; done'

container_id=$(docker ps -aqf "name=${IMAGE}")
echo "container_id=${container_id}"

echo "(*) Set-up devcontainer - ${IMAGE}"
devcontainer set-up --container-id "${container_id}" --config "src/${IMAGE}/.devcontainer/devcontainer.json"
echo "(*) Run devcontainer up - ${IMAGE}"
devcontainer up --id-label ${id_label} --workspace-folder "src/${IMAGE}/" --expect-existing-container

# # Run actual test
echo "(*) Running test..."
devcontainer exec \
--workspace-folder "src/${IMAGE}/" \
--id-label ${id_label} \
/bin/sh -c 'set -e && if [ -f "test-project/test.sh" ]; then cd test-project && if [ "$(id -u)" = "0" ]; then chmod +x test.sh; else sudo chmod +x test.sh; fi && ./test.sh; else ls -a; fi'

# # Clean up
docker rm -f $(docker container ls -f "label=${id_label}" -q)
