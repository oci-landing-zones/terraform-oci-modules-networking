# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 22 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

output "provisioned_networking_resources" {
  description = "Provisioned networking resources"
  value = {
    vcns                   = local.provisioned_vcns,
    subnets                = local.provisioned_subnets,
    service_gateways       = local.provisioned_service_gateways,
    default_security_lists = local.provisioned_default_security_lists
    security_lists         = local.provisioned_security_lists
    default_route_tables = {
      igw_natgw_specific_default_rts_attachable_to_igw_natgw_sgw_lpg_drga_subnet = local.provisioned_igw_natgw_specific_default_route_tables,
      sgw_specific_default_rts_attachable_to_sgw_subnet                          = local.provisioned_sgw_specific_default_route_tables,
      lpg_specific_default_rts_attachable_to_lpg_drga_subnet                     = local.provisioned_lpg_specific_default_route_tables,
      drga_specific_default_rts_attachable_to_drga_subnet                        = local.provisioned_drga_specific_default_route_tables,
      non_gw_specific_remaining_default_rts_attachable_to_drga_subnet            = local.provisioned_non_gw_specific_remaining_default_route_tables
    }
    route_tables = {
      igw_natgw_specific_rts_attachable_to_igw_natgw_sgw_lpg_drga_subnet = local.provisioned_igw_natgw_specific_route_tables,
      sgw_specific_rts_attachable_to_sgw_subnet                          = local.provisioned_sgw_specific_route_tables,
      lpg_specific_rts_attachable_to_lpg_drga_subnet                     = local.provisioned_lpg_specific_route_tables,
      drga_specific_rts_attachable_to_drga_subnet                        = local.provisioned_drga_specific_route_tables,
      non_gw_specific_remaining_rts_attachable_to_drga_subnet            = local.provisioned_non_gw_specific_remaining_route_tables
    }
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
    default_dhcp_options                           = local.provisioned_default_dhcp_options
    dhcp_options                                   = local.provisioned_dhcp_options
    l7_load_balancers                              = module.l7_load_balancers.provisioned_l7_load_balancers
    public_ips_pools                               = local.provisioned_oci_core_public_ip_pools
    public_ips                                     = local.provisioned_oci_core_public_ips
    customer_premises_equipments                   = local.provisioned_customer_premises_equipments
    ip_sec_vpns                                    = local.provisioned_ipsecs
    ipsec_tunnels_management                       = local.provisioned_ipsec_connection_tunnels_management
    fast_connect_virtual_circuits = {
      fast_connect_virtual_circuits = local.provisioned_fast_connect_virtual_circuits
      available_fast_connect_provider_services = local.one_dimmension_fast_connect_provider_services != null ? length(local.one_dimmension_fast_connect_provider_services) > 0 ? {
        for k, v in local.one_dimmension_fast_connect_provider_services :
        k => v if local.one_dimension_fast_connect_virtual_circuits[v.fcvc_key].show_available_fc_virtual_circuit_providers == true
      } : {} : {}
    }
    cross_connect_groups  = oci_core_cross_connect_group.these,
    cross_connects        = oci_core_cross_connect.these
    fc_vc_drg_attachments = local.fc_vc_drg_attachments
  }
}




