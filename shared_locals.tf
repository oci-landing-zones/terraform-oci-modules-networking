# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Jan 03 2024                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

locals {
  network_terminology = {
    TCP      = "6"
    ICMP     = "1"
    UDP      = "17"
    VRRP     = "112"
    ALL      = "all"
    ANYWHERE = "0.0.0.0/0"
  }

  DEFAULT_SSH_PORTS_TO_CHECK = [22, 3389] # Used in CIS Benchmark check.
  TCP_PORT_MIN               = 1
  TCP_PORT_MAX               = 65535

  one_dimension_processed_vcn_specific_gateways = var.network_configuration != null ? var.network_configuration.network_configuration_categories != null ? length(var.network_configuration.network_configuration_categories) > 0 ? {
    for vcn_specific_gw in [
      for vcn_key, vcn_value in local.one_dimension_processed_vcns : {
        internet_gateways              = vcn_value.vcn_specific_gateways.internet_gateways
        nat_gateways                   = vcn_value.vcn_specific_gateways.nat_gateways
        service_gateways               = vcn_value.vcn_specific_gateways.service_gateways
        local_peering_gateways         = vcn_value.vcn_specific_gateways.local_peering_gateways
        network_configuration_category = vcn_value.network_configuration_category
        vcn_key                        = vcn_key
        vcn_name                       = vcn_value.display_name
        default_compartment_id         = vcn_value.default_compartment_id
        category_compartment_id        = vcn_value.category_compartment_id
        default_defined_tags           = vcn_value.default_defined_tags
        category_defined_tags          = vcn_value.category_defined_tags
        default_freeform_tags          = vcn_value.default_freeform_tags
        category_freeform_tags         = vcn_value.category_freeform_tags
      } if vcn_value.vcn_specific_gateways != null
    ] : "${vcn_specific_gw.network_configuration_category}_${vcn_specific_gw.vcn_key}_gateways" => vcn_specific_gw
  } : {} : {} : {}

  one_dimension_processed_inject_vcn_specific_gateways = var.network_configuration != null ? var.network_configuration.network_configuration_categories != null ? length(var.network_configuration.network_configuration_categories) > 0 ? {
    for vcn_specific_gw in [
      for vcn_key, vcn_value in local.one_dimension_processed_existing_vcns : {
        internet_gateways              = vcn_value.vcn_specific_gateways.internet_gateways
        nat_gateways                   = vcn_value.vcn_specific_gateways.nat_gateways
        service_gateways               = vcn_value.vcn_specific_gateways.service_gateways
        local_peering_gateways         = vcn_value.vcn_specific_gateways.local_peering_gateways
        network_configuration_category = vcn_value.network_configuration_category
        vcn_key                        = vcn_key
        vcn_id                         = vcn_value.vcn_id
        vcn_name                       = vcn_value.vcn_name
        default_compartment_id         = vcn_value.default_compartment_id
        category_compartment_id        = vcn_value.category_compartment_id
        default_defined_tags           = vcn_value.default_defined_tags
        category_defined_tags          = vcn_value.category_defined_tags
        default_freeform_tags          = vcn_value.default_freeform_tags
        category_freeform_tags         = vcn_value.category_freeform_tags
      } if vcn_value.vcn_specific_gateways != null
    ] : "${vcn_specific_gw.network_configuration_category}_${vcn_specific_gw.vcn_key}_gateways" => vcn_specific_gw
  } : {} : {} : {}


  one_dimension_processed_non_vcn_specific_gateways = var.network_configuration != null ? var.network_configuration.network_configuration_categories != null ? length(var.network_configuration.network_configuration_categories) > 0 ? {
    for vcn_non_specific_gw in [
      for network_configuration_category_key, network_configuration_category_value in var.network_configuration.network_configuration_categories : {
        dynamic_routing_gateways        = network_configuration_category_value.non_vcn_specific_gateways.dynamic_routing_gateways
        customer_premises_equipments    = network_configuration_category_value.non_vcn_specific_gateways.customer_premises_equipments
        ipsecs                          = network_configuration_category_value.non_vcn_specific_gateways.ipsecs
        cross_connect_groups            = network_configuration_category_value.non_vcn_specific_gateways.cross_connect_groups
        fast_connect_virtual_circuits   = network_configuration_category_value.non_vcn_specific_gateways.fast_connect_virtual_circuits
        inject_into_existing_drgs       = network_configuration_category_value.non_vcn_specific_gateways.inject_into_existing_drgs
        network_configuration_category  = network_configuration_category_key
        default_compartment_id          = var.network_configuration.default_compartment_id
        category_compartment_id         = network_configuration_category_value.category_compartment_id
        default_defined_tags            = var.network_configuration.default_defined_tags
        category_defined_tags           = network_configuration_category_value.category_defined_tags
        default_freeform_tags           = var.network_configuration.default_freeform_tags
        category_freeform_tags          = network_configuration_category_value.category_freeform_tags
        network_firewalls_configuration = network_configuration_category_value.non_vcn_specific_gateways.network_firewalls_configuration
        l7_load_balancers               = network_configuration_category_value.non_vcn_specific_gateways.l7_load_balancers
      } if network_configuration_category_value.non_vcn_specific_gateways != null
    ] : "${vcn_non_specific_gw.network_configuration_category}_gateways" => vcn_non_specific_gw
  } : {} : {} : {}

  one_dimension_inject_into_existing_drgs = local.one_dimension_processed_non_vcn_specific_gateways != null ? {
    for flat_existing_drg in flatten([
      for vcn_non_specific_gw_key, vcn_non_specific_gw_value in local.one_dimension_processed_non_vcn_specific_gateways :
      vcn_non_specific_gw_value.inject_into_existing_drgs != null ? length(vcn_non_specific_gw_value.inject_into_existing_drgs) > 0 ? [
        for existing_drg_key, existing_drg_value in vcn_non_specific_gw_value.inject_into_existing_drgs : {
          drg_id                         = length(regexall("^ocid1.*$", existing_drg_value.drg_id)) > 0 ? existing_drg_value.drg_id : var.network_dependency["dynamic_routing_gateways"][existing_drg_value.drg_id].id
          category_compartment_id        = vcn_non_specific_gw_value.category_compartment_id
          default_compartment_id         = vcn_non_specific_gw_value.default_compartment_id
          category_defined_tags          = vcn_non_specific_gw_value.category_defined_tags
          default_defined_tags           = vcn_non_specific_gw_value.default_defined_tags
          network_configuration_category = vcn_non_specific_gw_value.network_configuration_category
          remote_peering_connections     = existing_drg_value.remote_peering_connections
          drg_attachments                = existing_drg_value.drg_attachments
          drg_route_tables               = existing_drg_value.drg_route_tables
          drg_route_distributions        = existing_drg_value.drg_route_distributions
          existing_drg_key               = existing_drg_key
        }
      ] : [] : []
    ]) : flat_existing_drg.existing_drg_key => flat_existing_drg
  } : null


  aux_one_dimension_processed_existing_vcns = var.network_configuration != null ? var.network_configuration.network_configuration_categories != null ? length(var.network_configuration.network_configuration_categories) > 0 ? {
    for flat_vcn in flatten([
      for network_configuration_category_key, network_configuration_category_value in var.network_configuration.network_configuration_categories :
      network_configuration_category_value.inject_into_existing_vcns != null ? length(network_configuration_category_value.inject_into_existing_vcns) > 0 ? [
        for vcn_key, vcn_value in network_configuration_category_value.inject_into_existing_vcns : {
          vcn_id  = length(regexall("^ocid1.*$", vcn_value.vcn_id)) > 0 ? vcn_value.vcn_id : var.network_dependency["vcns"][vcn_value.vcn_id].id
          vcn_key = vcn_key
        }
      ] : [] : []
    ]) : flat_vcn.vcn_key => flat_vcn
  } : {} : {} : {}

  one_dimension_processed_existing_vcns = var.network_configuration != null ? var.network_configuration.network_configuration_categories != null ? length(var.network_configuration.network_configuration_categories) > 0 ? {
    for flat_vcn in flatten([
      for network_configuration_category_key, network_configuration_category_value in var.network_configuration.network_configuration_categories :
      network_configuration_category_value.inject_into_existing_vcns != null ? length(network_configuration_category_value.inject_into_existing_vcns) > 0 ? [
        for vcn_key, vcn_value in network_configuration_category_value.inject_into_existing_vcns : {
          vcn_key                        = vcn_key
          vcn_id                         = length(regexall("^ocid1.*$", vcn_value.vcn_id)) > 0 ? vcn_value.vcn_id : var.network_dependency["vcns"][vcn_value.vcn_id].id
          network_configuration_category = network_configuration_category_key
          vcn_name                       = data.oci_core_vcn.existing_vcns[vcn_key].display_name
          compartment_id                 = data.oci_core_vcn.existing_vcns[vcn_key].compartment_id
          default_compartment_id         = var.network_configuration.default_compartment_id
          category_compartment_id        = network_configuration_category_value.category_compartment_id
          default_defined_tags           = var.network_configuration.default_defined_tags
          category_defined_tags          = network_configuration_category_value.category_defined_tags
          default_freeform_tags          = var.network_configuration.default_freeform_tags
          category_freeform_tags         = network_configuration_category_value.category_freeform_tags
          vcn_specific_gateways          = vcn_value.vcn_specific_gateways
          default_security_list          = vcn_value.default_security_list
          security_lists                 = vcn_value.security_lists
          subnets                        = vcn_value.subnets
          dns_resolver                   = vcn_value.dns_resolver
          network_security_groups        = vcn_value.network_security_groups
          route_tables                   = vcn_value.route_tables
          default_dhcp_options           = vcn_value.default_dhcp_options
          default_route_table            = vcn_value.default_route_table
          dhcp_options                   = vcn_value.dhcp_options
          category_enable_cis_checks     = network_configuration_category_value.category_enable_cis_checks
          category_ssh_ports_to_check    = network_configuration_category_value.category_ssh_ports_to_check
          default_enable_cis_checks      = var.network_configuration.default_enable_cis_checks
          default_ssh_ports_to_check     = var.network_configuration.default_ssh_ports_to_check
          default_dhcp_options_id        = data.oci_core_vcn.existing_vcns[vcn_key].default_dhcp_options_id
          default_route_table_id         = data.oci_core_vcn.existing_vcns[vcn_key].default_route_table_id
          default_security_list_id       = data.oci_core_vcn.existing_vcns[vcn_key].default_security_list_id
        }
      ] : [] : []
    ]) : flat_vcn.vcn_key => flat_vcn
  } : {} : {} : {}

  one_dimension_processed_IPs = var.network_configuration != null ? var.network_configuration.network_configuration_categories != null ? length(var.network_configuration.network_configuration_categories) > 0 ? {
    for IPs in [
      for network_configuration_category_key, network_configuration_category_value in var.network_configuration.network_configuration_categories : {
        public_ips_pools               = network_configuration_category_value.IPs.public_ips_pools
        public_ips                     = network_configuration_category_value.IPs.public_ips
        network_configuration_category = network_configuration_category_key
        default_compartment_id         = var.network_configuration.default_compartment_id
        category_compartment_id        = network_configuration_category_value.category_compartment_id
        default_defined_tags           = var.network_configuration.default_defined_tags
        category_defined_tags          = network_configuration_category_value.category_defined_tags
        default_freeform_tags          = var.network_configuration.default_freeform_tags
        category_freeform_tags         = network_configuration_category_value.category_freeform_tags
      } if network_configuration_category_value.IPs != null
    ] : "${IPs.network_configuration_category}_IPs" => IPs
  } : {} : {} : {}

}






