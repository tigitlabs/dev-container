# Dockerfile from this repository is used to build the image
# Only difference is that the image is based on devcontainers/base:bullseye for better compatibility with GitHub Codespaces
# https://github.com/NordicPlayground/nrf-docker
#FROM mcr.microsoft.com/devcontainers/base:bullseye

FROM tigitlabs/ubuntu-base:latest

WORKDIR /workdir

ARG sdk_nrf_branch=v2.4-branch
ARG toolchain_version=v2.4.1
ARG sdk_nrf_commit
ARG NORDIC_COMMAND_LINE_TOOLS_VERSION="10-23-0/nrf-command-line-tools-10.23.0"
ARG arch=amd64

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install \
    wget \
    unzip \
    git \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    python3-dev \
    python3-venv \
    clang-format

# PIP dependencies
RUN pip install --upgrade pip && \
    pip install --upgrade setuptools && \
    pip install install west

# Install toolchain
# Make nrfutil install in a shared location, because when used with GitHub
# Actions, the image will be launched with the home dir mounted from the local
# checkout.
ENV NRFUTIL_HOME=/usr/local/share/nrfutil
RUN wget -q https://developer.nordicsemi.com/.pc-tools/nrfutil/x64-linux/nrfutil ; \
    mv nrfutil /usr/local/bin ; \
    chmod +x /usr/local/bin/nrfutil ; \
    nrfutil install toolchain-manager ; \
    nrfutil install toolchain-manager search ; \
    nrfutil toolchain-manager install --ncs-version ${toolchain_version} ; \
    nrfutil toolchain-manager list

# ClangFormat
#
RUN wget -qO- https://raw.githubusercontent.com/nrfconnect/sdk-nrf/${sdk_nrf_branch}/.clang-format > /workdir/.clang-format

# Nordic command line tools
# Releases: https://www.nordicsemi.com/Products/Development-tools/nrf-command-line-tools/download
RUN NCLT_BASE=https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/desktop-software/nrf-command-line-tools/sw/versions-10-x-x ; \
    echo "Host architecture: $arch" ; \
    case $arch in \
        "amd64") \
            NCLT_URL="${NCLT_BASE}/${NORDIC_COMMAND_LINE_TOOLS_VERSION}_linux-amd64.tar.gz" ;; \
        "arm64") \
            NCLT_URL="${NCLT_BASE}/${NORDIC_COMMAND_LINE_TOOLS_VERSION}_linux-arm64.tar.gz" ;; \
    esac ; \
    echo "NCLT_URL=${NCLT_URL}" ; \
    if [ ! -z "$NCLT_URL" ] ; then \
        echo "Installing nRF Command Line Tools" ; \
        mkdir tmp && cd tmp ; \
        wget -qO - "${NCLT_URL}" | tar --no-same-owner -xz ; \
        # Install included JLink
        mkdir /opt/SEGGER ; \
        tar xzf JLink_*.tgz -C /opt/SEGGER ; \
        mv /opt/SEGGER/JLink* /opt/SEGGER/JLink ; \
        # Install nrf-command-line-tools
        cp -r ./nrf-command-line-tools /opt ; \
        ln -s /opt/nrf-command-line-tools/bin/nrfjprog /usr/local/bin/nrfjprog ; \
        ln -s /opt/nrf-command-line-tools/bin/mergehex /usr/local/bin/mergehex ; \
        cd .. && rm -rf tmp ; \
        nrfutil help ; \
    else \
        echo "Skipping nRF Command Line Tools (not available for $arch)" ; \
        exit 1 ; \
    fi

# Prepare image with a ready to use build environment
SHELL ["nrfutil","toolchain-manager","launch","/bin/bash","--","-c"]

RUN west init -m https://github.com/nrfconnect/sdk-nrf --mr ${sdk_nrf_branch} . ; \
    if [[ $sdk_nrf_commit =~ "^[a-fA-F0-9]{32}$" ]] ; \
    then \
        git checkout ${sdk_nrf_commit} ; \
    fi ; \
    west update --narrow -o=--depth=1

COPY ./entry.sh /root/entry.sh
RUN chmod +x /root/entry.sh

# Adding permission to non-root user from the the base image
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN chown -R $USERNAME:$USER_GID /root/ \
    && chown -R $USERNAME:$USER_GID /workdir/ \
    && chown -R $USERNAME:$USER_GID $NRFUTIL_HOME

# Launch into build environment with the passed arguments
# Currently this is not supported in GitHub Actions
# See https://github.com/actions/runner/issues/1964
ENTRYPOINT [ "nrfutil", "toolchain-manager", "launch", "/bin/bash", "--", "/root/entry.sh" ]
