# ###################################################################################################### #
# Copyright (c) 2024 Oracle and/or its affiliates, All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl. #
# ###################################################################################################### #

resource "oci_waf_web_app_firewall_policy" "these" {
  for_each       = var.waf_configuration != null ? (var.waf_configuration.waf != null ? var.waf_configuration.waf : {}) : {}
  compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : (length(regexall("^ocid1.*$", var.waf_configuration.default_compartment_id)) > 0 ? var.waf_configuration.default_compartment_id : var.compartments_dependency[var.waf_configuration.default_compartment_id].id)
  display_name   = each.value.waf_policy_display_name
  defined_tags   = merge(each.value.defined_tags, var.waf_configuration.default_defined_tags)
  freeform_tags  = merge(each.value.freeform_tags, var.waf_configuration.default_freeform_tags)
  dynamic "actions" {
    for_each = each.value.actions != null ? each.value.actions : {}
    content {
      name = actions.value.name
      type = actions.value.type
      dynamic "body" {
        for_each = actions.value.body != null ? [1] : []
        content {
          text = actions.value.body.text != null ? actions.value.body.text : null
          type = actions.value.body.type != null ? actions.value.body.type : null
        }
      }
      code = actions.value.code
      dynamic "headers" {
        for_each = actions.value.headers != null ? [1] : []
        content {
          name  = actions.value.headers.name != null ? actions.value.headers.name : null
          value = actions.value.headers.value != null ? actions.value.headers.value : null
        }
      }
    }
  }
}

resource "oci_waf_web_app_firewall" "these" {
  for_each                   = var.waf_configuration != null ? (var.waf_configuration.waf != null ? var.waf_configuration.waf : {}) : {}
  compartment_id             = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : (length(regexall("^ocid1.*$", var.waf_configuration.default_compartment_id)) > 0 ? var.waf_configuration.default_compartment_id : var.compartments_dependency[var.waf_configuration.default_compartment_id].id)
  display_name               = each.value.display_name
  defined_tags               = merge(each.value.defined_tags, var.waf_configuration.default_defined_tags)
  freeform_tags              = merge(each.value.freeform_tags, var.waf_configuration.default_freeform_tags)
  backend_type               = upper(each.value.backend_type)
  load_balancer_id           = each.value.load_balancer_id
  web_app_firewall_policy_id = oci_waf_web_app_firewall_policy.these[each.key].id
}
