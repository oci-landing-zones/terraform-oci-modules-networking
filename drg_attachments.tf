# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Jan 03 2024                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #


locals {
  one_dimension_processed_drg_attachments_1 = local.one_dimension_dynamic_routing_gateways != null ? length(local.one_dimension_dynamic_routing_gateways) > 0 ? {
    for flat_drga in flatten([
      for drg_key, drg_value in local.one_dimension_dynamic_routing_gateways :
      drg_value.drg_attachments != null ? length(drg_value.drg_attachments) > 0 ? [
        for drga_key, drga_value in drg_value.drg_attachments : {
          defined_tags        = merge(drga_value.defined_tags, drg_value.category_defined_tags, drg_value.default_defined_tags)
          freeform_tags       = merge(drga_value.freeform_tags, drg_value.category_freeform_tags, drg_value.default_freeform_tags)
          drg_id              = oci_core_drg.these[drg_key].id
          drg_name            = drg_value.display_name
          drg_key             = drg_key
          display_name        = drga_value.display_name
          drg_route_table_id  = drga_value.drg_route_table_id
          drg_route_table_key = drga_value.drg_route_table_key
          network_details = drga_value.network_details != null ? {
            attached_resource_id  = drga_value.network_details.attached_resource_id
            attached_resource_key = drga_value.network_details.attached_resource_key
            type                  = drga_value.network_details.type
            route_table_id        = drga_value.network_details.route_table_id
            route_table_key       = drga_value.network_details.route_table_key
            vcn_route_type        = drga_value.network_details.vcn_route_type
          } : null
          network_configuration_category = drg_value.network_configuration_category
          drga_key                       = drga_key
        } if drga_value.network_details.type == "VCN"
      ] : [] : []
    ]) : flat_drga.drga_key => flat_drga
  } : null : null

  one_dimension_injected_drg_attachments = local.one_dimension_inject_into_existing_drgs != null ? length(local.one_dimension_inject_into_existing_drgs) > 0 ? {
    for flat_drga in flatten([
      for drg_key, drg_value in local.one_dimension_inject_into_existing_drgs :
      drg_value.drg_attachments != null ? length(drg_value.drg_attachments) > 0 ? [
        for drga_key, drga_value in drg_value.drg_attachments : {
          defined_tags        = drga_value.defined_tags
          freeform_tags       = drga_value.freeform_tags
          drg_id              = drg_value.drg_id
          drg_name            = "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
          drg_key             = drg_key
          display_name        = drga_value.display_name
          drg_route_table_id  = drga_value.drg_route_table_id
          drg_route_table_key = drga_value.drg_route_table_key
          network_details = drga_value.network_details != null ? {
            attached_resource_id  = drga_value.network_details.attached_resource_id
            attached_resource_key = drga_value.network_details.attached_resource_key
            type                  = drga_value.network_details.type
            route_table_id        = drga_value.network_details.route_table_id
            route_table_key       = drga_value.network_details.route_table_key
            vcn_route_type        = drga_value.network_details.vcn_route_type
          } : null
          network_configuration_category = drg_value.network_configuration_category
          drga_key                       = drga_key
        } if drga_value.network_details.type == "VCN"
      ] : [] : []
    ]) : flat_drga.drga_key => flat_drga
  } : null : null

  one_dimension_processed_drg_attachments = merge(local.one_dimension_processed_drg_attachments_1, local.one_dimension_injected_drg_attachments)

  all_known_vcn_default_route_tables = {
    for vcn_key, vcn_value in merge(
      local.provisioned_vcns,
      local.one_dimension_processed_existing_vcns
      ) : vcn_value.default_route_table_id => {
      id  = vcn_value.default_route_table_id
      key = "${vcn_key}_default_route_table"
    } if vcn_value.default_route_table_id != null
  }

  provisioned_drg_attachments = {
    for drga_key, drga_value in oci_core_drg_attachment.these : drga_key => {
      compartment_id                   = drga_value.compartment_id
      defined_tags                     = drga_value.defined_tags
      display_name                     = drga_value.display_name
      drg_id                           = drga_value.drg_id
      drg_key                          = local.one_dimension_processed_drg_attachments[drga_key].drg_key
      drg_name                         = local.one_dimension_processed_drg_attachments[drga_key].drg_name
      drg_route_table_id               = drga_value.drg_route_table_id
      drg_route_table_key              = local.one_dimension_processed_drg_attachments[drga_key].drg_route_table_key != null ? local.one_dimension_processed_drg_attachments[drga_key].drg_route_table_key : "CANNOT BE DETERMINED - ROUTE TABLE CREATED OUTSIDE THIS AUTOMATION"
      drg_route_table_name             = local.one_dimension_processed_drg_attachments[drga_key].drg_route_table_key != null ? local.provisioned_drg_route_tables[local.one_dimension_processed_drg_attachments[drga_key].drg_route_table_key].display_name : "CANNOT BE DETERMINED - ROUTE TABLE CREATED OUTSIDE THIS AUTOMATION"
      export_drg_route_distribution_id = drga_value.export_drg_route_distribution_id
      freeform_tags                    = drga_value.freeform_tags
      id                               = drga_value.id
      is_cross_tenancy                 = drga_value.is_cross_tenancy
      network_details = drga_value.network_details != null ? [
        {
          id                     = drga_value.network_details[0].id
          attached_resource_name = can([for vcn_key, vcn_value in oci_core_vcn.these : vcn_value.display_name if vcn_value.id == drga_value.network_details[0].id][0]) ? [for vcn_key, vcn_value in oci_core_vcn.these : vcn_value.display_name if vcn_value.id == drga_value.network_details[0].id][0] : "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
          attached_resource_key  = can([for vcn_key, vcn_value in oci_core_vcn.these : vcn_key if vcn_value.id == drga_value.network_details[0].id][0]) ? [for vcn_key, vcn_value in oci_core_vcn.these : vcn_key if vcn_value.id == drga_value.network_details[0].id][0] : "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
          ipsec_connection_id    = drga_value.network_details[0].ipsec_connection_id
          route_table_id         = drga_value.network_details[0].route_table_id
          route_table_key = contains(
            keys(local.all_known_vcn_default_route_tables),
            drga_value.network_details[0].route_table_id
          ) ? local.all_known_vcn_default_route_tables[drga_value.network_details[0].route_table_id].key : can(local.one_dimension_processed_drg_attachments[drga_key].route_table_key) ? local.one_dimension_processed_drg_attachments[drga_key].route_table_key == null ? local.one_dimension_processed_drg_attachments[drga_key].route_table_id != null ? "CANNOT BE DETERMINED AS NOT CREATED BY THIS AUTOMATION" : null : local.one_dimension_processed_drg_attachments[drga_key].route_table_key : null

          route_table_name = contains(
            keys(local.all_known_vcn_default_route_tables),
            drga_value.network_details[0].route_table_id
            ) ? local.all_known_vcn_default_route_tables[drga_value.network_details[0].route_table_id].key : can(local.one_dimension_processed_drg_attachments[drga_key].route_table_key) ? local.one_dimension_processed_drg_attachments[drga_key].route_table_key == null ? local.one_dimension_processed_drg_attachments[drga_key].route_table_id != null ? "CANNOT BE DETERMINED AS NOT CREATED BY THIS AUTOMATION" : null : can(
            merge(
              local.provisioned_igw_natgw_specific_route_tables,
              local.provisioned_drga_specific_route_tables,
              local.provisioned_lpg_specific_route_tables
            )[local.one_dimension_processed_drg_attachments[drga_key].route_table_key].display_name) ? merge(
            local.provisioned_igw_natgw_specific_route_tables,
            local.provisioned_drga_specific_route_tables,
            local.provisioned_lpg_specific_route_tables
          )[local.one_dimension_processed_drg_attachments[drga_key].route_table_key].display_name : "CANNOT BE DETERMINED AS NOT CREATED BY THIS AUTOMATION" : null
          type           = drga_value.network_details[0].type
          vcn_route_type = drga_value.network_details[0].vcn_route_type
        }
      ] : []
      remove_export_drg_route_distribution_trigger = drga_value.remove_export_drg_route_distribution_trigger
      state                                        = drga_value.state
      time_created                                 = drga_value.time_created
      timeouts                                     = drga_value.timeouts
      vcn_id                                       = drga_value.vcn_id
      vcn_name                                     = can([for vcn_key, vcn_value in oci_core_vcn.these : vcn_value.display_name if vcn_value.id == drga_value.vcn_id][0]) ? [for vcn_key, vcn_value in oci_core_vcn.these : vcn_value.display_name if vcn_value.id == drga_value.vcn_id][0] : "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
      vcn_key                                      = can([for vcn_key, vcn_value in oci_core_vcn.these : vcn_key if vcn_value.id == drga_value.vcn_id][0]) ? [for vcn_key, vcn_value in oci_core_vcn.these : vcn_key if vcn_value.id == drga_value.vcn_id][0] : "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
      drga_key                                     = drga_key
      network_configuration_category               = local.one_dimension_processed_drg_attachments[drga_key].network_configuration_category
    }
  }
}

