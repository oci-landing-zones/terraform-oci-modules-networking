locals {
  instances = {
    "KEY-A" = "value-a"
    "KEY-B" = "value-b"
  }
}

module "igw_natgw_route_tables" {
  source = "./modules/route-table-partition"

  custom_label  = "igw_natgw_specific_route_tables"
  default_label = "igw_natgw_specific_default_route_tables"
  instances     = local.instances
}

module "sgw_route_tables" {
  source = "./modules/route-table-partition"

  custom_label  = "sgw_specific_route_tables"
  default_label = "sgw_specific_default_route_tables"
  instances     = local.instances
}

module "lpg_route_tables" {
  source = "./modules/route-table-partition"

  custom_label  = "lpg_specific_route_tables"
  default_label = "lpg_specific_default_route_tables"
  instances     = local.instances
}

module "drga_route_tables" {
  source = "./modules/route-table-partition"

  custom_label  = "drga_specific_route_tables"
  default_label = "drga_specific_default_route_tables"
  instances     = local.instances
}

module "remaining_route_tables" {
  source = "./modules/route-table-partition"

  custom_label  = "non_gw_specific_remaining_route_tables"
  default_label = "non_gw_specific_remaining_default_route_tables"
  instances     = local.instances
}

resource "terraform_data" "these" {
  for_each = local.instances
  input    = "route_table_attachments:${each.key}:${each.value}"
}
