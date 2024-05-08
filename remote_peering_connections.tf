# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Mon Dec 11 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #


locals {
  one_dimension_remote_peering_connections_1 = local.one_dimension_dynamic_routing_gateways != null ? length(local.one_dimension_dynamic_routing_gateways) > 0 ? {
    for flat_rpc in flatten([
      for drg_key, drg_value in local.one_dimension_dynamic_routing_gateways :
      drg_value.remote_peering_connections != null ? length(drg_value.remote_peering_connections) > 0 ? [
        for rpc_key, rpc_value in drg_value.remote_peering_connections : {
          compartment_id                 = rpc_value.compartment_id != null ? rpc_value.compartment_id : drg_value.category_compartment_id != null ? drg_value.category_compartment_id : drg_value.default_compartment_id != null ? drg_value.default_compartment_id : null
          defined_tags                   = merge(rpc_value.defined_tags, drg_value.category_defined_tags, drg_value.default_defined_tags)
          freeform_tags                  = merge(rpc_value.freeform_tags, drg_value.category_freeform_tags, drg_value.default_freeform_tags)
          drg_id                         = oci_core_drg.these[drg_key].id
          drg_key                        = drg_key
          drg_name                       = oci_core_drg.these[drg_key].display_name
          display_name                   = rpc_value.display_name
          peer_id                        = rpc_value.peer_id
          peer_key                       = rpc_value.peer_key
          peer_region_name               = rpc_value.peer_region_name
          network_configuration_category = drg_value.network_configuration_category
          rpc_key                        = rpc_key
        }
      ] : [] : []
    ]) : flat_rpc.rpc_key => flat_rpc
  } : null : null

  one_dimension_injected_remote_peering_connections = local.one_dimension_inject_into_existing_drgs != null ? length(local.one_dimension_inject_into_existing_drgs) > 0 ? {
    for flat_rpc in flatten([
      for drg_key, drg_value in local.one_dimension_inject_into_existing_drgs :
      drg_value.remote_peering_connections != null ? length(drg_value.remote_peering_connections) > 0 ? [
        for rpc_key, rpc_value in drg_value.remote_peering_connections : {
          compartment_id                 = rpc_value.compartment_id != null ? rpc_value.compartment_id : drg_value.category_compartment_id != null ? drg_value.category_compartment_id : drg_value.default_compartment_id != null ? drg_value.default_compartment_id : null
          defined_tags                   = rpc_value.defined_tags
          freeform_tags                  = rpc_value.freeform_tags
          drg_id                         = drg_value.drg_id
          drg_key                        = drg_key
          drg_name                       = "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
          display_name                   = rpc_value.display_name
          peer_id                        = rpc_value.peer_id
          peer_key                       = rpc_value.peer_key
          peer_region_name               = rpc_value.peer_region_name
          network_configuration_category = drg_value.network_configuration_category
          rpc_key                        = rpc_key
        }
      ] : [] : []
    ]) : flat_rpc.rpc_key => flat_rpc
  } : null : null

  one_dimension_remote_peering_connections = merge(local.one_dimension_remote_peering_connections_1, local.one_dimension_injected_remote_peering_connections)

  one_dimension_processed_requestor_remote_peering_connections = local.one_dimension_remote_peering_connections != null ? length(local.one_dimension_remote_peering_connections) > 0 ? {
    for requestor_rpc_key, requestor_rpc_value in local.one_dimension_remote_peering_connections :
    requestor_rpc_key => requestor_rpc_value if requestor_rpc_value.peer_key != null || requestor_rpc_value.peer_id != null
  } : {} : {}

  one_dimension_processed_acceptor_remote_peering_connections = local.one_dimension_remote_peering_connections != null ? length(local.one_dimension_remote_peering_connections) > 0 ? {
    for acceptor_rpc_key, acceptor_rpc_value in local.one_dimension_remote_peering_connections :
    acceptor_rpc_key => acceptor_rpc_value if acceptor_rpc_value.peer_key == null && acceptor_rpc_value.peer_id == null
  } : {} : {}

  provisioned_remote_peering_connections = {
    for rpc_key, rpc_value in merge(
      oci_core_remote_peering_connection.oci_requestor_remote_peering_connections,
      oci_core_remote_peering_connection.oci_acceptor_remote_peering_connections
      ) : rpc_key => {
      compartment_id                 = rpc_value.compartment_id
      defined_tags                   = rpc_value.defined_tags
      display_name                   = rpc_value.display_name
      drg_id                         = rpc_value.drg_id
      drg_name                       = local.one_dimension_remote_peering_connections[rpc_key].drg_name
      drg_key                        = local.one_dimension_remote_peering_connections[rpc_key].drg_key
      freeform_tags                  = rpc_value.freeform_tags
      id                             = rpc_value.id
      is_cross_tenancy_peering       = rpc_value.is_cross_tenancy_peering
      peer_id                        = rpc_value.peer_id
      #peer_key                       = can([for rpc_key2, rpc_value2 in merge(oci_core_remote_peering_connection.oci_requestor_remote_peering_connections, oci_core_remote_peering_connection.oci_acceptor_remote_peering_connections) : rpc_key2 if rpc_value2.id == rpc_value.peer_id][0]) ? [for rpc_key2, rpc_value2 in merge(oci_core_remote_peering_connection.oci_requestor_remote_peering_connections, oci_core_remote_peering_connection.oci_acceptor_remote_peering_connections) : rpc_key2 if rpc_value2.id == rpc_value.peer_id][0] : "NOT PEERED OR PARTNER RPC CREATED OUTSIDE THIS AUTOMATION"
      #peer_name                      = can([for rpc_key2, rpc_value2 in merge(oci_core_remote_peering_connection.oci_requestor_remote_peering_connections, oci_core_remote_peering_connection.oci_acceptor_remote_peering_connections) : rpc_value2.display_name if rpc_value2.id == rpc_value.peer_id][0]) ? [for rpc_key2, rpc_value2 in merge(oci_core_remote_peering_connection.oci_requestor_remote_peering_connections, oci_core_remote_peering_connection.oci_acceptor_remote_peering_connections) : rpc_key2 if rpc_value2.id == rpc_value.peer_id][0] : "NOT PEERED OR PARTNER RPC CREATED OUTSIDE THIS AUTOMATION"
      peer_region_name               = rpc_value.peer_region_name
      peer_tenancy_id                = rpc_value.peer_tenancy_id
      peering_status                 = rpc_value.peering_status
      state                          = rpc_value.state
      time_created                   = rpc_value.time_created
      timeouts                       = rpc_value.timeouts
      network_configuration_category = local.one_dimension_remote_peering_connections[rpc_key].network_configuration_category
      rpc_key                        = rpc_key
    }
  }
}

