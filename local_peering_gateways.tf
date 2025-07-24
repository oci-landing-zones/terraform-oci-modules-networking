# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

locals {
  one_dimension_processed_local_peering_gateways = local.one_dimension_processed_vcn_specific_gateways != null ? {
    for flat_lpgw in flatten([
      for vcn_specific_gw_key, vcn_specific_gw_value in local.one_dimension_processed_vcn_specific_gateways :
      vcn_specific_gw_value.local_peering_gateways != null ? length(vcn_specific_gw_value.local_peering_gateways) > 0 ? [
        for lpgw_key, lpgw_value in vcn_specific_gw_value.local_peering_gateways : {
          compartment_id                 = lpgw_value.compartment_id != null ? lpgw_value.compartment_id : vcn_specific_gw_value.category_compartment_id != null ? vcn_specific_gw_value.category_compartment_id : vcn_specific_gw_value.default_compartment_id != null ? vcn_specific_gw_value.default_compartment_id : null
          defined_tags                   = merge(lpgw_value.defined_tags, vcn_specific_gw_value.category_defined_tags, vcn_specific_gw_value.default_defined_tags)
          freeform_tags                  = merge(lpgw_value.freeform_tags, vcn_specific_gw_value.category_freeform_tags, vcn_specific_gw_value.default_freeform_tags)
          display_name                   = lpgw_value.display_name
          route_table_id                 = null
          route_table_key                = lpgw_value.route_table_key
          peer_id                        = lpgw_value.peer_id
          peer_key                       = lpgw_value.peer_key
          network_configuration_category = vcn_specific_gw_value.network_configuration_category
          lpgw_key                       = lpgw_key
          vcn_name                       = vcn_specific_gw_value.vcn_name
          vcn_key                        = vcn_specific_gw_value.vcn_key
          vcn_id                         = null
        }
      ] : [] : []
    ]) : flat_lpgw.lpgw_key => flat_lpgw
  } : null

  one_dimension_processed_injected_local_peering_gateways = local.one_dimension_processed_inject_vcn_specific_gateways != null ? {
    for flat_lpgw in flatten([
      for vcn_specific_gw_key, vcn_specific_gw_value in local.one_dimension_processed_inject_vcn_specific_gateways :
      vcn_specific_gw_value.local_peering_gateways != null ? length(vcn_specific_gw_value.local_peering_gateways) > 0 ? [
        for lpgw_key, lpgw_value in vcn_specific_gw_value.local_peering_gateways : {
          compartment_id                 = lpgw_value.compartment_id != null ? lpgw_value.compartment_id : vcn_specific_gw_value.category_compartment_id != null ? vcn_specific_gw_value.category_compartment_id : vcn_specific_gw_value.default_compartment_id != null ? vcn_specific_gw_value.default_compartment_id : null
          defined_tags                   = merge(lpgw_value.defined_tags, vcn_specific_gw_value.category_defined_tags, vcn_specific_gw_value.default_defined_tags)
          freeform_tags                  = merge(lpgw_value.freeform_tags, vcn_specific_gw_value.category_freeform_tags, vcn_specific_gw_value.default_freeform_tags)
          display_name                   = lpgw_value.display_name
          route_table_id                 = lpgw_value.route_table_id
          route_table_key                = lpgw_value.route_table_key
          peer_id                        = lpgw_value.peer_id
          peer_key                       = lpgw_value.peer_key
          network_configuration_category = vcn_specific_gw_value.network_configuration_category
          lpgw_key                       = lpgw_key
          vcn_name                       = vcn_specific_gw_value.vcn_name
          vcn_key                        = vcn_specific_gw_value.vcn_key
          vcn_id                         = vcn_specific_gw_value.vcn_id
        }
      ] : [] : []
    ]) : flat_lpgw.lpgw_key => flat_lpgw
  } : null

  merged_one_dimension_processed_local_peering_gateways = merge(local.one_dimension_processed_local_peering_gateways, local.one_dimension_processed_injected_local_peering_gateways)

  one_dimension_processed_requestor_local_peering_gateways = local.merged_one_dimension_processed_local_peering_gateways != null ? length(local.merged_one_dimension_processed_local_peering_gateways) > 0 ? {
    for requestor_lpg_key, requestor_lpg_value in local.merged_one_dimension_processed_local_peering_gateways :
    requestor_lpg_key => requestor_lpg_value if requestor_lpg_value.peer_key != null || requestor_lpg_value.peer_id != null
  } : {} : {}

  one_dimension_processed_acceptor_local_peering_gateways = local.merged_one_dimension_processed_local_peering_gateways != null ? length(local.merged_one_dimension_processed_local_peering_gateways) > 0 ? {
    for acceptor_lpg_key, acceptor_lpg_value in local.merged_one_dimension_processed_local_peering_gateways :
    acceptor_lpg_key => acceptor_lpg_value if acceptor_lpg_value.peer_key == null && acceptor_lpg_value.peer_id == null
  } : {} : {}

  provisioned_local_peering_gateways = {
    for lpg_key, lpg_value in merge(oci_core_local_peering_gateway.oci_acceptor_local_peering_gateways, oci_core_local_peering_gateway.oci_requestor_local_peering_gateways) : lpg_key => {
      compartment_id               = lpg_value.compartment_id
      defined_tags                 = lpg_value.defined_tags
      display_name                 = lpg_value.display_name
      freeform_tags                = lpg_value.freeform_tags
      id                           = lpg_value.id
      role                         = contains(keys(local.one_dimension_processed_requestor_local_peering_gateways), lpg_key) ? "REQUESTOR" : contains(keys(local.one_dimension_processed_acceptor_local_peering_gateways), lpg_key) ? "ACCEPTOR" : null
      is_cross_tenancy_peering     = lpg_value.is_cross_tenancy_peering
      peer_advertised_cidr         = lpg_value.peer_advertised_cidr
      peer_advertised_cidr_details = lpg_value.peer_advertised_cidr_details
      peer_id                      = lpg_value.peer_id
      #peer_key                     = can([for lpg_key2, lpg_value2 in merge(oci_core_local_peering_gateway.oci_acceptor_local_peering_gateways, oci_core_local_peering_gateway.oci_requestor_local_peering_gateways) : lpg_key2 if lpg_value2.id == lpg_value.peer_id][0]) ? [for lpg_key2, lpg_value2 in merge(oci_core_local_peering_gateway.oci_acceptor_local_peering_gateways, oci_core_local_peering_gateway.oci_requestor_local_peering_gateways) : lpg_key2 if lpg_value2.id == lpg_value.peer_id][0] : "NOT PEERED OR PARTNER LPG CREATED OUTSIDE THIS AUTOMATION"
      #peer_name                    = can([for lpg_key2, lpg_value2 in merge(oci_core_local_peering_gateway.oci_acceptor_local_peering_gateways, oci_core_local_peering_gateway.oci_requestor_local_peering_gateways) : lpg_value2.display_name if lpg_value2.id == lpg_value.peer_id][0]) ? [for lpg_key2, lpg_value2 in merge(oci_core_local_peering_gateway.oci_acceptor_local_peering_gateways, oci_core_local_peering_gateway.oci_requestor_local_peering_gateways) : lpg_value2.display_name if lpg_value2.id == lpg_value.peer_id][0] : "NOT PEERED OR PARTNER LPG CREATED OUTSIDE THIS AUTOMATION"
      peering_status               = lpg_value.peering_status
      peering_status_details       = lpg_value.peering_status_details
      route_table_id               = lpg_value.route_table_id
      route_table_key = lpg_value.route_table_id == merge(
        local.provisioned_vcns,
        local.one_dimension_processed_existing_vcns
      )[local.merged_one_dimension_processed_local_peering_gateways[lpg_key].vcn_key].default_route_table_id ? "default_route_table" : local.merged_one_dimension_processed_local_peering_gateways[lpg_key].route_table_key == null ? local.merged_one_dimension_processed_local_peering_gateways[lpg_key].route_table_id != null ? "CANNOT BE DETERMINED AS NOT CREATED BY THIS AUTOMATION" : null : local.merged_one_dimension_processed_local_peering_gateways[lpg_key].route_table_key
      route_table_name = lpg_value.route_table_id == merge(
        local.provisioned_vcns,
        local.one_dimension_processed_existing_vcns
        )[local.merged_one_dimension_processed_local_peering_gateways[lpg_key].vcn_key].default_route_table_id ? "default_route_table" : local.merged_one_dimension_processed_local_peering_gateways[lpg_key].route_table_key == null ? local.merged_one_dimension_processed_local_peering_gateways[lpg_key].route_table_id != null ? "CANNOT BE DETERMINED AS NOT CREATED BY THIS AUTOMATION" : null : can(
        merge(
          local.provisioned_igw_natgw_specific_route_tables,
          local.provisioned_lpg_specific_route_tables
        )[local.merged_one_dimension_processed_local_peering_gateways[lpg_key].route_table_key].display_name) ? merge(
        local.provisioned_igw_natgw_specific_route_tables,
        local.provisioned_lpg_specific_route_tables
      )[local.merged_one_dimension_processed_local_peering_gateways[lpg_key].route_table_key].display_name : "CANNOT BE DETERMINED AS NOT CREATED BY THIS AUTOMATION"
      state                          = lpg_value.state
      time_created                   = lpg_value.time_created
      timeouts                       = lpg_value.timeouts
      lpg_key                        = lpg_key
      vcn_id                         = lpg_value.vcn_id
      vcn_name                       = local.merged_one_dimension_processed_local_peering_gateways[lpg_key].vcn_name
      vcn_key                        = local.merged_one_dimension_processed_local_peering_gateways[lpg_key].vcn_key
      network_configuration_category = local.merged_one_dimension_processed_local_peering_gateways[lpg_key].network_configuration_category
    }
  }
}

