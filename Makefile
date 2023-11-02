.DEFAULT_GOAL:=help
SHELL:=/bin/bash

# Environment variables
# This is default value when running in docker desktop
TEST_ENV?="docker_native"
# Use this value when running on a linux host or an Github Action Runner
# make loggy-test TEST_ENV="docker_native"
# Use this value when running on Docker Desktop
# make loggy-test TEST_ENV="docker_desktop"

# --------------------------
.PHONY: help
help:       	## Show this help.
	@echo "Convinient make targets for development and testing"
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Github Actions - ACT

.PHONY: github-action-list
github-action-list:	## ✅List Workflows
	@echo "📋 List Push Workflows"
	@act push --list
	@echo "📋 List Pull Request Workflows"
	@act pull_request --list

# .PHONY: github-action-run
# github-action-run:	## ✅Run Workflows
# 	gh act --job build-and-test-all-images --secret-file ~/.ssh/act-secrets

# .PHONY: github-action-workflow-devcontainer-ci
# github-action-workflow-devcontainer-ci:	## ✅Run Workflows for devcontainers
# 	gh act  --workflows .github/workflows/nrf-devcontainer.yml --secret-file ~/.ssh/act-secrets

.PHONY: github-action-smoke-base-ubuntu
github-action-smoke-base-ubuntu:	## ✅Run smoke-test for base-ubuntu
	act -W .github/workflows/smoke-base-ubuntu.yaml \
	--secret GITHUB_TOKEN=${GITHUB_TOKEN}

.PHONY: github-action-smoke-test
github-action-smoke-test:	## ✅Run smoke-test for all images
	make github-action-smoke-base-ubuntu

.PHONY: github-action-docker-publish
github-action-docker-publish:	## ✅Build and publish all images
	act -W .github/workflows/docker-publish.yml \
	-s GITHUB_TOKEN="${GITHUB_TOKEN}" \
	--eventpath .github/workflows/act/event-publish-main.json


##@ 🐋 Docker Build

.PHONY: docker-build-ubuntu-base
docker-build-base-ubuntu:	## 🏗️Build ubuntu-base image
	@echo "🏗️ Building ubuntu-base image"
	docker buildx build \
	--tag tigtilabs-ubuntu-base:local \
	--file src/base-ubuntu/.devcontainer/Dockerfile src/base-ubuntu/.devcontainer/

# .PHONY: docker-build-nrf-docker
# docker-build-nrf-docker:	## 🏗️Build nrf-docker image
# 	@echo "🏗️ Building nrf-docker image"
# 	docker buildx build \
# 	--tag tigitlabs-nrf-docker:local \
# 	--build-arg BASE_IMAGE="tigtilabs-ubuntu-base:local" \
# 	--progress plain \
# 	--file .devcontainer/nrf-docker/Dockerfile .devcontainer/nrf-docker

# .PHONY: docker-build-nrf-docker-ci
# docker-build-nrf-docker-ci:	## 🏗️Build nrf-docker-ci image
# 	@echo "🏗️ Building nrf-docker-ci image"
# 	docker buildx build \
# 	--tag tigitlabs-nrf-docker-ci:local \
# 	--build-arg BASE_IMAGE="tigitlabs-nrf-docker:local" \
# 	--progress plain \
# 	--file .devcontainer/nrf-docker/ci.Dockerfile .devcontainer/nrf-docker

# .PHONY: docker-build-nrf-codespace
# docker-build-nrf-codespace:	## 🏗️Build nrf-codespace image
# 	@echo "🏗️ Building nrf-codespace image"
# 	docker buildx build \
# 	--tag tigitlabs-nrf-codespace:local \
# 	--build-arg BASE_IMAGE="tigitlabs-nrf-docker:local" \
# 	--progress plain \
# 	--file .devcontainer/nrf-codespace/Dockerfile .devcontainer/nrf-codespace

.PHONY: docker-build-all
docker-build-all:	## 🏗️Build all images
	@echo "🏗️ Building all images"
	@make docker-build-base-ubuntu
	@make docker-build-nrf-docker
	@make docker-build-nrf-docker-ci
	@make docker-build-nrf-codespace

##@ ✅ Tests
.PHONY: test-nrf-docker
test-nrf-docker:		## ✅Test nrf-docker
	echo "🧪 Check if west is installed"
	docker run --rm tigitlabs-nrf-docker:local west --version
	echo "🧪 Check if clang-format is installed"
	docker run --rm tigitlabs-nrf-docker:local clang-format --version
	echo "🧪 Checking if nrfutil is installed and working"
	docker run --rm tigitlabs-nrf-docker:local nrfutil --version

.PHONY: test-nrf-docker-ci
test-nrf-docker-ci:		## ✅Test nrf-docker-ci
	echo "🧪 Check if west is installed"
	docker run --rm tigitlabs-nrf-docker-ci:local west --version
	echo "🧪 Testing the firmware build"
	docker run --rm --name nrf-docker-ci-dev --workdir /workspace/nrf/applications/asset_tracker_v2  tigitlabs-nrf-docker-ci:local \
	west build -b nrf9160dk_nrf9160ns --build-dir /workspace/nrf/applications/asset_tracker_v2/build -- -DEXTRA_CFLAGS="-Werror -Wno-dev"

.PHONY: test-nrf-codespace
test-nrf-codespace:		## ✅Test-nrf-codespace
	echo "🧪 Check if west is installed"
	docker run --rm tigitlabs-nrf-docker:local west --version
	echo "🧪 Check if clang-format is installed"
	docker run --rm tigitlabs-nrf-docker:local clang-format --version
	echo "🧪 Checking if nrfutil is installed and working"
	docker run --rm tigitlabs-nrf-docker:local nrfutil --version
	echo "🧪 Checking if nrfjprog is installed and working"
	docker run --rm tigitlabs-nrf-codespace:local nrfjprog --version

.PHONY: test-all
test-all:		## ✅Test all
	echo "🧪 Testing all images"
	@make test-nrf-docker
	@make test-nrf-docker-ci
	@make test-nrf-codespace

.PHONY: test-all-ci
test-all-ci:		## ✅Test all images
	echo "🧪 Build and test all images"
	@make docker-build-all
	@make test-all
