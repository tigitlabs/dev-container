
ARG VARIANT="dev"
FROM ghcr.io/tigitlabs/base-nrf:${VARIANT}

LABEL dev.containers.features="common"
LABEL dev.containers.features="nrf-tools"
LABEL dev.containers.features="nrf-dev-container"

ARG NORDIC_COMMAND_LINE_TOOLS_VERSION="10-23-2/nrf-command-line-tools-10.23.2"
USER vscode
WORKDIR /home/vscode

# Nordic command line tools
# Releases: https://www.nordicsemi.com/Products/Development-tools/nrf-command-line-tools/download
RUN <<EOT
    NCLT_BASE=https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/desktop-software/nrf-command-line-tools/sw/versions-10-x-x
    NCLT_URL="${NCLT_BASE}/${NORDIC_COMMAND_LINE_TOOLS_VERSION}_linux-amd64.tar.gz"
    mkdir tmp && cd tmp
    wget -qO - "${NCLT_URL}" | tar --no-same-owner -xz
    # Install nrf-command-line-tools
    sudo cp -r ./nrf-command-line-tools /opt
    sudo ln -s /opt/nrf-command-line-tools/bin/nrfjprog /usr/local/bin/nrfjprog
    sudo ln -s /opt/nrf-command-line-tools/bin/mergehex /usr/local/bin/mergehex
    # Install included JLink
    sudo mkdir /opt/SEGGER
    sudo tar xzf JLink_*.tgz -C /opt/SEGGER
    sudo mv /opt/SEGGER/JLink* /opt/SEGGER/JLink
    cd .. && rm -rf tmp ;
EOT
