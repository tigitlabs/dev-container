#!/bin/bash

function build_docker_image() {
  echo "🐋 🏗️ Building the image"
  docker buildx build -t nrf-docker:dev -f .devcontainer/nrf-docker/Dockerfile .devcontainer/nrf-docker/
}

function create_docker_container() {
  echo "🐋 🏗️ Creating the container"
  docker create -it --name nrf-docker-dev --workdir /workspace/nrf/applications/asset_tracker_v2  nrf-docker:dev
}

function test_toolchain() {
   # Check if clang-format is installed is working
  echo "🧪 Checking if clang-format is installed and working"
  docker start nrf-docker-dev && docker exec -it nrf-docker-dev clang-format --version

  # Check if west is installed and working
  echo "🧪 Checking if west is installed and working"
  docker start nrf-docker-dev && docker exec -it nrf-docker-dev west --version

  # Check if nrfutil is installed and working
  echo "🧪 Checking if nrfutil is installed and working"
  docker start nrf-docker-dev && docker exec -it nrf-docker-dev nrfutil --version
}

function test_fw_build() {
  echo "🧪 Testing the firmware build"
  docker run -it --rm --name nrf-docker-dev --workdir /workspace/nrf/applications/asset_tracker_v2  nrf-docker:dev \
  west build -b nrf9160dk_nrf9160ns --build-dir /workspace/nrf/applications/asset_tracker_v2/build -- -DEXTRA_CFLAGS="-Werror -Wno-dev"
}

# ---------------------------------------- #
#             Command section              #
# ---------------------------------------- #
if [ "$1" == "build" ]; then
  # Build the image
  build_docker_image

elif [ "$1" == "full" ]; then
  # Build the image
  build_docker_image
  # Create the container
  create_docker_container
  # Test toolchain
  test_toolchain
  # Remove the container
  echo "🧹 Removing the container"
  docker stop nrf-docker-dev &&
  docker rm nrf-docker-dev

elif [ "$1" == "build-create" ]; then
  # Build the image
  build_docker_image
  # Create the container
  create_docker_container

elif [ "$1" == "bash" ]; then
  docker start nrf-docker-dev && docker exec -it nrf-docker-dev bash

elif [ "$1" == "clean" ]; then
  docker stop start nrf-docker-dev
  docker rm nrf-docker-dev
  docker rmi nrf-docker:dev


else
  echo "Script needs an argument"
fi