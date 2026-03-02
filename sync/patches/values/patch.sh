#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) ; readonly SCRIPT_DIR
source "${SCRIPT_DIR}"/../../_helpers.sh

cd "${REPO_DIR}"

# get the upstream sync version from vendir.yml
UPSTREAM_SYNC_VERSION=$(yq -r .directories[0].contents[0].git.ref ${REPO_DIR}/vendir.yml)

set -x
git apply "${SCRIPT_DIR_REL}/_values.yaml.patch"
cp "${SCRIPT_DIR_REL}/manifests/values.schema.json" "${CHART_DIR}"
{ set +x; } 2>/dev/null

sed -i -E "s/IMAGE_TAG/${UPSTREAM_SYNC_VERSION}/g" "${CHART_DIR}/values.yaml"
