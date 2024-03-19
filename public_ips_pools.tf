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
  one_dimension_processed_pub_ips_pools = local.one_dimension_processed_IPs != null ? {
    for flat_pubipspools in flatten([
      for ips_key, ips_value in local.one_dimension_processed_IPs :
      ips_value.public_ips_pools != null ? length(ips_value.public_ips_pools) > 0 ? [
        for pubipspools_key, pubipspools_value in ips_value.public_ips_pools : {
          compartment_id                 = pubipspools_value.compartment_id != null ? pubipspools_value.compartment_id : ips_value.category_compartment_id != null ? ips_value.category_compartment_id : ips_value.default_compartment_id != null ? ips_value.default_compartment_id : null
          default_compartment_id         = ips_value.default_compartment_id
          category_compartment_id        = ips_value.category_compartment_id
          defined_tags                   = merge(pubipspools_value.defined_tags, ips_value.category_defined_tags, ips_value.default_defined_tags)
          default_defined_tags           = ips_value.default_defined_tags
          category_defined_tags          = ips_value.category_defined_tags
          display_name                   = pubipspools_value.display_name
          freeform_tags                  = merge(pubipspools_value.freeform_tags, ips_value.category_freeform_tags, ips_value.default_freeform_tags)
          default_freeform_tags          = ips_value.default_freeform_tags
          category_freeform_tags         = ips_value.category_freeform_tags
          pubipspools_key                = pubipspools_key
          network_configuration_category = ips_value.network_configuration_category
        }
      ] : [] : []
    ]) : flat_pubipspools.pubipspools_key => flat_pubipspools
  } : null

  provisioned_oci_core_public_ip_pools = {
    for pubipspools_key, pubipspools_value in oci_core_public_ip_pool.these : pubipspools_key => {
      cidr_blocks                    = pubipspools_value.cidr_blocks
      compartment_id                 = pubipspools_value.compartment_id
      defined_tags                   = pubipspools_value.defined_tags
      display_name                   = pubipspools_value.display_name
      freeform_tags                  = pubipspools_value.freeform_tags
      id                             = pubipspools_value.id
      state                          = pubipspools_value.state
      time_created                   = pubipspools_value.time_created
      network_configuration_category = local.one_dimension_processed_pub_ips_pools[pubipspools_key].network_configuration_category
      pubipspools_key                = pubipspools_key
    }
  }
}

resource "oci_core_public_ip_pool" "these" {
  for_each = local.one_dimension_processed_pub_ips_pools != null ? length(local.one_dimension_processed_pub_ips_pools) > 0 ? local.one_dimension_processed_pub_ips_pools : {} : {}
  #Required
  compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null

  #Optional
  defined_tags  = each.value.defined_tags
  display_name  = each.value.display_name
  freeform_tags = merge(local.cislz_module_tag, each.value.freeform_tags)
}