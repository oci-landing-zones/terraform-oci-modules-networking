# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

data "oci_core_ipsec_connection_tunnels" "these" {
  for_each = local.provisioned_ipsecs
  #Required
  ipsec_id = each.value.id
}

locals {
  one_dimension_ipsec_tunnels_management = local.one_dimension_ipsecs != null ? {
    for flat_ipsec_tunnel_management in flatten([
      for ipsec_key, ipsec_value in local.one_dimension_ipsecs : ipsec_value.tunnels_management != null ? length(ipsec_value.tunnels_management) > 0 ? [
        for ipsec_tunnel_management_key, ipsec_tunnel_management_value in ipsec_value.tunnels_management : {
          display_name                   = join("_", [ipsec_value.display_name, ipsec_tunnel_management_key])
          ipsec_id                       = local.provisioned_ipsecs[ipsec_key].id
          tunnel_id                      = data.oci_core_ipsec_connection_tunnels.these[ipsec_key].ip_sec_connection_tunnels[tonumber(substr(ipsec_tunnel_management_key, length(ipsec_tunnel_management_key) - 1, length(ipsec_tunnel_management_key) - 2)) - 1].id
          routing                        = ipsec_tunnel_management_value.routing
          bgp_session_info               = ipsec_tunnel_management_value.bgp_session_info
          encryption_domain_config       = ipsec_tunnel_management_value.encryption_domain_config
          shared_secret                  = ipsec_tunnel_management_value.shared_secret
          ike_version                    = ipsec_tunnel_management_value.ike_version
          ipsec_tunnel_management_key    = join("-", [replace(ipsec_key, "-KEY", ""), replace(upper(ipsec_tunnel_management_key), "_", "-"), "KEY"])
          ipsec_key                      = ipsec_key
          ipsec_display_name             = local.provisioned_ipsecs[ipsec_key].display_name
          network_configuration_category = ipsec_value.network_configuration_category
          cpe_id                         = ipsec_value.cpe_id
          cpe_key                        = ipsec_value.cpe_key
          cpe_name                       = ipsec_value.cpe_name
          drg_id                         = ipsec_value.drg_id
          drg_key                        = ipsec_value.drg_key
          drg_name                       = ipsec_value.drg_name
        } if ipsec_tunnel_management_value != null
      ] : [] : []
    ]) : flat_ipsec_tunnel_management.ipsec_tunnel_management_key => flat_ipsec_tunnel_management
  } : null

  provisioned_ipsec_connection_tunnels_management = {
    for ipsec_tunnel_management_key, ipsec_tunnel_management_value in oci_core_ipsec_connection_tunnel_management.these : ipsec_tunnel_management_key => {
      bgp_session_info               = ipsec_tunnel_management_value.bgp_session_info
      compartment_id                 = ipsec_tunnel_management_value.compartment_id
      cpe_ip                         = ipsec_tunnel_management_value.cpe_ip
      cpe_id                         = local.one_dimension_ipsec_tunnels_management[ipsec_tunnel_management_key].cpe_id
      cpe_key                        = local.one_dimension_ipsec_tunnels_management[ipsec_tunnel_management_key].cpe_key
      cpe_name                       = local.one_dimension_ipsec_tunnels_management[ipsec_tunnel_management_key].cpe_name
      drg_id                         = local.one_dimension_ipsec_tunnels_management[ipsec_tunnel_management_key].drg_id
      drg_key                        = local.one_dimension_ipsec_tunnels_management[ipsec_tunnel_management_key].drg_key
      drg_name                       = local.one_dimension_ipsec_tunnels_management[ipsec_tunnel_management_key].drg_name
      display_name                   = ipsec_tunnel_management_value.display_name
      dpd_config                     = ipsec_tunnel_management_value.dpd_config
      dpd_mode                       = ipsec_tunnel_management_value.dpd_mode
      dpd_timeout_in_sec             = ipsec_tunnel_management_value.dpd_timeout_in_sec
      encryption_domain_config       = ipsec_tunnel_management_value.encryption_domain_config
      id                             = ipsec_tunnel_management_value.id
      ike_version                    = ipsec_tunnel_management_value.ike_version
      ipsec_id                       = ipsec_tunnel_management_value.ipsec_id
      ipsec_key                      = local.one_dimension_ipsec_tunnels_management[ipsec_tunnel_management_key].ipsec_key
      nat_translation_enabled        = ipsec_tunnel_management_value.nat_translation_enabled
      oracle_can_initiate            = ipsec_tunnel_management_value.oracle_can_initiate
      phase_one_details              = ipsec_tunnel_management_value.phase_one_details
      phase_two_details              = ipsec_tunnel_management_value.phase_two_details
      routing                        = ipsec_tunnel_management_value.routing
      shared_secret                  = ipsec_tunnel_management_value.shared_secret
      state                          = ipsec_tunnel_management_value.state
      status                         = ipsec_tunnel_management_value.status
      time_created                   = ipsec_tunnel_management_value.time_created
      time_status_updated            = ipsec_tunnel_management_value.time_status_updated
      timeouts                       = ipsec_tunnel_management_value.timeouts
      tunnel_id                      = ipsec_tunnel_management_value.tunnel_id
      vpn_ip                         = ipsec_tunnel_management_value.vpn_ip
      network_configuration_category = local.one_dimension_ipsec_tunnels_management[ipsec_tunnel_management_key].network_configuration_category
    }
  }
}

resource "oci_core_ipsec_connection_tunnel_management" "these" {
  for_each = local.one_dimension_ipsec_tunnels_management
  #Required
  ipsec_id  = each.value.ipsec_id
  tunnel_id = each.value.tunnel_id
  routing   = each.value.routing



  #Optional

  dynamic "bgp_session_info" {
    for_each = each.value.bgp_session_info != null ? [1] : []

    content {
      customer_bgp_asn      = each.value.bgp_session_info.customer_bgp_asn
      customer_interface_ip = each.value.bgp_session_info.customer_interface_ip
      oracle_interface_ip   = each.value.bgp_session_info.oracle_interface_ip
    }
  }

  display_name = each.value.display_name

  dynamic "encryption_domain_config" {
    for_each = each.value.encryption_domain_config != null ? [1] : []

    content {
      cpe_traffic_selector    = each.value.encryption_domain_config.cpe_traffic_selector
      oracle_traffic_selector = each.value.encryption_domain_configoracle_traffic_selector
    }
  }

  shared_secret = each.value.shared_secret
  ike_version   = each.value.ike_version
}