# dev-container

Repo to maintain base Github dev containers and codespaces

## Tools

### ACT

You have to run the act commands in the vscode terminal. When you run the act command in the bash shell it will not work.

## ubuntu-base

<https://github.com/devcontainers/images/tree/main/src/base-ubuntu>
Legacy, this contains the Dockerfile for the base image:
   <https://github.com/microsoft/vscode-dev-containers/tree/main/containers/ubuntu>

## nrf-docker

<https://devzone.nordicsemi.com/guides/nrf-connect-sdk-guides/b/getting-started/posts/build-ncs-application-firmware-images-using-docker>

## nrf-docker-ci

## nrf-codespace

Based on this [repo from Nordic](https://github.com/NordicPlayground/nrf-docker)

## Creating a devcontainer locally

`docker info | grep Username`
`export GITHUB_TOKEN=$(gh config get oauth_token --host github.com)`
`export GITHUB_USER=$(gh api user | jq -r '.login')`
`$echo $CR_PAT | sudo docker login ghcr.io -u $GITHUB_USER --password-stdin`
