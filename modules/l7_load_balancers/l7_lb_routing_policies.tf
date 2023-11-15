# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

locals {
  one_dimension_processed_l7_lb_routing_policies = local.one_dimension_processed_l7_load_balancers != null ? length(local.one_dimension_processed_l7_load_balancers) > 0 ? {
    for flat_routing_policy in flatten([
      for l7lb_key, l7lb_value in local.one_dimension_processed_l7_load_balancers : l7lb_value.routing_policies != null ? length(l7lb_value.routing_policies) > 0 ? [
        for l7lb_routing_policy_key, l7lb_routing_policy_value in l7lb_value.routing_policies : {
          load_balancer_id               = local.provisioned_l7_lbs[l7lb_key].id,
          name                           = l7lb_routing_policy_value.name,
          condition_language_version     = l7lb_routing_policy_value.condition_language_version,
          rules                          = l7lb_routing_policy_value.rules,
          l7lb_routing_policy_key        = l7lb_routing_policy_key,
          l7lb_name                      = l7lb_value.display_name,
          l7lb_id                        = local.provisioned_l7_lbs[l7lb_key].id,
          l7lb_key                       = l7lb_key,
          network_configuration_category = l7lb_value.network_configuration_category
        }
      ] : [] : []
    ]) : flat_routing_policy.l7lb_routing_policy_key => flat_routing_policy
  } : null : null

  provisioned_l7_lbs_path_routing_policies = {
    for l7lb_routing_policy_key, l7lb_routing_policy_value in oci_load_balancer_load_balancer_routing_policy.these : l7lb_routing_policy_key => {
      id                             = l7lb_routing_policy_value.id
      name                           = l7lb_routing_policy_value.name
      load_balancer_id               = l7lb_routing_policy_value.load_balancer_id
      condition_language_version     = l7lb_routing_policy_value.condition_language_version
      rules                          = l7lb_routing_policy_value.rules
      l7lb_name                      = local.one_dimension_processed_l7_lb_routing_policies[l7lb_routing_policy_key].l7lb_name
      l7lb_id                        = local.one_dimension_processed_l7_lb_routing_policies[l7lb_routing_policy_key].l7lb_id
      l7lb_key                       = local.one_dimension_processed_l7_lb_routing_policies[l7lb_routing_policy_key].l7lb_key
      state                          = l7lb_routing_policy_value.state
      timeouts                       = l7lb_routing_policy_value.timeouts
      l7lb_routing_policy_key        = l7lb_routing_policy_key
      network_configuration_category = local.one_dimension_processed_l7_lb_routing_policies[l7lb_routing_policy_key].network_configuration_category
    }
  }
}

resource "oci_load_balancer_load_balancer_routing_policy" "these" {
  for_each = local.one_dimension_processed_l7_lb_routing_policies != null ? local.one_dimension_processed_l7_lb_routing_policies : {}
  #Required
  condition_language_version = each.value.condition_language_version
  load_balancer_id           = each.value.load_balancer_id
  name                       = each.value.condition_language_version
  dynamic "rules" {
    for_each = each.value.rules != null ? length(each.value.rules) > 0 ? each.value.rules : {} : {}
    content {
      #Required
      dynamic "actions" {
        for_each = rules.value.actions != null ? length(rules.value.actions) > 0 ? rules.value.actions : {} : {}
        #Required
        content {
          backend_set_name = local.provisioned_l7_lbs_backend_sets[actions.value.backend_set_key].name
          name             = actions.value.name
        }
      }
      condition = rules.value.condition
      name      = rules.value.name
    }
  }
}

