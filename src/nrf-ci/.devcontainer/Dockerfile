ARG VARIANT="dev"
FROM ghcr.io/tigitlabs/base-nrf:${VARIANT}

LABEL dev.containers.features="common"
LABEL dev.containers.features="nrf-tools"
LABEL dev.containers.features="nrf-ci"

USER vscode
WORKDIR /home/vscode
# COPY entry.sh /root/entry.sh
COPY entry.sh entry.sh
RUN sudo chown vscode /home/vscode/entry.sh && sudo chmod +x /home/vscode/entry.sh
# SHELL ["nrfutil","toolchain-manager","launch","/bin/bash","--","-c"]
ENTRYPOINT [ "nrfutil", "toolchain-manager", "launch", "/bin/bash", "--", "/home/vscode/entry.sh" ]
