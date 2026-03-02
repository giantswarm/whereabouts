#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) ; readonly SCRIPT_DIR
source "${SCRIPT_DIR}"/../../_helpers.sh

cd "${REPO_DIR}"

set -x
git apply "${SCRIPT_DIR_REL}/_values.yaml.patch"
cp "${SCRIPT_DIR_REL}/manifests/values.schema.json" "${CHART_DIR}"

{ set +x; } 2>/dev/null
