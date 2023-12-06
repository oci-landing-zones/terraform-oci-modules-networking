# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

locals {
  one_dimension_processed_l7_lb_cipher_suites = local.one_dimension_processed_l7_load_balancers != null ? length(local.one_dimension_processed_l7_load_balancers) > 0 ? {
    for flat_cipher_suite in flatten([
      for l7lb_key, l7lb_value in local.one_dimension_processed_l7_load_balancers : l7lb_value.cipher_suites != null ? length(l7lb_value.cipher_suites) > 0 ? [
        for l7lb_cs_key, l7lb_cs_value in l7lb_value.cipher_suites : {
          load_balancer_id               = local.provisioned_l7_lbs[l7lb_key].id
          name                           = l7lb_cs_value.name
          ciphers                        = l7lb_cs_value.ciphers,
          l7lb_cs_key                    = l7lb_cs_key
          l7lb_name                      = l7lb_value.display_name
          l7lb_id                        = local.provisioned_l7_lbs[l7lb_key].id
          l7lb_key                       = l7lb_key
          network_configuration_category = l7lb_value.network_configuration_category
        }
      ] : [] : []
    ]) : flat_cipher_suite.l7lb_cs_key => flat_cipher_suite
  } : null : null

  provisioned_l7_lbs_cipher_suites = {
    for l7lb_cs_key, l7lb_cs_value in oci_load_balancer_ssl_cipher_suite.these : l7lb_cs_key => {
      ciphers                        = l7lb_cs_value.ciphers,
      id                             = l7lb_cs_value.id
      load_balancer_id               = l7lb_cs_value.load_balancer_id
      l7lb_name                      = local.one_dimension_processed_l7_lb_cipher_suites[l7lb_cs_key].l7lb_name
      l7lb_id                        = local.one_dimension_processed_l7_lb_cipher_suites[l7lb_cs_key].l7lb_id
      l7lb_key                       = local.one_dimension_processed_l7_lb_cipher_suites[l7lb_cs_key].l7lb_key
      name                           = l7lb_cs_value.name
      state                          = l7lb_cs_value.state
      timeouts                       = l7lb_cs_value.timeouts
      l7lb_cs_key                    = l7lb_cs_key
      network_configuration_category = local.one_dimension_processed_l7_lb_cipher_suites[l7lb_cs_key].network_configuration_category
    }
  }
}

resource "oci_load_balancer_ssl_cipher_suite" "these" {
  for_each = local.one_dimension_processed_l7_lb_cipher_suites != null ? local.one_dimension_processed_l7_lb_cipher_suites : {}
  #Required
  ciphers          = each.value.ciphers
  load_balancer_id = each.value.load_balancer_id
  name             = each.value.name
}