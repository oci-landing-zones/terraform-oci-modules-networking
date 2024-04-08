# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #


locals {
  one_dimension_processed_drg_route_tables_1 = local.one_dimension_dynamic_routing_gateways != null ? length(local.one_dimension_dynamic_routing_gateways) > 0 ? {
    for flat_drgrts in flatten([
      for drg_key, drg_value in local.one_dimension_dynamic_routing_gateways :
      drg_value.drg_route_tables != null ? length(drg_value.drg_route_tables) > 0 ? [
        for drgrt_key, drgrt_value in drg_value.drg_route_tables : {
          defined_tags                      = merge(drgrt_value.defined_tags, drg_value.category_defined_tags, drg_value.default_defined_tags)
          freeform_tags                     = merge(drgrt_value.freeform_tags, drg_value.category_freeform_tags, drg_value.default_freeform_tags)
          drg_id                            = oci_core_drg.these[drg_key].id
          drg_name                          = drg_value.display_name
          drg_key                           = drg_key
          display_name                      = drgrt_value.display_name
          import_drg_route_distribution_id  = drgrt_value.import_drg_route_distribution_id != null ? drgrt_value.import_drg_route_distribution_id : drgrt_value.import_drg_route_distribution_key != null ? local.provisioned_drg_route_distributions[drgrt_value.import_drg_route_distribution_key].id : null
          import_drg_route_distribution_key = drgrt_value.import_drg_route_distribution_key
          is_ecmp_enabled                   = drgrt_value.is_ecmp_enabled
          network_configuration_category    = drg_value.network_configuration_category
          drgrt_key                         = drgrt_key
          route_rules                       = drgrt_value.route_rules
        }
      ] : [] : []
    ]) : flat_drgrts.drgrt_key => flat_drgrts
  } : null : null

  one_dimension_processed_injected_drg_route_tables = local.one_dimension_inject_into_existing_drgs != null ? length(local.one_dimension_inject_into_existing_drgs) > 0 ? {
    for flat_drgrts in flatten([
      for drg_key, drg_value in local.one_dimension_inject_into_existing_drgs :
      drg_value.drg_route_tables != null ? length(drg_value.drg_route_tables) > 0 ? [
        for drgrt_key, drgrt_value in drg_value.drg_route_tables : {
          defined_tags                      = drgrt_value.defined_tags
          freeform_tags                     = drgrt_value.freeform_tags
          drg_id                            = drg_value.drg_id
          drg_name                          = "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
          drg_key                           = drg_key
          display_name                      = drgrt_value.display_name
          import_drg_route_distribution_id  = drgrt_value.import_drg_route_distribution_id != null ? drgrt_value.import_drg_route_distribution_id : drgrt_value.import_drg_route_distribution_key != null ? local.provisioned_drg_route_distributions[drgrt_value.import_drg_route_distribution_key].id : null
          import_drg_route_distribution_key = drgrt_value.import_drg_route_distribution_key
          is_ecmp_enabled                   = drgrt_value.is_ecmp_enabled
          network_configuration_category    = drg_value.network_configuration_category
          drgrt_key                         = drgrt_key
          route_rules                       = drgrt_value.route_rules
        }
      ] : [] : []
    ]) : flat_drgrts.drgrt_key => flat_drgrts
  } : null : null

  one_dimension_processed_drg_route_tables = merge(local.one_dimension_processed_drg_route_tables_1, local.one_dimension_processed_injected_drg_route_tables)

  provisioned_drg_route_tables = {
    for drgrt_key, drgrt_value in oci_core_drg_route_table.these : drgrt_key => {
      compartment_id                    = drgrt_value.compartment_id
      defined_tags                      = drgrt_value.defined_tags
      display_name                      = drgrt_value.display_name
      drg_id                            = drgrt_value.drg_id
      drg_name                          = local.one_dimension_processed_drg_route_tables[drgrt_key].drg_name
      freeform_tags                     = drgrt_value.freeform_tags
      id                                = drgrt_value.id
      import_drg_route_distribution_id  = drgrt_value.import_drg_route_distribution_id
      import_drg_route_distribution_key = local.one_dimension_processed_drg_route_tables[drgrt_key].import_drg_route_distribution_key != null ? local.one_dimension_processed_drg_route_tables[drgrt_key].import_drg_route_distribution_key : "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
      is_ecmp_enabled                   = drgrt_value.is_ecmp_enabled
      remove_import_trigger             = drgrt_value.remove_import_trigger
      state                             = drgrt_value.state
      time_created                      = drgrt_value.time_created
      timeouts                          = drgrt_value.timeouts
      network_configuration_category    = local.one_dimension_processed_drg_route_tables[drgrt_key].network_configuration_category
      drgrt_key                         = drgrt_key
      route_rules                       = local.one_dimension_processed_drg_route_tables[drgrt_key].route_rules
    }
  }
}

resource "oci_core_drg_route_table" "these" {

  for_each = local.one_dimension_processed_drg_route_tables != null ? local.one_dimension_processed_drg_route_tables : {}
  #Required
  drg_id = each.value.drg_id

  #Optional
  defined_tags                     = each.value.defined_tags
  display_name                     = each.value.display_name
  freeform_tags                    = merge(local.cislz_module_tag, each.value.freeform_tags)
  import_drg_route_distribution_id = each.value.import_drg_route_distribution_id
  is_ecmp_enabled                  = each.value.is_ecmp_enabled
}