resource "oci_core_drg_attachment" "these" {
  for_each = local.one_dimension_processed_drg_attachments != null ? local.one_dimension_processed_drg_attachments : {}
  #Required
  drg_id = each.value.drg_id

  #Optional
  defined_tags       = each.value.defined_tags
  display_name       = each.value.display_name
  drg_route_table_id = each.value.drg_route_table_id != null ? each.value.drg_route_table_id : each.value.drg_route_table_key != null ? oci_core_drg_route_table.these[each.value.drg_route_table_key].id : null
  freeform_tags      = merge(local.cislz_module_tag, each.value.freeform_tags)
  dynamic "network_details" {
    iterator = net_det
    for_each = each.value.network_details != null ? [each.value.network_details] : []
    content {
      id   = net_det.value.attached_resource_id != null ? net_det.value.attached_resource_id : net_det.value.attached_resource_key != null ? local.provisioned_vcns[net_det.value.attached_resource_key].id : null
      type = net_det.value.type

      #Optional

      route_table_id = net_det.value.route_table_id != null ? net_det.value.route_table_id : net_det.value.route_table_key != null ? merge(
        {
          for rt_key, rt_value in merge(
            local.provisioned_igw_natgw_specific_route_tables,
            local.provisioned_drga_specific_route_tables,
            local.provisioned_lpg_specific_route_tables
            ) : rt_key => {
            id = rt_value.id
          }
        },
        {
          for vcn_key, vcn_value in merge(
            local.provisioned_vcns,
            local.one_dimension_processed_existing_vcns
            ) : "${vcn_key}_default_route_table" => {
            id = vcn_value.default_route_table_id
          }
        }
      )[net_det.value.route_table_key].id : null
    }
  }
}