#!/bin/bash
# Running the pre_build.sh script with different parameters
# to make sure that the script is working as expected.

# DEFINES
BASE_IMAGE_FOR_BASE_UBUNTU="buildpack-deps:22.04-curl"
REPOSITORY_NAME="dev-container"
GITHUB_USERNAME="${GITHUB_USER}"
IMAGE_BASE_URL="ghcr.io/${GITHUB_USERNAME}/${REPOSITORY_NAME}"

script_dir="$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
absolute_root_dir="$(cd "${script_dir}/.." && pwd)"
build_script="${absolute_root_dir}/test/pre_build.sh"

function check_label() {
    local image="$1"
    local label="$2"
    local expected_value="$3"
    echo "🧪 Checking label ${label} for image ${image}"
    local actual_value=$(docker inspect "${image}" | jq -r ".[0].Config.Labels.\"${label}\"")
    if [[ "${actual_value}" != "${expected_value}" ]]; then
        echo "❌ Expected label ${label} to be ${expected_value}, but got ${actual_value}"
        exit 1
    else
        echo "✅ Label check passed"
    fi

}

function run_build() {
    local image=${1}
    local tag=${2}
    local base_image=${3}
    echo "🏃 Running build for image ${image}:${tag} and base image ${base_image}:${tag}"

    local result=$(${build_script} "${image}" "${tag}" "${base_image}" 2>&1)

    local IMAGE_SIZE_TAG='(*) Image size - '
    local IMAGE_SIZE=$(echo "${result}" | grep "${IMAGE_SIZE_TAG}")
    if [[ -z "${IMAGE_SIZE}" ]]; then
        echo "❌ Build failed"
        echo "${result}"
        exit 1
    fi
}

echo "⚒️⚒️⚒️ Test build base-ubuntu"
echo "⚒️ Test build base-ubuntu with no arguments"
run_build "base-ubuntu"
check_label "base-ubuntu:local" "dev.containers.base_image" "${BASE_IMAGE_FOR_BASE_UBUNTU}"
# This is needed for the next tests
run_build "base-ubuntu" "test"
check_label "base-ubuntu:test" "dev.containers.base_image" "${BASE_IMAGE_FOR_BASE_UBUNTU}"

## base-nrf
echo "⚒️⚒️⚒️ Test build base-nrf"
# Test no arguments
# Expected: Build image: base-ubuntu:local
#           Base image : base-ubuntu from ghcr.io/${GITHUB_USERNAME}/${REPOSITORY_NAME}:main
echo "⚒️ Test build base-nrf with no arguments"
run_build "base-nrf"
check_label "base-nrf:local" "dev.containers.base_image" "${IMAGE_BASE_URL}/base-ubuntu:main"

# Test with IMAGE_TAG
# Expected: Build image: base-ubuntu:test
#           Base image : base-ubuntu from ghcr.io/${GITHUB_USERNAME}/${REPOSITORY_NAME}:main
echo "⚒️ Test build base-nrf with IMAGE_TAG"
run_build "base-nrf" "test" "base-ubuntu"
check_label "base-nrf:test" "dev.containers.base_image" "base-ubuntu:test"

# Test with BASE_IMAGE from dev branch
# Expected: Build image: base-nrf:test
#           Base image : base-ubuntu:test
echo "⚒️ Test build base-nrf with BASE_IMAGE from dev branch"
run_build "base-nrf" "dev" "${IMAGE_BASE_URL}/base-ubuntu"
check_label "base-nrf:dev" "dev.containers.base_image" "${IMAGE_BASE_URL}/base-ubuntu:dev"

## nrf-ci
echo "⚒️⚒️⚒️ Test build nrf-ci"
# Test no arguments
# Expected: Build image: nrf-ci:local
#           Base image : base-nrf:local
echo "⚒️ Test build nrf-ci with no arguments"
run_build "nrf-ci"
check_label "nrf-ci:local" "dev.containers.base_image" "${IMAGE_BASE_URL}/base-nrf:main"

# Test with IMAGE_TAG
# Expected: Build image: nrf-ci:test
#           Base image : base-nrf:test
echo "⚒️ Test build nrf-ci with IMAGE_TAG and BASE_IMAGE_TAG"
run_build "nrf-ci" "test" "base-nrf"
check_label "nrf-ci:test" "dev.containers.base_image" "base-nrf:test"

## nrf-devcontainer
echo "⚒️⚒️⚒️ Test build nrf-devcontainer"
# Test no arguments
# Expected: Build image: nrf-devcontainer:local
#           Base image : base-nrf:local
echo "⚒️ Test build nrf-devcontainer with no arguments"
run_build "nrf-devcontainer"
check_label "nrf-devcontainer:local" "dev.containers.base_image" "${IMAGE_BASE_URL}/base-nrf:main"

# Test with IMAGE_TAG and BASE_IMAGE from dev branch
# Expected: Build image: nrf-devcontainer:dev
#           Base image : ghcr.io/${GITHUB_USERNAME}/${REPOSITORY_NAME}:base-nrf:dev
echo "⚒️ Test build nrf-devcontainer with IMAGE_TAG and BASE_IMAGE from dev branch"
run_build "nrf-devcontainer" "dev" "${IMAGE_BASE_URL}/base-nrf"
check_label "nrf-devcontainer:dev" "dev.containers.base_image" "${IMAGE_BASE_URL}/base-nrf:dev"
