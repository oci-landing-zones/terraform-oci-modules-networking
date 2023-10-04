
data "oci_core_route_tables" "these_default_route_tables_new_vcns" {
  for_each = local.provisioned_vcns
  #Required
  compartment_id = each.value.compartment_id

  #Optional
  display_name = "Default Route Table for ${each.value.display_name}"
  vcn_id       = each.value.id
}

data "oci_core_route_tables" "these_default_route_tables_existing_vcns" {
  for_each = local.one_dimension_processed_existing_vcns
  #Required
  compartment_id = each.value.compartment_id

  #Optional
  display_name = "Default Route Table for ${each.value.vcn_name}"
  vcn_id       = each.value.vcn_id
}

locals {

  default_route_tables = {
    for default_rt_key, default_rt_value in merge(
      data.oci_core_route_tables.these_default_route_tables_new_vcns,
    data.oci_core_route_tables.these_default_route_tables_existing_vcns) :
    replace(upper("${default_rt_value.route_tables[0].display_name}-KEY"), " ", "_") => {
      compartment_id                 = default_rt_value.route_tables[0].compartment_id
      defined_tags                   = default_rt_value.route_tables[0].defined_tags
      display_name                   = default_rt_value.route_tables[0].display_name
      freeform_tags                  = default_rt_value.route_tables[0].freeform_tags
      id                             = default_rt_value.route_tables[0].id
      route_rules                    = default_rt_value.route_tables[0].route_rules
      state                          = default_rt_value.route_tables[0].state
      time_created                   = default_rt_value.route_tables[0].time_created
      vcn_id                         = default_rt_value.route_tables[0].vcn_id
      vcn_key                        = [for vcn_key, vcn_value in local.provisioned_vcns : vcn_value.vcn_key if vcn_value.id == default_rt_value.route_tables[0].vcn_id][0]
      vcn_name                       = [for vcn_key, vcn_value in local.provisioned_vcns : vcn_value.display_name if vcn_value.id == default_rt_value.route_tables[0].vcn_id][0]
      network_configuration_category = [for vcn_key, vcn_value in local.provisioned_vcns : vcn_value.network_configuration_category if vcn_value.id == default_rt_value.route_tables[0].vcn_id][0]
      route_table_key                = replace(upper("${default_rt_value.route_tables[0].display_name}-KEY"), " ", "_")
    } if default_rt_value.route_tables != null
  }
  one_dimension_processed_route_tables = local.one_dimension_processed_vcns != null ? {
    for flat_route_table in flatten([
      for vcn_key, vcn_value in local.one_dimension_processed_vcns : vcn_value.route_tables != null ? length(vcn_value.route_tables) > 0 ? [
        for route_table_key, route_table_value in vcn_value.route_tables : {
          compartment_id          = route_table_value.compartment_id != null ? route_table_value.compartment_id : vcn_value.category_compartment_id != null ? vcn_value.category_compartment_id : vcn_value.default_compartment_id != null ? vcn_value.default_compartment_id : null
          default_compartment_id  = vcn_value.default_compartment_id
          category_compartment_id = vcn_value.category_compartment_id
          defined_tags            = merge(route_table_value.defined_tags, vcn_value.category_defined_tags, vcn_value.default_defined_tags)
          default_defined_tags    = vcn_value.default_defined_tags
          category_defined_tags   = vcn_value.category_defined_tags
          freeform_tags           = merge(route_table_value.freeform_tags, vcn_value.category_freeform_tags, vcn_value.default_freeform_tags)
          category_freeform_tags  = vcn_value.category_freeform_tags
          default_freeform_tags   = vcn_value.default_freeform_tags
          display_name            = route_table_value.display_name
          route_rules = route_table_value.route_rules != null ? {
            for rr_key, rr_value in route_table_value.route_rules : rr_key => {
              destination        = rr_value.destination
              destination_type   = rr_value.destination_type
              network_entity_id  = rr_value.network_entity_id
              network_entity_key = rr_value.network_entity_key
              description        = rr_value.description
            }
          } : {}
          network_configuration_category = vcn_value.network_configuration_category
          vcn_key                        = vcn_key
          vcn_name                       = vcn_value.display_name
          route_table_key                = route_table_key
          vcn_id                         = null
        }
      ] : [] : []
    ]) : flat_route_table.route_table_key => flat_route_table
  } : null

  one_dimension_processed_injected_route_tables = local.one_dimension_processed_existing_vcns != null ? {
    for flat_route_table in flatten([
      for vcn_key, vcn_value in local.one_dimension_processed_existing_vcns : vcn_value.route_tables != null ? length(vcn_value.route_tables) > 0 ? [
        for route_table_key, route_table_value in vcn_value.route_tables : {
          compartment_id                 = route_table_value.compartment_id != null ? route_table_value.compartment_id : vcn_value.category_compartment_id != null ? vcn_value.category_compartment_id : vcn_value.default_compartment_id != null ? vcn_value.default_compartment_id : null
          default_compartment_id         = vcn_value.default_compartment_id
          category_compartment_id        = vcn_value.category_compartment_id
          defined_tags                   = merge(route_table_value.defined_tags, vcn_value.category_defined_tags, vcn_value.default_defined_tags)
          default_defined_tags           = vcn_value.default_defined_tags
          category_defined_tags          = vcn_value.category_defined_tags
          freeform_tags                  = merge(route_table_value.freeform_tags, vcn_value.category_freeform_tags, vcn_value.default_freeform_tags)
          category_freeform_tags         = vcn_value.category_freeform_tags
          default_freeform_tags          = vcn_value.default_freeform_tags
          display_name                   = route_table_value.display_name
          route_rules                    = route_table_value.route_rules
          network_configuration_category = vcn_value.network_configuration_category
          vcn_key                        = vcn_key
          vcn_name                       = vcn_value.vcn_name
          vcn_id                         = vcn_value.vcn_id
          route_table_key                = route_table_key
        }
      ] : [] : []
    ]) : flat_route_table.route_table_key => flat_route_table
  } : null

  merged_one_dimension_processed_route_tables = merge(local.one_dimension_processed_route_tables, local.one_dimension_processed_injected_route_tables)

  network_firewalls_private_IPs_OCIDS = {
    for nfw_key, nfw_value in local.provisioned_oci_network_firewall_network_firewalls : nfw_key => {
      id = nfw_value.ipv4address_ocid
    }
  }

  network_entities = merge(
    oci_core_internet_gateway.these,
    oci_core_nat_gateway.these,
    oci_core_service_gateway.these,
    oci_core_local_peering_gateway.oci_acceptor_local_peering_gateways,
    oci_core_local_peering_gateway.oci_requestor_local_peering_gateways,
    oci_core_drg.these,
    local.network_firewalls_private_IPs_OCIDS
  )

  network_entities_no_drg = merge(
    oci_core_internet_gateway.these,
    oci_core_nat_gateway.these,
    oci_core_service_gateway.these,
    oci_core_local_peering_gateway.oci_acceptor_local_peering_gateways,
    oci_core_local_peering_gateway.oci_requestor_local_peering_gateways,
    local.network_firewalls_private_IPs_OCIDS
  )

  network_entities_attached_route_tables = [
    for gw_key, gw_value in merge(
      merge(local.one_dimension_processed_internet_gateways, local.one_dimension_processed_injected_internet_gateways),
      merge(local.one_dimension_processed_nat_gateways, local.one_dimension_processed_injected_nat_gateways),
      merge(local.one_dimension_processed_service_gateways, local.one_dimension_processed_injected_service_gateways),
      merge(local.one_dimension_processed_local_peering_gateways, local.one_dimension_processed_injected_local_peering_gateways),
  ) : gw_value.route_table_key if gw_value.route_table_key != null]

  drg_attachment_attached_route_tables = local.one_dimension_processed_drg_attachments != null ? compact([
    for drga_key, drga_value in local.one_dimension_processed_drg_attachments : drga_value.network_details.route_table_key if drga_value.network_details != null
  ]) : []

  one_dimension_processed_route_tables_no_gw_attached = {
    for rt_key, rt_value in local.merged_one_dimension_processed_route_tables : rt_key => rt_value if !contains(local.network_entities_attached_route_tables, rt_key) && !contains(local.drg_attachment_attached_route_tables, rt_key)
  }

  one_dimension_processed_route_tables_gw_attached = {
    for rt_key, rt_value in local.merged_one_dimension_processed_route_tables : rt_key => rt_value if contains(local.network_entities_attached_route_tables, rt_key) && !contains(local.drg_attachment_attached_route_tables, rt_key)
  }

  one_dimension_processed_route_tables_drg_attached = {
    for rt_key, rt_value in local.merged_one_dimension_processed_route_tables : rt_key => rt_value if contains(local.drg_attachment_attached_route_tables, rt_key)
  }

  provisioned_route_tables = merge(
    local.default_route_tables,
    {
      for route_table_key, route_value in merge(oci_core_route_table.these_gw_attached,
        oci_core_route_table.these_no_gw_attached, oci_core_route_table.these_drg_attached) : route_table_key => {
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
        vcn_key                        = local.merged_one_dimension_processed_route_tables[route_table_key].vcn_key
        vcn_name                       = local.merged_one_dimension_processed_route_tables[route_table_key].vcn_name
        network_configuration_category = local.merged_one_dimension_processed_route_tables[route_table_key].network_configuration_category
        route_table_key                = route_table_key
      }
    }
  )

  provisioned_route_tables_attachments = {
    for rta_key, rta_value in oci_core_route_table_attachment.these : rta_key => {
      id                             = rta_value.id
      route_table_id                 = rta_value.route_table_id
      route_table_key                = merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)[rta_key].route_table_key
      route_table_name               = merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)[rta_key].route_table_key != null ? local.provisioned_route_tables[merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)[rta_key].route_table_key].display_name : null
      subnet_id                      = rta_value.subnet_id
      subnet_key                     = rta_key
      subnet_name                    = can(local.provisioned_subnets[rta_key].display_name) ? local.provisioned_subnets[rta_key].display_name : null
      timeouts                       = rta_value.timeouts
      rta_key                        = rta_key
      vcn_key                        = merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)[rta_key].vcn_key
      vcn_name                       = merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)[rta_key].vcn_name
      network_configuration_category = merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)[rta_key].network_configuration_category
    }
  }

}


