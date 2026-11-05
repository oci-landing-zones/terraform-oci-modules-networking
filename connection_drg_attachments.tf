# ####################################################################################################### #
# Copyright (c) 2026 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# ####################################################################################################### #

resource "oci_core_drg_attachment_management" "ipsec_tunnels" {
  for_each = {
    for key, tunnel in coalesce(local.one_dimension_ipsec_tunnels_management, {}) : key => tunnel
    if tunnel.drg_attachment != null
  }

  attachment_type = "IPSEC_TUNNEL"
  compartment_id  = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
  drg_id          = each.value.drg_id
  network_id      = each.value.tunnel_id
  drg_route_table_id = each.value.drg_attachment.drg_route_table_id != null ? each.value.drg_attachment.drg_route_table_id : try(
    local.drg_route_table_targets[each.value.drg_attachment.drg_route_table_key].id, null
  )

  lifecycle {
    # The provider updates network_id in place without rediscovering the attachment.
    replace_triggered_by = [oci_core_ipsec_connection_tunnel_management.these[each.key].tunnel_id]

    precondition {
      condition = (
        each.value.drg_attachment.drg_route_table_id != null ||
        try(local.drg_route_table_targets[each.value.drg_attachment.drg_route_table_key].id != null, false)
      )
      error_message = "IPSec tunnel \"${each.key}\" references an unknown drg_route_table_key. Declare the route table in this configuration or provide it in network_dependency.drg_route_tables."
    }

    precondition {
      condition = !contains(
        [for attachment in oci_core_drg_attachment_management.these : attachment.network_id if attachment.attachment_type == "IPSEC_TUNNEL"],
        each.value.tunnel_id
      )
      error_message = "Do not also declare this IPSec tunnel in dynamic_routing_gateways.drg_attachments or inject_into_existing_drgs.drg_attachments when its drg_attachment is configured."
    }
  }
}

resource "oci_core_drg_attachment_management" "virtual_circuits" {
  for_each = {
    for key, circuit in coalesce(local.one_dimension_fast_connect_virtual_circuits, {}) : key => circuit
    if circuit.drg_attachment != null && circuit.provision_fc_virtual_circuit && upper(circuit.type) == "PRIVATE"
  }

  attachment_type = "VIRTUAL_CIRCUIT"
  compartment_id  = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
  drg_id          = each.value.gateway_id
  network_id      = oci_core_virtual_circuit.these[each.key].id
  drg_route_table_id = each.value.drg_attachment.drg_route_table_id != null ? each.value.drg_attachment.drg_route_table_id : try(
    local.drg_route_table_targets[each.value.drg_attachment.drg_route_table_key].id, null
  )

  lifecycle {
    replace_triggered_by = [oci_core_virtual_circuit.these[each.key].id]

    precondition {
      condition = (
        each.value.drg_attachment.drg_route_table_id != null ||
        try(local.drg_route_table_targets[each.value.drg_attachment.drg_route_table_key].id != null, false)
      )
      error_message = "Virtual circuit \"${each.key}\" references an unknown drg_route_table_key. Declare the route table in this configuration or provide it in network_dependency.drg_route_tables."
    }

    precondition {
      condition = !contains(
        [for attachment in oci_core_drg_attachment_management.these : attachment.network_id if attachment.attachment_type == "VIRTUAL_CIRCUIT"],
        oci_core_virtual_circuit.these[each.key].id
      )
      error_message = "Do not also declare this virtual circuit in dynamic_routing_gateways.drg_attachments or inject_into_existing_drgs.drg_attachments when its drg_attachment is configured."
    }
  }
}
