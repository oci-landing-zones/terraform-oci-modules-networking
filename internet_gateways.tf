# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# PROCESSED INPUT

locals {
  one_dimension_processed_internet_gateways = local.one_dimension_processed_vcn_specific_gateways != null ? {
    for flat_igw in flatten([
      for vcn_specific_gw_key, vcn_specific_gw_value in local.one_dimension_processed_vcn_specific_gateways :
      vcn_specific_gw_value.internet_gateways != null ? length(vcn_specific_gw_value.internet_gateways) > 0 ? [
        for igw_key, igw_value in vcn_specific_gw_value.internet_gateways : {
          compartment_id                 = igw_value.compartment_id != null ? igw_value.compartment_id : vcn_specific_gw_value.category_compartment_id != null ? vcn_specific_gw_value.category_compartment_id : vcn_specific_gw_value.default_compartment_id != null ? vcn_specific_gw_value.default_compartment_id : null
          defined_tags                   = merge(igw_value.defined_tags, vcn_specific_gw_value.category_defined_tags, vcn_specific_gw_value.default_defined_tags)
          freeform_tags                  = merge(igw_value.freeform_tags, vcn_specific_gw_value.category_freeform_tags, vcn_specific_gw_value.default_freeform_tags)
          display_name                   = igw_value.display_name
          enabled                        = igw_value.enabled
          route_table_id                 = null
          route_table_key                = igw_value.route_table_key
          network_configuration_category = vcn_specific_gw_value.network_configuration_category
          igw_key                        = igw_key
          vcn_name                       = vcn_specific_gw_value.vcn_name
          vcn_key                        = vcn_specific_gw_value.vcn_key
          vcn_id                         = null
        }
      ] : [] : []
    ]) : flat_igw.igw_key => flat_igw
  } : null

  one_dimension_processed_injected_internet_gateways = local.one_dimension_processed_inject_vcn_specific_gateways != null ? {
    for flat_igw in flatten([
      for vcn_specific_gw_key, vcn_specific_gw_value in local.one_dimension_processed_inject_vcn_specific_gateways :
      vcn_specific_gw_value.internet_gateways != null ? length(vcn_specific_gw_value.internet_gateways) > 0 ? [
        for igw_key, igw_value in vcn_specific_gw_value.internet_gateways : {
          compartment_id                 = igw_value.compartment_id != null ? igw_value.compartment_id : vcn_specific_gw_value.category_compartment_id != null ? vcn_specific_gw_value.category_compartment_id : vcn_specific_gw_value.default_compartment_id != null ? vcn_specific_gw_value.default_compartment_id : null
          defined_tags                   = merge(igw_value.defined_tags, vcn_specific_gw_value.category_defined_tags, vcn_specific_gw_value.default_defined_tags)
          freeform_tags                  = merge(igw_value.freeform_tags, vcn_specific_gw_value.category_freeform_tags, vcn_specific_gw_value.default_freeform_tags)
          display_name                   = igw_value.display_name
          enabled                        = igw_value.enabled
          route_table_id                 = igw_value.route_table_id
          route_table_key                = igw_value.route_table_key
          network_configuration_category = vcn_specific_gw_value.network_configuration_category
          igw_key                        = igw_key
          vcn_name                       = vcn_specific_gw_value.vcn_name
          vcn_key                        = vcn_specific_gw_value.vcn_key
          vcn_id                         = vcn_specific_gw_value.vcn_id
        }
      ] : [] : []
    ]) : flat_igw.igw_key => flat_igw
  } : null

  provisioned_internet_gateways = {
    for igw_key, igw_value in oci_core_internet_gateway.these : igw_key => {
      compartment_id                 = igw_value.compartment_id
      defined_tags                   = igw_value.defined_tags
      display_name                   = igw_value.display_name
      enabled                        = igw_value.enabled
      freeform_tags                  = igw_value.freeform_tags
      id                             = igw_value.id
      igw_key                        = igw_key
      route_table_id                 = igw_value.route_table_id
      route_table_key                = merge(local.one_dimension_processed_internet_gateways, local.one_dimension_processed_injected_internet_gateways)[igw_key].route_table_key
      route_table_name               = merge(local.one_dimension_processed_internet_gateways, local.one_dimension_processed_injected_internet_gateways)[igw_key].route_table_key != null ? oci_core_route_table.these_gw_attached[merge(local.one_dimension_processed_internet_gateways, local.one_dimension_processed_injected_internet_gateways)[igw_key].route_table_key].display_name : null
      state                          = igw_value.state
      time_created                   = igw_value.time_created
      timeouts                       = igw_value.timeouts
      vcn_id                         = igw_value.vcn_id
      vcn_name                       = merge(local.one_dimension_processed_internet_gateways, local.one_dimension_processed_injected_internet_gateways)[igw_key].vcn_name
      vcn_key                        = merge(local.one_dimension_processed_internet_gateways, local.one_dimension_processed_injected_internet_gateways)[igw_key].vcn_key
      network_configuration_category = merge(local.one_dimension_processed_internet_gateways, local.one_dimension_processed_injected_internet_gateways)[igw_key].network_configuration_category
    }
  }
}



# OCI RESOURCE

resource "oci_core_internet_gateway" "these" {
  for_each = merge(local.one_dimension_processed_internet_gateways, local.one_dimension_processed_injected_internet_gateways)

  #Required
  compartment_id = each.value.compartment_id
  vcn_id         = each.value.vcn_id != null ? each.value.vcn_id : oci_core_vcn.these[each.value.vcn_key].id

  #Optional
  enabled        = each.value.enabled
  defined_tags   = each.value.defined_tags
  display_name   = each.value.display_name
  freeform_tags  = each.value.freeform_tags
  route_table_id = each.value.route_table_id != null ? each.value.route_table_id : each.value.route_table_key != null ? oci_core_route_table.these_gw_attached[each.value.route_table_key].id : null
}
