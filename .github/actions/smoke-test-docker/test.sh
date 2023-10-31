#/bin/bash
IMAGE="$1"

export DOCKER_BUILDKIT=1
set -e

# Run actual test
echo "(*) Running test..."
image_tag="ci-image-${IMAGE}"

# devcontainer exec 
# --workspace-folder $(pwd)/src/$IMAGE  
# --id-label ${id_label} 
# /bin/sh -c 
# 'set -e && 
# if [ -f "test-project/test.sh" ]; then 
#    cd test-project 
#    && if [ "$(id -u)" = "0" ]; then 
#         chmod +x test.sh;
#      else 
#         sudo chmod +x test.sh;
#      fi 
#  && ./test.sh; 
# else 
#   ls -a; fi'
# Run the container and execute the test script
docker run \
--rm \
--label ${image_tag} \
--volume $(pwd)/src/$IMAGE:/workspace \
--workdir /workspace \
$image_tag /bin/sh -c 'set -e && if [ -f "test-project/test-docker.sh" ]; then cd test-project && if [ "$(id -u)" = "0" ]; then chmod +x test-docker.sh; else sudo chmod +x test-docker.sh; fi && ./test-docker.sh; else ls -a; fi'

echo "(*) Docker image details..."
docker images

# Clean up
docker rm -f $(docker container ls -f "label=${image_tag}" -q)
