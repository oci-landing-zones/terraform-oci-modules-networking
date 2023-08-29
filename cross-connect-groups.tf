locals {
  one_dimension_cross_connect_groups = local.one_dimension_processed_non_vcn_specific_gateways != null ? {
    for flat_ccg in flatten([
      for vcn_non_specific_gw_key, vcn_non_specific_gw_value in local.one_dimension_processed_non_vcn_specific_gateways :
      vcn_non_specific_gw_value.cross_connect_groups != null ? length(vcn_non_specific_gw_value.cross_connect_groups) > 0 ? [
        for ccg_key, ccg_value in vcn_non_specific_gw_value.cross_connect_groups : {
          compartment_id                 = ccg_value.compartment_id != null ? ccg_value.compartment_id : vcn_non_specific_gw_value.category_compartment_id != null ? vcn_non_specific_gw_value.category_compartment_id : vcn_non_specific_gw_value.default_compartment_id != null ? vcn_non_specific_gw_value.default_compartment_id : null
          category_compartment_id        = vcn_non_specific_gw_value.category_compartment_id
          default_compartment_id         = vcn_non_specific_gw_value.default_compartment_id
          defined_tags                   = merge(ccg_value.defined_tags, vcn_non_specific_gw_value.category_defined_tags, vcn_non_specific_gw_value.default_defined_tags)
          category_defined_tags          = vcn_non_specific_gw_value.category_defined_tags
          default_defined_tags           = vcn_non_specific_gw_value.default_defined_tags
          freeform_tags                  = merge(ccg_value.freeform_tags, vcn_non_specific_gw_value.category_freeform_tags, vcn_non_specific_gw_value.default_freeform_tags)
          category_freeform_tags         = vcn_non_specific_gw_value.category_freeform_tags
          default_freeform_tags          = vcn_non_specific_gw_value.default_freeform_tags
          customer_reference_name        = ccg_value.customer_reference_name
          display_name                   = ccg_value.display_name
          cross_connects                 = ccg_value.cross_connects
          network_configuration_category = vcn_non_specific_gw_value.network_configuration_category
          ccg_key                        = ccg_key
        }
      ] : [] : []
    ]) : flat_ccg.ccg_key => flat_ccg
  } : null
}


resource "oci_core_cross_connect_group" "these" {

  for_each = local.one_dimension_cross_connect_groups

  #Required
  compartment_id = each.value.compartment_id

  #Optional
  customer_reference_name = each.value.customer_reference_name
  defined_tags            = each.value.defined_tags
  display_name            = each.value.display_name
  freeform_tags           = each.value.freeform_tags
}