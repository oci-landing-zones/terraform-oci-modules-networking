locals {

  # PROCESSED INPUT
  one_dimension_processed_private_ips = local.one_dimension_processed_IPs != null ? {
    for flat_private_ip in flatten([
      for ips_key, ips_value in local.one_dimension_processed_IPs :
      ips_value.private_ips != null ? length(ips_value.private_ips) > 0 ? [
        for private_ip_key, private_ip_value in ips_value.private_ips : {
          defined_tags                   = merge(coalesce(private_ip_value.defined_tags, {}), coalesce(ips_value.category_defined_tags, {}), coalesce(ips_value.default_defined_tags, {}))
          default_defined_tags           = ips_value.default_defined_tags
          category_defined_tags          = ips_value.category_defined_tags
          display_name                   = private_ip_value.display_name
          freeform_tags                  = merge(coalesce(private_ip_value.freeform_tags, {}), coalesce(ips_value.category_freeform_tags, {}), coalesce(ips_value.default_freeform_tags, {}))
          default_freeform_tags          = ips_value.default_freeform_tags
          category_freeform_tags         = ips_value.category_freeform_tags
          hostname_label                 = private_ip_value.hostname_label
          ip_address                     = private_ip_value.ip_address
          private_ip_key                 = private_ip_key
          subnet_id                      = private_ip_value.subnet_id != null ? (length(regexall("^ocid1.*$", private_ip_value.subnet_id)) > 0 ? private_ip_value.subnet_id : try(local.aux_provisioned_subnets[private_ip_value.subnet_id].id, try(var.network_dependency.subnets[private_ip_value.subnet_id].id, null))) : private_ip_value.subnet_key != null ? try(local.aux_provisioned_subnets[private_ip_value.subnet_key].id, try(var.network_dependency.subnets[private_ip_value.subnet_key].id, null)) : null
          subnet_key                     = private_ip_value.subnet_key
          network_configuration_category = ips_value.network_configuration_category
        }
      ] : [] : []
    ]) : flat_private_ip.private_ip_key => flat_private_ip
  } : null

  provisioned_oci_core_private_ips = {
    for private_ip_key, private_ip_value in oci_core_private_ip.these : private_ip_key => {
      availability_domain            = private_ip_value.availability_domain
      cidr_prefix_length             = private_ip_value.cidr_prefix_length
      compartment_id                 = private_ip_value.compartment_id
      defined_tags                   = private_ip_value.defined_tags
      display_name                   = private_ip_value.display_name
      freeform_tags                  = private_ip_value.freeform_tags
      hostname_label                 = private_ip_value.hostname_label
      id                             = private_ip_value.id
      ip_address                     = private_ip_value.ip_address
      ip_state                       = private_ip_value.ip_state
      ipv4subnet_cidr_at_creation    = private_ip_value.ipv4subnet_cidr_at_creation
      is_primary                     = private_ip_value.is_primary
      is_reserved                    = private_ip_value.is_reserved
      lifetime                       = private_ip_value.lifetime
      route_table_id                 = private_ip_value.route_table_id
      subnet_id                      = private_ip_value.subnet_id
      subnet_key                     = local.one_dimension_processed_private_ips[private_ip_key].subnet_key
      time_created                   = private_ip_value.time_created
      vlan_id                        = private_ip_value.vlan_id
      vnic_id                        = private_ip_value.vnic_id
      private_ip_key                 = private_ip_key
      network_configuration_category = local.one_dimension_processed_private_ips[private_ip_key].network_configuration_category
    }
  }
}

resource "oci_core_private_ip" "these" {
  for_each = local.one_dimension_processed_private_ips != null ? length(local.one_dimension_processed_private_ips) > 0 ? local.one_dimension_processed_private_ips : {} : {}

  #Required
  lifetime  = "RESERVED"
  subnet_id = each.value.subnet_id

  #Optional
  defined_tags   = each.value.defined_tags
  display_name   = each.value.display_name
  freeform_tags  = merge(local.cislz_module_tag, each.value.freeform_tags)
  hostname_label = each.value.hostname_label
  ip_address     = each.value.ip_address

  lifecycle {
    ignore_changes = [vnic_id]

    precondition {
      condition     = each.value.subnet_id != null
      error_message = "VALIDATION FAILURE in private IP \"${each.key}\": either \"subnet_id\" or \"subnet_key\" must be provided and resolvable."
    }
  }
}
