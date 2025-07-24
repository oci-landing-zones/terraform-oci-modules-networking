# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Thu Jan 04 2024                                                                          #
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
    
    dns_views                                      = local.one_dimension_dns_views
    dns_zones                                      = local.one_dimension_dns_zones
    dns_rrsets                                     = local.one_dimension_dns_rrset
    dns_steering_policies                          = local.one_dimension_dns_steering_policies
    dns_resolver                                   = local.one_dimension_resolver
    dns_endpoints                                  = local.one_dimension_resolver_endpoints
    dns_tsig_keys                                  = local.one_dimension_dns_tsig_keys

    nat_gateways                       = local.provisioned_nat_gateways
    local_peering_gateways             = local.provisioned_local_peering_gateways
    internet_gateways                  = local.provisioned_internet_gateways
    dynamic_routing_gateways           = local.provisioned_dynamic_gateways
    drg_route_tables                   = local.provisioned_drg_route_tables
    drg_route_table_route_rules        = local.provisioned_drg_route_tables_route_rules
    drg_route_distributions            = local.provisioned_drg_route_distributions
    drg_route_distributions_statements = local.provisioned_drg_route_distributions_statements
    drg_attachments                    = local.provisioned_drg_attachments
    default_dhcp_options               = local.provisioned_default_dhcp_options
    dhcp_options                       = local.provisioned_dhcp_options
    l7_load_balancers                  = module.l7_load_balancers.provisioned_l7_load_balancers
    public_ips_pools                   = local.provisioned_oci_core_public_ip_pools
    public_ips                         = local.provisioned_oci_core_public_ips
    customer_premises_equipments       = local.provisioned_customer_premises_equipments
    ip_sec_vpns                        = local.provisioned_ipsecs
    ipsec_tunnels_management           = local.provisioned_ipsec_connection_tunnels_management
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

output "flat_map_of_provisioned_networking_resources" {
  description = "Flat map of provisioned networking resources - to facilitate the integration with other networking modules via network dependency mechanism"
  value = merge(
    local.provisioned_vcns != null ? { for key, value in local.provisioned_vcns : key => { id = value.id } } : null,
    local.provisioned_subnets != null ? { for key, value in local.provisioned_subnets : key => { id = value.id } } : null,
    local.provisioned_service_gateways != null ? { for key, value in local.provisioned_service_gateways : key => { id = value.id } } : null,
    local.provisioned_default_security_lists != null ? { for key, value in local.provisioned_default_security_lists : key => { id = value.id } } : null,
    local.provisioned_security_lists != null ? { for key, value in local.provisioned_security_lists : key => { id = value.id } } : null,
    local.provisioned_igw_natgw_specific_default_route_tables != null ? { for key, value in local.provisioned_igw_natgw_specific_default_route_tables : key => { id = value.id } } : null,
    local.provisioned_sgw_specific_default_route_tables != null ? { for key, value in local.provisioned_sgw_specific_default_route_tables : key => { id = value.id } } : null,
    local.provisioned_lpg_specific_default_route_tables != null ? { for key, value in local.provisioned_lpg_specific_default_route_tables : key => { id = value.id } } : null,
    local.provisioned_drga_specific_default_route_tables != null ? { for key, value in local.provisioned_drga_specific_default_route_tables : key => { id = value.id } } : null,
    local.provisioned_non_gw_specific_remaining_default_route_tables != null ? { for key, value in local.provisioned_non_gw_specific_remaining_default_route_tables : key => { id = value.id } } : null,
    local.provisioned_igw_natgw_specific_route_tables != null ? { for key, value in local.provisioned_igw_natgw_specific_route_tables : key => { id = value.id } } : null,
    local.provisioned_sgw_specific_route_tables != null ? { for key, value in local.provisioned_sgw_specific_route_tables : key => { id = value.id } } : null,
    local.provisioned_lpg_specific_route_tables != null ? { for key, value in local.provisioned_lpg_specific_route_tables : key => { id = value.id } } : null,
    local.provisioned_drga_specific_route_tables != null ? { for key, value in local.provisioned_drga_specific_route_tables : key => { id = value.id } } : null,
    local.provisioned_non_gw_specific_remaining_route_tables != null ? { for key, value in local.provisioned_non_gw_specific_remaining_route_tables : key => { id = value.id } } : null,
    local.provisioned_route_tables_attachments != null ? { for key, value in local.provisioned_route_tables_attachments : key => { id = value.id } } : null,
    local.provisioned_remote_peering_connections != null ? { for key, value in local.provisioned_remote_peering_connections : key => { id = value.id } } : null,
    local.provisioned_network_security_groups != null ? { for key, value in local.provisioned_network_security_groups : key => { id = value.id } } : null,
    //local.provisioned_network_security_groups_ingress_rules != null ? { for key, value in local.provisioned_network_security_groups_ingress_rules : key => { id = value.id} } : null,
    //local.provisioned_network_security_groups_egress_rules != null ? { for key, value in local.provisioned_network_security_groups_egress_rules : key => { id = value.id} } : null,
    local.provisioned_oci_network_firewall_network_firewalls != null ? { for key, value in local.provisioned_oci_network_firewall_network_firewalls : key => { id = value.id } } : null,
    local.provisioned_oci_network_firewall_network_firewall_policies != null ? { for key, value in local.provisioned_oci_network_firewall_network_firewall_policies : key => { id = value.id } } : null,
    local.provisioned_nat_gateways != null ? { for key, value in local.provisioned_nat_gateways : key => { id = value.id } } : null,
    local.provisioned_local_peering_gateways != null ? { for key, value in local.provisioned_local_peering_gateways : key => { id = value.id } } : null,
    local.provisioned_internet_gateways != null ? { for key, value in local.provisioned_internet_gateways : key => { id = value.id } } : null,
    local.provisioned_dynamic_gateways != null ? { for key, value in local.provisioned_dynamic_gateways : key => { id = value.id } } : null,
    local.provisioned_drg_route_tables != null ? { for key, value in local.provisioned_drg_route_tables : key => { id = value.id } } : null,
    local.provisioned_drg_route_tables_route_rules != null ? { for key, value in local.provisioned_drg_route_tables_route_rules : key => { id = value.id } } : null,
    local.provisioned_drg_route_distributions != null ? { for key, value in local.provisioned_drg_route_distributions : key => { id = value.id } } : null,
    local.provisioned_drg_route_distributions_statements != null ? { for key, value in local.provisioned_drg_route_distributions_statements : key => { id = value.id } } : null,
    local.provisioned_drg_attachments != null ? { for key, value in local.provisioned_drg_attachments : key => { id = value.id } } : null,
    local.provisioned_default_dhcp_options != null ? { for key, value in local.provisioned_default_dhcp_options : key => { id = value.id } } : null,
    local.provisioned_dhcp_options != null ? { for key, value in local.provisioned_dhcp_options : key => { id = value.id } } : null,
    //module.l7_load_balancers.provisioned_l7_load_balancers != null ? { for key, value in module.l7_load_balancers.provisioned_l7_load_balancers : key => { id = value.id} } : null,
    local.provisioned_oci_core_public_ip_pools != null ? { for key, value in local.provisioned_oci_core_public_ip_pools : key => { id = value.id } } : null,
    local.provisioned_oci_core_public_ips != null ? { for key, value in local.provisioned_oci_core_public_ips : key => { id = value.id } } : null,
    local.provisioned_customer_premises_equipments != null ? { for key, value in local.provisioned_customer_premises_equipments : key => { id = value.id } } : null,
  )
}






