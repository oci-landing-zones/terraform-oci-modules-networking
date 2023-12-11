# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Mon Dec 11 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #


locals {
  one_dimension_processed_drg_route_tables_route_rules = local.one_dimension_processed_drg_route_tables != null ? length(local.one_dimension_processed_drg_route_tables) > 0 ? {
    for flat_drgrtsrrs in flatten([
      for drgrt_key, drgrt_value in local.one_dimension_processed_drg_route_tables :
      drgrt_value.route_rules != null ? length(drgrt_value.route_rules) > 0 ? [
        for drgrtrr_key, drgrtrr_value in drgrt_value.route_rules : {
          drg_route_table_id             = local.provisioned_drg_route_tables[drgrt_key].id
          destination                    = drgrtrr_value.destination
          destination_type               = drgrtrr_value.destination_type
          next_hop_drg_attachment_id     = drgrtrr_value.next_hop_drg_attachment_id != null ? drgrtrr_value.next_hop_drg_attachment_id : drgrtrr_value.next_hop_drg_attachment_key != null ? merge(local.provisioned_drg_attachments, local.provisioned_fast_connect_virtual_circuits, local.rpc_drg_attachments)[drgrtrr_value.next_hop_drg_attachment_key].id : null
          next_hop_drg_attachment_key    = drgrtrr_value.next_hop_drg_attachment_key
          drg_id                         = drgrt_value.drg_id
          drg_name                       = drgrt_value.drg_name
          drg_key                        = drgrt_value.drg_key
          network_configuration_category = drgrt_value.network_configuration_category
          drgrtrr_key                    = drgrtrr_key
          drgrt_key                      = drgrt_key
          drgrt_name                     = drgrt_value.display_name
        }
      ] : [] : []
    ]) : flat_drgrtsrrs.drgrtrr_key => flat_drgrtsrrs
  } : null : null

  provisioned_drg_route_tables_route_rules = {
    for drgrtrr_key, drgrtrr_value in oci_core_drg_route_table_route_rule.these : drgrtrr_key => {

      attributes                     = drgrtrr_value.attributes
      destination                    = drgrtrr_value.destination
      destination_type               = drgrtrr_value.destination_type
      drg_route_table_id             = drgrtrr_value.drg_route_table_id
      id                             = drgrtrr_value.id
      is_blackhole                   = drgrtrr_value.is_blackhole
      is_conflict                    = drgrtrr_value.is_conflict
      next_hop_drg_attachment_id     = drgrtrr_value.next_hop_drg_attachment_id
      next_hop_drg_attachment_key    = local.one_dimension_processed_drg_route_tables_route_rules[drgrtrr_key].next_hop_drg_attachment_key != null ? local.one_dimension_processed_drg_route_tables_route_rules[drgrtrr_key].next_hop_drg_attachment_key : "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
      route_provenance               = drgrtrr_value.route_provenance
      route_type                     = drgrtrr_value.route_type
      timeouts                       = drgrtrr_value.timeouts
      drg_id                         = local.one_dimension_processed_drg_route_tables_route_rules[drgrtrr_key].drg_id
      drg_name                       = local.one_dimension_processed_drg_route_tables_route_rules[drgrtrr_key].drg_name
      drg_key                        = local.one_dimension_processed_drg_route_tables_route_rules[drgrtrr_key].drg_key
      network_configuration_category = local.one_dimension_processed_drg_route_tables_route_rules[drgrtrr_key].network_configuration_category
      drg_route_table_route_rule_key = drgrtrr_key
      drg_route_table_key            = local.one_dimension_processed_drg_route_tables_route_rules[drgrtrr_key].drgrt_key
      drg_route_table_name           = local.one_dimension_processed_drg_route_tables_route_rules[drgrtrr_key].drgrt_name

    }
  }
}

resource "oci_core_drg_route_table_route_rule" "these" {
  for_each = local.one_dimension_processed_drg_route_tables_route_rules != null ? local.one_dimension_processed_drg_route_tables_route_rules : {}
  #Required
  drg_route_table_id         = each.value.drg_route_table_id
  destination                = each.value.destination
  destination_type           = each.value.destination_type
  next_hop_drg_attachment_id = each.value.next_hop_drg_attachment_id
}