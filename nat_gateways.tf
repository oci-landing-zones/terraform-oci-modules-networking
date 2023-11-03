# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  one_dimension_processed_nat_gateways = local.one_dimension_processed_vcn_specific_gateways != null ? {
    for flat_natgw in flatten([
      for vcn_specific_gw_key, vcn_specific_gw_value in local.one_dimension_processed_vcn_specific_gateways :
      vcn_specific_gw_value.nat_gateways != null ? length(vcn_specific_gw_value.nat_gateways) > 0 ? [
        for natgw_key, natgw_value in vcn_specific_gw_value.nat_gateways : {
          compartment_id                 = natgw_value.compartment_id != null ? natgw_value.compartment_id : vcn_specific_gw_value.category_compartment_id != null ? vcn_specific_gw_value.category_compartment_id : vcn_specific_gw_value.default_compartment_id != null ? vcn_specific_gw_value.default_compartment_id : null
          defined_tags                   = merge(natgw_value.defined_tags, vcn_specific_gw_value.category_defined_tags, vcn_specific_gw_value.default_defined_tags)
          freeform_tags                  = merge(natgw_value.freeform_tags, vcn_specific_gw_value.category_freeform_tags, vcn_specific_gw_value.default_freeform_tags)
          display_name                   = natgw_value.display_name
          route_table_id                 = null
          route_table_key                = natgw_value.route_table_key
          block_traffic                  = natgw_value.block_traffic
          public_ip_id                   = natgw_value.public_ip_id
          network_configuration_category = vcn_specific_gw_value.network_configuration_category
          natgw_key                      = natgw_key
          vcn_name                       = vcn_specific_gw_value.vcn_name
          vcn_key                        = vcn_specific_gw_value.vcn_key
          natgw_key                      = natgw_key
          vcn_id                         = null
        }
      ] : [] : []
    ]) : flat_natgw.natgw_key => flat_natgw
  } : null

  one_dimension_processed_injected_nat_gateways = local.one_dimension_processed_inject_vcn_specific_gateways != null ? {
    for flat_natgw in flatten([
      for vcn_specific_gw_key, vcn_specific_gw_value in local.one_dimension_processed_inject_vcn_specific_gateways :
      vcn_specific_gw_value.nat_gateways != null ? length(vcn_specific_gw_value.nat_gateways) > 0 ? [
        for natgw_key, natgw_value in vcn_specific_gw_value.nat_gateways : {
          compartment_id                 = natgw_value.compartment_id != null ? natgw_value.compartment_id : vcn_specific_gw_value.category_compartment_id != null ? vcn_specific_gw_value.category_compartment_id : vcn_specific_gw_value.default_compartment_id != null ? vcn_specific_gw_value.default_compartment_id : null
          defined_tags                   = merge(natgw_value.defined_tags, vcn_specific_gw_value.category_defined_tags, vcn_specific_gw_value.default_defined_tags)
          freeform_tags                  = merge(natgw_value.freeform_tags, vcn_specific_gw_value.category_freeform_tags, vcn_specific_gw_value.default_freeform_tags)
          display_name                   = natgw_value.display_name
          route_table_id                 = natgw_value.route_table_id
          route_table_key                = natgw_value.route_table_key
          block_traffic                  = natgw_value.block_traffic
          public_ip_id                   = natgw_value.public_ip_id
          network_configuration_category = vcn_specific_gw_value.network_configuration_category
          natgw_key                      = natgw_key
          vcn_name                       = vcn_specific_gw_value.vcn_name
          vcn_key                        = vcn_specific_gw_value.vcn_key
          natgw_key                      = natgw_key
          vcn_id                         = vcn_specific_gw_value.vcn_id
        }
      ] : [] : []
    ]) : flat_natgw.natgw_key => flat_natgw
  } : null

  provisioned_nat_gateways = {
    for natgw_key, natgw_value in oci_core_nat_gateway.these : natgw_key => {
      block_traffic                  = natgw_value.block_traffic
      compartment_id                 = natgw_value.compartment_id
      defined_tags                   = natgw_value.defined_tags
      display_name                   = natgw_value.display_name
      freeform_tags                  = natgw_value.freeform_tags
      id                             = natgw_value.id
      nat_ip                         = natgw_value.nat_ip
      public_ip_id                   = natgw_value.public_ip_id
      route_table_id                 = natgw_value.route_table_id
      route_table_key                = merge(local.one_dimension_processed_nat_gateways, local.one_dimension_processed_injected_nat_gateways)[natgw_key].route_table_key
      route_table_name               = merge(local.one_dimension_processed_nat_gateways, local.one_dimension_processed_injected_nat_gateways)[natgw_key].route_table_key != null ? oci_core_route_table.these_gw_attached[merge(local.one_dimension_processed_nat_gateways, local.one_dimension_processed_injected_nat_gateways)[natgw_key].route_table_key].display_name : null
      state                          = natgw_value.state
      time_created                   = natgw_value.time_created
      timeouts                       = natgw_value.timeouts
      vcn_id                         = natgw_value.vcn_id
      vcn_name                       = merge(local.one_dimension_processed_nat_gateways, local.one_dimension_processed_injected_nat_gateways)[natgw_key].vcn_name
      vcn_key                        = merge(local.one_dimension_processed_nat_gateways, local.one_dimension_processed_injected_nat_gateways)[natgw_key].vcn_key
      network_configuration_category = merge(local.one_dimension_processed_nat_gateways, local.one_dimension_processed_injected_nat_gateways)[natgw_key].network_configuration_category
      natgw_key                      = natgw_key
    }
  }
}


resource "oci_core_nat_gateway" "these" {
  for_each = merge(local.one_dimension_processed_nat_gateways, local.one_dimension_processed_injected_nat_gateways)
  #Required
  compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
  vcn_id         = each.value.vcn_id != null ? each.value.vcn_id : oci_core_vcn.these[each.value.vcn_key].id

  #Optional
  block_traffic  = each.value.block_traffic
  defined_tags   = each.value.defined_tags
  display_name   = each.value.display_name
  freeform_tags  = each.value.freeform_tags
  public_ip_id   = each.value.public_ip_id
  route_table_id = each.value.route_table_id != null ? each.value.route_table_id : each.value.route_table_key != null ? oci_core_route_table.these_gw_attached[each.value.route_table_key].id : null
}
