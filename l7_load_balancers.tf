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
  one_dimension_processed_l7_load_balancers = local.one_dimension_processed_non_vcn_specific_gateways != null ? {
    for flat_l7lb in flatten([
      for vcn_non_specific_gw_key, vcn_non_specific_gw_value in local.one_dimension_processed_non_vcn_specific_gateways :
      vcn_non_specific_gw_value.l7_load_balancers != null ? length(vcn_non_specific_gw_value.l7_load_balancers) > 0 ? [
        for l7lb_key, l7lb_value in vcn_non_specific_gw_value.l7_load_balancers : {
          compartment_id          = l7lb_value.compartment_id != null ? l7lb_value.compartment_id : vcn_non_specific_gw_value.category_compartment_id != null ? vcn_non_specific_gw_value.category_compartment_id : vcn_non_specific_gw_value.default_compartment_id != null ? vcn_non_specific_gw_value.default_compartment_id : null
          category_compartment_id = vcn_non_specific_gw_value.category_compartment_id
          default_compartment_id  = vcn_non_specific_gw_value.default_compartment_id
          display_name            = l7lb_value.display_name
          shape                   = l7lb_value.shape
          subnet_keys             = l7lb_value.subnet_keys
          subnet_ids = concat(
            l7lb_value.subnet_ids != null ? l7lb_value.subnet_ids : [],
            l7lb_value.subnet_keys != null ? length(l7lb_value.subnet_keys) > 0 ? [
              for subnet_key in l7lb_value.subnet_keys : local.provisioned_subnets[subnet_key].id
            ] : [] : []
          )
          defined_tags                = merge(l7lb_value.defined_tags, vcn_non_specific_gw_value.category_defined_tags, vcn_non_specific_gw_value.default_defined_tags)
          category_defined_tags       = vcn_non_specific_gw_value.category_defined_tags
          default_defined_tags        = vcn_non_specific_gw_value.default_defined_tags
          freeform_tags               = merge(l7lb_value.freeform_tags, vcn_non_specific_gw_value.category_freeform_tags, vcn_non_specific_gw_value.default_freeform_tags)
          category_freeform_tags      = vcn_non_specific_gw_value.category_freeform_tags
          default_freeform_tags       = vcn_non_specific_gw_value.default_freeform_tags
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
          network_configuration_category = vcn_non_specific_gw_value.network_configuration_category
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
      ] : [] : []
    ]) : flat_l7lb.l7lb_key => flat_l7lb
  } : null
}

module "l7_load_balancers" {
  source = "./modules/l7_load_balancers"
  l7_load_balancers_configuration = {
    dependencies = {
      public_ips              = local.provisioned_oci_core_public_ips
      subnets                 = local.provisioned_subnets
      network_security_groups = local.provisioned_network_security_groups
    },
    l7_load_balancers = local.one_dimension_processed_l7_load_balancers
  }
  compartments_dependency = var.compartments_dependency
}