# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

locals {
  one_dimension_processed_l7_lb_host_names = local.one_dimension_processed_l7_load_balancers != null ? length(local.one_dimension_processed_l7_load_balancers) > 0 ? {
    for flat_hostname in flatten([
      for l7lb_key, l7lb_value in local.one_dimension_processed_l7_load_balancers : l7lb_value.host_names != null ? length(l7lb_value.host_names) > 0 ? [
        for l7lb_hostname_key, l7lb_hostname_value in l7lb_value.host_names : {
          load_balancer_id               = local.provisioned_l7_lbs[l7lb_key].id,
          name                           = l7lb_hostname_value.name,
          l7lb_hostname_key              = l7lb_hostname_key,
          hostname                       = l7lb_hostname_value.hostname,
          l7lb_name                      = l7lb_value.display_name,
          l7lb_id                        = local.provisioned_l7_lbs[l7lb_key].id,
          l7lb_key                       = l7lb_key,
          network_configuration_category = l7lb_value.network_configuration_category
        }
      ] : [] : []
    ]) : flat_hostname.l7lb_hostname_key => flat_hostname
  } : null : null

  provisioned_l7_lbs_hostnames = {
    for l7lb_hostname_key, l7lb_hostname_value in oci_load_balancer_hostname.these : l7lb_hostname_key => {
      hostname                       = l7lb_hostname_value.hostname
      id                             = l7lb_hostname_value.id
      l7lb_hostname_key              = l7lb_hostname_key
      load_balancer_id               = l7lb_hostname_value.load_balancer_id
      l7lb_name                      = local.one_dimension_processed_l7_lb_host_names[l7lb_hostname_key].l7lb_name
      l7lb_id                        = local.one_dimension_processed_l7_lb_host_names[l7lb_hostname_key].l7lb_id
      l7lb_key                       = local.one_dimension_processed_l7_lb_host_names[l7lb_hostname_key].l7lb_key
      name                           = l7lb_hostname_value.name
      state                          = l7lb_hostname_value.state
      timeouts                       = l7lb_hostname_value.timeouts
      network_configuration_category = local.one_dimension_processed_l7_lb_host_names[l7lb_hostname_key].network_configuration_category
    }
  }
}

resource "oci_load_balancer_hostname" "these" {
  for_each = local.one_dimension_processed_l7_lb_host_names != null ? local.one_dimension_processed_l7_lb_host_names : {}
  #Required
  hostname         = each.value.hostname
  load_balancer_id = each.value.load_balancer_id
  name             = each.value.name

  #Optional
  lifecycle {
    create_before_destroy = true
  }
}