# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

locals {
  one_dimension_processed_l7_lb_path_route_sets = local.one_dimension_processed_l7_load_balancers != null ? length(local.one_dimension_processed_l7_load_balancers) > 0 ? {
    for flat_path_route_set in flatten([
      for l7lb_key, l7lb_value in local.one_dimension_processed_l7_load_balancers : l7lb_value.path_route_sets != null ? length(l7lb_value.path_route_sets) > 0 ? [
        for l7lb_prs_key, l7lb_prs_value in l7lb_value.path_route_sets : {
          load_balancer_id               = local.provisioned_l7_lbs[l7lb_key].id,
          name                           = l7lb_prs_value.name,
          l7lb_prs_key                   = l7lb_prs_key,
          path_routes                    = l7lb_prs_value.path_routes,
          l7lb_name                      = l7lb_value.display_name,
          l7lb_id                        = local.provisioned_l7_lbs[l7lb_key].id,
          l7lb_key                       = l7lb_key,
          network_configuration_category = l7lb_value.network_configuration_category
        }
      ] : [] : []
    ]) : flat_path_route_set.l7lb_prs_key => flat_path_route_set
  } : null : null

  provisioned_l7_lbs_path_route_sets = {
    for l7lb_prs_key, l7lb_prs_value in oci_load_balancer_path_route_set.these : l7lb_prs_key => {
      id                             = l7lb_prs_value.id
      load_balancer_id               = l7lb_prs_value.load_balancer_id
      l7lb_name                      = local.one_dimension_processed_l7_lb_path_route_sets[l7lb_prs_key].l7lb_name
      l7lb_id                        = local.one_dimension_processed_l7_lb_path_route_sets[l7lb_prs_key].l7lb_id
      l7lb_key                       = local.one_dimension_processed_l7_lb_path_route_sets[l7lb_prs_key].l7lb_key
      name                           = l7lb_prs_value.name
      path_routes                    = l7lb_prs_value.path_routes
      state                          = l7lb_prs_value.state
      timeouts                       = l7lb_prs_value.timeouts
      l7lb_prs_key                   = l7lb_prs_key
      network_configuration_category = local.one_dimension_processed_l7_lb_path_route_sets[l7lb_prs_key].network_configuration_category
    }
  }
}

resource "oci_load_balancer_path_route_set" "these" {
  for_each = local.one_dimension_processed_l7_lb_path_route_sets != null ? local.one_dimension_processed_l7_lb_path_route_sets : {}
  #Required
  load_balancer_id = each.value.load_balancer_id
  name             = each.value.name

  dynamic "path_routes" {
    for_each = each.value.path_routes != null ? length(each.value.path_routes) > 0 ? each.value.path_routes : {} : {}
    #Required
    content {
      backend_set_name = local.provisioned_l7_lbs_backend_sets[path_routes.value.backend_set_key].name
      path             = path_routes.value.path
      path_match_type {
        match_type = path_routes.value.path_match_type.match_type
      }
    }
  }
}