
ARG BASE_IMAGE="${BASE_IMAGE}"
ARG TAG="${TAG}"
FROM ${BASE_IMAGE}:${TAG}

ARG BASE_IMAGE="${BASE_IMAGE}"
ARG TAG="${TAG}"
ENV BASE_IMAGE="${BASE_IMAGE}"
ENV TAG="${TAG}"

LABEL dev.containers.features="common"
LABEL dev.containers.features="nrf-tools"
LABEL dev.containers.features="nrf-ci"
LABEL dev.containers.base_image="${BASE_IMAGE}":"${TAG}"

USER vscode
WORKDIR /home/vscode

ENTRYPOINT [ "nrfutil", "toolchain-manager", "launch", "/bin/bash", "--", "/usr/local/bin/entry.sh" ]
