
ARG BASE_IMAGE="${BASE_IMAGE}"
FROM ${BASE_IMAGE}

LABEL dev.containers.features="common"
LABEL dev.containers.features="nrf-tools"
LABEL dev.containers.features="nrf-ci"

USER vscode
WORKDIR /home/vscode

ENTRYPOINT [ "nrfutil", "toolchain-manager", "launch", "/bin/bash", "--", "/usr/local/bin/entry.sh" ]
