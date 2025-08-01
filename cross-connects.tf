# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

locals {
  one_dimension_cross_connects = local.one_dimension_cross_connect_groups != null ? {
    for flat_cc in flatten([
      for ccg_key, ccg_value in local.one_dimension_cross_connect_groups :
      ccg_value.cross_connects != null ? length(ccg_value.cross_connects) > 0 ? [
        for cc_key, cc_value in ccg_value.cross_connects : {
          compartment_id                                = cc_value.compartment_id != null ? cc_value.compartment_id : ccg_value.category_compartment_id != null ? ccg_value.category_compartment_id : ccg_value.default_compartment_id != null ? ccg_value.default_compartment_id : null
          category_compartment_id                       = ccg_value.category_compartment_id
          default_compartment_id                        = ccg_value.default_compartment_id
          defined_tags                                  = merge(cc_value.defined_tags, ccg_value.category_defined_tags, ccg_value.default_defined_tags)
          category_defined_tags                         = ccg_value.category_defined_tags
          default_defined_tags                          = ccg_value.default_defined_tags
          freeform_tags                                 = merge(cc_value.freeform_tags, ccg_value.category_freeform_tags, ccg_value.default_freeform_tags)
          category_freeform_tags                        = ccg_value.category_freeform_tags
          default_freeform_tags                         = ccg_value.default_freeform_tags
          display_name                                  = cc_value.display_name
          cross_connect_group_id                        = oci_core_cross_connect_group.these[ccg_key].id
          location_name                                 = cc_value.location_name
          port_speed_shape_name                         = cc_value.port_speed_shape_name
          customer_reference_name                       = cc_value.customer_reference_name
          far_cross_connect_or_cross_connect_group_id   = cc_value.far_cross_connect_or_cross_connect_group_id
          far_cross_connect_or_cross_connect_group_key  = cc_value.far_cross_connect_or_cross_connect_group_key
          near_cross_connect_or_cross_connect_group_id  = cc_value.near_cross_connect_or_cross_connect_group_id
          near_cross_connect_or_cross_connect_group_key = cc_value.near_cross_connect_or_cross_connect_group_key
          network_configuration_category                = ccg_value.network_configuration_category
          cc_key                                        = cc_key
          ccg_key                                       = ccg_key
          ccg_display_name                              = ccg_value.display_name
        }
      ] : [] : []
    ]) : flat_cc.cc_key => flat_cc
  } : null
}

resource "oci_core_cross_connect" "these" {

  for_each = local.one_dimension_cross_connects

  #Required
  compartment_id        = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
  location_name         = each.value.location_name
  port_speed_shape_name = each.value.port_speed_shape_name

  #Optional
  cross_connect_group_id                       = oci_core_cross_connect_group.these[each.value.ccg_key].id
  customer_reference_name                      = each.value.customer_reference_name
  defined_tags                                 = each.value.defined_tags
  display_name                                 = each.value.display_name
  far_cross_connect_or_cross_connect_group_id  = each.value.far_cross_connect_or_cross_connect_group_id
  freeform_tags                                = merge(local.cislz_module_tag, each.value.freeform_tags)
  near_cross_connect_or_cross_connect_group_id = each.value.near_cross_connect_or_cross_connect_group_id
}


