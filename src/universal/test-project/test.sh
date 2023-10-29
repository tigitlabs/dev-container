#!/bin/bash
cd $(dirname "$0")

source test-utils.sh codespace

# Run common tests
checkCommon

check "git" git --version

git_version=$(git --version)
check-version-ge "git-requirement" "${git_version}" "git version 2.40.1"

check "set-git-config-user-name" sh -c "sudo git config --system user.name devcontainers"
check "gitconfig-file-location" sh -c "ls /etc/gitconfig"
check "gitconfig-contains-name" sh -c "cat /etc/gitconfig | grep 'name = devcontainers'"

check "usr-local-etc-config-does-not-exist" test ! -f "/usr/local/etc/gitconfig"

# Check Python
check "python" python --version
check "python3" python3 --version
check "pip" pip --version
check "pip3" pip3 --version
check "pipx" pipx --version
check "pylint" pylint --version
check "flake8" flake8 --version
check "autopep8" autopep8 --version
check "yapf" yapf --version
check "mypy" mypy --version
check "pydocstyle" pydocstyle --version
check "bandit" bandit --version
check "virtualenv" virtualenv --version
count=$(ls /usr/local/python | wc -l)
expectedCount=3 # 2 version folders + 1 current folder which links to either one of the version
checkVersionCount "two versions of python are present" $count $expectedCount
echo $(echo "python versions" && ls -a /usr/local/python)
echo $(echo "pip list" pip list)

# Check Python packages
check "numpy" python -c "import numpy; print(numpy.__version__)"
check "pandas" python -c "import pandas; print(pandas.__version__)"
check "scipy" python -c "import scipy; print(scipy.__version__)"
check "matplotlib" python -c "import matplotlib; print(matplotlib.__version__)"
check "seaborn" python -c "import seaborn; print(seaborn.__version__)"
check "scikit-learn" python -c "import sklearn; print(sklearn.__version__)"
check "torch" python -c "import torch; print(torch.__version__)"
check "requests" python -c "import requests; print(requests.__version__)"

# Node.js
check "node" node --version
check "nvm" bash -c ". /usr/local/share/nvm/nvm.sh && nvm --version"
check "nvs" bash -c ". /usr/local/nvs/nvs.sh && nvs --version"
check "yarn" yarn --version
check "npm" npm --version
count=$(ls /usr/local/share/nvm/versions/node | wc -l)
expectedCount=2
checkVersionCount "two versions of node are present" $count $expectedCount
echo $(echo "node versions" && ls -a /usr/local/share/nvm/versions/node)
checkBundledNpmVersion "default" "9.8.0"
checkBundledNpmVersion "18" "9.8.1"

# conda
check "conda" conda --version

# Check utilities
checkOSPackages "additional-os-packages" vim xtail software-properties-common
check "gh" gh --version
check "git-lfs" git-lfs --version
check "docker" docker --version

# Check expected shells
check "bash" bash --version
check "fish" fish --version
check "zsh" zsh --version

# Ensures nvm works in a Node Project
check "default-node-version" bash -c "node --version | grep 20."
check "default-node-location" bash -c "which node | grep /home/codespace/nvm/current/bin"
check "oryx-build-node-projectr" bash -c "oryx build ./sample/node"
check "oryx-configured-current-node-version" bash -c "ls -la /home/codespace/nvm/current | grep /opt/nodejs"
check "nvm-install-node" bash -c ". /usr/local/share/nvm/nvm.sh && nvm install 8.0.0"
check "nvm-works-in-node-project" bash -c "node --version | grep v8.0.0"
check "default-node-location-remained-same" bash -c "which node | grep /home/codespace/nvm/current/bin"

# Test patches

ls -la /home/codespace

## Python - current
checkPythonPackageVersion "python" "setuptools" "65.5.1"
checkPythonPackageVersion "python" "requests" "2.31.0"

## Python 3.9
checkPythonPackageVersion "/usr/local/python/3.9.*/bin/python" "setuptools" "65.5.1"

## Conda Python
checkCondaPackageVersion "requests" "2.31.0"
checkCondaPackageVersion "cryptography" "41.0.4"
checkCondaPackageVersion "pyopenssl" "23.2.0"
checkCondaPackageVersion "urllib3" "1.26.17"

## Test Conda
check "conda-update-conda" bash -c "conda update -y conda"
check "conda-install-tensorflow" bash -c "conda create --name test-env -c conda-forge --yes tensorflow"
check "conda-install-pytorch" bash -c "conda create --name test-env -c conda-forge --yes pytorch"

# Report result
reportResults
