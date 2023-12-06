# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

locals {
  one_dimension_processed_l7_lb_certificates = local.one_dimension_processed_l7_load_balancers != null ? length(local.one_dimension_processed_l7_load_balancers) > 0 ? {
    for flat_certificate in flatten([
      for l7lb_key, l7lb_value in local.one_dimension_processed_l7_load_balancers : l7lb_value.certificates != null ? length(l7lb_value.certificates) > 0 ? [
        for l7lb_certificate_key, l7lb_certificate_value in l7lb_value.certificates : {
          load_balancer_id               = local.provisioned_l7_lbs[l7lb_key].id,
          certificate_name               = l7lb_certificate_value.certificate_name,
          ca_certificate                 = l7lb_certificate_value.ca_certificate
          passphrase                     = l7lb_certificate_value.passphrase
          private_key                    = l7lb_certificate_value.private_key
          public_certificate             = l7lb_certificate_value.public_certificate
          l7lb_certificate_key           = l7lb_certificate_key,
          l7lb_name                      = l7lb_value.display_name,
          l7lb_id                        = local.provisioned_l7_lbs[l7lb_key].id,
          l7lb_key                       = l7lb_key,
          network_configuration_category = l7lb_value.network_configuration_category
        }
      ] : [] : []
    ]) : flat_certificate.l7lb_certificate_key => flat_certificate
  } : null : null

  provisioned_l7_lbs_certificates = {
    for l7lb_certificate_key, l7lb_certificate_value in oci_load_balancer_certificate.these : l7lb_certificate_key => {
      id                             = l7lb_certificate_value.id
      l7lb_certificate_key           = l7lb_certificate_key
      load_balancer_id               = l7lb_certificate_value.load_balancer_id
      l7lb_name                      = local.one_dimension_processed_l7_lb_certificates[l7lb_certificate_key].l7lb_name
      l7lb_id                        = local.one_dimension_processed_l7_lb_certificates[l7lb_certificate_key].l7lb_id
      l7lb_key                       = local.one_dimension_processed_l7_lb_certificates[l7lb_certificate_key].l7lb_key
      certificate_name               = l7lb_certificate_value.certificate_name
      ca_certificate                 = local.one_dimension_processed_l7_lb_certificates[l7lb_certificate_key].ca_certificate
      passphrase                     = local.one_dimension_processed_l7_lb_certificates[l7lb_certificate_key].passphrase != null ? "SECRET" : null
      private_key                    = local.one_dimension_processed_l7_lb_certificates[l7lb_certificate_key].private_key
      public_certificate             = local.one_dimension_processed_l7_lb_certificates[l7lb_certificate_key].public_certificate
      state                          = l7lb_certificate_value.state
      timeouts                       = l7lb_certificate_value.timeouts
      network_configuration_category = local.one_dimension_processed_l7_lb_certificates[l7lb_certificate_key].network_configuration_category
    }
  }
}

resource "oci_load_balancer_certificate" "these" {
  for_each = local.one_dimension_processed_l7_lb_certificates != null ? local.one_dimension_processed_l7_lb_certificates : {}
  #Required
  certificate_name = each.value.certificate_name
  load_balancer_id = each.value.load_balancer_id

  #Optional
  ca_certificate     = file(each.value.ca_certificate)
  passphrase         = each.value.passphrase
  private_key        = file(each.value.private_key)
  public_certificate = file(each.value.public_certificate)

  lifecycle {
    create_before_destroy = true
  }
}