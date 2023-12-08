
ARG BASE_IMAGE="${BASE_IMAGE}"
ARG TAG="${TAG}"
FROM ${BASE_IMAGE}:${TAG}

ARG BASE_IMAGE="${BASE_IMAGE}"
ARG TAG="${TAG}"
ENV BASE_IMAGE="${BASE_IMAGE}"
ENV TAG="${TAG}"

ARG sdk_nrf_branch="${sdk_nrf_branch}"
ARG nrf_toolchain_version="${nrf_toolchain_version}"
ARG sdk_dir=/home/vscode/sdk-nrf-${nrf_toolchain_version}

LABEL dev.containers.features="common"
LABEL dev.containers.features="nrf-tools"
LABEL dev.containers.base_image="${BASE_IMAGE}:${TAG}"
LABEL nrf.toolchain.version="${nrf_toolchain_version}"

USER vscode
WORKDIR /home/vscode

# ClangFormat
RUN wget -qO- "https://raw.githubusercontent.com/nrfconnect/sdk-nrf/${sdk_nrf_branch}/.clang-format" > /home/vscode/.clang-format

# Install nrfutil and toolchain
RUN  wget -q https://developer.nordicsemi.com/.pc-tools/nrfutil/x64-linux/nrfutil && \
    sudo mv nrfutil /usr/local/bin && \
    sudo chmod +x /usr/local/bin/nrfutil && \
    nrfutil install toolchain-manager && \
    nrfutil install completion && \
    nrfutil install nrf5sdk-tools && \
    nrfutil toolchain-manager install --ncs-version "${nrf_toolchain_version}"

# Install nRF Connect SDK
WORKDIR /home/vscode/ncs
SHELL ["nrfutil","toolchain-manager","launch","/bin/bash","--","-c"]
RUN <<EOT
    west init -m https://github.com/nrfconnect/sdk-nrf --mr ${sdk_nrf_branch} ./${nrf_toolchain_version}
    cd ./${nrf_toolchain_version}
    west update --narrow -o=--depth=1
EOT

SHELL ["/bin/bash", "-c"]
COPY entry.sh /usr/local/bin/entry.sh
RUN sudo chown vscode /usr/local/bin/entry.sh && sudo chmod +x /usr/local/bin/entry.sh

WORKDIR /home/vscode