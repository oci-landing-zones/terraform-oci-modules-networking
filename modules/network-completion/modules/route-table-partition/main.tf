resource "oci_core_route_table" "custom" {
  for_each = var.custom_route_tables

  display_name   = each.value.display_name
  compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
  vcn_id         = each.value.vcn_id
  defined_tags   = each.value.defined_tags
  freeform_tags  = var.merge_module_tag ? merge(var.module_tag, each.value.freeform_tags) : each.value.freeform_tags

  dynamic "route_rules" {
    iterator = rule
    for_each = each.value.route_rules != null ? [
      for route_rule in each.value.route_rules : {
        destination        = route_rule.destination
        destination_type   = route_rule.destination_type
        network_entity_id  = route_rule.network_entity_id
        network_entity_key = route_rule.network_entity_key
        description        = route_rule.description
      }
    ] : []

    content {
      destination       = rule.value.destination
      destination_type  = rule.value.destination_type
      network_entity_id = rule.value.network_entity_id != null ? rule.value.network_entity_id : rule.value.network_entity_key != null ? var.route_rule_targets[rule.value.network_entity_key].id : null
      description       = rule.value.description
    }
  }
}

resource "oci_core_default_route_table" "default" {
  for_each = var.default_route_tables

  display_name               = each.value.display_name
  manage_default_resource_id = var.default_route_table_ids_by_vcn[each.value.vcn_key]
  compartment_id             = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
  defined_tags               = each.value.defined_tags
  freeform_tags              = var.merge_module_tag ? merge(var.module_tag, each.value.freeform_tags) : each.value.freeform_tags

  dynamic "route_rules" {
    iterator = rule
    for_each = each.value.route_rules != null ? [
      for route_rule in each.value.route_rules : {
        destination        = route_rule.destination
        destination_type   = route_rule.destination_type
        network_entity_id  = route_rule.network_entity_id
        network_entity_key = route_rule.network_entity_key
        description        = route_rule.description
      }
    ] : []

    content {
      destination       = rule.value.destination
      destination_type  = rule.value.destination_type
      network_entity_id = rule.value.network_entity_id != null ? rule.value.network_entity_id : rule.value.network_entity_key != null ? var.route_rule_targets[rule.value.network_entity_key].id : null
      description       = rule.value.description
    }
  }
}
