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

##@ Github Actions - ACT - Smoke Test

.PHONY: github-action-smoke-base-ubuntu
github-action-smoke-base-ubuntu:	## ✅Run smoke-test for base-ubuntu
	act -W .github/workflows/smoke-base-ubuntu.yaml \
	--secret GITHUB_TOKEN=${GITHUB_TOKEN}

.PHONY: github-action-smoke-test
github-action-smoke-test:	## ✅Run smoke-test for all images
	make github-action-smoke-base-ubuntu

.PHONY: github-action-makefile-ci
github-action-makefile-ci:	## ✅Run makefile-ci
	act -W .github/workflows/makefile-ci.yml \
	--secret GITHUB_TOKEN=${GITHUB_TOKEN}

.PHONY: github-action-docker-publish
github-action-docker-publish:	## ✅Build and publish all images
	act -W .github/workflows/docker-publish.yml \
	-s GITHUB_TOKEN="${GITHUB_TOKEN}" \
	--eventpath .github/workflows/act/event-publish-main.json


##@ 🐋 devcontainer Build

.PHONY: build-base-ubuntu
build-base-ubuntu:	## 🏗️Build ubuntu-base image
	@echo "🏗️ Building base-ubuntu image"	
	VARIANT="jammy" && echo $$VARIANT && \
	./.github/actions/smoke-test/build.sh base-ubuntu
	@echo "🧪 Test ubuntu-base image"
	@./.github/actions/smoke-test/test.sh base-ubuntu

.PHONY: build-all
build-all:	## 🏗️Build all images
	@echo "🏗️ Building all images"
	@make build-base-ubuntu

.PHONY: makefile-ci
makefile-ci:	## 🧪 Run all makefile targets
	@make help
	@make github-action-list
	@make build-all
	@make github-action-smoke-test

