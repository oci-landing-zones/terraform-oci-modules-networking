#!/usr/bin/env bash
set -euo pipefail

NETWORKING_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE_DIR="${NETWORKING_REPO_ROOT}/tests/l7-foundation-subnet-contract"
TEST_TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TEST_TMP_DIR}"' EXIT

TF_DATA_DIR="${TEST_TMP_DIR}/terraform-data" terraform -chdir="${FIXTURE_DIR}" init -backend=false -input=false >/dev/null
TF_DATA_DIR="${TEST_TMP_DIR}/terraform-data" terraform -chdir="${FIXTURE_DIR}" validate -no-color >/dev/null
TF_DATA_DIR="${TEST_TMP_DIR}/terraform-data" terraform -chdir="${FIXTURE_DIR}" plan -refresh=false -lock=false -input=false -no-color >/dev/null

if TF_DATA_DIR="${TEST_TMP_DIR}/terraform-data" terraform -chdir="${FIXTURE_DIR}" plan -var-file=invalid.tfvars -refresh=false -lock=false -input=false -no-color >/dev/null 2>&1; then
  echo "The L7 subnet dependency contract accepted an invalid subnet id type." >&2
  exit 1
fi

echo "L7 foundation subnet contract checks passed"
