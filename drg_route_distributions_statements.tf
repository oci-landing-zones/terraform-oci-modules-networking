# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Thu Nov 23 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

data "oci_core_drg_attachments" "fc_vc_drg_attachments" {
  for_each = local.provisioned_fast_connect_virtual_circuits
  #Required
  compartment_id  = each.value.compartment_id
  attachment_type = "ALL"

  #Optional
  network_id = each.value.id
  drg_id     = each.value.gateway_id
}

data "oci_core_drg_attachments" "rpc_drg_attachments" {
  for_each = local.provisioned_remote_peering_connections
  #Required
  compartment_id  = each.value.compartment_id
  attachment_type = "ALL"

  #Optional
  network_id = each.value.id
  drg_id     = each.value.drg_id
}

data "oci_core_drg_attachments" "ipsec_drg_attachments" {
  for_each = local.provisioned_ipsec_connection_tunnels_management
  #Required
  compartment_id  = each.value.compartment_id
  attachment_type = "ALL"

  #Optional
  network_id = each.value.id
  drg_id     = each.value.drg_id
}

locals {
  fc_vc_drg_attachments = data.oci_core_drg_attachments.fc_vc_drg_attachments != null ? length(data.oci_core_drg_attachments.fc_vc_drg_attachments) > 0 ? {
    for fcvcdrga_key, fcvcdrga_value in data.oci_core_drg_attachments.fc_vc_drg_attachments : fcvcdrga_key => fcvcdrga_value.drg_attachments[0] if length(fcvcdrga_value.drg_attachments) > 0
  } : null : null

  rpc_drg_attachments = data.oci_core_drg_attachments.rpc_drg_attachments != null ? length(data.oci_core_drg_attachments.rpc_drg_attachments) > 0 ? {
    for rpcdrga_key, rpcdrga_value in data.oci_core_drg_attachments.rpc_drg_attachments : rpcdrga_key => rpcdrga_value.drg_attachments[0] if length(rpcdrga_value.drg_attachments) > 0
  } : null : null

  ipsec_drg_attachments = data.oci_core_drg_attachments.ipsec_drg_attachments != null ? length(data.oci_core_drg_attachments.ipsec_drg_attachments) > 0 ? {
    for ipsecdrga_key, ipsecdrga_value in data.oci_core_drg_attachments.ipsec_drg_attachments : ipsecdrga_key => ipsecdrga_value.drg_attachments[0] if length(ipsecdrga_value.drg_attachments) > 0
  } : null : null

  drtd_attachments = merge(
    local.provisioned_drg_attachments,
    local.fc_vc_drg_attachments,
    local.rpc_drg_attachments,
    local.ipsec_drg_attachments
  )

  one_dimension_processed_drg_route_distributions_statements = local.one_dimension_processed_drg_route_distributions != null ? length(local.one_dimension_processed_drg_route_distributions) > 0 ? {
    for flat_drgrdssts in flatten([
      for drgrd_key, drgrd_value in local.one_dimension_processed_drg_route_distributions :
      drgrd_value.statements != null ? length(drgrd_value.statements) > 0 ? [
        for drgrdsts_key, drgrdsts_value in drgrd_value.statements : {
          drg_route_distribution_id      = oci_core_drg_route_distribution.these[drgrd_key].id
          drg_id                         = drgrd_value.drg_id
          drg_name                       = drgrd_value.drg_name
          drg_key                        = drgrd_value.drg_key
          drg_route_distribution_key     = drgrd_key
          drg_route_distribution_name    = oci_core_drg_route_distribution.these[drgrd_key].display_name
          drg_route_distribution_id      = oci_core_drg_route_distribution.these[drgrd_key].id
          network_configuration_category = drgrd_value.network_configuration_category
          action                         = drgrdsts_value.action
          priority                       = drgrdsts_value.priority
          match_criteria = drgrdsts_value.match_criteria != null ? {
            match_type = drgrdsts_value.match_criteria.match_type
            #Optional
            attachment_type    = drgrdsts_value.match_criteria.attachment_type
            drg_attachment_key = drgrdsts_value.match_criteria.drg_attachment_key
            drg_attachment_id  = length(regexall("^ocid1.drgattachment.*$", coalesce(drgrdsts_value.match_criteria.drg_attachment_id,"__void__"))) > 0 ? drgrdsts_value.match_criteria.drg_attachment_id : (contains(keys(local.drtd_attachments),coalesce(drgrdsts_value.match_criteria.drg_attachment_key,"__void__")) ? local.drtd_attachments[drgrdsts_value.match_criteria.drg_attachment_key].id : var.network_dependency != null ? (contains(keys(var.network_dependency["drg_attachments"]),coalesce(drgrdsts_value.match_criteria.drg_attachment_key,"__void__")) ? var.network_dependency["drg_attachments"][drgrdsts_value.match_criteria.drg_attachment_key].id : null): null)
          } : null
          drgrdsts_key = drgrdsts_key
        }
      ] : [] : []
    ]) : flat_drgrdssts.drgrdsts_key => flat_drgrdssts
  } : null : null

  provisioned_drg_route_distributions_statements = {
    for drgrdsts_key, drgrdsts_value in oci_core_drg_route_distribution_statement.these : drgrdsts_key => {
      id                          = drgrdsts_value.id
      drgrdsts_key                = drgrdsts_key
      drg_route_distribution_id   = local.one_dimension_processed_drg_route_distributions_statements[drgrdsts_key].drg_route_distribution_id
      drg_route_distribution_key  = local.one_dimension_processed_drg_route_distributions_statements[drgrdsts_key].drg_route_distribution_key
      drg_route_distribution_name = local.one_dimension_processed_drg_route_distributions_statements[drgrdsts_key].drg_route_distribution_name
      action                      = drgrdsts_value.action
      match_criteria = {
        attachment_type     = drgrdsts_value.match_criteria[0].attachment_type
        drg_attachment_id   = drgrdsts_value.match_criteria[0].drg_attachment_id
        drg_attachment_key  = contains(keys(local.one_dimension_processed_drg_route_distributions_statements[drgrdsts_key].match_criteria), "drg_attachment_key") ? local.one_dimension_processed_drg_route_distributions_statements[drgrdsts_key].match_criteria.drg_attachment_key : "NOT DETERMINED AS DRG_ATTACHMENT NOT CREATED BY THIS AUTOMATION"
        #drg_attachment_name = contains(keys(local.one_dimension_processed_drg_route_distributions_statements[drgrdsts_key].match_criteria), "drg_attachment_key") ? local.one_dimension_processed_drg_route_distributions_statements[drgrdsts_key].match_criteria.drg_attachment_key != null ? local.drtd_attachments[local.one_dimension_processed_drg_route_distributions_statements[drgrdsts_key].match_criteria.drg_attachment_key].display_name : "NOT DETERMINED AS DRG_ATTACHMENT NOT CREATED BY THIS AUTOMATION" : "NOT DETERMINED AS DRG_ATTACHMENT NOT CREATED BY THIS AUTOMATION"
      }
      priority                       = drgrdsts_value.priority
      drg_id                         = local.one_dimension_processed_drg_route_distributions_statements[drgrdsts_key].drg_id
      drg_name                       = local.one_dimension_processed_drg_route_distributions_statements[drgrdsts_key].drg_name
      drg_key                        = local.one_dimension_processed_drg_route_distributions_statements[drgrdsts_key].drg_key
      network_configuration_category = local.one_dimension_processed_drg_route_distributions_statements[drgrdsts_key].network_configuration_category
    }
  }
}

resource "oci_core_drg_route_distribution_statement" "these" {
  for_each = local.one_dimension_processed_drg_route_distributions_statements != null ? local.one_dimension_processed_drg_route_distributions_statements : {}
  #Required
  drg_route_distribution_id = each.value.drg_route_distribution_id
  action                    = each.value.action
  #Optional 
  priority = each.value.priority
  #Optional
  dynamic "match_criteria" {
    for_each = each.value.match_criteria != null ? [1] : []

    content {
      #Required
      match_type = each.value.match_criteria.match_type
      #Optional
      attachment_type   = each.value.match_criteria.attachment_type
      drg_attachment_id = each.value.match_criteria.drg_attachment_id
    }
  }
}


