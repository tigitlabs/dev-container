# Based on: https://github.com/microsoft/vscode-dev-containers/tree/main/containers/ubuntu
# nrf-docker

ARG BASE_IMAGE=ghcr.io/tigitlabs/ubuntu-base:latest
FROM ${BASE_IMAGE}

ARG sdk_nrf_branch=v2.4-branch
ARG toolchain_version=v2.4.1
ARG sdk_nrf_commit
ARG arch=amd64
# Exit immediately if any command fails
RUN set -e

RUN apt-get -y update && export DEBIAN_FRONTEND=noninteractive ; \
    apt-get -y upgrade && \
    apt-get -y install --no-install-recommends \
    python3-pip \
    python3-setuptools \
    clang-format \
    cmake

COPY ./entry.sh /root/entry.sh

USER vscode
RUN sudo chmod +x /root/entry.sh && \
    sudo chown -R vscode:vscode /root

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
    sudo nrfutil install toolchain-manager ; \
    nrfutil install toolchain-manager ; \
    nrfutil install search ; \
    nrfutil install completion; \
    nrfutil toolchain-manager install --ncs-version ${toolchain_version} ; \
    nrfutil toolchain-manager list

# Prepare image with a ready to use build environment
# SHELL ["nrfutil","toolchain-manager","launch","/bin/bash","--","-c"]
RUN <<EOT
    west init -m https://github.com/nrfconnect/sdk-nrf --mr ${sdk_nrf_branch} /workspace
    if [[ $sdk_nrf_commit =~ "^[a-fA-F0-9]{32}$" ]]; then
        git checkout ${sdk_nrf_commit};
    fi
    west update --narrow -o=--depth=1
    west zephyr-export
EOT
