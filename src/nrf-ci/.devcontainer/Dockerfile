ARG VARIANT="dev"
FROM ghcr.io/tigitlabs/base-nrf:${VARIANT}

LABEL dev.containers.features="common"
LABEL dev.containers.features="nrf-tools"
LABEL dev.containers.features="nrf-ci"

USER vscode
WORKDIR /home/vscode

ENTRYPOINT [ "nrfutil", "toolchain-manager", "launch", "/bin/bash", "--", "/usr/local/bin/entry.sh" ]
