# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

locals {

  # PROCESSED INPUT
  one_dimension_processed_pub_ips = local.one_dimension_processed_IPs != null ? {
    for flat_pubips in flatten([
      for ips_key, ips_value in local.one_dimension_processed_IPs :
      ips_value.public_ips != null ? length(ips_value.public_ips) > 0 ? [
        for pubips_key, pubips_value in ips_value.public_ips : {
          compartment_id                 = pubips_value.compartment_id != null ? pubips_value.compartment_id : ips_value.category_compartment_id != null ? ips_value.category_compartment_id : ips_value.default_compartment_id != null ? ips_value.default_compartment_id : null
          default_compartment_id         = ips_value.default_compartment_id
          category_compartment_id        = ips_value.category_compartment_id
          defined_tags                   = merge(pubips_value.defined_tags, ips_value.category_defined_tags, ips_value.default_defined_tags)
          default_defined_tags           = ips_value.default_defined_tags
          category_defined_tags          = ips_value.category_defined_tags
          display_name                   = pubips_value.display_name
          freeform_tags                  = merge(pubips_value.freeform_tags, ips_value.category_freeform_tags, ips_value.default_freeform_tags)
          default_freeform_tags          = ips_value.default_freeform_tags
          category_freeform_tags         = ips_value.category_freeform_tags
          lifetime                       = pubips_value.lifetime
          pubips_key                     = pubips_key
          private_ip_id                  = pubips_value.private_ip_id
          public_ip_pool_id              = pubips_value.public_ip_pool_id != null ? pubips_value.public_ip_pool_id : pubips_value.public_ip_pool_key != null ? local.provisioned_oci_core_public_ip_pools[pubips_value.public_ip_pool_key].id : null
          public_ip_pool_key             = pubips_value.public_ip_pool_key
          network_configuration_category = ips_value.network_configuration_category
        }
      ] : [] : []
    ]) : flat_pubips.pubips_key => flat_pubips
  } : null

  provisioned_oci_core_public_ips = {
    for pubips_key, pubips_value in oci_core_public_ip.these : pubips_key => {
      assigned_entity_id             = pubips_value.assigned_entity_id
      assigned_entity_type           = pubips_value.assigned_entity_type
      availability_domain            = pubips_value.availability_domain
      compartment_id                 = pubips_value.compartment_id
      defined_tags                   = pubips_value.defined_tags
      display_name                   = pubips_value.display_name
      freeform_tags                  = pubips_value.freeform_tags
      id                             = pubips_value.id
      ip_address                     = pubips_value.ip_address
      lifetime                       = pubips_value.lifetime
      private_ip_id                  = pubips_value.private_ip_id
      public_ip_pool_id              = pubips_value.public_ip_pool_id
      public_ip_pool_key             = local.one_dimension_processed_pub_ips[pubips_key].public_ip_pool_key != null ? local.one_dimension_processed_pub_ips[pubips_key].public_ip_pool_key : "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
      scope                          = pubips_value.scope
      state                          = pubips_value.state
      time_created                   = pubips_value.time_created
      pubips_key                     = pubips_key
      network_configuration_category = local.one_dimension_processed_pub_ips[pubips_key].network_configuration_category
    }
  }
}

resource "oci_core_public_ip" "these" {
  for_each = local.one_dimension_processed_pub_ips != null ? length(local.one_dimension_processed_pub_ips) > 0 ? local.one_dimension_processed_pub_ips : {} : {}
  #Required
  compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
  lifetime       = each.value.lifetime

  #Optional
  defined_tags      = each.value.defined_tags
  display_name      = each.value.display_name
  freeform_tags     = merge(local.cislz_module_tag, each.value.freeform_tags)
  private_ip_id     = each.value.private_ip_id
  public_ip_pool_id = each.value.public_ip_pool_id
}