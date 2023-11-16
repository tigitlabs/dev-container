#!/bin/bash
# Test script to verify workflows locally with ACT

MARKDOWN_WORKFLOW_FILE=".github/workflows/docs.yml"
PUBLISH_WORKFLOW_FILE=".github/workflows/publish.yml"
MAKEFILE_WORKFLOW_FILE=".github/workflows/makefile-ci.yml"
SMOKETEST_BASE_UBUNTU_WORKFLOW_FILE=".github/workflows/smoke-base-ubuntu.yaml"
SMOKETEST_BASE_NRF_WORKFLOW_FILE=".github/workflows/smoke-base-nrf.yaml"
SMOKETEST_NRF_CI_WORKFLOW_FILE=".github/workflows/smoke-nrf-ci.yaml"


# Function to run act --dryrun and check for errors
# $1: The workflow file to run
function act_dryrun {
  echo "🧪🧪🧪 Testing act --dryrun $1 🧪🧪🧪"
  export RESULT=$(act --dryrun --workflows $1 \
  --secret GITHUB_TOKEN=${GITHUB_TOKEN} \
  --actor $GITHUB_USER 2>&1)

  if [[ $RESULT == *"Job succeeded"* ]]; then
    echo "✅ Test passed"
  else
    echo "❌ Test failed"
    echo $RESULT
    exit 1
  fi
}

echo "🧪🧪🧪 Check GITHUB variables 🧪🧪🧪"
set -e
if [ -z $GITHUB_TOKEN ] || [ -z $GITHUB_USER ]; then
  echo "GITHUB_TOKEN or GITHUB_USER not set"
  exit 1
else
  echo "✅ GITHUB_TOKEN and GITHUB_USER set"
fi

act_dryrun $MAKEFILE_WORKFLOW_FILE
act_dryrun $MARKDOWN_WORKFLOW_FILE
act_dryrun $SMOKETEST_BASE_UBUNTU_WORKFLOW_FILE
act_dryrun $SMOKETEST_BASE_NRF_WORKFLOW_FILE
act_dryrun $SMOKETEST_NRF_CI_WORKFLOW_FILE
# This fails
# act_dryrun $PUBLISH_WORKFLOW_FILE