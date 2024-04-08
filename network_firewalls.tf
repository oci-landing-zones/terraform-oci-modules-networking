# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

data "oci_identity_availability_domains" "these" {
  for_each = local.aux_one_dimension_network_firewalls != null ? length(local.aux_one_dimension_network_firewalls) > 0 ? local.aux_one_dimension_network_firewalls : {} : {}

  compartment_id = each.value.compartment_id
}

data "oci_core_private_ips" "these-nfws-private-ips" {
  for_each = oci_network_firewall_network_firewall.these
  #Optional
  ip_address = each.value.ipv4address
  subnet_id  = each.value.subnet_id
}

locals {

  aux_one_dimension_network_firewalls = local.one_dimension_processed_non_vcn_specific_gateways != null ? {
    for flat_nfw in flatten([
      for vcn_non_specific_gw_key, vcn_non_specific_gw_value in local.one_dimension_processed_non_vcn_specific_gateways :
      vcn_non_specific_gw_value.network_firewalls_configuration != null ? vcn_non_specific_gw_value.network_firewalls_configuration.network_firewalls != null ? length(vcn_non_specific_gw_value.network_firewalls_configuration.network_firewalls) > 0 ? [
        for nfw_key, nfw_value in vcn_non_specific_gw_value.network_firewalls_configuration.network_firewalls : {
          compartment_id = nfw_value.compartment_id != null ? nfw_value.compartment_id : vcn_non_specific_gw_value.category_compartment_id != null ? vcn_non_specific_gw_value.category_compartment_id : vcn_non_specific_gw_value.default_compartment_id != null ? vcn_non_specific_gw_value.default_compartment_id : null
          nfw_key        = nfw_key
        }
      ] : [] : [] : []
    ]) : flat_nfw.nfw_key => flat_nfw
  } : null

  one_dimension_network_firewalls = local.one_dimension_processed_non_vcn_specific_gateways != null ? {
    for flat_nfw in flatten([
      for vcn_non_specific_gw_key, vcn_non_specific_gw_value in local.one_dimension_processed_non_vcn_specific_gateways :
      vcn_non_specific_gw_value.network_firewalls_configuration != null ? vcn_non_specific_gw_value.network_firewalls_configuration.network_firewalls != null ? length(vcn_non_specific_gw_value.network_firewalls_configuration.network_firewalls) > 0 ? [
        for nfw_key, nfw_value in vcn_non_specific_gw_value.network_firewalls_configuration.network_firewalls : {
          compartment_id                 = nfw_value.compartment_id != null ? nfw_value.compartment_id : vcn_non_specific_gw_value.category_compartment_id != null ? vcn_non_specific_gw_value.category_compartment_id : vcn_non_specific_gw_value.default_compartment_id != null ? vcn_non_specific_gw_value.default_compartment_id : null
          category_compartment_id        = vcn_non_specific_gw_value.category_compartment_id
          default_compartment_id         = vcn_non_specific_gw_value.default_compartment_id
          defined_tags                   = merge(nfw_value.defined_tags, vcn_non_specific_gw_value.category_defined_tags, vcn_non_specific_gw_value.default_defined_tags)
          category_defined_tags          = vcn_non_specific_gw_value.category_defined_tags
          default_defined_tags           = vcn_non_specific_gw_value.default_defined_tags
          freeform_tags                  = merge(nfw_value.freeform_tags, vcn_non_specific_gw_value.category_freeform_tags, vcn_non_specific_gw_value.default_freeform_tags)
          category_freeform_tags         = vcn_non_specific_gw_value.category_freeform_tags
          default_freeform_tags          = vcn_non_specific_gw_value.default_freeform_tags
          display_name                   = nfw_value.display_name
          network_configuration_category = vcn_non_specific_gw_value.network_configuration_category
          availability_domain            = nfw_value.availability_domain != null ? lookup(data.oci_identity_availability_domains.these[nfw_key].availability_domains[nfw_value.availability_domain - 1], "name") : null
          ipv4address                    = nfw_value.ipv4address
          ipv6address                    = nfw_value.ipv6address
          network_security_group_ids = concat(
            nfw_value.network_security_group_keys != null ? [
              for nsg_key in nfw_value.network_security_group_keys : oci_core_network_security_group.these[nsg_key].id
            ] : [],

            nfw_value.network_security_group_ids != null ? nfw_value.network_security_group_ids : []
          )
          network_security_group_keys = nfw_value.network_security_group_keys
          subnet_id                   = nfw_value.subnet_id != null ? nfw_value.subnet_id : local.aux_provisioned_subnets[nfw_value.subnet_key].id
          subnet_key                  = nfw_value.subnet_key
          network_firewall_policy_id  = nfw_value.network_firewall_policy_id != null ? nfw_value.network_firewall_policy_id : oci_network_firewall_network_firewall_policy.these[nfw_value.network_firewall_policy_key].id
          network_firewall_policy_key = nfw_value.network_firewall_policy_key
          nfw_key                     = nfw_key
        }
      ] : [] : [] : []
    ]) : flat_nfw.nfw_key => flat_nfw
  } : null

  provisioned_oci_network_firewall_network_firewalls = {
    for nfw_key, nfw_value in oci_network_firewall_network_firewall.these : nfw_key => {
      availability_domain         = nfw_value.availability_domain
      compartment_id              = nfw_value.compartment_id
      defined_tags                = nfw_value.defined_tags
      display_name                = nfw_value.display_name
      freeform_tags               = nfw_value.freeform_tags
      id                          = nfw_value.id
      ipv4address                 = nfw_value.ipv4address
      ipv4address_ocid            = data.oci_core_private_ips.these-nfws-private-ips[nfw_key].private_ips[0].id
      ipv4address_vnic_id         = data.oci_core_private_ips.these-nfws-private-ips[nfw_key].private_ips[0].vnic_id
      ipv6address                 = nfw_value.ipv6address
      lifecycle_details           = nfw_value.lifecycle_details
      network_firewall_policy_id  = nfw_value.network_firewall_policy_id
      network_firewall_policy_key = local.one_dimension_network_firewalls[nfw_key].network_firewall_policy_key != null ? local.one_dimension_network_firewalls[nfw_key].network_firewall_policy_key : "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
      network_security_group_ids = [
        for nsg_id in nfw_value.network_security_group_ids : {
          nsg_id  = nsg_id
          nsg_key = can([for nsg_key, nsg_value in local.provisioned_network_security_groups : nsg_key if nsg_value.id == nsg_id][0]) ? [for nsg_key, nsg_value in local.provisioned_network_security_groups : nsg_key if nsg_value.id == nsg_id][0] : "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
        }
      ]
      state                          = nfw_value.state
      subnet_id                      = nfw_value.subnet_id
      subnet_key                     = local.one_dimension_network_firewalls[nfw_key].subnet_key != null ? local.one_dimension_network_firewalls[nfw_key].subnet_key : "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
      system_tags                    = nfw_value.system_tags
      time_created                   = nfw_value.time_created
      time_updated                   = nfw_value.time_updated
      timeouts                       = nfw_value.timeouts
      network_configuration_category = local.one_dimension_network_firewalls[nfw_key].network_configuration_category
      nfw_key                        = nfw_key
    }
  }
}

resource "oci_network_firewall_network_firewall" "these" {
  for_each = local.one_dimension_network_firewalls != null ? length(local.one_dimension_network_firewalls) > 0 ? local.one_dimension_network_firewalls : {} : {}

  #Required
  compartment_id             = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
  network_firewall_policy_id = each.value.network_firewall_policy_id
  subnet_id                  = each.value.subnet_id

  #Optional
  availability_domain        = each.value.availability_domain
  defined_tags               = each.value.defined_tags
  display_name               = each.value.display_name
  freeform_tags              = merge(local.cislz_module_tag, each.value.freeform_tags)
  ipv4address                = each.value.ipv4address
  ipv6address                = each.value.ipv6address
  network_security_group_ids = each.value.network_security_group_ids
}