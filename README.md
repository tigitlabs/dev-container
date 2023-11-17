# dev-container

Repo to maintain base Github dev containers and codespaces

## Tools

### ACT

You have to run the act commands in the vscode terminal. When you run the act command in the bash shell it will not work.

### tmate

<https://dev.to/github/debug-your-github-actions-via-ssh-by-using-tmate-1hd6>

## ubuntu-base

<https://github.com/devcontainers/images/tree/main/src/base-ubuntu>
Legacy, this contains the Dockerfile for the base image:
   <https://github.com/microsoft/vscode-dev-containers/tree/main/containers/ubuntu>

## nrf-docker

<https://devzone.nordicsemi.com/guides/nrf-connect-sdk-guides/b/getting-started/posts/build-ncs-application-firmware-images-using-docker>

## nrf-docker-ci

## nrf-codespace

Based on this [repo from Nordic](https://github.com/NordicPlayground/nrf-docker)

## Setup for Host Machine

### SSH Agent

This is only required if you want to use SSH to authenticate with Github.
If you are using HTTPS, then you can skip this section.

When creating the devcontainer, and you want to use the ssh agent forwarding,
for Github, you need to add the following to your `~/.ssh/config` file:

```bash
# Github
Host github.com
  HostName github.com
  PreferredAuthentications publickey
  User git
  AddKeysToAgent yes
  IdentityFile ~/.ssh/id_rsa
  ForwardAgent yes
```

In your `~/.bashrc` file add the following:

```bash
# SSH Agent
# https://code.visualstudio.com/remote/advancedcontainers/sharing-git-credentials
if [ -z "$SSH_AUTH_SOCK" ]; then
   # Check for a currently running instance of the agent
   RUNNING_AGENT="`ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]'`"
   if [ "$RUNNING_AGENT" = "0" ]; then
        # Launch a new instance of the agent
        ssh-agent -s &> $HOME/.ssh/ssh-agent
   fi
   eval `cat $HOME/.ssh/ssh-agent`
fi
```
