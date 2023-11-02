#!/bin/bash
# Test script for this worklfow:
# .github/workflows/release.yml
# when running this localy by triggering the workflow run this command:
# act -W .github/workflows/act.yml --actor $GITHUB_USER --secret GITHUB_TOKEN=${GITHUB_TOKEN}
# act push --workflows .github/workflows/release.yml --secret GITHUB_TOKEN=${GITHUB_TOKEN} --actor $GITHUB_USER --eventpath .github/workflows/act/event-release.json

WORKFLOW_FILE=".github/workflows/docker-publish.yml"
# Sanity check
echo "🧪🧪🧪 Sanity Check 🧪🧪🧪"
set -e
if [ -z $GITHUB_TOKEN ] ; then
  echo "GITHUB_TOKEN not set"
  exit 1
fi

if [ -z $GITHUB_USER ] ; then
  echo "GITHUB_USER not set"
  exit 1
fi

echo "🧪🧪🧪 Testing act --list 🧪🧪🧪"
act --list --workflows $WORKFLOW_FILE
echo "🧪🧪🧪 Testing act push --list 🧪🧪🧪"
act push --list --workflows $WORKFLOW_FILE

echo "🧪🧪🧪 Testing act --dryrun 🧪🧪🧪"
act --workflows $WORKFLOW_FILE --dryrun \

echo "🧪🧪🧪 Running push to main 🧪🧪🧪"
export RESULT=$(act push --workflows $WORKFLOW_FILE \
--eventpath .github/workflows/act/event-publish-main.json \
--secret GITHUB_TOKEN=${GITHUB_TOKEN} \
--actor $GITHUB_USER 2>&1)

if [[ $RESULT == *"tag=main"* ]]; then
  echo "✅ Test passed 🧪🧪🧪"
else
  echo "❌ Test failed 🧪🧪🧪"
  echo $RESULT
  exit 1
fi

echo "🧪🧪🧪 Running push tag 🧪🧪🧪"
export RESULT=$(act push --workflows $WORKFLOW_FILE \
--eventpath .github/workflows/act/event-publish-tag.json \
--secret GITHUB_TOKEN=${GITHUB_TOKEN} \
--actor $GITHUB_USER 2>&1)

if [[ $RESULT == *"tag=v0.001"* ]]; then
  echo "✅ Test passed 🧪🧪🧪"
else
  echo "❌ Test failed 🧪🧪🧪"
  echo $RESULT
  exit 1
fi