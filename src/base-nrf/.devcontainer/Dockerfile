ARG VARIANT="main"
FROM ghcr.io/tigitlabs/base-ubuntu:${VARIANT}

LABEL dev.containers.features="common"
LABEL dev.containers.features="nrf-tools"

ARG nrf_toolchain_version=v2.5.0
ARG sdk_dir=/home/vscode/sdk-nrf-${nrf_toolchain_version}

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    cmake \
    clang-format \
    && apt-get autoremove -y && apt-get clean -y

RUN pip3 install west

USER vscode
WORKDIR /home/vscode

# ClangFormat
RUN wget -qO- "https://raw.githubusercontent.com/nrfconnect/sdk-nrf/v2.5-branch/.clang-format" > /home/vscode/.clang-format

# Install toolchain
RUN  wget -q https://developer.nordicsemi.com/.pc-tools/nrfutil/x64-linux/nrfutil && \
    sudo mv nrfutil /usr/local/bin && \
    sudo chmod +x /usr/local/bin/nrfutil && \
    nrfutil install toolchain-manager && \
    nrfutil install completion && \
    nrfutil install nrf5sdk-tools && \
    nrfutil toolchain-manager install --ncs-version ${nrf_toolchain_version}