### Route tables
resource "oci_core_route_table" "these_no_gw_attached" {
  for_each = local.one_dimension_processed_route_tables_no_gw_attached

  display_name   = each.value.display_name
  vcn_id         = each.value.vcn_id != null ? each.value.vcn_id : oci_core_vcn.these[each.value.vcn_key].id
  compartment_id = each.value.compartment_id
  defined_tags   = each.value.defined_tags
  freeform_tags  = each.value.freeform_tags
  dynamic "route_rules" {
    iterator = rule
    for_each = each.value.route_rules != null ? [
      for route_rule in each.value.route_rules : {
        destination : route_rule.destination
        destination_type : route_rule.destination_type
        network_entity_id : route_rule.network_entity_id
        network_entity_key : route_rule.network_entity_key
        description : route_rule.description
    }] : []
    content {
      destination       = rule.value.destination
      destination_type  = rule.value.destination_type
      network_entity_id = rule.value.network_entity_id != null ? rule.value.network_entity_id : local.network_entities[rule.value.network_entity_key].id
      description       = rule.value.description
    }
  }
}

resource "oci_core_route_table" "these_gw_attached" {
  for_each = local.one_dimension_processed_route_tables_gw_attached

  display_name   = each.value.display_name
  vcn_id         = each.value.vcn_id != null ? each.value.vcn_id : oci_core_vcn.these[each.value.vcn_key].id
  compartment_id = each.value.compartment_id
  defined_tags   = each.value.defined_tags
  freeform_tags  = each.value.freeform_tags
  dynamic "route_rules" {
    iterator = rule
    for_each = each.value.route_rules != null ? [
      for route_rule in each.value.route_rules : {
        destination : route_rule.destination
        destination_type : route_rule.destination_type
        network_entity_id : route_rule.network_entity_id
        network_entity_key : route_rule.network_entity_key
        description : route_rule.description
    }] : []
    content {
      destination       = rule.value.destination
      destination_type  = rule.value.destination_type
      network_entity_id = rule.value.network_entity_id != null ? rule.value.network_entity_id : local.network_firewalls_private_IPs_OCIDS[rule.value.network_entity_key].id
      description       = rule.value.description
    }
  }
}


