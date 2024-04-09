# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #


data "oci_core_fast_connect_provider_services" "fast_connect_provider_services" {
  for_each = local.one_dimension_fast_connect_virtual_circuits_aux_01
  #Required
  compartment_id = each.value.compartment_id
}

locals {
  one_dimension_fast_connect_virtual_circuits_aux_01 = local.one_dimension_processed_non_vcn_specific_gateways != null ? {
    for flat_fcvc in flatten([
      for vcn_non_specific_gw_key, vcn_non_specific_gw_value in local.one_dimension_processed_non_vcn_specific_gateways :
      vcn_non_specific_gw_value.fast_connect_virtual_circuits != null ? length(vcn_non_specific_gw_value.fast_connect_virtual_circuits) > 0 ? [
        for fcvc_key, fcvc_value in vcn_non_specific_gw_value.fast_connect_virtual_circuits : {
          provision_fc_virtual_circuit                = fcvc_value.provision_fc_virtual_circuit
          show_available_fc_virtual_circuit_providers = fcvc_value.show_available_fc_virtual_circuit_providers
          compartment_id                              = fcvc_value.compartment_id != null ? fcvc_value.compartment_id : vcn_non_specific_gw_value.category_compartment_id != null ? vcn_non_specific_gw_value.category_compartment_id : vcn_non_specific_gw_value.default_compartment_id != null ? vcn_non_specific_gw_value.default_compartment_id : null
          category_compartment_id                     = vcn_non_specific_gw_value.category_compartment_id
          default_compartment_id                      = vcn_non_specific_gw_value.default_compartment_id
          type                                        = fcvc_value.type
          defined_tags                                = merge(fcvc_value.defined_tags, vcn_non_specific_gw_value.category_defined_tags, vcn_non_specific_gw_value.default_defined_tags)
          category_defined_tags                       = vcn_non_specific_gw_value.category_defined_tags
          default_defined_tags                        = vcn_non_specific_gw_value.default_defined_tags
          freeform_tags                               = merge(fcvc_value.freeform_tags, vcn_non_specific_gw_value.category_freeform_tags, vcn_non_specific_gw_value.default_freeform_tags)
          category_freeform_tags                      = vcn_non_specific_gw_value.category_freeform_tags
          default_freeform_tags                       = vcn_non_specific_gw_value.default_freeform_tags
          display_name                                = fcvc_value.display_name
          network_configuration_category              = vcn_non_specific_gw_value.network_configuration_category
          fcvc_key                                    = fcvc_key
          bandwidth_shape_name                        = fcvc_value.bandwidth_shape_name
          bgp_admin_state                             = fcvc_value.bgp_admin_state
          cross_connect_mappings = fcvc_value.cross_connect_mappings != null ? length(fcvc_value.cross_connect_mappings) > 0 ? {
            for ccm_key, ccm_value in fcvc_value.cross_connect_mappings : ccm_key => {
              bgp_md5auth_key                         = ccm_value.bgp_md5auth_key
              cross_connect_or_cross_connect_group_id = ccm_value.cross_connect_or_cross_connect_group_id
              customer_bgp_peering_ip                 = ccm_value.customer_bgp_peering_ip
              customer_bgp_peering_ipv6               = ccm_value.customer_bgp_peering_ipv6
              oracle_bgp_peering_ip                   = ccm_value.oracle_bgp_peering_ip
              oracle_bgp_peering_ipv6                 = ccm_value.oracle_bgp_peering_ipv6
              vlan                                    = ccm_value.vlan
            }
          } : null : null
          customer_asn              = fcvc_value.customer_asn
          ip_mtu                    = fcvc_value.ip_mtu
          is_bfd_enabled            = fcvc_value.is_bfd_enabled
          gateway_id                = fcvc_value.gateway_id != null ? fcvc_value.gateway_id : fcvc_value.gateway_key != null ? local.provisioned_dynamic_gateways[fcvc_value.gateway_key].id : null
          gateway_key               = fcvc_value.gateway_key
          provider_service_id       = fcvc_value.provider_service_id
          provider_service_key      = fcvc_value.provider_service_key
          provider_service_key_name = fcvc_value.provider_service_key_name
          public_prefixes           = fcvc_value.public_prefixes
          region                    = fcvc_value.region
          routing_policy            = fcvc_value.routing_policy
        }
      ] : [] : []
    ]) : flat_fcvc.fcvc_key => flat_fcvc
  } : null

  one_dimension_fast_connect_virtual_circuits = local.one_dimension_fast_connect_virtual_circuits_aux_01 != null ? length(local.one_dimension_fast_connect_virtual_circuits_aux_01) > 0 ? {
    for fcvc_key, fcvc_value in local.one_dimension_fast_connect_virtual_circuits_aux_01 : fcvc_key => {
      provision_fc_virtual_circuit                = fcvc_value.provision_fc_virtual_circuit
      show_available_fc_virtual_circuit_providers = fcvc_value.show_available_fc_virtual_circuit_providers
      compartment_id                              = fcvc_value.compartment_id
      category_compartment_id                     = fcvc_value.default_compartment_id
      default_compartment_id                      = fcvc_value.default_compartment_id
      type                                        = fcvc_value.type
      defined_tags                                = fcvc_value.defined_tags
      category_defined_tags                       = fcvc_value.category_defined_tags
      default_defined_tags                        = fcvc_value.default_defined_tags
      freeform_tags                               = fcvc_value.freeform_tags
      category_freeform_tags                      = fcvc_value.category_freeform_tags
      default_freeform_tags                       = fcvc_value.default_freeform_tags
      display_name                                = fcvc_value.display_name
      network_configuration_category              = fcvc_value.network_configuration_category
      fcvc_key                                    = fcvc_key
      bandwidth_shape_name                        = fcvc_value.bandwidth_shape_name
      bgp_admin_state                             = fcvc_value.bgp_admin_state
      cross_connect_mappings                      = fcvc_value.cross_connect_mappings
      customer_asn                                = fcvc_value.customer_asn
      ip_mtu                                      = fcvc_value.ip_mtu
      is_bfd_enabled                              = fcvc_value.is_bfd_enabled
      gateway_id                                  = fcvc_value.gateway_id
      gateway_key                                 = fcvc_value.gateway_key
      available_provider_service_ids = [
        for fc_provider_service in data.oci_core_fast_connect_provider_services.fast_connect_provider_services[fcvc_key].fast_connect_provider_services : {
          bandwith_shape_management       = fc_provider_service.bandwith_shape_management
          customer_asn_management         = fc_provider_service.customer_asn_management
          description                     = fc_provider_service.description
          id                              = fc_provider_service.id
          private_peering_bgp_management  = fc_provider_service.private_peering_bgp_management
          provider_name                   = fc_provider_service.provider_name
          provider_service_key_management = fc_provider_service.provider_service_key_management
          provider_service_name           = fc_provider_service.provider_service_name
          public_peering_bgp_management   = fc_provider_service.public_peering_bgp_management
          required_total_cross_connects   = fc_provider_service.required_total_cross_connects
          supported_virtual_circuit_types = fc_provider_service.supported_virtual_circuit_types
          type                            = fc_provider_service.type
          fcvc_key                        = fcvc_key
          fcvc_display_name               = fcvc_value.display_name
          fc_provider_service_key         = replace(replace(upper(join("-", [fcvc_value.display_name, fc_provider_service.provider_name, fc_provider_service.provider_service_name, "KEY"])), "_", "-"), " ", "-")
        }
      ]
      # provider_service_id       = fcvc_value.provider_service_id != null ? fcvc_value.provider_service_id : fcvc_value.provider_service_key != null ? data.oci_core_fast_connect_provider_services.fast_connect_provider_services[fcvc_value.provider_service_key].id : null
      provider_service_id       = fcvc_value.provider_service_id
      provider_service_key      = fcvc_value.provider_service_key
      provider_service_key_name = fcvc_value.provider_service_key_name
      public_prefixes           = fcvc_value.public_prefixes
      region                    = fcvc_value.region
      routing_policy            = fcvc_value.routing_policy
    }
  } : null : null

  one_dimmension_fast_connect_provider_services = local.one_dimension_fast_connect_virtual_circuits != null ? length(local.one_dimension_fast_connect_virtual_circuits) > 0 ? {
    for flat_apsi in flatten([
      for fcvc_key, fcvc_value in local.one_dimension_fast_connect_virtual_circuits : fcvc_value.available_provider_service_ids
    ]) : flat_apsi.fc_provider_service_key => flat_apsi
  } : null : null

  provisioned_fast_connect_virtual_circuits = {
    for fcvc_key, fcvc_value in oci_core_virtual_circuit.these : fcvc_key => {
      bandwidth_shape_name   = fcvc_value.bandwidth_shape_name
      bgp_admin_state        = fcvc_value.bgp_admin_state
      bgp_ipv6session_state  = fcvc_value.bgp_ipv6session_state
      bgp_management         = fcvc_value.bgp_management
      bgp_session_state      = fcvc_value.bgp_session_state
      compartment_id         = fcvc_value.compartment_id
      cross_connect_mappings = fcvc_value.cross_connect_mappings
      customer_asn           = fcvc_value.customer_asn
      defined_tags           = fcvc_value.defined_tags
      display_name           = fcvc_value.display_name
      freeform_tags          = fcvc_value.freeform_tags
      gateway_id             = fcvc_value.gateway_id
      drg_key                = local.one_dimension_fast_connect_virtual_circuits[fcvc_key].gateway_key != null ? local.one_dimension_fast_connect_virtual_circuits[fcvc_key].gateway_key : "Not known as not created by this automation"
      drg_name               = local.one_dimension_fast_connect_virtual_circuits[fcvc_key].gateway_key != null ? local.provisioned_dynamic_gateways[local.one_dimension_fast_connect_virtual_circuits[fcvc_key].gateway_key].display_name : "Not known as not created by this automation"
      id                     = fcvc_value.id
      ip_mtu                 = fcvc_value.ip_mtu
      is_bfd_enabled         = fcvc_value.is_bfd_enabled
      oracle_bgp_asn         = fcvc_value.oracle_bgp_asn
      provider_service_id    = fcvc_value.provider_service_id
      provider_service_details = {
        for k, v in local.one_dimmension_fast_connect_provider_services : k => v if v.id == fcvc_value.provider_service_id
      }
      provider_service_key_name      = fcvc_value.provider_service_key_name
      provider_state                 = fcvc_value.provider_state
      public_prefixes                = fcvc_value.public_prefixes
      reference_comment              = fcvc_value.reference_comment
      region                         = fcvc_value.region
      routing_policy                 = fcvc_value.routing_policy
      service_type                   = fcvc_value.service_type
      state                          = fcvc_value.state
      time_created                   = fcvc_value.time_created
      timeouts                       = fcvc_value.timeouts
      type                           = fcvc_value.type
      network_configuration_category = local.one_dimension_fast_connect_virtual_circuits[fcvc_key].network_configuration_category
      fcvc_key                       = fcvc_key
    }
  }
}


