# Tests

Run the L7 foundation-subnet contract regression with:

```shell
./tests/check-l7-foundation-subnet-contract.sh
```

The fixture passes only the subnet identity and display metadata consumed by
the L7 module. It prevents the L7 dependency contract from becoming coupled to
late route-table completion fields. It also verifies that the existing completed
`provisioned_subnets` output shape remains accepted and that invalid field types
are still rejected.

Run the network-completion dependency fixture with:

```shell
./tests/check-network-completion-graph.sh
```

The fixture validates and graphs all five static route-table worker calls, each
containing one custom and one customized default-route-table partition, native
firewall and VM/NLB private-IP targets, managed and literal private IPs, gateway
targets, subnet completion, and a configuration without firewalls. The VM/NLB path
mirrors the pinned
`cis-compute-storage` output contract: secondary VNIC keys such as
`PANF-1.INDOOR` and `PANF-1.OUTDOOR` resolve at the workloads boundary to a
separate map of plan-stable private-IP OCIDs for backend `target_id`. The checker
also rejects aggregate completion-module interfaces, completion references in the
foundation output, inline subnet route-table ownership, graph cycles, and any
migration count other than 11 whole-resource moves.

Run the credential-free state-migration fixture with:

```shell
./tests/check-network-completion-migration.sh
```

The migration test applies a before fixture at the unchanged orchestrator-style
`module.oci_lz_network[0]` address, transfers its state to the after fixture, and
verifies that all 22 instances from the 11 resource collections move into the internal
`module.network_completion` address. Every planned action must be `no-op`; resource
labels and both `for_each` keys must remain unchanged, with no add, change, or destroy.

Run the root-module provider-floor validation with:

```shell
./tests/check-provider-floor.sh
```

This initializes the real networking root module with OCI provider 7.27.0 and the
standalone NLB module with OCI provider 6.23.0, then validates both full provider
schemas without requiring OCI credentials.

Run the NLB backend target-resolution regression with:

```shell
./tests/check-nlb-target-resolution.sh
```

The fixture plans one unchanged literal `ip_address` backend, a bare instance-key
`target_id`, a two-segment VNIC-key `target_id`, and a literal private-IP OCID. It
locks the legacy `ip_address` resolution expression, uses plan-stable private-IP OCID
targets from a separate `private_ips_dependency` map, preserves the historical instance-OCID
fallback for a one-segment `instances_dependency` key, and keeps a third key segment rejected until
explicit private-IP selection is implemented. It also rejects an ambiguous backend
that sets both `ip_address` and `target_id`, an unknown dependency key, and a literal
VNIC OCID that the NLB backend API cannot accept.

Provider-backed upgrade and apply checks require OCI credentials and existing v0.8.3
(or v0.8.4) state. For a release candidate, additionally verify:

1. Unchanged v0.8.3 and v0.8.4 configurations plan only the 11 state moves and no resource replacements.
2. Fresh native firewall and Hub C VM/NLB configurations apply once, followed by an empty plan.
3. Route-rule and backend updates, attachment reassignment, target replacement, drift, interrupted-apply recovery, injected VCNs, and destroy ordering.
