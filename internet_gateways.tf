# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

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
          vcn_id                         = local.provisioned_vcns[vcn_specific_gw_value.vcn_key].id
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

  //merging new VCNs defined IGWs with existing VCNs defined IGWs into a single map
  merged_one_dimension_processed_internet_gateways = merge(local.one_dimension_processed_internet_gateways, local.one_dimension_processed_injected_internet_gateways)

  provisioned_internet_gateways = {
    for igw_key, igw_value in oci_core_internet_gateway.these : igw_key => {
      compartment_id = igw_value.compartment_id
      defined_tags   = igw_value.defined_tags
      display_name   = igw_value.display_name
      enabled        = igw_value.enabled
      freeform_tags  = igw_value.freeform_tags
      id             = igw_value.id
      igw_key        = igw_key
      route_table_id = igw_value.route_table_id
      route_table_key = igw_value.route_table_id == merge(
        local.provisioned_vcns,
        local.one_dimension_processed_existing_vcns
      )[local.merged_one_dimension_processed_internet_gateways[igw_key].vcn_key].default_route_table_id ? "default_route_table" : local.merged_one_dimension_processed_internet_gateways[igw_key].route_table_key == null ? local.merged_one_dimension_processed_internet_gateways[igw_key].route_table_id != null ? "CANNOT BE DETERMINED AS NOT CREATED BY THIS AUTOMATION" : null : local.merged_one_dimension_processed_internet_gateways[igw_key].route_table_key
      route_table_name = igw_value.route_table_id == merge(
        local.provisioned_vcns,
        local.one_dimension_processed_existing_vcns
        )[local.merged_one_dimension_processed_internet_gateways[igw_key].vcn_key].default_route_table_id ? "default_route_table" : local.merged_one_dimension_processed_internet_gateways[igw_key].route_table_key == null ? local.merged_one_dimension_processed_internet_gateways[igw_key].route_table_id != null ? "CANNOT BE DETERMINED AS NOT CREATED BY THIS AUTOMATION" : null : can(
      local.provisioned_igw_natgw_specific_route_tables[local.merged_one_dimension_processed_internet_gateways[igw_key].route_table_key].display_name) ? local.provisioned_igw_natgw_specific_route_tables[local.merged_one_dimension_processed_internet_gateways[igw_key].route_table_key].display_name : "CANNOT BE DETERMINED AS NOT CREATED BY THIS AUTOMATION"
      state                          = igw_value.state
      time_created                   = igw_value.time_created
      timeouts                       = igw_value.timeouts
      vcn_id                         = igw_value.vcn_id
      vcn_name                       = local.merged_one_dimension_processed_internet_gateways[igw_key].vcn_name
      vcn_key                        = local.merged_one_dimension_processed_internet_gateways[igw_key].vcn_key
      network_configuration_category = local.merged_one_dimension_processed_internet_gateways[igw_key].network_configuration_category
    }
  }
}



# OCI RESOURCE

resource "oci_core_internet_gateway" "these" {
  for_each = local.merged_one_dimension_processed_internet_gateways

  #Required
  compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
  vcn_id         = each.value.vcn_id

  #Optional
  enabled       = each.value.enabled
  defined_tags  = each.value.defined_tags
  display_name  = each.value.display_name
  freeform_tags = merge(local.cislz_module_tag, each.value.freeform_tags)
  // Searching for the id based on the key in the:
  //       - IGW and NAT GW specific route tables: local.provisioned_igw_natgw_specific_route_tables + the default route table
  route_table_id = each.value.route_table_id != null ? each.value.route_table_id : each.value.route_table_key != null ? merge(
    {
      for rt_key, rt_value in local.provisioned_igw_natgw_specific_route_tables : rt_key => {
        id = rt_value.id
      }
    },
    {
      "default_route_table" = {
        id = oci_core_vcn.these[each.value.vcn_key].default_route_table_id
      }
    }
  )[each.value.route_table_key].id : null
}
