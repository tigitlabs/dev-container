#!/bin/bash
# Test script to verify workflows locally with ACT

DEBUG_WORKFLOW_FILE=".github/workflows/debug.yml"
MARKDOWN_WORKFLOW_FILE=".github/workflows/docs.yml"
PUBLISH_WORKFLOW_FILE=".github/workflows/publish.yml"
ACT_WORKFLOW_FILE=".github/workflows/act.yml"
MAKEFILE_WORKFLOW_FILE=".github/workflows/makefile-ci.yml"
SMOKETEST_BASE_UBUNTU_WORKFLOW_FILE=".github/workflows/smoke-base-ubuntu.yaml"
SMOKETEST_BASE_NRF_WORKFLOW_FILE=".github/workflows/smoke-base-nrf.yaml"
SMOKETEST_NRF_CI_WORKFLOW_FILE=".github/workflows/smoke-nrf-ci.yaml"

# Event files
CREATE_TAG_EVENT_FILE=".github/workflows/act/event-create-tag.json"
PUSH_TAG_EVENT_FILE=".github/workflows/act/event-push-tag.json"
PUSH_COMMIT_EVENT_FILE=".github/workflows/act/event-push-commit.json"
PR_OPEN_EVENT_FILE=".github/workflows/act/event-pr-opened.json"

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

# Function to run act_dryrun for all workflows
function act_dryrun_all {
  echo "🧪🧪🧪 Testing all workflows with dryrun 🧪🧪🧪"
  act_dryrun $MAKEFILE_WORKFLOW_FILE
  act_dryrun $MARKDOWN_WORKFLOW_FILE
  act_dryrun $SMOKETEST_BASE_UBUNTU_WORKFLOW_FILE
  act_dryrun $SMOKETEST_BASE_NRF_WORKFLOW_FILE
  act_dryrun $SMOKETEST_NRF_CI_WORKFLOW_FILE
  act_dryrun $ACT_WORKFLOW_FILE
  # TODO this fails
  # act_dryrun $PUBLISH_WORKFLOW_FILE
}


function check_env() {
  echo "🧪🧪🧪 Check GITHUB variables 🧪🧪🧪"
  set -e
  if [ -z $GITHUB_TOKEN ] || [ -z $GITHUB_USER ]; then
    echo "GITHUB_TOKEN or GITHUB_USER not set"
    exit 1
  else
    echo "✅ GITHUB_TOKEN and GITHUB_USER set"
  fi
}

function act_github_event() {
  echo "🧪🧪🧪 Testing act with event files 🧪🧪🧪"
  echo "🧪🧪🧪 push commit event 🧪🧪🧪"
  act push --workflows $DEBUG_WORKFLOW_FILE --job print_event_details --eventpath $PUSH_COMMIT_EVENT_FILE
  echo "🧪🧪🧪 push tag event 🧪🧪🧪"
  act push --workflows $DEBUG_WORKFLOW_FILE --job print_event_details --eventpath $PUSH_TAG_EVENT_FILE
  echo "🧪🧪🧪 create tag event 🧪🧪🧪"
  act create --workflows $DEBUG_WORKFLOW_FILE --job print_event_details --eventpath $CREATE_TAG_EVENT_FILE
  echo "🧪🧪🧪 PR open event 🧪🧪🧪"
  act pull_request --workflows $DEBUG_WORKFLOW_FILE --job print_event_details --eventpath $PR_OPEN_EVENT_FILE
}

# Run tests
check_env
act_github_event
act_dryrun_all
