# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

# PROCESSED INPUT

locals {
  one_dimension_processed_nsgs = local.one_dimension_processed_vcns != null ? {
    for flat_nsg in flatten([
      for vcn_key, vcn_value in local.one_dimension_processed_vcns :
      vcn_value.network_security_groups != null ? length(vcn_value.network_security_groups) > 0 ? [
        for nsg_key, nsg_value in vcn_value.network_security_groups : {
          compartment_id                 = nsg_value.compartment_id != null ? nsg_value.compartment_id : vcn_value.category_compartment_id != null ? vcn_value.category_compartment_id : vcn_value.default_compartment_id != null ? vcn_value.default_compartment_id : null
          default_compartment_id         = vcn_value.default_compartment_id
          category_compartment_id        = vcn_value.category_compartment_id
          defined_tags                   = merge(nsg_value.defined_tags, vcn_value.category_defined_tags, vcn_value.default_defined_tags)
          default_defined_tags           = vcn_value.default_defined_tags
          category_defined_tags          = vcn_value.category_defined_tags
          freeform_tags                  = merge(nsg_value.freeform_tags, vcn_value.category_freeform_tags, vcn_value.default_freeform_tags)
          default_freeform_tags          = vcn_value.default_freeform_tags
          category_freeform_tags         = vcn_value.category_freeform_tags
          egress_rules                   = nsg_value.egress_rules
          ingress_rules                  = nsg_value.ingress_rules
          network_configuration_category = vcn_value.network_configuration_category
          vcn_key                        = vcn_key
          vcn_id                         = oci_core_vcn.these[vcn_key].id
          vcn_name                       = vcn_value.display_name
          nsg_key                        = nsg_key
          nsg_name                       = nsg_value.display_name
          enable_cis_checks              = vcn_value.category_enable_cis_checks != null ? vcn_value.category_enable_cis_checks : vcn_value.default_enable_cis_checks != null ? vcn_value.default_enable_cis_checks : true
          ssh_ports_to_check             = vcn_value.category_ssh_ports_to_check != null ? vcn_value.category_ssh_ports_to_check : vcn_value.default_ssh_ports_to_check != null ? vcn_value.default_ssh_ports_to_check : local.DEFAULT_SSH_PORTS_TO_CHECK
        }
      ] : [] : []
    ]) : flat_nsg.nsg_key => flat_nsg
  } : null


  one_dimension_processed_injected_nsgs = local.one_dimension_processed_existing_vcns != null ? {
    for flat_nsg in flatten([
      for vcn_key, vcn_value in local.one_dimension_processed_existing_vcns :
      vcn_value.network_security_groups != null ? length(vcn_value.network_security_groups) > 0 ? [
        for nsg_key, nsg_value in vcn_value.network_security_groups : {
          compartment_id                 = nsg_value.compartment_id != null ? nsg_value.compartment_id : vcn_value.category_compartment_id != null ? vcn_value.category_compartment_id : vcn_value.default_compartment_id != null ? vcn_value.default_compartment_id : null
          default_compartment_id         = vcn_value.default_compartment_id
          category_compartment_id        = vcn_value.category_compartment_id
          defined_tags                   = merge(nsg_value.defined_tags, vcn_value.category_defined_tags, vcn_value.default_defined_tags)
          default_defined_tags           = vcn_value.default_defined_tags
          category_defined_tags          = vcn_value.category_defined_tags
          freeform_tags                  = merge(nsg_value.freeform_tags, vcn_value.category_freeform_tags, vcn_value.default_freeform_tags)
          default_freeform_tags          = vcn_value.default_freeform_tags
          category_freeform_tags         = vcn_value.category_freeform_tags
          egress_rules                   = nsg_value.egress_rules
          ingress_rules                  = nsg_value.ingress_rules
          network_configuration_category = vcn_value.network_configuration_category
          vcn_key                        = vcn_key
          vcn_id                         = vcn_value.vcn_id
          vcn_name                       = vcn_value.vcn_name
          nsg_key                        = nsg_key
          nsg_name                       = nsg_value.display_name
          enable_cis_checks              = vcn_value.category_enable_cis_checks != null ? vcn_value.category_enable_cis_checks : vcn_value.default_enable_cis_checks != null ? vcn_value.default_enable_cis_checks : true
          ssh_ports_to_check             = vcn_value.category_ssh_ports_to_check != null ? vcn_value.category_ssh_ports_to_check : vcn_value.default_ssh_ports_to_check != null ? vcn_value.default_ssh_ports_to_check : local.DEFAULT_SSH_PORTS_TO_CHECK
        }
      ] : [] : []
    ]) : flat_nsg.nsg_key => flat_nsg
  } : null

  merged_one_dimension_processed_nsgs = merge(local.one_dimension_processed_nsgs, local.one_dimension_processed_injected_nsgs)


  one_dimension_processed_nsgs_ingress_rules = local.merged_one_dimension_processed_nsgs != null ? length(local.merged_one_dimension_processed_nsgs) > 0 ? {
    for flat_i_rule in flatten([
      for nsg_key, nsg_value in local.merged_one_dimension_processed_nsgs : nsg_value.ingress_rules != null ? length(nsg_value.ingress_rules) > 0 ? [
        for i_rule_key, i_rule_value in nsg_value.ingress_rules : {
          description                    = i_rule_value.description
          protocol                       = local.network_terminology["${i_rule_value.protocol}"]
          stateless                      = i_rule_value.stateless
          src                            = i_rule_value.src
          src_type                       = i_rule_value.src_type
          dst_port_min                   = i_rule_value.dst_port_min
          dst_port_max                   = i_rule_value.dst_port_max
          src_port_min                   = i_rule_value.src_port_min
          src_port_max                   = i_rule_value.src_port_max
          icmp_type                      = i_rule_value.icmp_type
          icmp_code                      = i_rule_value.icmp_code
          i_rule_key                     = i_rule_key
          network_configuration_category = nsg_value.network_configuration_category
          vcn_key                        = nsg_value.vcn_key
          vcn_name                       = nsg_value.vcn_name
          nsg_key                        = nsg_key
          enable_cis_checks              = nsg_value.enable_cis_checks
          ssh_ports_to_check             = nsg_value.ssh_ports_to_check
        }
      ] : [] : []
  ]) : "${flat_i_rule.nsg_key}.${flat_i_rule.i_rule_key}" => flat_i_rule } : null : null

  one_dimension_processed_nsgs_egress_rules = local.merged_one_dimension_processed_nsgs != null ? length(local.merged_one_dimension_processed_nsgs) > 0 ? {
    for flat_e_rule in flatten([
      for nsg_key, nsg_value in local.merged_one_dimension_processed_nsgs : nsg_value.egress_rules != null ? length(nsg_value.egress_rules) > 0 ? [
        for e_rule_key, e_rule_value in nsg_value.egress_rules : {
          description                    = e_rule_value.description
          protocol                       = local.network_terminology["${e_rule_value.protocol}"]
          stateless                      = e_rule_value.stateless
          dst                            = e_rule_value.dst
          dst_type                       = e_rule_value.dst_type
          dst_port_min                   = e_rule_value.dst_port_min
          dst_port_max                   = e_rule_value.dst_port_max
          src_port_min                   = e_rule_value.src_port_min
          src_port_max                   = e_rule_value.src_port_max
          icmp_type                      = e_rule_value.icmp_type
          icmp_code                      = e_rule_value.icmp_code
          e_rule_key                     = e_rule_key
          network_configuration_category = nsg_value.network_configuration_category
          vcn_key                        = nsg_value.vcn_key
          vcn_name                       = nsg_value.vcn_name
          nsg_key                        = nsg_key
        }
      ] : [] : []
  ]) : "${flat_e_rule.nsg_key}.${flat_e_rule.e_rule_key}" => flat_e_rule } : null : null

  provisioned_network_security_groups = {
    for nsg_key, nsg_value in oci_core_network_security_group.these : nsg_key => {
      compartment_id                 = nsg_value.compartment_id
      defined_tags                   = nsg_value.defined_tags
      display_name                   = nsg_value.display_name
      freeform_tags                  = nsg_value.freeform_tags
      id                             = nsg_value.id
      nsg_key                        = nsg_key
      state                          = nsg_value.state
      time_created                   = nsg_value.time_created
      timeouts                       = nsg_value.timeouts
      vcn_id                         = nsg_value.vcn_id
      vcn_key                        = local.merged_one_dimension_processed_nsgs[nsg_key].vcn_key
      vcn_name                       = local.merged_one_dimension_processed_nsgs[nsg_key].vcn_name
      network_configuration_category = local.merged_one_dimension_processed_nsgs[nsg_key].network_configuration_category
    }
  }

  provisioned_network_security_groups_ingress_rules = {
    for i_nsg_rule_key, i_nsg_rule_value in oci_core_network_security_group_security_rule.ingress : i_nsg_rule_key => {
      description                    = i_nsg_rule_value.description
      destination                    = i_nsg_rule_value.destination
      destination_type               = i_nsg_rule_value.destination_type
      direction                      = i_nsg_rule_value.direction
      icmp_options                   = i_nsg_rule_value.icmp_options
      id                             = i_nsg_rule_value.id
      is_valid                       = i_nsg_rule_value.is_valid
      network_security_group_id      = i_nsg_rule_value.network_security_group_id
      network_security_group_name    = oci_core_network_security_group.these[local.one_dimension_processed_nsgs_ingress_rules[i_nsg_rule_key].nsg_key].display_name
      network_security_group_key     = local.one_dimension_processed_nsgs_ingress_rules[i_nsg_rule_key].nsg_key
      protocol                       = i_nsg_rule_value.protocol
      source                         = i_nsg_rule_value.source
      source_type                    = i_nsg_rule_value.source_type
      stateless                      = i_nsg_rule_value.stateless
      tcp_options                    = i_nsg_rule_value.tcp_options
      time_created                   = i_nsg_rule_value.time_created
      timeouts                       = i_nsg_rule_value.timeouts
      udp_options                    = i_nsg_rule_value.udp_options
      vcn_key                        = local.merged_one_dimension_processed_nsgs[local.one_dimension_processed_nsgs_ingress_rules[i_nsg_rule_key].nsg_key].vcn_key
      vcn_name                       = local.merged_one_dimension_processed_nsgs[local.one_dimension_processed_nsgs_ingress_rules[i_nsg_rule_key].nsg_key].vcn_name
      network_configuration_category = local.merged_one_dimension_processed_nsgs[local.one_dimension_processed_nsgs_ingress_rules[i_nsg_rule_key].nsg_key].network_configuration_category
    }
  }

  provisioned_network_security_groups_egress_rules = {
    for e_nsg_rule_key, e_nsg_rule_value in oci_core_network_security_group_security_rule.egress : e_nsg_rule_key => {
      description                    = e_nsg_rule_value.description
      destination                    = e_nsg_rule_value.destination
      destination_type               = e_nsg_rule_value.destination_type
      direction                      = e_nsg_rule_value.direction
      icmp_options                   = e_nsg_rule_value.icmp_options
      id                             = e_nsg_rule_value.id
      is_valid                       = e_nsg_rule_value.is_valid
      network_security_group_id      = e_nsg_rule_value.network_security_group_id
      network_security_group_name    = oci_core_network_security_group.these[local.one_dimension_processed_nsgs_egress_rules[e_nsg_rule_key].nsg_key].display_name
      network_security_group_key     = local.one_dimension_processed_nsgs_egress_rules[e_nsg_rule_key].nsg_key
      protocol                       = e_nsg_rule_value.protocol
      source                         = e_nsg_rule_value.source
      source_type                    = e_nsg_rule_value.source_type
      stateless                      = e_nsg_rule_value.stateless
      tcp_options                    = e_nsg_rule_value.tcp_options
      time_created                   = e_nsg_rule_value.time_created
      timeouts                       = e_nsg_rule_value.timeouts
      udp_options                    = e_nsg_rule_value.udp_options
      vcn_key                        = local.merged_one_dimension_processed_nsgs[local.one_dimension_processed_nsgs_egress_rules[e_nsg_rule_key].nsg_key].vcn_key
      vcn_name                       = local.merged_one_dimension_processed_nsgs[local.one_dimension_processed_nsgs_egress_rules[e_nsg_rule_key].nsg_key].vcn_name
      network_configuration_category = local.merged_one_dimension_processed_nsgs[local.one_dimension_processed_nsgs_egress_rules[e_nsg_rule_key].nsg_key].network_configuration_category
    }
  }
}

