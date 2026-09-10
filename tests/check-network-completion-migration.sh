#!/usr/bin/env bash
set -euo pipefail

NETWORKING_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MIGRATION_FIXTURE_DIR="${NETWORKING_REPO_ROOT}/tests/network-completion-migration"
MIGRATION_TMP_DIR="$(mktemp -d)"
BEFORE_WORK_DIR="${MIGRATION_TMP_DIR}/before"
AFTER_WORK_DIR="${MIGRATION_TMP_DIR}/after"
PLAN_FILE="${MIGRATION_TMP_DIR}/migration.tfplan"
PLAN_JSON_FILE="${MIGRATION_TMP_DIR}/migration.json"
trap 'rm -rf "${MIGRATION_TMP_DIR}"' EXIT

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required to inspect the Terraform migration plan." >&2
  exit 1
fi

mkdir -p "${BEFORE_WORK_DIR}" "${AFTER_WORK_DIR}"
cp -R "${MIGRATION_FIXTURE_DIR}/before/." "${BEFORE_WORK_DIR}/"
cp -R "${MIGRATION_FIXTURE_DIR}/after/." "${AFTER_WORK_DIR}/"

terraform -chdir="${BEFORE_WORK_DIR}" init -backend=false -input=false >/dev/null
terraform -chdir="${BEFORE_WORK_DIR}" apply -auto-approve -input=false -no-color >/dev/null

cp "${BEFORE_WORK_DIR}/terraform.tfstate" "${AFTER_WORK_DIR}/terraform.tfstate"
terraform -chdir="${AFTER_WORK_DIR}" init -backend=false -input=false >/dev/null
terraform -chdir="${AFTER_WORK_DIR}" plan -refresh=false -lock=false -input=false -no-color -out="${PLAN_FILE}" >/dev/null
terraform -chdir="${AFTER_WORK_DIR}" show -json "${PLAN_FILE}" >"${PLAN_JSON_FILE}"

resource_change_count="$(jq '[.resource_changes[]] | length' "${PLAN_JSON_FILE}")"
if [[ "${resource_change_count}" != "22" ]]; then
  echo "Expected 22 migration resource changes, found ${resource_change_count}." >&2
  exit 1
fi

moved_count="$(jq '[.resource_changes[] | select(.previous_address != null)] | length' "${PLAN_JSON_FILE}")"
if [[ "${moved_count}" != "22" ]]; then
  echo "Expected 22 resources with previous_address, found ${moved_count}." >&2
  exit 1
fi

non_noop_count="$(jq '[.resource_changes[] | select(.change.actions != ["no-op"])] | length' "${PLAN_JSON_FILE}")"
if [[ "${non_noop_count}" != "0" ]]; then
  echo "Migration plan contains add, change, or destroy actions." >&2
  jq -r '.resource_changes[] | select(.change.actions != ["no-op"]) | "\(.address): \(.change.actions | join(","))"' "${PLAN_JSON_FILE}" >&2
  exit 1
fi

resource_collections=(
  igw_natgw_specific_route_tables
  sgw_specific_route_tables
  lpg_specific_route_tables
  drga_specific_route_tables
  non_gw_specific_remaining_route_tables
  igw_natgw_specific_default_route_tables
  sgw_specific_default_route_tables
  lpg_specific_default_route_tables
  drga_specific_default_route_tables
  non_gw_specific_remaining_default_route_tables
  these
)

destination_suffixes=(
  module.igw_natgw_route_tables.terraform_data.custom
  module.sgw_route_tables.terraform_data.custom
  module.lpg_route_tables.terraform_data.custom
  module.drga_route_tables.terraform_data.custom
  module.remaining_route_tables.terraform_data.custom
  module.igw_natgw_route_tables.terraform_data.default
  module.sgw_route_tables.terraform_data.default
  module.lpg_route_tables.terraform_data.default
  module.drga_route_tables.terraform_data.default
  module.remaining_route_tables.terraform_data.default
  terraform_data.these
)

for index in "${!resource_collections[@]}"; do
  collection="${resource_collections[index]}"
  destination_suffix="${destination_suffixes[index]}"
  for key in KEY-A KEY-B; do
    previous_address="module.oci_lz_network[0].terraform_data.${collection}[\"${key}\"]"
    expected_address="module.oci_lz_network[0].module.network_completion.${destination_suffix}[\"${key}\"]"
    match_count="$(jq --arg previous_address "${previous_address}" --arg expected_address "${expected_address}" '[
      .resource_changes[]
      | select(.previous_address == $previous_address and .address == $expected_address and .change.actions == ["no-op"])
    ] | length' "${PLAN_JSON_FILE}")"
    if [[ "${match_count}" != "1" ]]; then
      echo "Expected one no-op move from ${previous_address} to ${expected_address}, found ${match_count}." >&2
      exit 1
    fi
  done
done

echo "network-completion migration checks passed"
