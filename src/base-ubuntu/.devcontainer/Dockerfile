# [Choice] Ubuntu version (use jammy on local arm64/Apple Silicon): jammy, focal
ARG VARIANT="${VARIANT}"
FROM buildpack-deps:${VARIANT}-curl

LABEL dev.containers.features="common"

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    make \
    bash-completion \
    # Clean up
    && apt-get autoremove -y && apt-get clean -y