# OCI RESOURCES

resource "oci_core_network_security_group" "these" {
  for_each       = local.merged_one_dimension_processed_nsgs != null ? local.merged_one_dimension_processed_nsgs : {}
  compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
  vcn_id         = each.value.vcn_id
  display_name   = each.value.nsg_name
  defined_tags   = each.value.defined_tags
  freeform_tags  = merge(local.cislz_module_tag, each.value.freeform_tags)
}

resource "oci_core_network_security_group_security_rule" "ingress" {
  for_each = local.one_dimension_processed_nsgs_ingress_rules != null ? local.one_dimension_processed_nsgs_ingress_rules : {}

  lifecycle {
    precondition {
      condition     = coalesce(each.value.dst_port_min, local.TCP_PORT_MIN) <= coalesce(each.value.dst_port_max, local.TCP_PORT_MAX)
      error_message = "VALIDATION FAILURE: Invalid configuration in NSG ingress rule [${each.key}]: dst_port_min [${coalesce(each.value.dst_port_min, local.TCP_PORT_MIN)}] must be less than or equal to dst_port_max [${coalesce(each.value.dst_port_max, local.TCP_PORT_MAX)}]."
    }
    precondition {
      condition = each.value.enable_cis_checks ? (
        length(
          [for p in each.value.ssh_ports_to_check : p
            if p >= coalesce(each.value.dst_port_min, local.TCP_PORT_MIN) && p <= coalesce(each.value.dst_port_max, local.TCP_PORT_MAX) && contains(["6", "all"], each.value.protocol) && each.value.src_type == "CIDR_BLOCK" && each.value.src == local.network_terminology["ANYWHERE"]
          ]
        ) > 0 ? false : true
      ) : true
      error_message = "VALIDATION FAILURE (CIS BENCHMARK NETWORKING 2.3/2.4): Provided NSG ingress rule [${each.key}] violates CIS Benchmark recommendation 2.3/2.4: ingress from CIDR ${each.value.src} on port(s) ${join(
        ", ",
        [
          for p in each.value.ssh_ports_to_check : p
          if p >= coalesce(each.value.dst_port_min, local.TCP_PORT_MIN) && p <= coalesce(each.value.dst_port_max, local.TCP_PORT_MAX) && contains(["6", "all"], each.value.protocol) && each.value.src_type == "CIDR_BLOCK" && each.value.src == local.network_terminology["ANYWHERE"]
        ]
      )} over TCP(6) or ALL(all) protocols should be avoided. Either fix the rule in your configuration by scoping down the CIDR range, or specify your actual SSH/RDP ports (default is [22,3389]) using default_ssh_ports_to_check/category_ssh_ports_to_check attributes, or disable module CIS checks altogether by setting default_enable_cis_checks/category_enable_cis_checks attributes to false."
    }
  }

  network_security_group_id = oci_core_network_security_group.these[each.value.nsg_key].id
  direction                 = "INGRESS"
  protocol                  = each.value.protocol

  description = each.value.description
  source      = each.value.src_type != "NETWORK_SECURITY_GROUP" ? each.value.src : oci_core_network_security_group.these[each.value.src].id
  source_type = each.value.src_type != "NETWORK_SECURITY_GROUP" ? each.value.src_type : "NETWORK_SECURITY_GROUP"
  stateless   = each.value.stateless

  dynamic "tcp_options" {
    for_each = each.value.protocol == "6" ? [1] : []
    content {
      dynamic "destination_port_range" {
        for_each = each.value.dst_port_min != null && each.value.dst_port_max != null ? [1] : []
        content {
          max = each.value.dst_port_max
          min = each.value.dst_port_min
        }
      }
      dynamic "source_port_range" {
        for_each = each.value.src_port_min != null && each.value.src_port_max != null ? [1] : []
        content {
          max = each.value.src_port_max
          min = each.value.src_port_min
        }
      }
    }
  }

  dynamic "icmp_options" {
    for_each = each.value.protocol == "1" && each.value.icmp_type != null ? [1] : []
    content {
      type = each.value.icmp_type
      code = each.value.icmp_code
    }
  }

  dynamic "udp_options" {
    for_each = each.value.protocol == "17" ? [1] : []
    content {
      dynamic "destination_port_range" {
        for_each = each.value.dst_port_min != null && each.value.dst_port_max != null ? [1] : []
        content {
          max = each.value.dst_port_max
          min = each.value.dst_port_min
        }
      }
      dynamic "source_port_range" {
        for_each = each.value.src_port_min != null && each.value.src_port_max != null ? [1] : []
        content {
          max = each.value.src_port_max
          min = each.value.src_port_min
        }
      }
    }
  }
}

