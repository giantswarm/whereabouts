#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) ; readonly SCRIPT_DIR
source "${SCRIPT_DIR}"/../../_helpers.sh

cd "${REPO_DIR}"

echo "Syncing kube-linter config"

cp -r "${SCRIPT_DIR}"/manifests/kube-linter.yaml "${CHART_DIR}"/.kube-linter.yaml
