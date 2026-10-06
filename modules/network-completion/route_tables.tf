locals {
  private_ip_targets = merge(
    var.external_private_ip_targets,
    var.managed_private_ip_targets,
    var.network_firewall_private_ip_targets
  )
}

module "igw_natgw_route_tables" {
  source = "./modules/route-table-partition"

  compartments_dependency        = var.compartments_dependency
  custom_route_tables            = var.igw_natgw_specific_route_tables
  default_route_tables           = var.igw_natgw_specific_default_route_tables
  default_route_table_ids_by_vcn = var.default_route_table_ids_by_vcn
  route_rule_targets             = local.private_ip_targets
}

module "sgw_route_tables" {
  source = "./modules/route-table-partition"

  compartments_dependency        = var.compartments_dependency
  custom_route_tables            = var.sgw_specific_route_tables
  default_route_tables           = var.sgw_specific_default_route_tables
  default_route_table_ids_by_vcn = var.default_route_table_ids_by_vcn
  route_rule_targets = merge(
    var.dynamic_gateway_targets,
    local.private_ip_targets
  )
}

module "lpg_route_tables" {
  source = "./modules/route-table-partition"

  compartments_dependency        = var.compartments_dependency
  custom_route_tables            = var.lpg_specific_route_tables
  default_route_tables           = var.lpg_specific_default_route_tables
  default_route_table_ids_by_vcn = var.default_route_table_ids_by_vcn
  route_rule_targets = merge(
    var.service_gateway_targets,
    local.private_ip_targets
  )
}

module "drga_route_tables" {
  source = "./modules/route-table-partition"

  compartments_dependency        = var.compartments_dependency
  custom_route_tables            = var.drga_specific_route_tables
  default_route_tables           = var.drga_specific_default_route_tables
  default_route_table_ids_by_vcn = var.default_route_table_ids_by_vcn
  route_rule_targets = merge(
    var.local_peering_gateway_targets,
    var.service_gateway_targets,
    local.private_ip_targets
  )
}

module "remaining_route_tables" {
  source = "./modules/route-table-partition"

  compartments_dependency        = var.compartments_dependency
  custom_route_tables            = var.non_gw_specific_remaining_route_tables
  default_route_tables           = var.non_gw_specific_remaining_default_route_tables
  default_route_table_ids_by_vcn = var.default_route_table_ids_by_vcn
  merge_module_tag               = true
  module_tag                     = var.module_tag
  route_rule_targets = merge(
    var.internet_gateway_targets,
    var.nat_gateway_targets,
    var.service_gateway_targets,
    var.dynamic_gateway_targets,
    var.local_peering_gateway_targets,
    local.private_ip_targets
  )
}
