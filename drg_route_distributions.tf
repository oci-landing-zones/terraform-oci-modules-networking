# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #


locals {
  one_dimension_processed_drg_route_distributions_1 = local.one_dimension_dynamic_routing_gateways != null ? length(local.one_dimension_dynamic_routing_gateways) > 0 ? {
    for flat_drgrds in flatten([
      for drg_key, drg_value in local.one_dimension_dynamic_routing_gateways :
      drg_value.drg_route_distributions != null ? length(drg_value.drg_route_distributions) > 0 ? [
        for drgrd_key, drgrd_value in drg_value.drg_route_distributions : {
          defined_tags                   = merge(drgrd_value.defined_tags, drg_value.category_defined_tags, drg_value.default_defined_tags)
          freeform_tags                  = merge(drgrd_value.freeform_tags, drg_value.category_freeform_tags, drg_value.default_freeform_tags)
          drg_id                         = oci_core_drg.these[drg_key].id
          drg_name                       = drg_value.display_name
          drg_key                        = drg_key
          display_name                   = drgrd_value.display_name
          distribution_type              = drgrd_value.distribution_type
          drgrd_key                      = drgrd_key
          network_configuration_category = drg_value.network_configuration_category
          statements                     = drgrd_value.statements
        }
      ] : [] : []
    ]) : flat_drgrds.drgrd_key => flat_drgrds
  } : null : null

  one_dimension_processed_injected_drg_route_distributions = local.one_dimension_inject_into_existing_drgs != null ? length(local.one_dimension_inject_into_existing_drgs) > 0 ? {
    for flat_drgrds in flatten([
      for drg_key, drg_value in local.one_dimension_inject_into_existing_drgs :
      drg_value.drg_route_distributions != null ? length(drg_value.drg_route_distributions) > 0 ? [
        for drgrd_key, drgrd_value in drg_value.drg_route_distributions : {
          defined_tags                   = drgrd_value.defined_tags
          freeform_tags                  = drgrd_value.freeform_tags
          drg_id                         = drg_value.drg_id
          drg_name                       = "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
          drg_key                        = drg_key
          display_name                   = drgrd_value.display_name
          distribution_type              = drgrd_value.distribution_type
          drgrd_key                      = drgrd_key
          network_configuration_category = drg_value.network_configuration_category
          statements                     = drgrd_value.statements
        }
      ] : [] : []
    ]) : flat_drgrds.drgrd_key => flat_drgrds
  } : null : null

  one_dimension_processed_drg_route_distributions = merge(local.one_dimension_processed_drg_route_distributions_1, local.one_dimension_processed_injected_drg_route_distributions)

  provisioned_drg_route_distributions = {
    for drgrd_key, drgrd_value in oci_core_drg_route_distribution.these : drgrd_key => {
      compartment_id                 = drgrd_value.compartment_id
      defined_tags                   = drgrd_value.defined_tags
      display_name                   = drgrd_value.display_name
      drg_id                         = drgrd_value.drg_id
      drg_name                       = local.one_dimension_processed_drg_route_distributions[drgrd_key].drg_name
      freeform_tags                  = drgrd_value.freeform_tags
      id                             = drgrd_value.id
      distribution_type              = drgrd_value.distribution_type
      state                          = drgrd_value.state
      time_created                   = drgrd_value.time_created
      network_configuration_category = local.one_dimension_processed_drg_route_distributions[drgrd_key].network_configuration_category
      drgrd_key                      = drgrd_key
    }
  }
}

resource "oci_core_drg_route_distribution" "these" {
  for_each = local.one_dimension_processed_drg_route_distributions != null ? local.one_dimension_processed_drg_route_distributions : {}
  #Required
  drg_id            = each.value.drg_id
  distribution_type = each.value.distribution_type

  #Optional
  defined_tags  = each.value.defined_tags
  display_name  = each.value.display_name
  freeform_tags = merge(local.cislz_module_tag, each.value.freeform_tags)
}