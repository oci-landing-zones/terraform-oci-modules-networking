# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

locals {
  one_dimension_processed_l7_lb_backends = local.one_dimension_processed_l7_lb_backend_sets != null ? length(local.one_dimension_processed_l7_lb_backend_sets) > 0 ? {
    for flat_backend in flatten([
      for l7lb_bes_key, l7lb_bes_value in local.one_dimension_processed_l7_lb_backend_sets : l7lb_bes_value.backends != null ? length(l7lb_bes_value.backends) > 0 ? [
        for l7lb_be_key, l7lb_be_value in l7lb_bes_value.backends : {
          backendset_name                = local.provisioned_l7_lbs_backend_sets[l7lb_bes_key].name
          ip_address                     = l7lb_be_value.ip_address
          load_balancer_id               = l7lb_bes_value.l7lb_id
          port                           = l7lb_be_value.port
          backup                         = l7lb_be_value.backup
          drain                          = l7lb_be_value.drain
          offline                        = l7lb_be_value.offline
          weight                         = l7lb_be_value.weight
          l7lb_name                      = l7lb_bes_value.l7lb_name
          l7lb_id                        = l7lb_bes_value.l7lb_id
          l7lb_key                       = l7lb_bes_value.l7lb_key
          network_configuration_category = l7lb_bes_value.network_configuration_category
          l7lb_be_key                    = l7lb_be_key
          l7lb_bes_key                   = l7lb_bes_key
        }
      ] : [] : []
    ]) : flat_backend.l7lb_be_key => flat_backend
  } : null : null

  provisioned_l7_lb_backends = {
    for l7lb_be_key, l7lb_be_value in oci_load_balancer_backend.these : l7lb_be_key => {
      backendset_name                = l7lb_be_value.backendset_name
      backendset_key                 = local.one_dimension_processed_l7_lb_backends[l7lb_be_key].l7lb_bes_key
      backup                         = l7lb_be_value.backup
      drain                          = l7lb_be_value.drain
      id                             = l7lb_be_value.id
      ip_address                     = l7lb_be_value.ip_address
      load_balancer_id               = l7lb_be_value.load_balancer_id
      name                           = l7lb_be_value.name
      offline                        = l7lb_be_value.offline
      port                           = l7lb_be_value.port
      state                          = l7lb_be_value.state
      timeouts                       = l7lb_be_value.timeouts
      weight                         = l7lb_be_value.weight
      network_configuration_category = local.one_dimension_processed_l7_lb_backends[l7lb_be_key].network_configuration_category
      l7lb_name                      = local.one_dimension_processed_l7_lb_backends[l7lb_be_key].l7lb_name
      l7lb_id                        = local.one_dimension_processed_l7_lb_backends[l7lb_be_key].l7lb_id
      l7lb_key                       = local.one_dimension_processed_l7_lb_backends[l7lb_be_key].l7lb_key
    }
  }
}

resource "oci_load_balancer_backend" "these" {
  for_each = local.one_dimension_processed_l7_lb_backends != null ? local.one_dimension_processed_l7_lb_backends : {}
  #Required
  backendset_name  = each.value.backendset_name
  ip_address       = each.value.ip_address
  load_balancer_id = each.value.load_balancer_id
  port             = each.value.port

  #Optional
  backup  = each.value.backup
  drain   = each.value.drain
  offline = each.value.offline
  weight  = each.value.weight
}