resource "oci_core_local_peering_gateway" "oci_acceptor_local_peering_gateways" {
  for_each = local.one_dimension_processed_acceptor_local_peering_gateways
  #Required
  compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
  vcn_id         = each.value.vcn_id != null ? each.value.vcn_id : oci_core_vcn.these[each.value.vcn_key].id

  #Optional
  defined_tags  = each.value.defined_tags
  display_name  = each.value.display_name
  freeform_tags = merge(local.cislz_module_tag, each.value.freeform_tags)
  peer_id       = null
  route_table_id = each.value.route_table_id != null ? each.value.route_table_id : each.value.route_table_key != null ? merge(
    {
      for rt_key, rt_value in merge(
        local.provisioned_igw_natgw_specific_route_tables,
        local.provisioned_lpg_specific_route_tables
        ) : rt_key => {
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

resource "oci_core_local_peering_gateway" "oci_requestor_local_peering_gateways" {
  for_each = local.one_dimension_processed_requestor_local_peering_gateways
  #Required
  compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
  vcn_id         = each.value.vcn_id != null ? each.value.vcn_id : oci_core_vcn.these[each.value.vcn_key].id

  #Optional
  defined_tags  = each.value.defined_tags
  display_name  = each.value.display_name
  freeform_tags = merge(local.cislz_module_tag, each.value.freeform_tags)

  peer_id = each.value.peer_id != null ? each.value.peer_id : (each.value.peer_key != null ? merge(oci_core_local_peering_gateway.oci_acceptor_local_peering_gateways, try(var.network_dependency["local_peering_gateways"],{}))[each.value.peer_key].id : null)

  route_table_id = each.value.route_table_id != null ? each.value.route_table_id : each.value.route_table_key != null ? merge(
    {
      for rt_key, rt_value in merge(
        local.provisioned_igw_natgw_specific_route_tables,
        local.provisioned_lpg_specific_route_tables
        ) : rt_key => {
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
