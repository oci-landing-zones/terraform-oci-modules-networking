# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

locals {
  one_dimension_processed_l7_lb_rule_sets = local.one_dimension_processed_l7_load_balancers != null ? length(local.one_dimension_processed_l7_load_balancers) > 0 ? {
    for flat_rule_set in flatten([
      for l7lb_key, l7lb_value in local.one_dimension_processed_l7_load_balancers : l7lb_value.rule_sets != null ? length(l7lb_value.rule_sets) > 0 ? [
        for l7lb_rule_set_key, l7lb_rule_set_value in l7lb_value.rule_sets : {
          load_balancer_id               = local.provisioned_l7_lbs[l7lb_key].id,
          name                           = l7lb_rule_set_value.name,
          items                          = l7lb_rule_set_value.items
          l7lb_rule_set_key              = l7lb_rule_set_key,
          l7lb_name                      = l7lb_value.display_name,
          l7lb_id                        = local.provisioned_l7_lbs[l7lb_key].id,
          l7lb_key                       = l7lb_key,
          network_configuration_category = l7lb_value.network_configuration_category
        }
      ] : [] : []
    ]) : flat_rule_set.l7lb_rule_set_key => flat_rule_set
  } : null : null

  provisioned_l7_lbs_path_rule_sets = {
    for l7lb_rule_set_key, l7lb_rule_set_value in oci_load_balancer_rule_set.these : l7lb_rule_set_key => {
      id                             = l7lb_rule_set_value.id
      name                           = l7lb_rule_set_value.name
      load_balancer_id               = l7lb_rule_set_value.load_balancer_id
      items                          = l7lb_rule_set_value.items
      l7lb_name                      = local.one_dimension_processed_l7_lb_rule_sets[l7lb_rule_set_key].l7lb_name
      l7lb_id                        = local.one_dimension_processed_l7_lb_rule_sets[l7lb_rule_set_key].l7lb_id
      l7lb_key                       = local.one_dimension_processed_l7_lb_rule_sets[l7lb_rule_set_key].l7lb_key
      state                          = l7lb_rule_set_value.state
      timeouts                       = l7lb_rule_set_value.timeouts
      l7lb_rule_set_key              = l7lb_rule_set_key
      network_configuration_category = local.one_dimension_processed_l7_lb_rule_sets[l7lb_rule_set_key].network_configuration_category
    }
  }
}

resource "oci_load_balancer_rule_set" "these" {
  for_each = local.one_dimension_processed_l7_lb_rule_sets != null ? local.one_dimension_processed_l7_lb_rule_sets : {}
  #Required
  dynamic "items" {
    for_each = each.value.items != null ? length(each.value.items) > 0 ? each.value.items : {} : {}
    content {
      #Required
      action = items.value.action

      #Optional
      allowed_methods                = items.value.allowed_methods
      are_invalid_characters_allowed = items.value.are_invalid_characters_allowed
      dynamic "conditions" {
        for_each = items.value.conditions != null ? length(items.value.conditions) > 0 ? items.value.conditions : {} : {}
        content {
          #Required
          attribute_name  = conditions.value.attribute_name
          attribute_value = conditions.value.attribute_value

          #Optional
          operator = conditions.value.operator
        }
      }
      description                  = items.value.description
      header                       = items.value.header
      http_large_header_size_in_kb = items.value.http_large_header_size_in_kb
      prefix                       = items.value.prefix
      dynamic "redirect_uri" {
        for_each = items.value.redirect_uri != null ? [1] : []
        content {
          #Optional
          host     = items.value.redirect_uri.host
          path     = items.value.redirect_uri.path
          port     = items.value.redirect_uri.port
          protocol = items.value.redirect_uri.protocol
          query    = items.value.redirect_uri.query
        }
      }
      response_code = items.value.response_code
      status_code   = items.value.status_code
      suffix        = items.value.suffix
      value         = items.value.value
    }
  }
  load_balancer_id = each.value.load_balancer_id
  name             = each.value.name
}