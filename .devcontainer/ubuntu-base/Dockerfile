FROM ubuntu:22.04
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*
# Add non-root user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd \
  --uid $USER_UID \
  --gid $USER_GID \
  --create-home \
  --shell /bin/bash \
  $USERNAME
