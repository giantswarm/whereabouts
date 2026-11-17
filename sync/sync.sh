#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) ; readonly SCRIPT_DIR
cd "${SCRIPT_DIR}/.."
source "${SCRIPT_DIR}"/_helpers.sh

# test if requirements are installed
PROGRAMS=("yq" "jq" "vendir")
for program in "${PROGRAMS[@]}"; do
    if ! command -v "${program}" &> /dev/null; then
        echo "${program} not installed; aborting."
        exit 1
    fi
done

set -x
# Sync using vendir
vendir sync
{ set +x; } 2>/dev/null

# patches
./sync/patches/chart/patch.sh
./sync/patches/values/patch.sh
./sync/patches/helpers/patch.sh
./sync/patches/policy-exceptions/patch.sh
./sync/patches/kube-linter/patch.sh
./sync/patches/chart-label/patch.sh

# crds should always be last
./sync/patches/crds/patch.sh

if ! git diff --quiet --exit-code helm/ ; then
    echo -e "\n---------- PRINTING GIT DIFF ----------\n"
    git diff helm/
fi
