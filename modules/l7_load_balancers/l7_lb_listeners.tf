# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

locals {
  one_dimension_processed_l7_lb_listeners = local.one_dimension_processed_l7_load_balancers != null ? length(local.one_dimension_processed_l7_load_balancers) > 0 ? {
    for flat_listener in flatten([
      for l7lb_key, l7lb_value in local.one_dimension_processed_l7_load_balancers : l7lb_value.listeners != null ? length(l7lb_value.listeners) > 0 ? [
        for l7lb_listener_key, l7lb_listener_value in l7lb_value.listeners : {
          default_backend_set_name = l7lb_listener_value.default_backend_set_key != null ? local.provisioned_l7_lbs_backend_sets[l7lb_listener_value.default_backend_set_key].name : null
          load_balancer_id         = local.provisioned_l7_lbs[l7lb_key].id,
          name                     = l7lb_listener_value.name,
          port                     = l7lb_listener_value.port,
          protocol                 = l7lb_listener_value.protocol,
          connection_configuration = l7lb_listener_value.connection_configuration
          hostname_names           = l7lb_listener_value.hostname_keys != null ? [for hostname_key in l7lb_listener_value.hostname_keys : local.provisioned_l7_lbs_hostnames[hostname_key].name] : []
          path_route_set_name      = l7lb_listener_value.path_route_set_key != null ? local.provisioned_l7_lbs_path_route_sets[l7lb_listener_value.path_route_set_key].name : null,
          routing_policy_name      = l7lb_listener_value.routing_policy_key != null ? local.provisioned_l7_lbs_path_routing_policies[l7lb_listener_value.routing_policy_key].name : null
          rule_set_names           = l7lb_listener_value.rule_set_keys != null ? [for rule_set_key in l7lb_listener_value.rule_set_keys : local.provisioned_l7_lbs_path_rule_sets[rule_set_key].name] : []
          ssl_configuration = l7lb_listener_value.ssl_configuration != null ? {
            certificate_name                  = l7lb_listener_value.ssl_configuration.certificate_key != null ? local.provisioned_l7_lbs_certificates[l7lb_listener_value.ssl_configuration.certificate_key].certificate_name : null
            certificate_ids                   = l7lb_listener_value.ssl_configuration.certificate_ids
            cipher_suite_name                 = l7lb_listener_value.ssl_configuration.cipher_suite_key != null ? local.provisioned_l7_lbs_cipher_suites[l7lb_listener_value.ssl_configuration.cipher_suite_key].name : null
            protocols                         = l7lb_listener_value.ssl_configuration.protocols
            server_order_preference           = l7lb_listener_value.ssl_configuration.server_order_preference
            trusted_certificate_authority_ids = l7lb_listener_value.ssl_configuration.trusted_certificate_authority_ids
            verify_depth                      = l7lb_listener_value.ssl_configuration.verify_depth
            verify_peer_certificate           = l7lb_listener_value.ssl_configuration.verify_peer_certificate
            } : {
            certificate_name                  = "NULL-SSL-CONFIGURATION"
            certificate_ids                   = [null]
            cipher_suite_name                 = null
            protocols                         = [null]
            server_order_preference           = null
            trusted_certificate_authority_ids = [null]
            verify_depth                      = null
            verify_peer_certificate           = null
          }
          l7lb_listener_key              = l7lb_listener_key,
          l7lb_name                      = l7lb_value.display_name,
          l7lb_id                        = local.provisioned_l7_lbs[l7lb_key].id,
          l7lb_key                       = l7lb_key,
          network_configuration_category = l7lb_value.network_configuration_category
        }
      ] : [] : []
    ]) : flat_listener.l7lb_listener_key => flat_listener
  } : null : null

  provisioned_l7_lb_listeners = {
    for l7lb_listener_key, l7lb_listener_value in oci_load_balancer_listener.these : l7lb_listener_key => {

      connection_configuration       = l7lb_listener_value.connection_configuration
      default_backend_set_name       = l7lb_listener_value.default_backend_set_name
      hostname_names                 = l7lb_listener_value.hostname_names
      id                             = l7lb_listener_value.id
      load_balancer_id               = l7lb_listener_value.load_balancer_id
      name                           = l7lb_listener_value.name
      path_route_set_name            = l7lb_listener_value.path_route_set_name
      port                           = l7lb_listener_value.port
      protocol                       = l7lb_listener_value.protocol
      routing_policy_name            = l7lb_listener_value.routing_policy_name
      rule_set_names                 = l7lb_listener_value.rule_set_names
      ssl_configuration              = l7lb_listener_value.ssl_configuration
      l7lb_listener_key              = l7lb_listener_key
      load_balancer_id               = l7lb_listener_value.load_balancer_id
      l7lb_name                      = local.one_dimension_processed_l7_lb_listeners[l7lb_listener_key].l7lb_name
      l7lb_id                        = local.one_dimension_processed_l7_lb_listeners[l7lb_listener_key].l7lb_id
      l7lb_key                       = local.one_dimension_processed_l7_lb_listeners[l7lb_listener_key].l7lb_key
      state                          = l7lb_listener_value.state
      timeouts                       = l7lb_listener_value.timeouts
      network_configuration_category = local.one_dimension_processed_l7_lb_listeners[l7lb_listener_key].network_configuration_category
    }
  }
}

resource "oci_load_balancer_listener" "these" {
  for_each = local.one_dimension_processed_l7_lb_listeners != null ? local.one_dimension_processed_l7_lb_listeners : {}
  #Required
  default_backend_set_name = each.value.default_backend_set_name
  load_balancer_id         = each.value.load_balancer_id
  name                     = each.value.name
  port                     = each.value.port
  protocol                 = each.value.protocol

  #Optional
  dynamic "connection_configuration" {
    for_each = each.value.connection_configuration != null ? [1] : []
    content {
      #Required
      idle_timeout_in_seconds = each.value.connection_configuration.idle_timeout_in_seconds

      #Optional
      backend_tcp_proxy_protocol_version = each.value.connection_configuration.backend_tcp_proxy_protocol_version
    }
  }
  hostname_names      = each.value.hostname_names
  path_route_set_name = each.value.path_route_set_name
  routing_policy_name = each.value.routing_policy_name
  rule_set_names      = each.value.rule_set_names
  dynamic "ssl_configuration" {
    for_each = each.value.ssl_configuration != null ? length(each.value.ssl_configuration) > 0 ? each.value.ssl_configuration.certificate_name != "NULL-SSL-CONFIGURATION" ? [1] : [] : [] : []
    content {
      #Optional
      certificate_name                  = each.value.ssl_configuration.certificate_name
      certificate_ids                   = each.value.ssl_configuration.certificate_ids
      cipher_suite_name                 = each.value.ssl_configuration.cipher_suite_name
      protocols                         = each.value.ssl_configuration.protocols
      server_order_preference           = each.value.ssl_configuration.server_order_preference
      trusted_certificate_authority_ids = each.value.ssl_configuration.trusted_certificate_authority_ids
      verify_depth                      = each.value.ssl_configuration.verify_depth
      verify_peer_certificate           = each.value.ssl_configuration.verify_peer_certificate
    }
  }
}