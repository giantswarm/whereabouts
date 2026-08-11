#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) ; readonly SCRIPT_DIR
source "${SCRIPT_DIR}"/../../_helpers.sh

cd "${REPO_DIR}"

# prepare the CRD dependency chart
cp -r "${SCRIPT_DIR}"/manifests/* "${CHART_DIR}"
mkdir "${CRD_CHART_DIR}"/templates -p || true

# copy the CRDs from the vendored directory to the CRD dependency chart
cp "${VENDIR_SYNC_DIR}"/crds/* "${CRD_CHART_DIR}"/templates/

# update the crd Chart.yaml if the CRDs have changed
CRDS_CHANGED=0

# add annotation to ensure helm doesn't delete CRDs
for crd in "${CRD_CHART_DIR}"/templates/*; do
    # this command ensures that the annotations field exists and then adds the helm annotation. it does not remove any existing annotations.
    yq eval '.metadata.annotations = (.metadata.annotations // {} ) | .metadata.annotations += {"helm.sh/resource-policy": "keep"}' -i "${crd}"
done

# check for updated or new CRDs. we compare against the default branch and not
# against HEAD because the renovate artifact update deletes the vendored files.
BASE_REF="origin/main"
if ! git rev-parse --verify --quiet "${BASE_REF}" > /dev/null; then
    BASE_REF="main"
fi

# mark restored and new CRDs as intended additions so that git diff sees them
git add --intent-to-add "${CRD_CHART_DIR}"/templates/

if ! git diff --quiet "${BASE_REF}" -- "${CRD_CHART_DIR}"/templates/; then
    CRDS_CHANGED=1
fi

if [[ $CRDS_CHANGED -eq 1 ]]; then
    # CRDs have changed in this release, set the CRD chart version to match the upstream version we're syncing against
    CRD_CHART_VERSION=$(yq -r .directories[0].contents[0].git.ref "${REPO_DIR}"/vendir.yml)
    # remove leading 'v' if present
    CRD_CHART_VERSION="${CRD_CHART_VERSION#v}"
else
    # no change to CRDs, ensure the CRD chart version is not bumped by setting it to the current published version
    CRD_CHART_VERSION=$(curl --silent https://raw.githubusercontent.com/giantswarm/whereabouts/refs/heads/main/helm/whereabouts/charts/whereabouts-crds/Chart.yaml | yq .version -r)
fi

# curl exits 0 on an http error, so a failed request gives us an empty or null version
if [[ -z "${CRD_CHART_VERSION}" || "${CRD_CHART_VERSION}" == "null" ]]; then
    echo "unable to determine the CRD chart version; aborting."
    exit 1
fi

# update the crd chart version
sed -i -E "s/^(version: ).*/\1${CRD_CHART_VERSION}/" "${CRD_CHART_DIR}/Chart.yaml"

# replace the placeholder in the main chart's dependencies
sed -i -E "s/CRD_VERSION_PLACEHOLDER/${CRD_CHART_VERSION}/" "${CHART_DIR}/Chart.yaml"
