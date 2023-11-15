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
  one_dimension_processed_l7_load_balancers = var.l7_load_balancers_configuration != null ? var.l7_load_balancers_configuration.l7_load_balancers != null ? {
    for l7lb_key, l7lb_value in var.l7_load_balancers_configuration.l7_load_balancers : l7lb_key => {
      compartment_id = l7lb_value.compartment_id
      display_name   = l7lb_value.display_name
      shape          = l7lb_value.shape
      subnet_keys    = l7lb_value.subnet_keys
      subnet_ids = concat(
        l7lb_value.subnet_ids != null ? l7lb_value.subnet_ids : [],
        l7lb_value.subnet_keys != null ? length(l7lb_value.subnet_keys) > 0 ? [
          for subnet_key in l7lb_value.subnet_keys : local.provisioned_subnets[subnet_key].id
        ] : [] : []
      )
      defined_tags                = l7lb_value.defined_tags
      freeform_tags               = l7lb_value.freeform_tags
      ip_mode                     = l7lb_value.ip_mode
      is_private                  = l7lb_value.is_private
      network_security_group_keys = l7lb_value.network_security_group_keys
      network_security_group_ids = concat(
        l7lb_value.network_security_group_ids != null ? l7lb_value.network_security_group_ids : [],
        l7lb_value.network_security_group_keys != null ? length(l7lb_value.network_security_group_keys) > 0 ? [
          for nsg_key in l7lb_value.network_security_group_keys : local.provisioned_network_security_groups[nsg_key].id
        ] : [] : []
      )
      reserved_ips_ids = concat(
        l7lb_value.reserved_ips_ids != null ? length(l7lb_value.reserved_ips_ids) > 0 ? l7lb_value.reserved_ips_ids : [] : [],
        l7lb_value.reserved_ips_keys != null ? length(l7lb_value.reserved_ips_keys) > 0 ? [
          for reserver_ip_key in l7lb_value.reserved_ips_keys : local.provisioned_oci_core_public_ips[reserver_ip_key].id
        ] : [] : []
      )
      reserved_ips_keys = l7lb_value.reserved_ips_keys
      shape_details = {
        maximum_bandwidth_in_mbps = l7lb_value.shape_details.maximum_bandwidth_in_mbps
        minimum_bandwidth_in_mbps = l7lb_value.shape_details.minimum_bandwidth_in_mbps
      }
      network_configuration_category = null
      l7lb_key                       = l7lb_key
      backend_sets                   = l7lb_value.backend_sets
      cipher_suites                  = l7lb_value.cipher_suites
      path_route_sets                = l7lb_value.path_route_sets
      host_names                     = l7lb_value.host_names
      routing_policies               = l7lb_value.routing_policies
      rule_sets                      = l7lb_value.rule_sets
      certificates                   = l7lb_value.certificates
      listeners                      = l7lb_value.listeners
    }
  } : {} : {}

  provisioned_oci_core_public_ips     = var.l7_load_balancers_configuration != null ? var.l7_load_balancers_configuration.dependencies != null ? var.l7_load_balancers_configuration.dependencies.public_ips != null ? var.l7_load_balancers_configuration.dependencies.public_ips : null : null : null
  provisioned_subnets                 = var.l7_load_balancers_configuration != null ? var.l7_load_balancers_configuration.dependencies != null ? var.l7_load_balancers_configuration.dependencies.subnets != null ? var.l7_load_balancers_configuration.dependencies.subnets : null : null : null
  provisioned_network_security_groups = var.l7_load_balancers_configuration != null ? var.l7_load_balancers_configuration.dependencies != null ? var.l7_load_balancers_configuration.dependencies.network_security_groups != null ? var.l7_load_balancers_configuration.dependencies.network_security_groups : null : null : null
}

module "l7_load_balancers" {
  source = "../../"
  l7_load_balancers_configuration = {
    dependencies = {
      public_ips              = local.provisioned_oci_core_public_ips
      subnets                 = local.provisioned_subnets
      network_security_groups = local.provisioned_network_security_groups
    },
    l7_load_balancers = local.one_dimension_processed_l7_load_balancers
  }
}