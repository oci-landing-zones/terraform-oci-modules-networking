# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

locals {
  one_dimension_dynamic_routing_gateways = local.one_dimension_processed_non_vcn_specific_gateways != null ? {
    for flat_drg in flatten([
      for vcn_non_specific_gw_key, vcn_non_specific_gw_value in local.one_dimension_processed_non_vcn_specific_gateways :
      vcn_non_specific_gw_value.dynamic_routing_gateways != null ? length(vcn_non_specific_gw_value.dynamic_routing_gateways) > 0 ? [
        for drg_key, drg_value in vcn_non_specific_gw_value.dynamic_routing_gateways : {
          compartment_id                 = drg_value.compartment_id != null ? drg_value.compartment_id : vcn_non_specific_gw_value.category_compartment_id != null ? vcn_non_specific_gw_value.category_compartment_id : vcn_non_specific_gw_value.default_compartment_id != null ? vcn_non_specific_gw_value.default_compartment_id : null
          category_compartment_id        = vcn_non_specific_gw_value.category_compartment_id
          default_compartment_id         = vcn_non_specific_gw_value.default_compartment_id
          defined_tags                   = merge(drg_value.defined_tags, vcn_non_specific_gw_value.category_defined_tags, vcn_non_specific_gw_value.default_defined_tags)
          category_defined_tags          = vcn_non_specific_gw_value.category_defined_tags
          default_defined_tags           = vcn_non_specific_gw_value.default_defined_tags
          freeform_tags                  = merge(drg_value.freeform_tags, vcn_non_specific_gw_value.category_freeform_tags, vcn_non_specific_gw_value.default_freeform_tags)
          category_freeform_tags         = vcn_non_specific_gw_value.category_freeform_tags
          default_freeform_tags          = vcn_non_specific_gw_value.default_freeform_tags
          display_name                   = drg_value.display_name
          network_configuration_category = vcn_non_specific_gw_value.network_configuration_category
          remote_peering_connections     = drg_value.remote_peering_connections
          drg_attachments                = drg_value.drg_attachments
          drg_route_tables               = drg_value.drg_route_tables
          drg_route_distributions        = drg_value.drg_route_distributions
          drg_key                        = drg_key
        }
      ] : [] : []
    ]) : flat_drg.drg_key => flat_drg
  } : null

  provisioned_dynamic_gateways = {
    for drg_key, drg_value in oci_core_drg.these : drg_key => {
      compartment_id                           = drg_value.compartment_id
      default_drg_route_tables                 = drg_value.default_drg_route_tables
      default_export_drg_route_distribution_id = drg_value.default_export_drg_route_distribution_id
      defined_tags                             = drg_value.defined_tags
      display_name                             = drg_value.display_name
      freeform_tags                            = drg_value.freeform_tags
      id                                       = drg_value.id
      redundancy_status                        = drg_value.redundancy_status
      state                                    = drg_value.state
      time_created                             = drg_value.time_created
      timeouts                                 = drg_value.timeouts
      network_configuration_category           = local.one_dimension_dynamic_routing_gateways[drg_key].network_configuration_category
    }
  }
}

resource "oci_core_drg" "these" {
  for_each = local.one_dimension_dynamic_routing_gateways
  #Required
  compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null

  #Optional
  defined_tags  = each.value.defined_tags
  display_name  = each.value.display_name
  freeform_tags = merge(local.cislz_module_tag, each.value.freeform_tags)
}
