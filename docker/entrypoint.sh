#!/bin/bash
# Disclaimer: AI was used to help generate this script. This script was reviewed and edited by Mitchell Moore.
set -e

if [ -z "${GH_PAT}" ] || [ -z "${GH_OWNER}" ] || [ -z "${GH_REPO}" ]; then
    echo "ERROR: Missing required environment variables (GH_PAT, GH_OWNER, or GH_REPO)."
    exit 1
fi

echo "Retrieving dynamic registration token from GitHub..."

REG_TOKEN=$(curl -sX POST \
  -H "Authorization: token ${GH_PAT}" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/${GH_OWNER}/${GH_REPO}/actions/runners/registration-token \
  | jq -r .token)

if [ "$REG_TOKEN" = "null" ] || [ -z "$REG_TOKEN" ]; then
    echo "ERROR: Failed to retrieve a registration token from GitHub"
    exit 1
fi

./config.sh \
  --url "https://github.com/$(echo "${GH_OWNER}" | tr -d ' ')/$(echo "${GH_REPO}" | tr -d ' ')" \
  --token "${REG_TOKEN}" \
  --name "k8s-runner-$(hostname)" \
  --work "_work" \
  --unattended \
  --replace

cleanup() {
    echo "Caught removal signal! Deregistering runner from GitHub..."
    REMOVE_TOKEN=$(curl -sX POST \
      -H "Authorization: token ${GH_PAT}" \
      -H "Accept: application/vnd.github+json" \
      https://api.github.com/repos/${GH_OWNER}/${GH_REPO}/actions/runners/remove-token \
      | jq -r .token)
    ./config.sh remove --token "${REMOVE_TOKEN}"
}

trap 'cleanup; exit 130' INT QUIT TERM

echo "Starting GitHub actions runner..."
./run.sh &

wait $!
