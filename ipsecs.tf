# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

locals {
  one_dimension_ipsecs = local.one_dimension_processed_non_vcn_specific_gateways != null ? {
    for flat_ipsec in flatten([
      for vcn_non_specific_gw_key, vcn_non_specific_gw_value in local.one_dimension_processed_non_vcn_specific_gateways :
      vcn_non_specific_gw_value.ipsecs != null ? length(vcn_non_specific_gw_value.ipsecs) > 0 ? [
        for ipsec_key, ipsec_value in vcn_non_specific_gw_value.ipsecs : {
          compartment_id                 = ipsec_value.compartment_id != null ? ipsec_value.compartment_id : vcn_non_specific_gw_value.category_compartment_id != null ? vcn_non_specific_gw_value.category_compartment_id : vcn_non_specific_gw_value.default_compartment_id != null ? vcn_non_specific_gw_value.default_compartment_id : null
          category_compartment_id        = vcn_non_specific_gw_value.category_compartment_id
          default_compartment_id         = vcn_non_specific_gw_value.default_compartment_id
          defined_tags                   = merge(ipsec_value.defined_tags, vcn_non_specific_gw_value.category_defined_tags, vcn_non_specific_gw_value.default_defined_tags)
          category_defined_tags          = vcn_non_specific_gw_value.category_defined_tags
          default_defined_tags           = vcn_non_specific_gw_value.default_defined_tags
          freeform_tags                  = merge(ipsec_value.freeform_tags, vcn_non_specific_gw_value.category_freeform_tags, vcn_non_specific_gw_value.default_freeform_tags)
          category_freeform_tags         = vcn_non_specific_gw_value.category_freeform_tags
          default_freeform_tags          = vcn_non_specific_gw_value.default_freeform_tags
          display_name                   = ipsec_value.display_name
          cpe_id                         = ipsec_value.cpe_id != null ? ipsec_value.cpe_id : ipsec_value.cpe_key != null ? local.provisioned_customer_premises_equipments[ipsec_value.cpe_key].id : null
          cpe_key                        = ipsec_value.cpe_key
          cpe_name                       = ipsec_value.cpe_key != null ? local.provisioned_customer_premises_equipments[ipsec_value.cpe_key].display_name : "Not known as not created by this automation"
          drg_id                         = ipsec_value.drg_id != null ? ipsec_value.drg_id : ipsec_value.drg_key != null ? local.provisioned_dynamic_gateways[ipsec_value.drg_key].id : null
          drg_key                        = ipsec_value.drg_key
          drg_name                       = ipsec_value.drg_key != null ? local.provisioned_dynamic_gateways[ipsec_value.drg_key].display_name : "Not known as not created by this automation"
          static_routes                  = ipsec_value.static_routes
          cpe_local_identifier           = ipsec_value.cpe_local_identifier
          cpe_local_identifier_type      = ipsec_value.cpe_local_identifier_type
          network_configuration_category = vcn_non_specific_gw_value.network_configuration_category
          ipsec_key                      = ipsec_key
          tunnels_management             = ipsec_value.tunnels_management
        }
      ] : [] : []
    ]) : flat_ipsec.ipsec_key => flat_ipsec
  } : null

  provisioned_ipsecs = {
    for ipsec_key, ipsec_value in oci_core_ipsec.these : ipsec_key => {
      compartment_id                 = ipsec_value.compartment_id
      defined_tags                   = ipsec_value.defined_tags
      display_name                   = ipsec_value.display_name
      freeform_tags                  = ipsec_value.freeform_tags
      id                             = ipsec_value.id
      cpe_id                         = ipsec_value.cpe_id
      cpe_key                        = local.one_dimension_ipsecs[ipsec_key].cpe_key != null ? local.one_dimension_ipsecs[ipsec_key].cpe_key : "Not known as not created by this automation"
      cpe_name                       = local.one_dimension_ipsecs[ipsec_key].cpe_key != null ? local.provisioned_customer_premises_equipments[local.one_dimension_ipsecs[ipsec_key].cpe_key].display_name : "Not known as not created by this automation"
      drg_id                         = ipsec_value.drg_id
      drg_key                        = local.one_dimension_ipsecs[ipsec_key].drg_key != null ? local.one_dimension_ipsecs[ipsec_key].drg_key : "Not known as not created by this automation"
      drg_name                       = local.one_dimension_ipsecs[ipsec_key].drg_key != null ? local.provisioned_dynamic_gateways[local.one_dimension_ipsecs[ipsec_key].drg_key].display_name : "Not known as not created by this automation"
      cpe_local_identifier           = ipsec_value.cpe_local_identifier
      cpe_local_identifier_type      = ipsec_value.cpe_local_identifier_type
      time_created                   = ipsec_value.time_created
      timeouts                       = ipsec_value.timeouts
      network_configuration_category = local.one_dimension_ipsecs[ipsec_key].network_configuration_category
      ipsec_key                      = ipsec_key
    }
  }
}

resource "oci_core_ipsec" "these" {
  for_each = local.one_dimension_ipsecs
  #Required
  compartment_id = each.value.compartment_id
  cpe_id         = each.value.cpe_id
  drg_id         = each.value.drg_id
  static_routes  = each.value.static_routes

  #Optional
  cpe_local_identifier      = each.value.cpe_local_identifier
  cpe_local_identifier_type = each.value.cpe_local_identifier_type
  defined_tags              = each.value.defined_tags
  display_name              = each.value.display_name
  freeform_tags             = merge(local.cislz_module_tag, each.value.freeform_tags)
}