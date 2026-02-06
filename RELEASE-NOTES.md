# February XX, 2026 Release Notes - 0.8.0

## Updates
1. CIS checks can be now be managed at the VCN level via new attribute *enable_cis_checks*. With this addition, CIS checks can be managed at the most global level (affecting all VCNs), at the category level (affecting all VCNs at that category), and now at the VCN level.


# January 28, 2026 Release Notes - 0.7.9

## Fixes
1. Update default value for Network Load Balancer health checker

# October 28, 2025 Release Notes - 0.7.8

## Fixes
1. Add network dependency to L7 Load Balancers.
2. Resolve issue blocking Remote Peering Connections from attaching to DRG.
3. Resolve issue affecting route rules targeting Local Peering Gateways.

# August 08, 2025 Release Notes - 0.7.7

## Fixes
1. Resolve missing DNS resolver IDs.
2. Ability to set up IPSEC Tunnels Phase 1 and 2 details.
3. Resolve private DNS Zone not being able to accept a compartment key.
4. Format code to adhere to Terraform standards.
5. Ability for NAT Gateway resource to support assigning a reserved IP using a logical key.

# June 12, 2025 Release Notes - 0.7.6

## Fixes
1. *cpe_traffic_selector* and *oracle_traffic_selector* are updated to *optional(list(string))* in [variables.tf](./variables.tf)
2. *oracle_traffic_selector* typo corrected in [ipsecs-tunnels-management.tf](./ipsecs-tunnels-management.tf)

## Updates
1. Steps to generate Self-Signed certificates for Load Balancers added in [README.md
(simple-no_vcn-oci-native-l7-lbaas-example)](./examples/simple-no_vcn-oci-native-l7-lbaas-example/README.md)  and [README.md (standard-vcn-oci-native-l7-lbaas-example)](./examples/standard-vcn-oci-native-l7-lbaas-example/README.md)

# April 29, 2025 Release Notes - 0.7.5

## Updates
1. Ability to attach an externally managed VCN to DRG. The externally managed VCN must be available in the *vcns* attribute of *network_dependency* variable. The key within the *vcns* attribute is to be referred in *network_configuration_categories.non_vcn_specific_gateways.dynamic_routing_gateways.drg_attachments.network_details.attached_resource_key* attribute of *network_configuration* variable.
2. Any leading and trailing spaces in *dns_label* attribute of *vcns* and *subnets* attributes are removed. The assigned value defaults to *display_name*, constrained to only alphanumeric characters truncated at 15th character.
3. Unrestricted ingress access from source 0.0.0.0/0 removed from default security list for all protocols. Both ingress and egress rules in the default security list are checked for compliance with CIS Benchmark 3.0.

## Fixes
1. Route table targets fixed according to the solution for graph cycle described in [Route tables graph cycle](./route-tables-graph-cycle-fix.md). The fixes relate to route table targets that refer to externally managed DRGs and externally managed private IPs.


# March 24, 2025 Release Notes - 0.7.4

## Updates
1. *is_preserve_source* attribute added to backend sets in [Network Load Balancer module](./modules/nlb/) When it is set to true (default), the Network Load Balancer preserves the source IP of the packet when it is forwarded to backends. Backends see the original source IP. However, setting it to false has not effect if *skip_source_dest_check* attribute is set to true at the Network Load Balancer level.


# February 12, 2025 Release Notes - 0.7.3

## Updates
1. Symmetric hashing support added for Network Load Balancers via *enable_symmetric_hashing* attribute.

## Fixes
1. *ip_mtu* attribute assignment fixed in [fast_connect_virtual_circuits.tf](./fast_connect_virtual_circuits.tf).
2. Condition check added for *drg_attachment_id* in [drg_route_distributions_statements.tf](./drg_route_distributions_statements.tf).


# December 04, 2024 Release Notes - 0.7.2

## Updates
1. ZPR (Zero Trust Packet Routing) security attributes can now be applied to Network Load Balancers. See *zpr_attributes* attribute in [example template](./modules/nlb/examples/vision/input.auto.tfvars.template) for details.
2. Redundant *dns_resolver* attribute removed from *network_configuration.vcns* attribute.
3. Attribute *vcn_route_type* added to *oci_core_drg_attachment* resource.
4. Attribute *dns_steering_policies* correctly spelled in [dns.tf](./dns.tf).


# November 04, 2024 Release Notes - 0.7.1

## Updates
1. ZPR (Zero Trust Packet Routing) security attributes can now be applied to VCNs. See *zpr_attributes* attribute under [Module Functioning](./README.md#functioning) for details.

# September 20, 2024 Release Notes - 0.7.0

## Updates
1. OCI Network Firewall refactored according to updates post Terraform OCI Provider 5.16.0 release. See [oci-network-firewall example](./examples/oci-network-firewall/).
2. Ability to inject externally managed existing private DNS views into managed DNS resolvers. See [dns-view-injection example](./examples/dns-view-injection/).

# August 28, 2024 Release Notes - 0.6.9

## Updates
1. All modules now require Terraform binary equal or greater than 1.3.0.
2. *cislz-terraform-module* tag renamed to *ocilz-terraform-module*.


# July 24, 2024 Release Notes - 0.6.8

## New
1. [VTAP module](./modules/vtap/)
    - New VTAP (Virtual Test Access Point) module available.
## Updates
1. Aligned [README.md](./README.md) structure to Oracle's GitHub organizations requirements.


# May 15, 2024 Release Notes - 0.6.7

## New
1. Support added for private DNS with the introduction of *dns_resolver* attribute for VCNs.
2. New modules for [WAF (Web Application Firewall)](./modules/waf/) and [WAA (Web Application Acceleration)](./modules/waa/).
2. Examples of network topologies for OKE deployments added. See [oke-examples](./examples/oke-examples/).


# April 16, 2024 Release Notes - 0.6.6

## Updates
1. Module now supports external dependencies on private IP addresses, DRG attachments, remote peering connections and local peering gateways. See [External Dependencies](./README.md#ext-dep) for details.
2. All dependency variables are now strongly typed, enhancing usage guidance.


# April 08, 2024 Release Notes - 0.6.5
## Additions
1. MVP module for Network Load Balancers.

## Updates
1. Module dependency on externally managed network resources enhanced, including improved examples and documentation.
2. Release tracking via freeform tags.

## Fixes
1. L7 load balancers module dependency on compartments.
2. IPV6 CIDR block data type changed from bool to string in L7 load balancers module.


# March 21, 2023 Release Notes - 0.1.0
## Added
1. [Initial Release](#0-1-0-initial)
### <a name="0-1-0-initial">Initial Release</a>
Module for networking.