ARG VARIANT="main"
FROM ghcr.io/tigitlabs/base-ubuntu:${VARIANT}

LABEL dev.containers.features="common"
LABEL dev.containers.features="nrf-tools"

ARG nrf_toolchain_version=v2.4.2

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    cmake \
    && apt-get autoremove -y && apt-get clean -y

USER vscode
WORKDIR /home/vscode
RUN pip3 install west

# Install toolchain
RUN  wget -q https://developer.nordicsemi.com/.pc-tools/nrfutil/x64-linux/nrfutil && \
    sudo mv nrfutil /usr/local/bin && \
    sudo chmod +x /usr/local/bin/nrfutil && \
    nrfutil install toolchain-manager && \
    nrfutil install completion && \
    nrfutil install nrf5sdk-tools && \
    nrfutil toolchain-manager install --ncs-version ${nrf_toolchain_version} && \
    nrfutil toolchain-manager list
