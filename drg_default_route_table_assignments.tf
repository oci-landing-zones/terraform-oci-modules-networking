# ####################################################################################################### #
# Copyright (c) 2026 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# ####################################################################################################### #

locals {
  default_drg_route_table_selectors = {
    for drg_key, drg_value in coalesce(local.one_dimension_dynamic_routing_gateways, {}) : drg_key => {
      for attachment_type, selector in {
        IPSEC_TUNNEL    = try(drg_value.default_drg_route_tables.ipsec_tunnel, null)
        VIRTUAL_CIRCUIT = try(drg_value.default_drg_route_tables.virtual_circuit, null)
      } : attachment_type => selector
      if selector != null && selector.drg_route_table_id != null
    }
  }

  default_drg_route_table_assignments = {
    for assignment in concat(
      flatten([
        for drg_key, selectors in local.default_drg_route_table_selectors : flatten([
          for attachment_type, selector in selectors : attachment_type == "IPSEC_TUNNEL" ? [
            for ipsec_key, ipsec_value in coalesce(local.one_dimension_ipsecs, {}) : [
              for tunnel_index in range(2) : {
                assignment_key     = format("%s.%s.TUNNEL-%d", attachment_type, ipsec_key, tunnel_index + 1)
                attachment_type    = attachment_type
                compartment_id     = ipsec_value.compartment_id
                drg_id             = oci_core_drg.these[drg_key].id
                drg_route_table_id = selector.drg_route_table_id
                network_id         = data.oci_core_ipsec_connection_tunnels.these[ipsec_key].ip_sec_connection_tunnels[tunnel_index].id
              }
            ] if ipsec_value.drg_key == drg_key
          ] : []
        ])
      ]),
      flatten([
        for fast_connect_key, fast_connect_value in coalesce(local.one_dimension_fast_connect_virtual_circuits, {}) : [
          for attachment_type, selector in try(local.default_drg_route_table_selectors[fast_connect_value.gateway_key], {}) : {
            assignment_key     = format("%s.%s", attachment_type, fast_connect_key)
            attachment_type    = attachment_type
            compartment_id     = fast_connect_value.compartment_id
            drg_id             = fast_connect_value.gateway_id
            drg_route_table_id = selector.drg_route_table_id
            network_id         = oci_core_virtual_circuit.these[fast_connect_key].id
          } if attachment_type == "VIRTUAL_CIRCUIT" && fast_connect_value.provision_fc_virtual_circuit && upper(fast_connect_value.type) == "PRIVATE"
        ]
      ])
    ) : assignment.assignment_key => assignment
  }
}

resource "oci_core_drg_attachment_management" "default_route_table_assignments" {
  for_each = local.default_drg_route_table_assignments

  attachment_type = each.value.attachment_type
  compartment_id  = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
  drg_id          = each.value.drg_id
  network_id      = each.value.network_id

  drg_route_table_id = length(regexall("^ocid1.*$", each.value.drg_route_table_id)) > 0 ? each.value.drg_route_table_id : oci_core_drg_route_table.these[each.value.drg_route_table_id].id

  lifecycle {
    precondition {
      condition = !contains(
        [
          for attachment in oci_core_drg_attachment_management.these : format("%s.%s", attachment.attachment_type, attachment.network_id)
          if contains(["IPSEC_TUNNEL", "VIRTUAL_CIRCUIT"], attachment.attachment_type)
        ],
        format("%s.%s", each.value.attachment_type, each.value.network_id)
      )
      error_message = "Do not configure the same IPsec tunnel or virtual circuit in dynamic_routing_gateways.drg_attachments and default_drg_route_tables. The default route-table assignment already manages that generated DRG attachment."
    }
  }
}
