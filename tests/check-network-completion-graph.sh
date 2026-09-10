#!/usr/bin/env bash
set -euo pipefail

NETWORKING_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GRAPH_FIXTURE_DIR="${NETWORKING_REPO_ROOT}/tests/network-completion-graph"
GRAPH_TMP_DIR="$(mktemp -d)"
GRAPH_DOT_FILE="${GRAPH_TMP_DIR}/network-completion.dot"
trap 'rm -rf "${GRAPH_TMP_DIR}"' EXIT

terraform -chdir="${GRAPH_FIXTURE_DIR}" init -backend=false -input=false >/dev/null
terraform -chdir="${GRAPH_FIXTURE_DIR}" validate >/dev/null
terraform -chdir="${GRAPH_FIXTURE_DIR}" plan -refresh=false -lock=false -input=false -no-color >/dev/null
terraform -chdir="${GRAPH_FIXTURE_DIR}" graph -type=plan -draw-cycles >"${GRAPH_DOT_FILE}"

if rg -q 'color[[:space:]]*=[[:space:]]*"red"' "${GRAPH_DOT_FILE}"; then
  echo "Terraform marked a dependency cycle in the network-completion fixture." >&2
  exit 1
fi

custom_resource_addresses=(
  module.completion.module.igw_natgw_route_tables.oci_core_route_table.custom
  module.completion.module.sgw_route_tables.oci_core_route_table.custom
  module.completion.module.lpg_route_tables.oci_core_route_table.custom
  module.completion.module.drga_route_tables.oci_core_route_table.custom
  module.completion.module.remaining_route_tables.oci_core_route_table.custom
)

default_resource_addresses=(
  module.completion.module.igw_natgw_route_tables.oci_core_default_route_table.default
  module.completion.module.sgw_route_tables.oci_core_default_route_table.default
  module.completion.module.lpg_route_tables.oci_core_default_route_table.default
  module.completion.module.drga_route_tables.oci_core_default_route_table.default
  module.completion.module.remaining_route_tables.oci_core_default_route_table.default
)

for resource_address in "${custom_resource_addresses[@]}"; do
  rg -q "${resource_address}" "${GRAPH_DOT_FILE}"
done

for resource_address in "${default_resource_addresses[@]}"; do
  rg -q "${resource_address}" "${GRAPH_DOT_FILE}"
done

rg -q 'module.completion.oci_core_route_table_attachment.these' "${GRAPH_DOT_FILE}"
rg -q 'module.completion_without_firewalls.oci_core_route_table_attachment.these' "${GRAPH_DOT_FILE}"
rg -q 'terraform_data.nlb_route_target.*terraform_data.nlb_backend' "${GRAPH_DOT_FILE}"
rg -q 'terraform_data.nlb_backend.*local.private_ip_targets_dependency' "${GRAPH_DOT_FILE}"
rg -q 'local.private_ip_targets_dependency.*terraform_data.vnic_primary_private_ip' "${GRAPH_DOT_FILE}"
rg -q 'terraform_data.vnic_primary_private_ip.*terraform_data.workload_secondary_vnic' "${GRAPH_DOT_FILE}"
rg -q 'terraform_data.workload_secondary_vnic.*terraform_data.firewall_vm' "${GRAPH_DOT_FILE}"
rg -q 'terraform_data.network_firewall_private_ip.*terraform_data.network_firewall' "${GRAPH_DOT_FILE}"

workload_backend_keys=(
  PANF-1.INDOOR
  PANF-1.OUTDOOR
  PANF-2.INDOOR
  PANF-2.OUTDOOR
)

for workload_backend_key in "${workload_backend_keys[@]}"; do
  rg -q "\"${workload_backend_key}\"" "${GRAPH_FIXTURE_DIR}/main.tf"
done

if ! rg -q 'target_id[[:space:]]*=[[:space:]]*local\.private_ip_targets_dependency.*\.id' "${GRAPH_FIXTURE_DIR}/main.tf"; then
  echo "The VM/NLB fixture must pass plan-stable private IP targets to target_id." >&2
  exit 1
fi

gateway_output_relationships=(
  'internet_gateway|provisioned_igw_natgw_specific_route_tables'
  'nat_gateway|provisioned_igw_natgw_specific_route_tables'
  'service_gateway|provisioned_igw_natgw_specific_route_tables'
  'service_gateway|provisioned_sgw_specific_route_tables'
  'local_peering_gateway|provisioned_igw_natgw_specific_route_tables'
  'local_peering_gateway|provisioned_lpg_specific_route_tables'
  'drg_attachment|provisioned_igw_natgw_specific_route_tables'
  'drg_attachment|provisioned_lpg_specific_route_tables'
  'drg_attachment|provisioned_drga_specific_route_tables'
)

for relationship in "${gateway_output_relationships[@]}"; do
  gateway_name="${relationship%%|*}"
  output_name="${relationship#*|}"
  gateway_resource="$({
    sed -n "/^resource \"terraform_data\" \"${gateway_name}\"/,/^}/p" "${GRAPH_FIXTURE_DIR}/main.tf"
  } || true)"
  if ! rg -q "module\.completion\.${output_name}" <<<"${gateway_resource}"; then
    echo "Fixture ${gateway_name} is missing completion dependency ${output_name}." >&2
    exit 1
  fi
done

