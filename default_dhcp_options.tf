# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

locals {
  one_dimension_processed_default_dhcp_options = local.one_dimension_processed_vcns != null ? {
    for flat_default_dhcp_option in flatten([
      for vcn_key, vcn_value in local.one_dimension_processed_vcns : [
        {
          compartment_id                 = vcn_value.default_dhcp_options.compartment_id != null ? vcn_value.default_dhcp_options.compartment_id : vcn_value.category_compartment_id != null ? vcn_value.category_compartment_id : vcn_value.default_compartment_id != null ? vcn_value.default_compartment_id : null
          default_compartment_id         = vcn_value.default_compartment_id
          category_compartment_id        = vcn_value.category_compartment_id
          defined_tags                   = merge(vcn_value.default_dhcp_options.defined_tags, vcn_value.category_defined_tags, vcn_value.default_defined_tags)
          default_defined_tags           = vcn_value.default_defined_tags
          category_defined_tags          = vcn_value.category_defined_tags
          freeform_tags                  = merge(vcn_value.default_dhcp_options.freeform_tags, vcn_value.category_freeform_tags, vcn_value.default_freeform_tags)
          category_freeform_tags         = vcn_value.category_freeform_tags
          default_freeform_tags          = vcn_value.default_freeform_tags
          display_name                   = vcn_value.default_dhcp_options.display_name
          domain_name_type               = vcn_value.default_dhcp_options.domain_name_type
          options                        = vcn_value.default_dhcp_options.options
          network_configuration_category = vcn_value.network_configuration_category
          vcn_key                        = vcn_key
          vcn_id                         = oci_core_vcn.these[vcn_key].id
          vcn_name                       = vcn_value.display_name
          dhcp_option_key                = "CUSTOM-DEFAULT-DHCP-OPTIONS-${vcn_key}"
        }
      ] if vcn_value.default_dhcp_options != null
    ]) : flat_default_dhcp_option.dhcp_option_key => flat_default_dhcp_option
  } : null

  one_dimension_processed_injected_default_dhcp_options = local.one_dimension_processed_existing_vcns != null ? {
    for flat_default_dhcp_option in flatten([
      for vcn_key, vcn_value in local.one_dimension_processed_existing_vcns : [
        {
          compartment_id                 = vcn_value.default_dhcp_options.compartment_id != null ? vcn_value.default_dhcp_options.compartment_id : vcn_value.category_compartment_id != null ? vcn_value.category_compartment_id : vcn_value.default_compartment_id != null ? vcn_value.default_compartment_id : null
          default_compartment_id         = vcn_value.default_compartment_id
          category_compartment_id        = vcn_value.category_compartment_id
          defined_tags                   = merge(vcn_value.default_dhcp_options.defined_tags, vcn_value.category_defined_tags, vcn_value.default_defined_tags)
          default_defined_tags           = vcn_value.default_defined_tags
          category_defined_tags          = vcn_value.category_defined_tags
          freeform_tags                  = merge(vcn_value.default_dhcp_options.freeform_tags, vcn_value.category_freeform_tags, vcn_value.default_freeform_tags)
          category_freeform_tags         = vcn_value.category_freeform_tags
          default_freeform_tags          = vcn_value.default_freeform_tags
          display_name                   = vcn_value.default_dhcp_options.display_name
          domain_name_type               = vcn_value.default_dhcp_options.domain_name_type
          options                        = vcn_value.default_dhcp_options.options
          network_configuration_category = vcn_value.network_configuration_category
          vcn_key                        = vcn_key
          vcn_id                         = vcn_value.vcn_id
          vcn_name                       = vcn_value.vcn_name
          dhcp_option_key                = "CUSTOM-DEFAULT-DHCP-OPTIONS-${vcn_key}"
        }
      ] if vcn_value.default_dhcp_options != null
    ]) : flat_default_dhcp_option.dhcp_option_key => flat_default_dhcp_option
  } : null

  merged_one_dimension_processed_default_dhcp_options = merge(
    local.one_dimension_processed_default_dhcp_options,
    local.one_dimension_processed_injected_default_dhcp_options
  )

  provisioned_default_dhcp_options = {
    for opt_key, opt_value in oci_core_default_dhcp_options.these : opt_key => {
      compartment_id                 = opt_value.compartment_id
      defined_tags                   = opt_value.defined_tags
      display_name                   = opt_value.display_name
      domain_name_type               = opt_value.domain_name_type
      freeform_tags                  = opt_value.freeform_tags
      id                             = opt_value.id
      options                        = opt_value.options
      state                          = opt_value.state
      time_created                   = opt_value.time_created
      timeouts                       = opt_value.timeouts
      vcn_id                         = local.merged_one_dimension_processed_default_dhcp_options[opt_key].vcn_id
      vcn_key                        = local.merged_one_dimension_processed_default_dhcp_options[opt_key].vcn_key
      vcn_name                       = local.merged_one_dimension_processed_default_dhcp_options[opt_key].vcn_name
      network_configuration_category = local.merged_one_dimension_processed_default_dhcp_options[opt_key].network_configuration_category
      dhcp_options_key               = opt_key
    }
  }

}

resource "oci_core_default_dhcp_options" "these" {
  for_each = local.merged_one_dimension_processed_default_dhcp_options

  manage_default_resource_id = merge(local.provisioned_vcns, local.one_dimension_processed_existing_vcns)[each.value.vcn_key].default_dhcp_options_id

  compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
  display_name   = each.value.display_name
  defined_tags   = each.value.defined_tags
  freeform_tags  = merge(local.cislz_module_tag, each.value.freeform_tags)

  dynamic "options" {
    iterator = opt
    for_each = [
      for option_key, option_value in each.value.options : {
        type                = option_value.type
        search_domain_names = option_value.search_domain_names
    } if option_value.type == "SearchDomain" && option_value.search_domain_names != null]
    content {
      type                = opt.value.type
      search_domain_names = opt.value.search_domain_names
    }
  }

  # dynamic block to handle custom/vcn options
  dynamic "options" {
    iterator = opt
    for_each = [
      for option_key, option_value in each.value.options : {
        type                = option_value.type
        search_domain_names = option_value.search_domain_names
        server_type         = option_value.server_type
    } if option_value.type == "DomainNameServer" && option_value.server_type == "VcnLocalPlusInternet"]

    content {
      type                = opt.value.type
      server_type         = opt.value.server_type
      search_domain_names = opt.value.search_domain_names
    }
  }

  dynamic "options" {
    iterator = opt
    for_each = [
      for option_key, option_value in each.value.options : {
        type               = option_value.type
        server_type        = option_value.server_type
        custom_dns_servers = option_value.custom_dns_servers
    } if option_value.server_type == "CustomDnsServer"]

    content {
      type               = opt.value.type
      server_type        = opt.value.server_type
      custom_dns_servers = opt.value.custom_dns_servers
    }
  }
}