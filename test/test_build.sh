#!/bin/bash
## Run tests on pre-built devcontainer images
IMAGE="$1"
IMAGE_TAG="$2"

set -e

# Check if devcontainer cli is available
# This should not happen as the container is built with devcontainer cli
if ! command -v devcontainer &> /dev/null; then
    echo "🚫 devcontainer cli not found"
    exit 1
fi

image_name="${IMAGE}:${IMAGE_TAG}"
id_label=" dev.containers.name=${IMAGE}"

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
echo "container_id: ${container_id}"

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
