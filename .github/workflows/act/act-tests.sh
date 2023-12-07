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
PR_MERGE_MAIN_EVENT_FILE=".github/workflows/act/event-publish-main-merged.json"

# Function to run act --dryrun and check for errors
# $1: The workflow file to run
function act_dryrun {
  echo "🧪🧪🧪 Testing act --dryrun $1 🧪🧪🧪"
  echo "🏃: act --dryrun --workflows $1 --secret GITHUB_TOKEN=\${GITHUB_TOKEN} --actor \${GITHUB_USER}"
  export RESULT=$(act --dryrun --workflows $1 \
  --secret GITHUB_TOKEN=${GITHUB_TOKEN} \
  --actor $GITHUB_USER 2>&1)

  if [[ $RESULT == *"Job succeeded"* ]]; then
    echo "✅ Test passed"
  elif [[ -z $RESULT ]]; then
    echo "⚠️ Nothing returned from act"
  else
    echo "❌ Test failed"
    echo $RESULT
    exit 1
  fi
}

#   $1: The event name. This is the name of the GitHub event that triggers the workflow.
#   $2: The workflow file. This is the path to the file that defines the workflow.
#   $3: The event file. This is the path to the file that contains the payload for the event.
function act_dryrun_event {
  EVENT=$1
  WORKFLOW=$2
  EVENT_FILE=$3
  echo "🧪🧪🧪 Testing act Event: ${EVENT} Workflow: ${WORKFLOW} with Event file: ${EVENT_FILE} 🧪🧪🧪"
  echo "🏃: act ${EVENT} --workflows $WORKFLOW --secret GITHUB_TOKEN=\${GITHUB_TOKEN} --actor \${GITHUB_USER} --dryrun --eventpath ${EVENT_FILE}"
  export RESULT=$(act ${EVENT} \
  --workflows $WORKFLOW \
  --secret GITHUB_TOKEN=${GITHUB_TOKEN} \
  --actor $GITHUB_USER \
  --dryrun \
  --eventpath ${EVENT_FILE} 2>&1)

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
  act_dryrun $PUBLISH_WORKFLOW_FILE
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
  act push --workflows $DEBUG_WORKFLOW_FILE --eventpath $PUSH_COMMIT_EVENT_FILE
  echo "🧪🧪🧪 push tag event 🧪🧪🧪"
  act push --workflows $DEBUG_WORKFLOW_FILE --eventpath $PUSH_TAG_EVENT_FILE
  echo "🧪🧪🧪 create tag event 🧪🧪🧪"
  act create --workflows $DEBUG_WORKFLOW_FILE --eventpath $CREATE_TAG_EVENT_FILE
  echo "🧪🧪🧪 PR open event 🧪🧪🧪"
  act pull_request --workflows $DEBUG_WORKFLOW_FILE --eventpath $PR_OPEN_EVENT_FILE
}

# Test the get_tags job
# On tag creation, returns the tag name
# On pull request to dev rerturn the branch name
# On pull request merge to main or dev return base branch name
function act_test_get_tags() {
  echo "🧪🧪🧪 Test PR events 🧪🧪🧪"
  # PR openend to dev
  act pull_request --workflows $PUBLISH_WORKFLOW_FILE --job get-tags --eventpath $PR_OPEN_EVENT_FILE
}


# Run tests
check_env
act_github_event
act_dryrun_all
act_dryrun_event create $PUBLISH_WORKFLOW_FILE $CREATE_TAG_EVENT_FILE
act_test_get_tags