resource "oci_core_network_security_group_security_rule" "egress" {
  for_each = local.one_dimension_processed_nsgs_egress_rules != null ? local.one_dimension_processed_nsgs_egress_rules : {}

  network_security_group_id = oci_core_network_security_group.these[each.value.nsg_key].id
  direction                 = "EGRESS"
  protocol                  = each.value.protocol

  description = each.value.description

  destination      = each.value.dst_type != "NETWORK_SECURITY_GROUP" ? (each.value.dst_type != "SERVICE_CIDR_BLOCK" ? each.value.dst : local.oci_services_details[each.value.dst].cidr_block) : oci_core_network_security_group.these[each.value.dst].id
  destination_type = each.value.dst_type != "NETWORK_SECURITY_GROUP" ? each.value.dst_type : "NETWORK_SECURITY_GROUP"
  stateless        = each.value.stateless
  dynamic "tcp_options" {
    for_each = each.value.protocol == "6" ? [1] : []
    content {
      dynamic "destination_port_range" {
        for_each = each.value.dst_port_min != null && each.value.dst_port_max != null ? [1] : []
        content {
          max = each.value.dst_port_max
          min = each.value.dst_port_min
        }
      }
      dynamic "source_port_range" {
        for_each = each.value.src_port_min != null && each.value.src_port_max != null ? [1] : []
        content {
          max = each.value.src_port_max
          min = each.value.src_port_min
        }
      }
    }
  }

  dynamic "icmp_options" {
    for_each = each.value.protocol == "1" && each.value.icmp_type != null ? [1] : []
    content {
      type = each.value.icmp_type
      code = each.value.icmp_code
    }
  }

  dynamic "udp_options" {
    for_each = each.value.protocol == "17" ? [1] : []
    content {
      dynamic "destination_port_range" {
        for_each = each.value.dst_port_min != null && each.value.dst_port_max != null ? [1] : []
        content {
          max = each.value.dst_port_max
          min = each.value.dst_port_min
        }
      }
      dynamic "source_port_range" {
        for_each = each.value.src_port_min != null && each.value.src_port_max != null ? [1] : []
        content {
          max = each.value.src_port_max
          min = each.value.src_port_min
        }
      }
    }
  }
}