if rg -q 'variable "(all_.*targets|all_targets|route_rules_targets|private_ip_targets|gateway_targets|all_.*route_tables|route_tables)"' "${NETWORKING_REPO_ROOT}/modules/network-completion/variables.tf"; then
  echo "A combined target or route-table input crossed the completion module boundary." >&2
  exit 1
fi

route_table_worker="${NETWORKING_REPO_ROOT}/modules/network-completion/modules/route-table-partition/main.tf"
if [[ "$(rg -c '^resource "oci_core_route_table"' "${route_table_worker}")" != "1" ]]; then
  echo "The route-table worker must contain exactly one custom route-table resource." >&2
  exit 1
fi
if [[ "$(rg -c '^resource "oci_core_default_route_table"' "${route_table_worker}")" != "1" ]]; then
  echo "The route-table worker must contain exactly one default route-table resource." >&2
  exit 1
fi
if rg -q '^resource "oci_core_(default_)?route_table"' "${NETWORKING_REPO_ROOT}"/modules/network-completion/*.tf; then
  echo "Top-level route-table resources must be implemented only by the shared partition worker." >&2
  exit 1
fi

if rg -q 'output "(all_.*targets|all_targets|route_rules_targets|private_ip_targets|gateway_targets|all_.*route_tables|route_tables)"' "${NETWORKING_REPO_ROOT}/modules/network-completion/outputs.tf"; then
  echo "A combined target or route-table output crossed the completion module boundary." >&2
  exit 1
fi

if rg -q 'keys\(local\.private_ip_dependency_targets\)' "${NETWORKING_REPO_ROOT}/route_tables.tf" "${NETWORKING_REPO_ROOT}/default_route_tables.tf"; then
  echo "Route-table partition selection depends on computed private-IP target objects instead of configuration-derived keys." >&2
  exit 1
fi

completion_call="$({
  sed -n '/^module "network_completion"/,/^moved {/p' "${NETWORKING_REPO_ROOT}/network_completion.tf"
} || true)"
if rg -q 'local\.provisioned_(internet|nat|service|local_peering|dynamic).*gateway' <<<"${completion_call}"; then
  echo "A completion target input uses an enriched gateway compatibility local." >&2
  exit 1
fi

nlb_route_target_output="$({
  sed -n '/^output "route_target_private_ips"/,/^}/p' "${NETWORKING_REPO_ROOT}/modules/nlb/outputs.tf"
} || true)"

if ! rg -q 'id[[:space:]]*=[[:space:]]*one\(private_ips\.private_ips\)\.id' <<<"${nlb_route_target_output}"; then
  echo "The NLB route-target output must expose one private IP OCID per NLB." >&2
  exit 1
fi

nlb_readiness_dependencies=(
  oci_network_load_balancer_listener.these
  oci_network_load_balancer_backend_set.these
  oci_network_load_balancer_backend.these
)

for dependency in "${nlb_readiness_dependencies[@]}"; do
  if ! rg -q "${dependency}" <<<"${nlb_route_target_output}"; then
    echo "The NLB route-target output is missing readiness dependency ${dependency}." >&2
    exit 1
  fi
done

foundation_output="$({
  sed -n '/^output "provisioned_networking_foundation_resources"/,/^}/p' "${NETWORKING_REPO_ROOT}/outputs.tf"
} || true)"
if rg -q 'network_completion|provisioned_.*route_table|local\.' <<<"${foundation_output}"; then
  echo "The foundation output contains a completion dependency." >&2
  exit 1
fi

l7_module_call="$({
  sed -n '/^module "l7_load_balancers"/,/^}/p' "${NETWORKING_REPO_ROOT}/l7_load_balancers.tf"
} || true)"
if ! rg -q 'subnets[[:space:]]*=[[:space:]]*local\.l7_subnet_dependencies' <<<"${l7_module_call}"; then
  echo "The L7 module must consume the explicit foundation subnet dependency projection." >&2
  exit 1
fi
if rg -q 'provisioned_subnets|network_completion|provisioned_.*route_table' <<<"${l7_module_call}"; then
  echo "The L7 module call contains a route-completion dependency." >&2
  exit 1
fi

l7_subnet_contract="$({
  sed -n '/subnets = optional(map(object({/,/}))),/p' "${NETWORKING_REPO_ROOT}/modules/l7_load_balancers/variables.tf"
} || true)"
l7_subnet_fields=(display_name id vcn_id vcn_key vcn_name)
for field in "${l7_subnet_fields[@]}"; do
  if ! rg -q "${field}[[:space:]]*=[[:space:]]*string" <<<"${l7_subnet_contract}"; then
    echo "The L7 subnet dependency contract is missing ${field}." >&2
    exit 1
  fi
done
if rg -q 'route_table|dhcp_options|security_lists' <<<"${l7_subnet_contract}"; then
  echo "The L7 subnet dependency contract contains late or unused subnet metadata." >&2
  exit 1
fi

subnet_resource="$({
  sed -n '/^resource "oci_core_subnet" "these"/,/^}/p' "${NETWORKING_REPO_ROOT}/subnets.tf"
} || true)"
if rg -q 'route_table_id' <<<"${subnet_resource}"; then
  echo "The subnet resource must not own the final route-table association." >&2
  exit 1
fi

move_count="$(rg -c '^moved[[:space:]]*\{' "${NETWORKING_REPO_ROOT}/network_completion.tf")"
if [[ "${move_count}" != "11" ]]; then
  echo "Expected exactly 11 whole-resource moved blocks, found ${move_count}." >&2
  exit 1
fi

echo "network-completion graph checks passed"
