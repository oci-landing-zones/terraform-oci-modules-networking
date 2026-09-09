locals {
  all_custom_route_tables = merge(
    module.igw_natgw_route_tables.provisioned_custom_route_tables,
    module.sgw_route_tables.provisioned_custom_route_tables,
    module.lpg_route_tables.provisioned_custom_route_tables,
    module.drga_route_tables.provisioned_custom_route_tables,
    module.remaining_route_tables.provisioned_custom_route_tables
  )
}

resource "oci_core_route_table_attachment" "these" {
  for_each = var.route_table_attachments

  subnet_id = each.value.subnet_id
  route_table_id = each.value.route_table_id != null ? each.value.route_table_id : (
    each.value.route_table_key == null || each.value.route_table_key == "default_route_table"
    ? each.value.default_route_table_id
    : local.all_custom_route_tables[each.value.route_table_key].id
  )
}
