
locals {

  # PROCESSED INPUT
  one_dimension_processed_l7_load_balancers = local.one_dimension_processed_non_vcn_specific_gateways != null ? {
    for flat_l7lb in flatten([
      for vcn_non_specific_gw_key, vcn_non_specific_gw_value in local.one_dimension_processed_non_vcn_specific_gateways :
      vcn_non_specific_gw_value.l7_load_balancers != null ? length(vcn_non_specific_gw_value.l7_load_balancers) > 0 ? [
        for l7lb_key, l7lb_value in vcn_non_specific_gw_value.l7_load_balancers : {
          compartment_id          = l7lb_value.compartment_id != null ? l7lb_value.compartment_id : vcn_non_specific_gw_value.category_compartment_id != null ? vcn_non_specific_gw_value.category_compartment_id : vcn_non_specific_gw_value.default_compartment_id != null ? vcn_non_specific_gw_value.default_compartment_id : null
          category_compartment_id = vcn_non_specific_gw_value.category_compartment_id
          default_compartment_id  = vcn_non_specific_gw_value.default_compartment_id
          display_name            = l7lb_value.display_name
          shape                   = l7lb_value.shape
          subnet_keys             = l7lb_value.subnet_keys
          subnet_ids = concat(
            l7lb_value.subnet_ids != null ? l7lb_value.subnet_ids : [],
            l7lb_value.subnet_keys != null ? length(l7lb_value.subnet_keys) > 0 ? [
              for subnet_key in l7lb_value.subnet_keys : local.provisioned_subnets[subnet_key].id
            ] : [] : []
          )
          defined_tags                = merge(l7lb_value.defined_tags, vcn_non_specific_gw_value.category_defined_tags, vcn_non_specific_gw_value.default_defined_tags)
          category_defined_tags       = vcn_non_specific_gw_value.category_defined_tags
          default_defined_tags        = vcn_non_specific_gw_value.default_defined_tags
          freeform_tags               = merge(l7lb_value.freeform_tags, vcn_non_specific_gw_value.category_freeform_tags, vcn_non_specific_gw_value.default_freeform_tags)
          category_freeform_tags      = vcn_non_specific_gw_value.category_freeform_tags
          default_freeform_tags       = vcn_non_specific_gw_value.default_freeform_tags
          ip_mode                     = l7lb_value.ip_mode
          is_private                  = l7lb_value.is_private
          network_security_group_keys = l7lb_value.network_security_group_keys
          network_security_group_ids = concat(
            l7lb_value.network_security_group_ids != null ? l7lb_value.network_security_group_ids : [],
            l7lb_value.network_security_group_keys != null ? length(l7lb_value.network_security_group_keys) > 0 ? [
              for nsg_key in l7lb_value.network_security_group_keys : local.provisioned_network_security_groups[nsg_key].id
            ] : [] : []
          )
          reserved_ips_ids = concat(
            l7lb_value.reserved_ips_ids != null ? length(l7lb_value.reserved_ips_ids) > 0 ? l7lb_value.reserved_ips_ids : [] : [],
            l7lb_value.reserved_ips_keys != null ? length(l7lb_value.reserved_ips_keys) > 0 ? [
              for reserver_ip_key in l7lb_value.reserved_ips_keys : local.provisioned_oci_core_public_ips[reserver_ip_key].id
            ] : [] : []
          )
          reserved_ips_keys              = l7lb_value.reserved_ips_keys
          maximum_bandwidth_in_mbps      = l7lb_value.shape_details.maximum_bandwidth_in_mbps
          minimum_bandwidth_in_mbps      = l7lb_value.shape_details.minimum_bandwidth_in_mbps
          network_configuration_category = vcn_non_specific_gw_value.network_configuration_category
          l7lb_key                       = l7lb_key
          backend_sets                   = l7lb_value.backend_sets
          cipher_suites                  = l7lb_value.cipher_suites
        }
      ] : [] : []
    ]) : flat_l7lb.l7lb_key => flat_l7lb
  } : null

  provisioned_l7_lbs = {
    for l7lb_key, l7lb_value in oci_load_balancer_load_balancer.these : l7lb_key => {
      compartment_id             = l7lb_value.compartment_id
      defined_tags               = l7lb_value.defined_tags
      display_name               = l7lb_value.display_name
      freeform_tags              = l7lb_value.freeform_tags
      ip_mode                    = l7lb_value.ip_mode
      is_private                 = l7lb_value.is_private
      network_security_group_ids = l7lb_value.network_security_group_ids
      id                         = l7lb_value.id

      network_security_groups = {
        for nsg in flatten(l7lb_value.network_security_group_ids != null ? [
          for nsg_id in l7lb_value.network_security_group_ids : contains([
            for nsg_key, nsg_value in local.provisioned_network_security_groups : nsg_value.id
            ],

            nsg_id) ? [
            for nsg_key, nsg_value in local.provisioned_network_security_groups : {
              display_name = nsg_value.display_name
              nsg_key      = nsg_key
              nsg_id       = nsg_id
            } if nsg_value.id == nsg_id] : [
            {
              display_name = "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
              nsg_key      = "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
              nsg_id       = nsg_id
            }
          ]
          ] : []) : nsg.nsg_id => {
          display_name = nsg.display_name
          nsg_key      = nsg.nsg_key
          nsg_id       = nsg.nsg_id
        }
      }

      reserved_ips = l7lb_value.reserved_ips
      reserved_public_ips = {
        for rpip in flatten(l7lb_value.reserved_ips != null ? [
          for rpip_id in l7lb_value.reserved_ips : contains([
            for rpip_id_key, rpip_id_value in local.provisioned_oci_core_public_ips : rpip_id_value.id
            ],

            rpip_id) ? [
            for rpip_id_key, rpip_id_value in local.provisioned_oci_core_public_ips : {
              display_name = rpip_id_value.display_name
              rpip_id_key  = rpip_id_key
              rpip_id      = rpip_id
            } if rpip_id_value.id == rpip_id] : [
            {
              display_name = "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
              rpip_id_key  = "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
              rpip_id      = rpip_id
            }
          ]
          ] : []) : rpip.rpip_id => {
          display_name = rpip.display_name
          rpip_id_key  = rpip.rpip_id_key
          rpip_id      = rpip.rpip_id
        }
      }
      shape         = l7lb_value.shape
      shape_details = l7lb_value.shape_details
      subnet_ids    = l7lb_value.subnet_ids
      subnets = {
        for subnet in flatten(l7lb_value.subnet_ids != null ? [
          for subnet_id in l7lb_value.subnet_ids : contains([
            for subnet_key, subnet_value in local.provisioned_subnets : subnet_value.id
            ],
            subnet_id) ? [
            for subnet_key, subnet_value in local.provisioned_subnets : {
              display_name = subnet_value.display_name
              subnet_key   = subnet_key
              subnet_id    = subnet_id
              vcn_key      = subnet_value.vcn_key
              vcn_name     = subnet_value.vcn_name
              vcn_id       = subnet_value.vcn_id
            } if subnet_value.id == subnet_id] : [
            {
              display_name = "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
              subnet_key   = "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
              subnet_id    = subnet_id
              vcn_key      = "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
              vcn_name     = "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
              vcn_id       = "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
            }
          ]
          ] : []) : subnet.subnet_id => {
          display_name = subnet.display_name
          subnet_key   = subnet.subnet_key
          subnet_id    = subnet.subnet_id
          vcn_key      = subnet.vcn_key
          vcn_name     = subnet.vcn_name
          vcn_id       = subnet.vcn_id
        }
      }
      network_configuration_category = local.one_dimension_processed_l7_load_balancers[l7lb_key].network_configuration_category
    }
  }
}

resource "oci_load_balancer_load_balancer" "these" {
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
    for_each = each.value.reserved_ips_ids
    content {
      id = reserved_ips.value
    }
  }
  shape_details {
    maximum_bandwidth_in_mbps = each.value.maximum_bandwidth_in_mbps
    minimum_bandwidth_in_mbps = each.value.minimum_bandwidth_in_mbps
  }
}