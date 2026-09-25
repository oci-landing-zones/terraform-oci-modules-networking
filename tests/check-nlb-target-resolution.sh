#!/usr/bin/env bash
set -euo pipefail

NETWORKING_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE_DIR="${NETWORKING_REPO_ROOT}/tests/nlb-target-resolution"
TEST_TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TEST_TMP_DIR}"' EXIT

legacy_ip_expression='  ip_address               = each.value.ip_address != null ? (length(regexall("(\\d{1,3}?).(\\d{1,3}?).(\\d{1,3}?).(\\d{1,3}?)", each.value.ip_address)) > 0 ? each.value.ip_address : var.instances_dependency[each.value.ip_address].private_ip) : null'
grep -Fx "${legacy_ip_expression}" "${NETWORKING_REPO_ROOT}/modules/nlb/main.tf" >/dev/null

TF_DATA_DIR="${TEST_TMP_DIR}/terraform-data" terraform -chdir="${FIXTURE_DIR}" init -backend=false -input=false >/dev/null
TF_DATA_DIR="${TEST_TMP_DIR}/terraform-data" terraform -chdir="${FIXTURE_DIR}" plan -refresh=false -input=false -out="${TEST_TMP_DIR}/valid.tfplan" >/dev/null
TF_DATA_DIR="${TEST_TMP_DIR}/terraform-data" terraform -chdir="${FIXTURE_DIR}" show -json "${TEST_TMP_DIR}/valid.tfplan" >"${TEST_TMP_DIR}/valid.json"

jq -e '
  [.resource_changes[]
   | select(.type == "oci_network_load_balancer_backend")
   | {key: .index, after: .change.after, unknown: .change.after_unknown}]
  | length == 5
    and (map(select(.key == "FIREWALL.TCP.BACKENDSET.LEGACY"))[0].after.ip_address == "10.0.0.10")
    and (map(select(.key == "FIREWALL.TCP.BACKENDSET.LEGACY"))[0].after.target_id == null)
    and (map(select(.key == "FIREWALL.TCP.BACKENDSET.PRIMARY"))[0].after.ip_address == null)
    and (map(select(.key == "FIREWALL.TCP.BACKENDSET.PRIMARY"))[0].after.target_id == "ocid1.privateip.oc1.eu-frankfurt-1.primary-fixture")
    and (map(select(.key == "FIREWALL.TCP.BACKENDSET.INSTANCE_FALLBACK"))[0].after.target_id == "ocid1.instance.oc1.eu-frankfurt-1.legacy-fixture")
    and (map(select(.key == "FIREWALL.TCP.BACKENDSET.UNTRUST"))[0].after.ip_address == null)
    and (map(select(.key == "FIREWALL.TCP.BACKENDSET.UNTRUST"))[0].after.target_id == "ocid1.privateip.oc1.eu-frankfurt-1.untrust-fixture")
    and (map(select(.key == "FIREWALL.TCP.BACKENDSET.OCID"))[0].after.target_id == "ocid1.privateip.oc1.eu-frankfurt-1.fixture")
' "${TEST_TMP_DIR}/valid.json" >/dev/null

if jq -e '.resource_changes[] | select(.mode == "data" and .type == "oci_core_private_ips" and .name == "backend_vnic_targets")' "${TEST_TMP_DIR}/valid.json" >/dev/null; then
  echo "NLB must consume plan-stable private_ips_dependency targets instead of rediscovering VNIC private IPs downstream" >&2
  exit 1
fi

if TF_DATA_DIR="${TEST_TMP_DIR}/terraform-data" terraform -chdir="${FIXTURE_DIR}" plan -refresh=false -input=false -no-color -var-file=invalid-three-segment.tfvars >"${TEST_TMP_DIR}/invalid.log" 2>&1; then
  echo "Expected the three-segment target_id plan to fail" >&2
  exit 1
fi

grep -F "Symbolic backend target_id must use" "${TEST_TMP_DIR}/invalid.log" >/dev/null

if TF_DATA_DIR="${TEST_TMP_DIR}/terraform-data" terraform -chdir="${FIXTURE_DIR}" plan -refresh=false -input=false -no-color -var-file=invalid-both-selectors.tfvars >"${TEST_TMP_DIR}/invalid-both.log" 2>&1; then
  echo "Expected a backend with both ip_address and target_id to fail" >&2
  exit 1
fi

grep -F "Each NLB backend must set exactly one of ip_address or target_id" "${TEST_TMP_DIR}/invalid-both.log" >/dev/null

if TF_DATA_DIR="${TEST_TMP_DIR}/terraform-data" terraform -chdir="${FIXTURE_DIR}" plan -refresh=false -input=false -no-color -var-file=invalid-missing-key.tfvars >"${TEST_TMP_DIR}/invalid-missing.log" 2>&1; then
  echo "Expected an unknown symbolic target_id to fail" >&2
  exit 1
fi

grep -F "The given key does not identify an element in this collection value" "${TEST_TMP_DIR}/invalid-missing.log" >/dev/null

if TF_DATA_DIR="${TEST_TMP_DIR}/terraform-data" terraform -chdir="${FIXTURE_DIR}" plan -refresh=false -input=false -no-color -var-file=invalid-vnic-ocid.tfvars >"${TEST_TMP_DIR}/invalid-vnic.log" 2>&1; then
  echo "Expected a literal VNIC OCID target_id to fail" >&2
  exit 1
fi

grep -F "Literal backend target_id must be an instance or private-IP OCID" "${TEST_TMP_DIR}/invalid-vnic.log" >/dev/null

if TF_DATA_DIR="${TEST_TMP_DIR}/terraform-data" terraform -chdir="${FIXTURE_DIR}" plan -refresh=false -input=false -no-color -var-file=invalid-private-ip-ocid.tfvars >"${TEST_TMP_DIR}/invalid-private-ip.log" 2>&1; then
  echo "Expected a canonical target with a non-private-IP OCID to fail" >&2
  exit 1
fi

grep -F "Each private_ips_dependency id must be a private IP OCID" "${TEST_TMP_DIR}/invalid-private-ip.log" >/dev/null

echo "NLB target resolution checks passed (legacy IP, separate canonical private-IP targets, literal OCID, reserved third segment)"
