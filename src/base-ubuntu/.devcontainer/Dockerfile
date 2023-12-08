# [Choice] Ubuntu version (use jammy on local arm64/Apple Silicon): jammy, focal
ARG VARIANT="${VARIANT}"
ARG BASE_IMAGE=buildpack-deps:${VARIANT}-curl
FROM ${BASE_IMAGE}

ARG VARIANT="${VARIANT}"
ARG BASE_IMAGE=buildpack-deps:${VARIANT}-curl
ENV BASE_IMAGE="${BASE_IMAGE}"

LABEL dev.containers.features="common"
LABEL dev.containers.base_image="${BASE_IMAGE}"

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    make \
    bash-completion \
    # Clean up
    && apt-get autoremove -y && apt-get clean -y
