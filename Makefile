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

.PHONY: github-action-act-test
github-action-act-test:	## ✅Run act-test
	GITHUB_TOKEN=${GITHUB_TOKEN} && ./.github/workflows/act/act-tests.sh

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


##@ 🐋 devcontainer Build & Test

.PHONY: build-base-ubuntu
build-base-ubuntu:	## 🏗️Build ubuntu-base image
	@echo "🏗️ Building base-ubuntu image"	
	./test/pre_build.sh base-ubuntu local

.PHONY: test-base-ubuntu
test-base-ubuntu:	## 🧪Test base-ubuntu image
	@echo "🧪 Testing base-ubuntu image"
	./test/test_build.sh base-ubuntu local

.PHONY: build-base-nrf
build-base-nrf:	## 🏗️Build nrf-base image
	@echo "🏗️ Building base-nrf image"
	./test/pre_build.sh base-nrf local base-ubuntu

.PHONY: test-base-nrf
test-base-nrf:	## 🧪Test base-nrf image
	@echo "🧪 Testing base-nrf image"
	./test/test_build.sh base-nrf local

.PHONY: build-nrf-ci
build-nrf-ci:	## 🏗️Build nrf-ci image
	@echo "🏗️ Building nrf-ci image"
	./test/pre_build.sh nrf-ci local base-nrf

.PHONY: test-nrf-ci
test-nrf-ci:	## 🧪Test nrf-ci image
	@echo "🧪 Testing nrf-ci image"
	./test/test_build.sh nrf-ci local

.PHONY: build-nrf-devcontainer
build-nrf-devcontainer:	## 🏗️Build nrf-ci image
	@echo "🏗️ Building nrf-devcontainer image"
	./test/pre_build.sh nrf-devcontainer local base-nrf

.PHONY: test-nrf-devcontainer
test-nrf-devcontainer:	## 🧪Test nrf-devcontainer image
	@echo "🧪 Testing nrf-devcontainer image"
	./test/test_build.sh nrf-devcontainer local

.PHONY: build-all
build-all:	## 🏗️Build all images
	@echo "🏗️ Building all images"
	@make build-base-ubuntu
	@make build-base-nrf
	@make build-nrf-ci
	@make build-nrf-devcontainer

.PHONY: test-all
test-all:	## 🧪Test all images
	@echo "🧪 Testing all images"
	@make test-base-ubuntu
	@make test-base-nrf
	@make test-nrf-ci
	@make test-nrf-devcontainer

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

.PHONY: attach-nrf-devcontainer
attach-nrf-devcontainer:	## bring up nrf-devc container and attach shell
	@echo "🐋 Bring-up nrf-devcontainer"
	export VARIANT="dev" && \
	devcontainer up \
	--workspace-folder src/nrf-devcontainer/ \
	--id-label debug-container=nrf-devcontainer
	devcontainer exec --id-label debug-container=nrf-devcontainer /bin/bash

.PHONY: makefile-ci
makefile-ci:	## 🧪 Run all makefile targets
	@make help
	@make github-action-list
	@make github-action-act-test
	@make github-action-smoke-test
	@make github-action-markdown-lint
	@make github-action-makefile-ci
	@make build-all
	@make test-all
