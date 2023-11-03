ARG VARIANT="dev"
FROM ghcr.io/tigitlabs/base-ubuntu:${VARIANT}

LABEL dev.containers.features="common"
LABEL dev.containers.features="nrf-tools"

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    cmake \
    && apt-get autoremove -y && apt-get clean -y
