# Based on: https://github.com/microsoft/vscode-dev-containers/tree/main/containers/ubuntu
# nrf-docker
ARG BASE_IMAGE=ghcr.io/tigitlabs/nrf-docker:latest
FROM ${BASE_IMAGE}

ENTRYPOINT [ "nrfutil", "toolchain-manager", "launch", "/bin/bash", "--", "/root/entry.sh" ]
