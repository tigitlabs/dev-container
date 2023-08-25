# Based on: https://github.com/microsoft/vscode-dev-containers/tree/main/containers/ubuntu
# nrf-docker
ARG VARIANT=ubuntu-22.04
# FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}
FROM ghcr.io/tigitlabs/ubuntu-base

ARG sdk_nrf_branch=v2.4-branch
ARG toolchain_version=v2.4.1
ARG sdk_nrf_commit
ARG NORDIC_COMMAND_LINE_TOOLS_VERSION="10-23-0/nrf-command-line-tools-10.23.0"
ARG arch=amd64

# Exit immediately if any command fails
RUN set -e

RUN apt-get -y update && export DEBIAN_FRONTEND=noninteractive ; \
    apt-get -y upgrade && \
    apt-get -y install --no-install-recommends \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    python3-dev \
    python3-venv \
    clang-format \
    cmake

USER vscode
WORKDIR /workspace
# ClangFormat
RUN wget -qO- https://raw.githubusercontent.com/nrfconnect/sdk-nrf/${sdk_nrf_branch}/.clang-format > /workspace/.clang-format

# pip dependecies
RUN sudo pip install --upgrade pip && \
    sudo pip install --upgrade setuptools && \
    sudo pip install west

# Install toolchain
# Make nrfutil install in a shared location, because when used with GitHub
# Actions, the image will be launched with the home dir mounted from the local
# checkout.
RUN wget -q https://developer.nordicsemi.com/.pc-tools/nrfutil/x64-linux/nrfutil ; \
    sudo mv nrfutil /usr/local/bin ; \
    sudo chmod +x /usr/local/bin/nrfutil ; \
    nrfutil install toolchain-manager ; \
    nrfutil install toolchain-manager search ; \
    nrfutil toolchain-manager install --ncs-version ${toolchain_version} ; \
    nrfutil toolchain-manager list

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
