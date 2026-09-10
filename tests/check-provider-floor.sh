#!/usr/bin/env bash
set -euo pipefail

NETWORKING_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE_DIR="${NETWORKING_REPO_ROOT}/tests/provider-floor"
NLB_FIXTURE_DIR="${NETWORKING_REPO_ROOT}/tests/nlb-provider-floor"
TEST_TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TEST_TMP_DIR}"' EXIT

TF_DATA_DIR="${TEST_TMP_DIR}/terraform-data" terraform -chdir="${FIXTURE_DIR}" init -upgrade -backend=false -input=false >/dev/null
TF_DATA_DIR="${TEST_TMP_DIR}/terraform-data" terraform -chdir="${FIXTURE_DIR}" validate -no-color >/dev/null
TF_DATA_DIR="${TEST_TMP_DIR}/nlb-terraform-data" terraform -chdir="${NLB_FIXTURE_DIR}" init -upgrade -backend=false -input=false >/dev/null
TF_DATA_DIR="${TEST_TMP_DIR}/nlb-terraform-data" terraform -chdir="${NLB_FIXTURE_DIR}" validate -no-color >/dev/null

echo "OCI provider floor checks passed (root 7.27.0, NLB 6.23.0)"
