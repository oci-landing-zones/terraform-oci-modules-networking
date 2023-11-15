# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

locals {
  one_dimension_processed_l7_lb_backend_sets = local.one_dimension_processed_l7_load_balancers != null ? length(local.one_dimension_processed_l7_load_balancers) > 0 ? {
    for flat_backend_set in flatten([
      for l7lb_key, l7lb_value in local.one_dimension_processed_l7_load_balancers : l7lb_value.backend_sets != null ? length(l7lb_value.backend_sets) > 0 ? [
        for l7lb_be_key, l7lb_be_value in l7lb_value.backend_sets : {
          health_checker                              = l7lb_be_value.health_checker
          load_balancer_id                            = local.provisioned_l7_lbs[l7lb_key].id
          name                                        = l7lb_be_value.name
          policy                                      = l7lb_be_value.policy
          lb_cookie_session_persistence_configuration = l7lb_be_value.lb_cookie_session_persistence_configuration
          session_persistence_configuration           = l7lb_be_value.session_persistence_configuration
          ssl_configuration = l7lb_be_value.ssl_configuration != null ? {
            certificate_ids                    = l7lb_be_value.ssl_configuration.certificate_ids
            certificate_keys                   = l7lb_be_value.ssl_configuration.certificate_keys
            certificate_name                   = l7lb_be_value.ssl_configuration.certificate_name
            cipher_suite_name                  = l7lb_be_value.ssl_configuration.cipher_suite_name
            protocols                          = l7lb_be_value.ssl_configuration.protocols
            server_order_preference            = l7lb_be_value.ssl_configuration.server_order_preference
            trusted_certificate_authority_ids  = l7lb_be_value.ssl_configuration.trusted_certificate_authority_ids
            trusted_certificate_authority_keys = l7lb_be_value.ssl_configuration.trusted_certificate_authority_keys
            verify_depth                       = l7lb_be_value.ssl_configuration.verify_depth
            verify_peer_certificate            = l7lb_be_value.ssl_configuration.verify_peer_certificate
          } : null
          backends                       = l7lb_be_value.backends
          l7lb_be_key                    = l7lb_be_key
          l7lb_name                      = l7lb_value.display_name
          l7lb_id                        = local.provisioned_l7_lbs[l7lb_key].id
          l7lb_key                       = l7lb_key
          network_configuration_category = l7lb_value.network_configuration_category
        }
      ] : [] : []
    ]) : flat_backend_set.l7lb_be_key => flat_backend_set
  } : null : null

  provisioned_l7_lbs_backend_sets = {
    for l7lb_be_key, l7lb_be_value in oci_load_balancer_backend_set.these : l7lb_be_key => {
      backend                                     = l7lb_be_value.backend
      health_checker                              = l7lb_be_value.health_checker
      id                                          = l7lb_be_value.id
      lb_cookie_session_persistence_configuration = l7lb_be_value.lb_cookie_session_persistence_configuration
      load_balancer_id                            = l7lb_be_value.load_balancer_id
      name                                        = l7lb_be_value.name
      policy                                      = l7lb_be_value.policy
      session_persistence_configuration           = l7lb_be_value.session_persistence_configuration
      ssl_configuration                           = l7lb_be_value.ssl_configuration
      state                                       = l7lb_be_value.state
      timeouts                                    = l7lb_be_value.timeouts
      l7lb_backendset_key                         = l7lb_be_key
      l7lb_name                                   = local.one_dimension_processed_l7_lb_backend_sets[l7lb_be_key].l7lb_name
      l7lb_id                                     = local.one_dimension_processed_l7_lb_backend_sets[l7lb_be_key].l7lb_id
      l7lb_key                                    = local.one_dimension_processed_l7_lb_backend_sets[l7lb_be_key].l7lb_key
      network_configuration_category              = local.one_dimension_processed_l7_lb_backend_sets[l7lb_be_key].network_configuration_category
    }
  }
}

resource "oci_load_balancer_backend_set" "these" {
  for_each = local.one_dimension_processed_l7_lb_backend_sets != null ? local.one_dimension_processed_l7_lb_backend_sets : {}

  dynamic "health_checker" {
    for_each = each.value.health_checker != null ? [1] : []
    content {

      protocol = each.value.health_checker.protocol

      #Optional
      interval_ms = each.value.health_checker.interval_ms
      #is_force_plain_text = each.value.is_force_plain_text
      port                = each.value.health_checker.port
      response_body_regex = each.value.health_checker.response_body_regex
      retries             = each.value.health_checker.retries
      return_code         = each.value.health_checker.return_code
      timeout_in_millis   = each.value.health_checker.timeout_in_millis
      url_path            = each.value.health_checker.url_path
    }
  }
  load_balancer_id = each.value.l7lb_id
  name             = each.value.name
  policy           = each.value.policy
  dynamic "lb_cookie_session_persistence_configuration" {
    for_each = each.value.lb_cookie_session_persistence_configuration != null ? [1] : []
    content {
      #Optional
      cookie_name        = each.value.lb_cookie_session_persistence_configuration.cookie_name
      disable_fallback   = each.value.lb_cookie_session_persistence_configuration.disable_fallback
      domain             = each.value.lb_cookie_session_persistence_configuration.domain
      is_http_only       = each.value.lb_cookie_session_persistence_configuration.is_http_only
      is_secure          = each.value.lb_cookie_session_persistence_configuration.is_secure
      max_age_in_seconds = each.value.lb_cookie_session_persistence_configuration.max_age_in_seconds
      path               = each.value.lb_cookie_session_persistence_configuration.path
    }
  }
  dynamic "session_persistence_configuration" {
    for_each = each.value.session_persistence_configuration != null ? [1] : []
    content {
      cookie_name = each.value.session_persistence_configuration.cookie_name

      #Optional
      disable_fallback = each.value.session_persistence_configuration.disable_fallback
    }
  }
  dynamic "ssl_configuration" {
    for_each = each.value.ssl_configuration != null ? [1] : []
    content {
      certificate_ids                   = each.value.ssl_configuration.certificate_ids
      certificate_name                  = each.value.ssl_configuration.certificate_name
      cipher_suite_name                 = each.value.ssl_configuration.cipher_suite_name
      protocols                         = each.value.ssl_configuration.protocols
      server_order_preference           = each.value.ssl_configuration.server_order_preference
      trusted_certificate_authority_ids = each.value.ssl_configuration.trusted_certificate_authority_ids
      verify_depth                      = each.value.ssl_configuration.verify_depth
      verify_peer_certificate           = each.value.ssl_configuration.verify_peer_certificate
    }
  }
}