resource "oci_core_virtual_circuit" "these" {
  for_each = local.one_dimension_fast_connect_virtual_circuits != null ? length(local.one_dimension_fast_connect_virtual_circuits) > 0 ? {
    for k, v in local.one_dimension_fast_connect_virtual_circuits :
    k => v if v.provision_fc_virtual_circuit == true
  } : {} : {}
  #Required
  compartment_id = each.value.compartment_id
  type           = each.value.type

  #Optional
  bandwidth_shape_name = each.value.bandwidth_shape_name
  bgp_admin_state      = each.value.bgp_admin_state

  dynamic "cross_connect_mappings" {
    for_each = each.value.cross_connect_mappings != null ? length(each.value.cross_connect_mappings) > 0 ? each.value.cross_connect_mappings : {} : {}
    iterator = ccm
    content {
      bgp_md5auth_key                         = ccm.value.bgp_md5auth_key
      cross_connect_or_cross_connect_group_id = ccm.value.cross_connect_or_cross_connect_group_id
      customer_bgp_peering_ip                 = ccm.value.customer_bgp_peering_ip
      customer_bgp_peering_ipv6               = ccm.value.customer_bgp_peering_ipv6
      oracle_bgp_peering_ip                   = ccm.value.oracle_bgp_peering_ip
      oracle_bgp_peering_ipv6                 = ccm.value.oracle_bgp_peering_ipv6
      vlan                                    = ccm.value.vlan
    }
  }
  customer_asn              = each.value.customer_asn
  defined_tags              = each.value.defined_tags
  display_name              = each.value.display_name
  freeform_tags             = merge(local.cislz_module_tag, each.value.freeform_tags)
  ip_mtu                    = each.value.ip_mtu
  is_bfd_enabled            = each.value.is_bfd_enabled
  gateway_id                = each.value.gateway_id
  provider_service_id       = each.value.provider_service_id != null ? each.value.provider_service_id : each.value.provider_service_key != null ? local.one_dimmension_fast_connect_provider_services[each.value.provider_service_key].id : null
  provider_service_key_name = each.value.provider_service_key_name

  dynamic "public_prefixes" {
    for_each = each.value.public_prefixes != null ? length(each.value.public_prefixes) > 0 ? each.value.public_prefixes : [] : []
    iterator = pp
    content {
      cidr_block = pp.cidr_block
    }
  }

  region         = each.value.region
  routing_policy = each.value.routing_policy
}

