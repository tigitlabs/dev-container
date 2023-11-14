.DEFAULT_GOAL:=help
SHELL:=/bin/bash

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

.PHONY: github-action-smoke-base-ubuntu
github-action-smoke-base-ubuntu:	## ✅Run smoke-test for base-ubuntu
	act -W .github/workflows/smoke-base-ubuntu.yaml \
	--secret GITHUB_TOKEN=${GITHUB_TOKEN}

.PHONY: github-action-smoke-base-nrf
github-action-smoke-base-nrf:	## ✅Run smoke-test for base-nrf
	act -W .github/workflows/smoke-base-nrf.yaml \
	--secret GITHUB_TOKEN=${GITHUB_TOKEN}

.PHONY: github-action-smoke-nrf-ci
github-action-smoke-nrf-ci:	## ✅Run smoke-test for nrf-ci
	act -W .github/workflows/smoke-nrf-ci.yaml \
	--secret GITHUB_TOKEN=${GITHUB_TOKEN}

.PHONY: github-action-smoke-nrf-devcontainer
github-action-smoke-nrf-devcontainer:	## ✅Run smoke-test for nrf-devcontainer
	act -W .github/workflows/smoke-nrf-devcontainer.yaml \
	--secret GITHUB_TOKEN=${GITHUB_TOKEN}

.PHONY: github-action-smoke-test
github-action-smoke-test:	## ✅Run smoke-test for all images
	make github-action-smoke-base-ubuntu
	make github-action-smoke-base-nrf
	make github-action-smoke-nrf-ci
	make github-action-smoke-nrf-devcontainer

.PHONY: github-action-makefile-ci
github-action-makefile-ci:	## ✅Run makefile-ci
	act -W .github/workflows/makefile-ci.yml \
	--secret GITHUB_TOKEN=${GITHUB_TOKEN}

.PHONY: github-action-markdown-lint
github-action-markdown-lint:	## ✅Run markdown-lint
	act -W .github/workflows/docs.yml \
	--secret GITHUB_TOKEN=${GITHUB_TOKEN}

.PHONY: github-action-publish
github-action-publish:	## ✅Build and publish all images
	act -W .github/workflows/publish.yml \
	-s GITHUB_TOKEN="${GITHUB_TOKEN}" \
	--eventpath .github/workflows/act/event-publish-main.json


##@ 🐋 devcontainer Build

.PHONY: build-base-ubuntu
build-base-ubuntu:	## 🏗️Build ubuntu-base image
	@echo "🏗️ Building base-ubuntu image"	
	export VARIANT="jammy" && \
	./.github/actions/smoke-test/build.sh base-ubuntu
	@echo "🧪 Test ubuntu-base image"
	@./.github/actions/smoke-test/test.sh base-ubuntu

.PHONY: build-base-nrf
build-base-nrf:	## 🏗️Build nrf-base image
	@echo "🏗️ Building base-nrf image"	
	export VARIANT="dev" && \
	./.github/actions/smoke-test/build.sh base-nrf
	@echo "🧪 Test nrf-base image"
	@./.github/actions/smoke-test/test.sh base-nrf

.PHONY: build-nrf-ci
build-nrf-ci:	## 🏗️Build nrf-ci image
	@echo "🏗️ Building nrf-ci image"
	export VARIANT="dev" && \
	./.github/actions/smoke-test/build.sh nrf-ci
	@echo "🧪 Test nrf-ci image"
	@./.github/actions/smoke-test/test.sh nrf-ci

.PHONY: build-nrf-devcontainer
build-nrf-devcontainer:	## 🏗️Build nrf-ci image
	@echo "🏗️ Building nrf-devcontainer image"
	export VARIANT="dev" && \
	./.github/actions/smoke-test/build.sh nrf-devcontainer
	@echo "🧪 Test nrf-devcontainer image"
	@./.github/actions/smoke-test/test.sh nrf-devcontainer

.PHONY: build-all
build-all:	## 🏗️Build all images
	@echo "🏗️ Building all images"
	@make build-base-ubuntu
	@make build-base-nrf

##@ 🐋 devcontainer attach

.PHONY: attach-base-nrf
attach-base-nrf:	## bring up base-nrf container and attach shell
	@echo "🐋 Bring-up base-nrf container"
	@export VARIANT=dev && \
	devcontainer up \
	--workspace-folder src/base-nrf \
	--remove-existing-container \
	--id-label debug-container=base-nrf
	devcontainer exec --id-label debug-container=base-nrf /bin/bash

.PHONY: attach-nrf-ci
attach-nrf-ci:	## bring up nrf-ci container and attach shell
	@echo "🐋 Bring-up nrf-ci container"
	export VARIANT="dev" && \
	devcontainer up \
	--workspace-folder src/nrf-ci/ \
	--id-label debug-container=nrf-ci
	devcontainer exec --id-label debug-container=nrf-ci /bin/bash

.PHONY: makefile-ci
makefile-ci:	## 🧪 Run all makefile targets
	@make help
	@make github-action-list
	@make build-all
	@make github-action-smoke-test
	@make github-action-markdown-lint
	@make github-action-makefile-ci
