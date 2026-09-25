locals {
  instances = {
    "KEY-A" = "value-a"
    "KEY-B" = "value-b"
  }
}

resource "terraform_data" "igw_natgw_specific_route_tables" {
  for_each = local.instances
  input    = "igw_natgw_specific_route_tables:${each.key}:${each.value}"
}

resource "terraform_data" "sgw_specific_route_tables" {
  for_each = local.instances
  input    = "sgw_specific_route_tables:${each.key}:${each.value}"
}

resource "terraform_data" "lpg_specific_route_tables" {
  for_each = local.instances
  input    = "lpg_specific_route_tables:${each.key}:${each.value}"
}

resource "terraform_data" "drga_specific_route_tables" {
  for_each = local.instances
  input    = "drga_specific_route_tables:${each.key}:${each.value}"
}

resource "terraform_data" "non_gw_specific_remaining_route_tables" {
  for_each = local.instances
  input    = "non_gw_specific_remaining_route_tables:${each.key}:${each.value}"
}

resource "terraform_data" "igw_natgw_specific_default_route_tables" {
  for_each = local.instances
  input    = "igw_natgw_specific_default_route_tables:${each.key}:${each.value}"
}

resource "terraform_data" "sgw_specific_default_route_tables" {
  for_each = local.instances
  input    = "sgw_specific_default_route_tables:${each.key}:${each.value}"
}

resource "terraform_data" "lpg_specific_default_route_tables" {
  for_each = local.instances
  input    = "lpg_specific_default_route_tables:${each.key}:${each.value}"
}

resource "terraform_data" "drga_specific_default_route_tables" {
  for_each = local.instances
  input    = "drga_specific_default_route_tables:${each.key}:${each.value}"
}

resource "terraform_data" "non_gw_specific_remaining_default_route_tables" {
  for_each = local.instances
  input    = "non_gw_specific_remaining_default_route_tables:${each.key}:${each.value}"
}

resource "terraform_data" "these" {
  for_each = local.instances
  input    = "route_table_attachments:${each.key}:${each.value}"
}
