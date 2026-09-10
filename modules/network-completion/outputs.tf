locals {
  provisioned_igw_natgw_specific_route_tables         = module.igw_natgw_route_tables.provisioned_custom_route_tables
  provisioned_sgw_specific_route_tables               = module.sgw_route_tables.provisioned_custom_route_tables
  provisioned_lpg_specific_route_tables               = module.lpg_route_tables.provisioned_custom_route_tables
  provisioned_drga_specific_route_tables              = module.drga_route_tables.provisioned_custom_route_tables
  provisioned_non_gw_specific_remaining_route_tables  = module.remaining_route_tables.provisioned_custom_route_tables
  provisioned_igw_natgw_specific_default_route_tables = module.igw_natgw_route_tables.provisioned_default_route_tables
  provisioned_sgw_specific_default_route_tables       = module.sgw_route_tables.provisioned_default_route_tables
  provisioned_lpg_specific_default_route_tables       = module.lpg_route_tables.provisioned_default_route_tables
  provisioned_drga_specific_default_route_tables      = module.drga_route_tables.provisioned_default_route_tables
  provisioned_non_gw_specific_remaining_default_route_tables = (
    module.remaining_route_tables.provisioned_default_route_tables
  )

  provisioned_route_tables_attachments = {
    for rta_key, rta_value in oci_core_route_table_attachment.these : rta_key => {
      id             = rta_value.id
      route_table_id = rta_value.route_table_id
      # Keep the caller's route-table key in the public output. route_table_id
      # reports the association returned by OCI after completion.
      route_table_key = var.route_table_attachments[rta_key].route_table_key
      route_table_name = (
        var.route_table_attachments[rta_key].route_table_id == var.route_table_attachments[rta_key].default_route_table_id ||
        (var.route_table_attachments[rta_key].route_table_id == null && (var.route_table_attachments[rta_key].route_table_key == null || var.route_table_attachments[rta_key].route_table_key == "default_route_table"))
        ) ? "default_route_table" : var.route_table_attachments[rta_key].route_table_key == null ? "CANNOT BE DETERMINED AS NOT CREATED BY THIS AUTOMATION" : (
        local.all_custom_route_tables[var.route_table_attachments[rta_key].route_table_key].display_name
      )
      subnet_id                      = rta_value.subnet_id
      subnet_key                     = rta_key
      subnet_name                    = var.route_table_attachments[rta_key].subnet_name
      timeouts                       = rta_value.timeouts
      rta_key                        = rta_key
      vcn_key                        = var.route_table_attachments[rta_key].vcn_key
      vcn_name                       = var.route_table_attachments[rta_key].vcn_name
      network_configuration_category = var.route_table_attachments[rta_key].network_configuration_category
    }
  }
}

output "provisioned_igw_natgw_specific_route_tables" {
  description = "Provisioned route tables that can be assigned to internet and NAT gateways."
  value       = local.provisioned_igw_natgw_specific_route_tables
}

output "provisioned_sgw_specific_route_tables" {
  description = "Provisioned route tables that can be assigned to service gateways."
  value       = local.provisioned_sgw_specific_route_tables
}

output "provisioned_lpg_specific_route_tables" {
  description = "Provisioned route tables that can be assigned to local peering gateways."
  value       = local.provisioned_lpg_specific_route_tables
}

output "provisioned_drga_specific_route_tables" {
  description = "Provisioned route tables that can be assigned to DRG attachments."
  value       = local.provisioned_drga_specific_route_tables
}

output "provisioned_non_gw_specific_remaining_route_tables" {
  description = "Provisioned route tables that can be assigned only to subnets."
  value       = local.provisioned_non_gw_specific_remaining_route_tables
}

output "provisioned_igw_natgw_specific_default_route_tables" {
  description = "Provisioned default route tables that can be assigned to internet and NAT gateways."
  value       = local.provisioned_igw_natgw_specific_default_route_tables
}

output "provisioned_sgw_specific_default_route_tables" {
  description = "Provisioned default route tables that can be assigned to service gateways."
  value       = local.provisioned_sgw_specific_default_route_tables
}

output "provisioned_lpg_specific_default_route_tables" {
  description = "Provisioned default route tables that can be assigned to local peering gateways."
  value       = local.provisioned_lpg_specific_default_route_tables
}

output "provisioned_drga_specific_default_route_tables" {
  description = "Provisioned default route tables that can be assigned to DRG attachments."
  value       = local.provisioned_drga_specific_default_route_tables
}

output "provisioned_non_gw_specific_remaining_default_route_tables" {
  description = "Provisioned default route tables that can be assigned only to subnets."
  value       = local.provisioned_non_gw_specific_remaining_default_route_tables
}

output "provisioned_route_tables_attachments" {
  description = "Provisioned subnet route-table attachments."
  value       = local.provisioned_route_tables_attachments
}
