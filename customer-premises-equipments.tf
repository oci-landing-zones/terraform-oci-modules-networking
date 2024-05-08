# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Tue Dec 19 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

data "oci_core_cpe_device_shapes" "cpe_device_shapes" {
  count = var.network_configuration != null ? 1 : 0
}

locals {
  one_dimension_customer_premises_equipments = local.one_dimension_processed_non_vcn_specific_gateways != null ? {
    for flat_cpe in flatten([
      for vcn_non_specific_gw_key, vcn_non_specific_gw_value in local.one_dimension_processed_non_vcn_specific_gateways :
      vcn_non_specific_gw_value.customer_premises_equipments != null ? length(vcn_non_specific_gw_value.customer_premises_equipments) > 0 ? [
        for cpe_key, cpe_value in vcn_non_specific_gw_value.customer_premises_equipments : {
          compartment_id                 = cpe_value.compartment_id != null ? cpe_value.compartment_id : vcn_non_specific_gw_value.category_compartment_id != null ? vcn_non_specific_gw_value.category_compartment_id : vcn_non_specific_gw_value.default_compartment_id != null ? vcn_non_specific_gw_value.default_compartment_id : null
          category_compartment_id        = vcn_non_specific_gw_value.category_compartment_id
          default_compartment_id         = vcn_non_specific_gw_value.default_compartment_id
          defined_tags                   = merge(cpe_value.defined_tags, vcn_non_specific_gw_value.category_defined_tags, vcn_non_specific_gw_value.default_defined_tags)
          category_defined_tags          = vcn_non_specific_gw_value.category_defined_tags
          default_defined_tags           = vcn_non_specific_gw_value.default_defined_tags
          freeform_tags                  = merge(cpe_value.freeform_tags, vcn_non_specific_gw_value.category_freeform_tags, vcn_non_specific_gw_value.default_freeform_tags)
          category_freeform_tags         = vcn_non_specific_gw_value.category_freeform_tags
          default_freeform_tags          = vcn_non_specific_gw_value.default_freeform_tags
          display_name                   = cpe_value.display_name
          ip_address                     = cpe_value.ip_address
          network_configuration_category = vcn_non_specific_gw_value.network_configuration_category
          cpe_device_shape_vendor_name   = cpe_value.cpe_device_shape_vendor_name
          cpe_device_shape_id            = cpe_value.cpe_device_shape_id != null ? cpe_value.cpe_device_shape_id : cpe_value.cpe_device_shape_vendor_name != null ? [for cpe_shape in length(data.oci_core_cpe_device_shapes.cpe_device_shapes) > 0 ? data.oci_core_cpe_device_shapes.cpe_device_shapes[0].cpe_device_shapes : [] : cpe_shape.cpe_device_shape_id if cpe_shape.cpe_device_info[0].vendor == cpe_value.cpe_device_shape_vendor_name][0] : [for cpe_shape in length(data.oci_core_cpe_device_shapes.cpe_device_shapes) > 0 ? data.oci_core_cpe_device_shapes.cpe_device_shapes[0].cpe_device_shapes : [] : cpe_shape.cpe_device_shape_id if cpe_shape.cpe_device_info[0].vendor == "Other"][0]
          cpe_key                        = cpe_key
        }
      ] : [] : []
    ]) : flat_cpe.cpe_key => flat_cpe
  } : null

  provisioned_customer_premises_equipments = {
    for cpe_key, cpe_value in oci_core_cpe.these : cpe_key => {
      compartment_id                 = cpe_value.compartment_id
      defined_tags                   = cpe_value.defined_tags
      display_name                   = cpe_value.display_name
      ip_address                     = cpe_value.ip_address
      freeform_tags                  = cpe_value.freeform_tags
      id                             = cpe_value.id
      time_created                   = cpe_value.time_created
      timeouts                       = cpe_value.timeouts
      network_configuration_category = local.one_dimension_customer_premises_equipments[cpe_key].network_configuration_category
      cpe_device_shape_id            = cpe_value.cpe_device_shape_id
      cpe_device_shape_details       = [for cpe_shape in length(data.oci_core_cpe_device_shapes.cpe_device_shapes) > 0 ? data.oci_core_cpe_device_shapes.cpe_device_shapes[0].cpe_device_shapes : [] : cpe_shape if cpe_shape.cpe_device_shape_id == cpe_value.cpe_device_shape_id][0],
      cpe_key                        = cpe_key
    }
  }
}


resource "oci_core_cpe" "these" {
  for_each = local.one_dimension_customer_premises_equipments
  #Required
  compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
  ip_address     = each.value.ip_address

  #Optional
  cpe_device_shape_id = each.value.cpe_device_shape_id
  defined_tags        = each.value.defined_tags
  display_name        = each.value.display_name
  freeform_tags       = merge(local.cislz_module_tag, each.value.freeform_tags)
}