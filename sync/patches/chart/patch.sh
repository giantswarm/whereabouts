#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) ; readonly SCRIPT_DIR
source "${SCRIPT_DIR}"/../../_helpers.sh

echo "Updating Chart.yaml"

cd "${SCRIPT_DIR}"

# we need to get the current version of the chart in order to
# reset it after copying Chart.yaml over.

# we retrieve this from the github api because the local chart has now been vendored.
CURRENT_CHART_VERSION=$(curl -s https://api.github.com/repos/giantswarm/whereabouts/releases/latest | jq -r .name)
# remove leading 'v' if present
CURRENT_CHART_VERSION="${CURRENT_CHART_VERSION#v}"

# we need to set the appVersion field in Chart.yaml to match the
# version being synced from upstream.

# get the upstream sync version from vendir.yml
UPSTREAM_SYNC_VERSION=$(yq -r .directories[0].contents[0].git.ref ${REPO_DIR}/vendir.yml)
# strip leading 'v' if present
UPSTREAM_SYNC_VERSION_STRIPPED="${UPSTREAM_SYNC_VERSION#v}"

set -x
cp manifests/Chart.yaml "${CHART_DIR}"/Chart.yaml
{ set +x; } 2>/dev/null

# set the app version in Chart.yaml
sed -i -E "s/APP_VERSION_PLACEHOLDER/${UPSTREAM_SYNC_VERSION_STRIPPED}/g" "${CHART_DIR}/Chart.yaml"

# reset the version in Chart.yaml
sed -i -E "s/CHART_VERSION_PLACEHOLDER/${CURRENT_CHART_VERSION}/g" "${CHART_DIR}/Chart.yaml"
