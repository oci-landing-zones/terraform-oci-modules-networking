locals {
  default_route_table_ids_by_vcn = merge(
    { for vcn_key, vcn_value in oci_core_vcn.these : vcn_key => vcn_value.default_route_table_id },
    { for vcn_key, vcn_value in local.one_dimension_processed_existing_vcns : vcn_key => vcn_value.default_route_table_id }
  )
}

module "network_completion" {
  source = "./modules/network-completion"

  compartments_dependency = coalesce(var.compartments_dependency, {})
  module_tag              = local.cislz_module_tag

  igw_natgw_specific_route_tables         = local.igw_natgw_attachable_specific_route_tables != null ? local.igw_natgw_attachable_specific_route_tables : {}
  sgw_specific_route_tables               = local.sgw_attachable_specific_route_tables != null ? local.sgw_attachable_specific_route_tables : {}
  lpg_specific_route_tables               = local.lpg_attachable_specific_route_tables != null ? local.lpg_attachable_specific_route_tables : {}
  drga_specific_route_tables              = local.drga_attachable_specific_route_tables != null ? local.drga_attachable_specific_route_tables : {}
  non_gw_specific_remaining_route_tables  = local.non_gw_specific_remaining_route_tables != null ? local.non_gw_specific_remaining_route_tables : {}
  igw_natgw_specific_default_route_tables = local.igw_natgw_attachable_specific_default_route_tables != null ? local.igw_natgw_attachable_specific_default_route_tables : {}
  sgw_specific_default_route_tables       = local.sgw_attachable_specific_default_route_tables != null ? local.sgw_attachable_specific_default_route_tables : {}
  lpg_specific_default_route_tables       = local.lpg_attachable_specific_default_route_tables != null ? local.lpg_attachable_specific_default_route_tables : {}
  drga_specific_default_route_tables      = local.drga_attachable_specific_default_route_tables != null ? local.drga_attachable_specific_default_route_tables : {}
  non_gw_specific_remaining_default_route_tables = (
    local.non_gw_specific_remaining_default_route_tables != null
    ? local.non_gw_specific_remaining_default_route_tables
    : {}
  )

  default_route_table_ids_by_vcn = local.default_route_table_ids_by_vcn

  external_private_ip_targets = coalesce(var.private_ips_dependency, {})
  managed_private_ip_targets = {
    for private_ip_key, private_ip_value in oci_core_private_ip.these : private_ip_key => {
      id = private_ip_value.id
    }
  }
  network_firewall_private_ip_targets = local.network_firewall_route_targets

  internet_gateway_targets = {
    for gateway_key, gateway_value in oci_core_internet_gateway.these : gateway_key => {
      id = gateway_value.id
    }
  }

  nat_gateway_targets = {
    for gateway_key, gateway_value in oci_core_nat_gateway.these : gateway_key => {
      id = gateway_value.id
    }
  }

  service_gateway_targets = {
    for gateway_key, gateway_value in oci_core_service_gateway.these : gateway_key => {
      id = gateway_value.id
    }
  }

  dynamic_gateway_targets = merge(
    {
      for gateway_key, gateway_value in oci_core_drg.these : gateway_key => {
        id = gateway_value.id
      }
    },
    {
      for gateway_key, gateway_value in local.one_dimension_inject_into_existing_drgs : gateway_key => {
        id = gateway_value.id
      }
    },
    {
      for gateway_key, gateway_value in coalesce(try(var.network_dependency.dynamic_routing_gateways, null), {}) : gateway_key => {
        id = gateway_value.id
      }
    }
  )

  local_peering_gateway_targets = {
    for gateway_key, gateway_value in merge(
      oci_core_local_peering_gateway.oci_acceptor_local_peering_gateways,
      oci_core_local_peering_gateway.oci_requestor_local_peering_gateways
      ) : gateway_key => {
      id = gateway_value.id
    }
  }

  route_table_attachments = {
    for subnet_key, subnet_value in local.merged_one_dimension_processed_subnets : subnet_key => {
      default_route_table_id         = local.default_route_table_ids_by_vcn[subnet_value.vcn_key]
      network_configuration_category = subnet_value.network_configuration_category
      route_table_id                 = subnet_value.route_table_id
      route_table_key                = subnet_value.route_table_key
      subnet_id                      = oci_core_subnet.these[subnet_key].id
      subnet_name                    = oci_core_subnet.these[subnet_key].display_name
      vcn_key                        = subnet_value.vcn_key
      vcn_name                       = subnet_value.vcn_name
    }
  }
}

moved {
  from = oci_core_route_table.igw_natgw_specific_route_tables
  to   = module.network_completion.module.igw_natgw_route_tables.oci_core_route_table.custom
}

moved {
  from = oci_core_route_table.sgw_specific_route_tables
  to   = module.network_completion.module.sgw_route_tables.oci_core_route_table.custom
}

moved {
  from = oci_core_route_table.lpg_specific_route_tables
  to   = module.network_completion.module.lpg_route_tables.oci_core_route_table.custom
}

moved {
  from = oci_core_route_table.drga_specific_route_tables
  to   = module.network_completion.module.drga_route_tables.oci_core_route_table.custom
}

moved {
  from = oci_core_route_table.non_gw_specific_remaining_route_tables
  to   = module.network_completion.module.remaining_route_tables.oci_core_route_table.custom
}

moved {
  from = oci_core_default_route_table.igw_natgw_specific_default_route_tables
  to   = module.network_completion.module.igw_natgw_route_tables.oci_core_default_route_table.default
}

moved {
  from = oci_core_default_route_table.sgw_specific_default_route_tables
  to   = module.network_completion.module.sgw_route_tables.oci_core_default_route_table.default
}

moved {
  from = oci_core_default_route_table.lpg_specific_default_route_tables
  to   = module.network_completion.module.lpg_route_tables.oci_core_default_route_table.default
}

moved {
  from = oci_core_default_route_table.drga_specific_default_route_tables
  to   = module.network_completion.module.drga_route_tables.oci_core_default_route_table.default
}

moved {
  from = oci_core_default_route_table.non_gw_specific_remaining_default_route_tables
  to   = module.network_completion.module.remaining_route_tables.oci_core_default_route_table.default
}

moved {
  from = oci_core_route_table_attachment.these
  to   = module.network_completion.oci_core_route_table_attachment.these
}