# OCI RESOURCE
resource "oci_core_remote_peering_connection" "oci_acceptor_remote_peering_connections" {
  for_each = local.one_dimension_processed_acceptor_remote_peering_connections
  #Required
  compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
  #drg_id         = each.value.drg_id != null ? each.value.drg_id : each.value.drg_name != null ? oci_core_drg.these[each.value.drg_name].id : null
  drg_id = each.value.drg_id
  #Optional
  defined_tags  = each.value.defined_tags
  display_name  = each.value.display_name
  freeform_tags = merge(local.cislz_module_tag, each.value.freeform_tags)

  peer_region_name = null

  peer_id = null
}

# OCI RESOURCE
resource "oci_core_remote_peering_connection" "oci_requestor_remote_peering_connections" {
  for_each = local.one_dimension_processed_requestor_remote_peering_connections
  #Required
  compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
  drg_id         = each.value.drg_id
  #Optional
  defined_tags  = each.value.defined_tags
  display_name  = each.value.display_name
  freeform_tags = merge(local.cislz_module_tag, each.value.freeform_tags)

  peer_region_name = contains(keys(try(var.network_dependency["remote_peering_connections"],{})),each.value.peer_key) ? var.network_dependency["remote_peering_connections"][each.value.peer_key].region_name : each.value.peer_region_name

  peer_id = each.value.peer_id != null ? each.value.peer_id : (each.value.peer_key != null ? merge(oci_core_remote_peering_connection.oci_acceptor_remote_peering_connections, try(var.network_dependency["remote_peering_connections"],{}))[each.value.peer_key].id : null)
}