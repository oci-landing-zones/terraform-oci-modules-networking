locals {
  provisioned_custom_route_tables = {
    for route_table_key, route_value in oci_core_route_table.custom : route_table_key => {
      compartment_id                 = route_value.compartment_id
      defined_tags                   = route_value.defined_tags
      display_name                   = route_value.display_name
      freeform_tags                  = route_value.freeform_tags
      id                             = route_value.id
      route_rules                    = route_value.route_rules
      state                          = route_value.state
      time_created                   = route_value.time_created
      timeouts                       = route_value.timeouts
      vcn_id                         = route_value.vcn_id
      vcn_key                        = var.custom_route_tables[route_table_key].vcn_key
      vcn_name                       = var.custom_route_tables[route_table_key].vcn_name
      network_configuration_category = var.custom_route_tables[route_table_key].network_configuration_category
      route_table_key                = route_table_key
    }
  }

  provisioned_default_route_tables = {
    for route_table_key, route_value in oci_core_default_route_table.default : route_table_key => {
      compartment_id                 = route_value.compartment_id
      defined_tags                   = route_value.defined_tags
      display_name                   = route_value.display_name
      freeform_tags                  = route_value.freeform_tags
      id                             = route_value.id
      route_rules                    = route_value.route_rules
      state                          = route_value.state
      time_created                   = route_value.time_created
      timeouts                       = route_value.timeouts
      vcn_id                         = var.default_route_tables[route_table_key].vcn_id
      vcn_key                        = var.default_route_tables[route_table_key].vcn_key
      vcn_name                       = var.default_route_tables[route_table_key].vcn_name
      network_configuration_category = var.default_route_tables[route_table_key].network_configuration_category
      route_table_key                = route_table_key
    }
  }
}

output "provisioned_custom_route_tables" {
  description = "Provisioned custom route tables."
  value       = local.provisioned_custom_route_tables
}

output "provisioned_default_route_tables" {
  description = "Provisioned default route tables."
  value       = local.provisioned_default_route_tables
}
