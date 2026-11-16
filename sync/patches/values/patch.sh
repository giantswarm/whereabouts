#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) ; readonly SCRIPT_DIR
source "${SCRIPT_DIR}"/../../_helpers.sh

# get the upstream sync version from vendir.yml
UPSTREAM_SYNC_VERSION=$(yq -r .directories[0].contents[0].git.ref "${REPO_DIR}"/vendir.yml)

set -x
git apply "${SCRIPT_DIR}/_values.yaml.patch"
{ set +x; } 2>/dev/null

sed -i -E "s/IMAGE_TAG/${UPSTREAM_SYNC_VERSION}/g" "${VALUES_YAML}"

# Generate schema.
echo "Generating values schema..."
if ! helm plugin list | grep -q values-schema-json; then
  helm plugin install https://github.com/losisin/helm-values-schema-json.git --verify=false || true
fi
helm schema -f "${VALUES_YAML}" -o "${CHART_DIR}"/values.schema.json