resource "oci_core_route_table" "these_drg_attached" {
  for_each = local.one_dimension_processed_route_tables_drg_attached

  display_name   = each.value.display_name
  vcn_id         = each.value.vcn_id != null ? each.value.vcn_id : oci_core_vcn.these[each.value.vcn_key].id
  compartment_id = each.value.compartment_id
  defined_tags   = each.value.defined_tags
  freeform_tags  = each.value.freeform_tags
  dynamic "route_rules" {
    iterator = rule
    for_each = each.value.route_rules != null ? [
      for route_rule in each.value.route_rules : {
        destination : route_rule.destination
        destination_type : route_rule.destination_type
        network_entity_id : route_rule.network_entity_id
        network_entity_key : route_rule.network_entity_key
        description : route_rule.description
    }] : []
    content {
      destination       = rule.value.destination
      destination_type  = rule.value.destination_type
      network_entity_id = rule.value.network_entity_id != null ? rule.value.network_entity_id : local.network_entities[rule.value.network_entity_key].id
      description       = rule.value.description
    }
  }
}


### Route Table Attachments
resource "oci_core_route_table_attachment" "these" {
  for_each  = oci_core_subnet.these
  subnet_id = each.value.id
  route_table_id = merge(
    local.one_dimension_processed_subnets,
    local.one_dimension_processed_injected_subnets
    )[each.key].route_table_id != null ? merge(
    local.one_dimension_processed_subnets,
    local.one_dimension_processed_injected_subnets
    )[each.key].route_table_id : merge(
    local.one_dimension_processed_subnets,
    local.one_dimension_processed_injected_subnets
    )[each.key].route_table_key != null ? merge(
    oci_core_route_table.these_gw_attached,
    oci_core_route_table.these_no_gw_attached,
    local.default_route_tables
    )[merge(
      local.one_dimension_processed_subnets,
      local.one_dimension_processed_injected_subnets
    )[each.key].route_table_key].id : [
    for drt_key, drt_value in local.default_route_tables : drt_value.id if drt_value.vcn_id == each.value.vcn_id
  ][0]
}