/*
locals {
  # PROCESSED INPUT
  one_dimension_processed_l7_load_balancers = var.network_configuration != null ? var.network_configuration.network_configuration_categories != null ? length(var.network_configuration.network_configuration_categories) > 0 ? {
    for flat_l7lb in flatten([
      for network_configuration_category_key, network_configuration_category_value in var.network_configuration.network_configuration_categories :
      network_configuration_category_value.l7_load_balancers != null ? length(network_configuration_category_value.l7_load_balancers) > 0 ? [
        for l7lb_key, l7lb_value in network_configuration_category_value.l7_load_balancers : {
          compartment_id                 = l7lb_value.compartment_id
          display_name                   = l7lb_value.display_name
          shape                          = l7lb_value.shape
          subnet_keys                    = l7lb_value.subnet_keys
          subnet_ids                     = l7lb_value.subnet_ids
          defined_tags                   = l7lb_value.defined_tags
          freeform_tags                  = l7lb_value.freeform_tags
          ip_mode                        = l7lb_value.ip_mode
          is_private                     = l7lb_value.is_private
          network_security_group_keys    = l7lb_value.network_security_group_keys
          network_security_group_ids     = l7lb_value.network_security_group_ids
          reserved_ips_keys               = l7lb_value.reserved_ips_keys
          reserved_ips_ids                = l7lb_value.reserved_ips_ids
          maximum_bandwidth_in_mbps      = l7lb_value.maximum_bandwidth_in_mbps
          minimum_bandwidth_in_mbps      = l7lb_value.minimum_bandwidth_in_mbps
          network_configuration_category = network_configuration_category_key
        }
      ] : [] : []
    ]) :  [flat_l7lb]
  } : null : null : null
}
*/

/*
resource "oci_load_balancer_load_balancer" "l7_load_balancers" {
  for_each = local.one_dimension_processed_l7_load_balancers
  #Required
  compartment_id = each.value.compartment_id
  display_name   = each.value.display_name
  shape          = each.value.shape
  subnet_ids     = each.value.subnet_ids

  #Optional
  defined_tags               = each.value.defined_tags
  freeform_tags              = each.value.freeform_tags
  ip_mode                    = each.value.ip_mode
  is_private                 = each.value.is_private
  network_security_group_ids = each.value.network_security_group_ids
  dynamic "reserved_ips" {
    for_each = each.value.reserved_ips
    content {
      id = reserved_ips.value
    }
  }
  dynamic "shape_details" {
    for_each = each.value.maximum_bandwidth_in_mbps != null && each.value.minimum_bandwidth_in_mbps != null && each.value.shape == "flexible" ? [{
      maximum_bandwidth_in_mbps = each.value.maximum_bandwidth_in_mbps
      minimum_bandwidth_in_mbps = each.value.minimum_bandwidth_in_mbps
    }] : []
    content {
      maximum_bandwidth_in_mbps = shape_details.value.maximum_bandwidth_in_mbps
      minimum_bandwidth_in_mbps = shape_details.value.minimum_bandwidth_in_mbps
    }
  }
}
*/
/*
output "l7_load_balancers_input" {
  description = "load_balancers_input"
  value = {
    load_balancers_input = local.one_dimension_processed_l7_load_balancers
  }
}
*/
/*
output "provisioned_l7_load_balancers" {
  description = "provisioned_l7_load_balancers"
  value = {
    load_balancers_input = oci_load_balancer_load_balancer.l7_load_balancers
  }
}
*/