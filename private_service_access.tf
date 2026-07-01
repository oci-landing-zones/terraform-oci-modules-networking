# ####################################################################################################### #
# Copyright (c) 2026 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl.
# ####################################################################################################### #

locals {
  category_level_private_service_access = var.network_configuration != null && try(var.network_configuration.network_configuration_categories, null) != null ? {
    for flat_psa in flatten([
      for category_key, category_value in var.network_configuration.network_configuration_categories : [
        for psa_key, psa_value in try(coalesce(category_value.private_service_access, {}), {}) : {
          key                     = psa_key
          category_key            = category_key
          value                   = psa_value
          category_compartment_id = try(category_value.category_compartment_id, null)
          category_defined_tags   = try(category_value.category_defined_tags, {})
          category_freeform_tags  = try(category_value.category_freeform_tags, {})
        }
      ]
      ]) : flat_psa.key => merge(flat_psa.value, {
      compartment_id                 = try(flat_psa.value.compartment_id, null) != null ? flat_psa.value.compartment_id : flat_psa.category_compartment_id
      defined_tags                   = merge(flat_psa.category_defined_tags, try(flat_psa.value.defined_tags, {}))
      freeform_tags                  = merge(flat_psa.category_freeform_tags, try(flat_psa.value.freeform_tags, {}))
      network_configuration_category = flat_psa.category_key
    })
  } : {}

  private_service_access_defaults = {
    default_defined_tags  = try(var.network_configuration.default_defined_tags, {}) != null ? try(var.network_configuration.default_defined_tags, {}) : {}
    default_freeform_tags = try(var.network_configuration.default_freeform_tags, {}) != null ? try(var.network_configuration.default_freeform_tags, {}) : {}
    default_compartment   = try(var.network_configuration.default_compartment_id, null)
    entries = merge(
      var.network_configuration != null && try(var.network_configuration.private_service_access, {}) != null ? try(var.network_configuration.private_service_access, {}) : {},
      local.category_level_private_service_access
    )
  }

  processed_private_service_access = length(local.private_service_access_defaults.entries) > 0 ? {
    for psa_key, psa_value in local.private_service_access_defaults.entries : psa_key => {
      key               = psa_key
      compartment_id    = psa_value.compartment_id != null ? psa_value.compartment_id : local.private_service_access_defaults.default_compartment
      target_service_id = psa_value.target_service_id
      subnet_id         = psa_value.subnet_id != null ? psa_value.subnet_id : psa_value.subnet_key != null ? try(local.aux_provisioned_subnets[psa_value.subnet_key].id, try(var.network_dependency.subnets[psa_value.subnet_key].id, null)) : null
      subnet_key        = psa_value.subnet_key
      defined_tags      = merge(local.private_service_access_defaults.default_defined_tags != null ? local.private_service_access_defaults.default_defined_tags : {}, psa_value.defined_tags != null ? psa_value.defined_tags : {})
      freeform_tags     = merge(local.private_service_access_defaults.default_freeform_tags != null ? local.private_service_access_defaults.default_freeform_tags : {}, psa_value.freeform_tags != null ? psa_value.freeform_tags : {})
      ipv4_address      = try(psa_value.ipv4_address, null)
      nsg_ids           = try(psa_value.nsg_ids, null)
      nsg_keys          = try(psa_value.nsg_keys, null)
      security_attributes = length(try(coalesce(psa_value.zpr_attributes, []), [])) > 0 ? merge([
        for attr in psa_value.zpr_attributes : merge(
          try(attr.attr_name, null) != null && try(attr.attr_value, null) != null ? {
            format(
              "%s.%s.value",
              coalesce(try(attr.namespace, null), "oracle-zpr"),
              attr.attr_name
            ) = attr.attr_value
          } : {},
          try(attr.attr_name, null) != null ? {
            format(
              "%s.%s.mode",
              coalesce(try(attr.namespace, null), "oracle-zpr"),
              attr.attr_name
            ) = try(attr.mode, "enforce")
          } : {}
        )
      ]...) : {}
      network_configuration_category = try(psa_value.network_configuration_category, null)
      display_name                   = replace(coalesce(try(psa_value.display_name, null), try(psa_value.target_service_id, null)), "/\\s+/", "-")
      description                    = coalesce(try(psa_value.description, null), try(psa_value.display_name, null), try(psa_value.target_service_id, null))
    }
  } : {}

  network_dependency_network_security_group_ids = {
    for key, value in try(var.network_dependency.network_security_groups, {}) : key => value.id
  }
}

resource "oci_psa_private_service_access" "these" {
  for_each = local.processed_private_service_access

  compartment_id = each.value.compartment_id != null ? (
    length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id
  ) : null

  service_id = each.value.target_service_id
  subnet_id = each.value.subnet_id != null ? each.value.subnet_id : each.value.subnet_key != null ? try(
    local.aux_provisioned_subnets[each.value.subnet_key].id,
    try(var.network_dependency.subnets[each.value.subnet_key].id, null)
  ) : null

  defined_tags = length(each.value.defined_tags) > 0 ? each.value.defined_tags : null

  description  = each.value.description != null ? each.value.description : each.value.display_name
  display_name = each.value.display_name

  freeform_tags = merge(local.cislz_module_tag, each.value.freeform_tags)

  ipv4ip = each.value.ipv4_address

  nsg_ids = each.value.nsg_ids != null ? [
    for nsg_id in each.value.nsg_ids :
    length(regexall("^ocid1.*$", nsg_id)) > 0 ? nsg_id : lookup(local.network_dependency_network_security_group_ids, nsg_id, nsg_id)
    ] : each.value.nsg_keys != null ? flatten([
      for nsg_key in each.value.nsg_keys :
      can(oci_core_network_security_group.these[nsg_key].id) ? [oci_core_network_security_group.these[nsg_key].id] :
      can(local.network_dependency_network_security_group_ids[nsg_key]) ? [local.network_dependency_network_security_group_ids[nsg_key]] :
      []
  ]) : null

  security_attributes = length(each.value.security_attributes) > 0 ? each.value.security_attributes : null
}
