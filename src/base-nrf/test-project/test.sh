#!/bin/bash
cd $(dirname "$0")

source ../../test/test-utils.sh  vscode

#### Base Image Tests ####
# Run common tests
checkCommon

check "Oh My Zsh! theme" test -e $HOME/.oh-my-zsh/custom/themes/devcontainers.zsh-theme
check "zsh theme symlink" test -e $HOME/.oh-my-zsh/custom/themes/codespaces.zsh-theme

check "git" git --version

git_version=$(git --version)
check-version-ge "git-requirement" "${git_version}" "git version 2.40.1"

check "set-git-config-user-name" sh -c "sudo git config --system user.name devcontainers"
check "gitconfig-file-location" sh -c "ls /etc/gitconfig"
check "gitconfig-contains-name" sh -c "cat /etc/gitconfig | grep 'name = devcontainers'"

check "usr-local-etc-config-does-not-exist" test ! -f "/usr/local/etc/gitconfig"
checkPythonExtension
#### Base Image Tests ####

#### nrf tools ####
check "cmake" cmake --version
check "west" west --version
check "nrfutil" nrfutil --version
check "nrfutil toolchain" nrfutil toolchain-manager list
nrf_toolchain_version=$(nrfutil toolchain-manager list | grep -oP 'v\d+\.\d+\.\d+' | awk '{print $1}')
check-version-ge "nrf toolchain version" "${nrf_toolchain_version}" "v2.5.0"
#### nrf tools ####

# Report result
reportResults
