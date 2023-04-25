# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "provisioned_networking_resources" {
  description = "Provisioned networking resources"
  value = {
    vcns                                           = local.provisioned_vcns,
    subnets                                        = local.provisioned_subnets,
    service_gateways                               = local.provisioned_service_gateways,
    security_lists                                 = local.provisioned_security_lists
    route_tables                                   = local.provisioned_route_tables
    route_tables_attachments                       = local.provisioned_route_tables_attachments
    remote_peering_connections                     = local.provisioned_remote_peering_connections
    network_security_groups                        = local.provisioned_network_security_groups
    network_security_groups_ingress_rules          = local.provisioned_network_security_groups_ingress_rules
    network_security_groups_egress_rules           = local.provisioned_network_security_groups_egress_rules
    oci_network_firewall_network_firewalls         = local.provisioned_oci_network_firewall_network_firewalls
    oci_network_firewall_network_firewall_policies = local.provisioned_oci_network_firewall_network_firewall_policies
    nat_gateways                                   = local.provisioned_nat_gateways
    local_peering_gateways                         = local.provisioned_local_peering_gateways
    internet_gateways                              = local.provisioned_internet_gateways
    dynamic_routing_gateways                       = local.provisioned_dynamic_gateways
    drg_route_tables                               = local.provisioned_drg_route_tables
    drg_route_table_route_rules                    = local.provisioned_drg_route_tables_route_rules
    drg_route_distributions                        = local.provisioned_drg_route_distributions
    drg_route_distributions_statements             = local.provisioned_drg_route_distributions_statements
    drg_attachments                                = local.provisioned_drg_attachments
    dhcp_options                                   = local.provisioned_dhcp_options
    z_l7_lbz                                       = local.one_dimension_processed_l7_load_balancers
    public_ips_pools                               = local.provisioned_oci_core_public_ip_pools
    public_ips                                     = local.provisioned_oci_core_public_ips
  }
}




