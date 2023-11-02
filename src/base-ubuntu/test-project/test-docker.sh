#!/bin/bash
cd $(dirname "$0")

source test-utils.sh vscode

# Check package versions
check "make" make --version

# Report result
reportResults
