# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  # PROCESSED INPUT
  one_dimension_processed_vcns = var.network_configuration != null ? var.network_configuration.network_configuration_categories != null ? length(var.network_configuration.network_configuration_categories) > 0 ? {
    for flat_vcn in flatten([
      for network_configuration_category_key, network_configuration_category_value in var.network_configuration.network_configuration_categories :
      network_configuration_category_value.vcns != null ? length(network_configuration_category_value.vcns) > 0 ? [
        for vcn_key, vcn_value in network_configuration_category_value.vcns : {
          block_nat_traffic                = vcn_value.block_nat_traffic
          byoipv6cidr_details              = vcn_value.byoipv6cidr_details
          cidr_blocks                      = vcn_value.cidr_blocks
          compartment_id                   = vcn_value.compartment_id != null ? vcn_value.compartment_id : network_configuration_category_value.category_compartment_id != null ? network_configuration_category_value.category_compartment_id : var.network_configuration.default_compartment_id != null ? var.network_configuration.default_compartment_id : null
          default_compartment_id           = var.network_configuration.default_compartment_id
          category_compartment_id          = network_configuration_category_value.category_compartment_id
          defined_tags                     = merge(vcn_value.defined_tags, network_configuration_category_value.category_defined_tags, var.network_configuration.default_defined_tags)
          default_defined_tags             = var.network_configuration.default_defined_tags
          category_defined_tags            = network_configuration_category_value.category_defined_tags
          display_name                     = vcn_value.display_name
          dns_label                        = vcn_value.dns_label
          freeform_tags                    = merge(vcn_value.freeform_tags, network_configuration_category_value.category_freeform_tags, var.network_configuration.default_freeform_tags)
          default_freeform_tags            = var.network_configuration.default_freeform_tags
          category_freeform_tags           = network_configuration_category_value.category_freeform_tags
          ipv6private_cidr_blocks          = vcn_value.ipv6private_cidr_blocks
          is_ipv6enabled                   = vcn_value.is_ipv6enabled
          is_oracle_gua_allocation_enabled = vcn_value.is_oracle_gua_allocation_enabled
          vcn_key                          = vcn_key
          network_configuration_category   = network_configuration_category_key
          default_security_list            = vcn_value.default_security_list
          security_lists                   = vcn_value.security_lists
          subnets                          = vcn_value.subnets
          vcn_specific_gateways            = vcn_value.vcn_specific_gateways
          network_security_groups          = vcn_value.network_security_groups
          route_tables                     = vcn_value.route_tables
          dhcp_options                     = vcn_value.dhcp_options
          category_enable_cis_checks       = network_configuration_category_value.category_enable_cis_checks
          category_ssh_ports_to_check      = network_configuration_category_value.category_ssh_ports_to_check
          default_enable_cis_checks        = var.network_configuration.default_enable_cis_checks != null ? var.network_configuration.default_enable_cis_checks : true
          default_ssh_ports_to_check       = var.network_configuration.default_ssh_ports_to_check != null ? var.network_configuration.default_ssh_ports_to_check : local.DEFAULT_SSH_PORTS_TO_CHECK
        }
      ] : [] : []
    ]) : flat_vcn.vcn_key => flat_vcn
  } : {} : {} : {}

  provisioned_vcns = {
    for vcn_key, vcn_value in oci_core_vcn.these : vcn_key => {
      byoipv6cidr_blocks               = vcn_value.byoipv6cidr_blocks
      byoipv6cidr_details              = vcn_value.byoipv6cidr_details
      cidr_block                       = vcn_value.cidr_block
      cidr_blocks                      = vcn_value.cidr_blocks
      compartment_id                   = vcn_value.compartment_id
      default_dhcp_options_id          = vcn_value.default_dhcp_options_id
      default_route_table_id           = vcn_value.default_route_table_id
      default_security_list_id         = vcn_value.default_security_list_id
      defined_tags                     = vcn_value.defined_tags
      display_name                     = vcn_value.display_name
      dns_label                        = vcn_value.dns_label
      freeform_tags                    = vcn_value.freeform_tags
      id                               = vcn_value.id
      ipv6cidr_blocks                  = vcn_value.ipv6cidr_blocks
      ipv6private_cidr_blocks          = vcn_value.ipv6private_cidr_blocks
      is_ipv6enabled                   = vcn_value.is_ipv6enabled
      is_oracle_gua_allocation_enabled = vcn_value.is_oracle_gua_allocation_enabled
      state                            = vcn_value.state
      time_created                     = vcn_value.time_created
      timeouts                         = vcn_value.timeouts
      vcn_domain_name                  = vcn_value.vcn_domain_name
      vcn_key                          = vcn_key
      network_configuration_category   = local.one_dimension_processed_vcns[vcn_key].network_configuration_category
    }
  }
}

# OCI RESOURCE
resource "oci_core_vcn" "these" {
  for_each = local.one_dimension_processed_vcns

  compartment_id = each.value.compartment_id

  #Optional
  dynamic "byoipv6cidr_details" {
    for_each = (each.value.byoipv6cidr_details != null ? each.value.byoipv6cidr_details : {})
    #Required
    content {
      byoipv6range_id = byoipv6cidr_details.value["byoipv6range_id"]
      ipv6cidr_block  = byoipv6cidr_details.value["ipv6cidr_block"]
    }
  }

  cidr_blocks             = each.value.cidr_blocks
  defined_tags            = each.value.defined_tags
  display_name            = each.value.display_name
  dns_label               = each.value.dns_label
  freeform_tags           = each.value.freeform_tags
  ipv6private_cidr_blocks = each.value.ipv6private_cidr_blocks
  is_ipv6enabled          = each.value.is_ipv6enabled
  # is_oracle_gua_allocation_enabled = each.value.is_oracle_gua_allocation_enabled
  # 400-InvalidParameter, The parameter isOracleGuaAllocationEnabled can only be used with IPv6 enabled Vcn.
}