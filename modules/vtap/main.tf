# ###################################################################################################### #
# Copyright (c) 2024 Oracle and/or its affiliates, All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl. #
# ###################################################################################################### #

# -----------------------------------------------------------------------------
# Create VTAP and Capture Filter Resources
# -----------------------------------------------------------------------------
resource "oci_core_capture_filter" "these" {
  for_each = var.vtaps_configuration != null ? (var.vtaps_configuration.capture_filters != null ? var.vtaps_configuration.capture_filters : {}) : {}
  compartment_id = each.value.compartment_id != null ? each.value.compartment_id : (var.vtaps_configuration.default_compartment_id != null ? var.vtaps_configuration.default_compartment_id : null)
  filter_type    = each.value.filter_type
  display_name   = each.value.display_name

  dynamic "vtap_capture_filter_rules" {
    for_each = each.value.vtap_capture_filter_rules != null ? each.value.vtap_capture_filter_rules : {}
    content {
      traffic_direction = vtap_capture_filter_rules.value.traffic_direction
      rule_action       = vtap_capture_filter_rules.value.rule_action != null ? vtap_capture_filter_rules.value.rule_action : null
      source_cidr       = vtap_capture_filter_rules.value.source_cidr != null ? vtap_capture_filter_rules.value.source_cidr : null
      destination_cidr  = vtap_capture_filter_rules.value.destination_cidr != null ? vtap_capture_filter_rules.value.destination_cidr : null
      protocol          = vtap_capture_filter_rules.value.protocol != null ? vtap_capture_filter_rules.value.protocol : null

      dynamic "icmp_options" {
        for_each = vtap_capture_filter_rules.value.icmp_options != null ? vtap_capture_filter_rules.value.icmp_options : {}
        content {
          type = icmp_options.value.type
          code = icmp_options.value.code
        }
      }

      dynamic "tcp_options" {
        for_each = vtap_capture_filter_rules.value.tcp_options != null ? vtap_capture_filter_rules.value.tcp_options : {}
        content {
          destination_port_range {
            max = tcp_options.value.destination_port_range_max
            min = tcp_options.value.destination_port_range_min
          }
          source_port_range {
            max = tcp_options.value.source_port_range_max
            min = tcp_options.value.source_port_range_min
          }
        }
      }

      dynamic "udp_options" {
        for_each = vtap_capture_filter_rules.value.udp_options != null ? vtap_capture_filter_rules.value.udp_options : {}
        content {
          destination_port_range {
            max = udp_options.value.destination_port_range_max
            min = udp_options.value.destination_port_range_min
          }
          source_port_range {
            max = udp_options.value.source_port_range_max
            min = udp_options.value.source_port_range_min
          }
        }
      }
    }
  }
}

resource "oci_network_load_balancer_network_load_balancer" "these" {
  for_each = var.vtaps_configuration != null ? (var.vtaps_configuration.network_load_balancers != null ? var.vtaps_configuration.network_load_balancers : {}) : {}
  compartment_id = each.value.compartment_id != null ? each.value.compartment_id : (var.vtaps_configuration.default_compartment_id != null ? var.vtaps_configuration.default_compartment_id : null)
  display_name   = each.value.display_name
  subnet_id      = each.value.subnet_id
}

resource "oci_core_vtap" "these" {
  for_each = var.vtaps_configuration != null ? (var.vtaps_configuration.vtaps != null ? var.vtaps_configuration.vtaps : {}) : {}
  capture_filter_id = oci_core_capture_filter.these[each.value.capture_filter_id].id
  compartment_id    = each.value.compartment_id != null ? each.value.compartment_id : (var.vtaps_configuration.default_compartment_id != null ? var.vtaps_configuration.default_compartment_id : null)
  source_type       = each.value.source_type
  source_id         = each.value.source_id
  vcn_id            = each.value.vcn_id
  display_name      = each.value.display_name
  is_vtap_enabled   = each.value.is_vtap_enabled
  target_type       = each.value.target_type
  target_id         = oci_network_load_balancer_network_load_balancer.these[each.value.target_id].id
}

# -----------------------------------------------------------------------------
# Create NLB Resouces
# -----------------------------------------------------------------------------

resource "oci_network_load_balancer_listener" "these" {
  for_each = var.vtaps_configuration != null ? (var.vtaps_configuration.network_load_balancer_listeners != null ? var.vtaps_configuration.network_load_balancer_listeners : {}) : {}
  default_backend_set_name = oci_network_load_balancer_backend_set.these[each.value.default_backend_set_name].name
  name                     = each.value.listener_name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.these[each.value.network_load_balancer_id].id
  port                     = each.value.port
  protocol                 = each.value.protocol
}

resource "oci_network_load_balancer_backend_set" "these" {
  for_each = var.vtaps_configuration != null ? (var.vtaps_configuration.network_load_balancer_backend_sets != null ? var.vtaps_configuration.network_load_balancer_backend_sets : {}) : {}
  health_checker {
    protocol = each.value.protocol
  }
  name                     = each.value.name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.these[each.value.network_load_balancer_id].id
  policy                   = each.value.policy
}
