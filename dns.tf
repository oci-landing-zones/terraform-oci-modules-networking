# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Flavius Sana                                                                                    #
# Author email: flavius.sana@oracle.com                                                                   #
# Last Modified: Sat Dec 9 2023                                                                          #
# Modified by: Flavius Sana, email: flavius.sana@oracle.com                                               #
# ####################################################################################################### #


locals {
  one_dimension_dns_tsig_keys = local.one_dimension_processed_vcns != null ? {
    for flat_tsig_keys in flatten([
      for vcn_key, vcn_value in local.one_dimension_processed_vcns :
      vcn_value.dns_resolver != null ? vcn_value.dns_resolver.tsig_keys != null ? [
        for tsig_key_key, tsig_key_value in vcn_value.dns_resolver.tsig_keys : {
          vcn_key        = vcn_key
          tsig_key_key   = tsig_key_key
          algorithm      = tsig_key_value.algorithm
          compartment_id = tsig_key_value.compartment_id != null ? tsig_key_value.compartment_id : vcn_value.category_compartment_id != null ? vcn_value.category_compartment_id : vcn_value.default_compartment_id != null ? vcn_value.default_compartment_id : null
          name           = tsig_key_value.name
          secret         = tsig_key_value.secret
          defined_tags   = tsig_key_value.defined_tags
          freeform_tags  = tsig_key_value.freeform_tags
        }
      ] : [] : []
    ]) : flat_tsig_keys.tsig_key_key => flat_tsig_keys
  } : {}


  one_dimension_resolver_endpoints = local.one_dimension_processed_vcns != null ? {
    for flat_resolver_endpoint in flatten([
      for vcn_key, vcn_value in local.one_dimension_processed_vcns :
      vcn_value.dns_resolver != null ? vcn_value.dns_resolver.resolver_endpoints != null ? [
        for resolver_endpoint_key, resolver_endpoint_value in vcn_value.dns_resolver.resolver_endpoints : {
          name                  = resolver_endpoint_value.name
          vcn_key               = vcn_key
          resolver_endpoint_key = resolver_endpoint_key
          is_forwarding         = resolver_endpoint_value.is_forwarding
          is_listening          = resolver_endpoint_value.is_listening
          subnet                = resolver_endpoint_value.subnet != null ? oci_core_subnet.these[resolver_endpoint_value.subnet].id : null
          endpoint_type         = resolver_endpoint_value.endpoint_type
          forwarding_address    = resolver_endpoint_value.forwarding_address
          listening_address     = resolver_endpoint_value.listening_address
          nsgs = resolver_endpoint_value.nsg != null ? [
            for key in resolver_endpoint_value.nsg :
            oci_core_network_security_group.these[key].id
          ] : []
        }
      ] : [] : []
    ]) : flat_resolver_endpoint.resolver_endpoint_key => flat_resolver_endpoint
  } : {}


  one_dimension_resolver = local.one_dimension_processed_vcns != null ? {
    for flat_resolver in flatten([
      for vcn_key, vcn_value in local.one_dimension_processed_vcns :
      vcn_value.dns_resolver != null ? [{
        vcn_key        = vcn_key
        display_name   = vcn_value.dns_resolver.display_name
        rules          = vcn_value.dns_resolver.rules != null ? vcn_value.dns_resolver.rules : []
        attached_views = vcn_value.dns_resolver.attached_views
        defined_tags   = vcn_value.dns_resolver.defined_tags
        freeform_tags  = vcn_value.dns_resolver.freeform_tags
      }] : []
    ]) : flat_resolver.vcn_key => flat_resolver
  } : {}

  one_dimension_dns_views = local.one_dimension_processed_vcns != null ? {
    for flat_attached_views in flatten([
      for vcn_key, vcn_value in local.one_dimension_processed_vcns :
      vcn_value.dns_resolver != null ? vcn_value.dns_resolver.attached_views != null ? [
        for view_key, view_value in vcn_value.dns_resolver.attached_views : {
          vcn_key        = vcn_key
          view_key       = view_key
          compartment_id = view_value.compartment_id != null ? view_value.compartment_id : vcn_value.category_compartment_id != null ? vcn_value.category_compartment_id : vcn_value.default_compartment_id != null ? vcn_value.default_compartment_id : null
          display_name   = view_value.display_name
          defined_tags   = view_value.defined_tags
          freeform_tags  = view_value.freeform_tags
        } if view_value.existing_view_id == null
      ] : [] : []
    ]) : flat_attached_views.view_key => flat_attached_views
  } : {}


  one_dimension_dns_zones = local.one_dimension_processed_vcns != null ? {
    for flat_dns_zones in flatten([
      for vcn_key, vcn_value in local.one_dimension_processed_vcns :
      vcn_value.dns_resolver != null ? vcn_value.dns_resolver.attached_views != null ? [
        for view_key, view_value in vcn_value.dns_resolver.attached_views :
        view_value.dns_zones != null ? [
          for zone_key, zone_value in view_value.dns_zones : {
            zone_key             = zone_key
            view_key             = zone_value.scope != "GLOBAL" ? view_key : null
            compartment_id       = zone_value.compartment_id != null ? zone_value.compartment_id : vcn_value.category_compartment_id != null ? vcn_value.category_compartment_id : vcn_value.default_compartment_id != null ? vcn_value.default_compartment_id : null
            name                 = zone_value.name
            defined_tags         = zone_value.defined_tags
            freeform_tags        = zone_value.freeform_tags
            scope                = zone_value.scope
            external_downstreams = zone_value.external_downstreams != null ? zone_value.external_downstreams : []
            external_masters     = zone_value.external_masters != null ? zone_value.external_masters : []
            zone_type            = zone_value.zone_type
            view_id              = view_value.existing_view_id
          }
        ] : []
      ] : [] : []
    ]) : flat_dns_zones.zone_key => flat_dns_zones
  } : {}

  one_dimension_dns_steering_policies = local.one_dimension_processed_vcns != null ? {
    for flat_dns_steering_policies in flatten([
      for vcn_key, vcn_value in local.one_dimension_processed_vcns :
      vcn_value.dns_resolver != null ? vcn_value.dns_resolver.attached_views != null ? [
        for view_key, view_value in vcn_value.dns_resolver.attached_views :
        view_value.dns_zones != null ? [
          for zone_key, zone_value in view_value.dns_zones : [
            for steering_policy_key, steering_policy_value in coalesce(zone_value.dns_steering_policies,{}) : {
              zone_key                = zone_key
              steering_policy_key     = steering_policy_key
              domain_name             = steering_policy_value.domain_name
              compartment_id          = steering_policy_value.compartment_id != null ? steering_policy_value.compartment_id : vcn_value.category_compartment_id != null ? vcn_value.category_compartment_id : vcn_value.default_compartment_id != null ? vcn_value.default_compartment_id : null
              template                = steering_policy_value.template
              answers                 = steering_policy_value.answers
              defined_tags            = steering_policy_value.defined_tags
              freeform_tags           = steering_policy_value.freeform_tags
              health_check_monitor_id = steering_policy_value.health_check_monitor_id
              rules                   = steering_policy_value.rules
              ttl                     = steering_policy_value.ttl
            }
          ]
        ] : []
      ] : [] : []
    ]) : flat_dns_steering_policies.zone_key => flat_dns_steering_policies
  } : {}


  one_dimension_dns_rrset = local.one_dimension_processed_vcns != null ? {
    for flat_dns_rrset in flatten([
      for vcn_key, vcn_value in local.one_dimension_processed_vcns :
      vcn_value.dns_resolver != null ? vcn_value.dns_resolver.attached_views != null ? [
        for view_key, view_value in vcn_value.dns_resolver.attached_views :
        view_value.dns_zones != null ? [
          for zone_key, zone_value in view_value.dns_zones : [
            zone_value.dns_rrset != null ? [
              for rrset_key, rrset_value in zone_value.dns_rrset : {
                rrset_key      = rrset_key
                zone_key       = zone_key
                view_key       = view_key
                compartment_id = rrset_value.compartment_id != null ? rrset_value.compartment_id : vcn_value.category_compartment_id != null ? vcn_value.category_compartment_id : vcn_value.default_compartment_id != null ? vcn_value.default_compartment_id : null
                rtype          = rrset_value.rtype
                domain = rrset_value.domain
                scope          = rrset_value.scope
                items          = rrset_value.items
            }] : []
          ]
        ] : []
      ] : [] : []
    ]) : flat_dns_rrset.rrset_key => flat_dns_rrset
  } : {}

  provisioned_dns_tsig_keys = {
    for tsig_key, tsig_value in oci_dns_tsig_key.these : tsig_key => {
      compartment_id = tsig_value.compartment_id
      name           = tsig_value.name
      secret         = tsig_value.secret
      algorithm      = tsig_value.algorithm
      defined_tags   = tsig_value.defined_tags
      freeform_tags  = tsig_value.freeform_tags
    }
  }

  provisioned_dns_resolver_endpoints = {
    for endpoint_key, endpoint_value in oci_dns_resolver_endpoint.these : endpoint_key => {
      is_forwarding      = endpoint_value.is_forwarding
      is_listening       = endpoint_value.is_listening
      name               = endpoint_value.name
      resolver_id        = endpoint_value.resolver_id
      subnet_id          = endpoint_value.subnet_id
      scope              = endpoint_value.scope
      endpoint_type      = endpoint_value.endpoint_type
      forwarding_address = endpoint_value.forwarding_address
      listening_address  = endpoint_value.listening_address
      nsg_ids            = endpoint_value.nsg_ids
    }
  }

  provisioned_dns_resolver = {
    for resolver_key, resolver_value in oci_dns_resolver.these : resolver_key => {
      resolver_id    = resolver_value.resolver_id
      scope          = resolver_value.scope
      display_name   = resolver_value.display_name
      attached_views = resolver_value.attached_views
      defined_tags   = resolver_value.defined_tags
      freeform_tags  = resolver_value.freeform_tags
      rules          = resolver_value.rules
    }
  }

  provisioned_dns_views = {
    for view_key, view_value in oci_dns_view.these : view_key => {
      compartment_id = view_value.compartment_id
      display_name   = view_value.display_name
      scope          = view_value.scope
      defined_tags   = view_value.defined_tags
      freeform_tags  = view_value.freeform_tags
    }
  }

  provisioned_dns_zones = {
    for zone_key, zone_value in oci_dns_zone.these : zone_key => {
      compartment_id       = zone_value.compartment_id
      name                 = zone_value.name
      scope                = zone_value.scope
      zone_type            = zone_value.zone_type
      view_id              = zone_value.view_id
      external_downstreams = zone_value.external_downstreams
      external_masters     = zone_value.external_masters
      defined_tags         = zone_value.defined_tags
      freeform_tags        = zone_value.freeform_tags
    }
  }

  provisioned_dns_steering_policies = {
    for steering_policy_key, steering_policy_value in oci_dns_steering_policy.these : steering_policy_key => {
      compartment_id          = steering_policy_value.compartment_id
      display_name            = steering_policy_value.display_name
      template                = steering_policy_value.template
      answers                 = steering_policy_value.answers
      defined_tags            = steering_policy_value.defined_tags
      freeform_tags           = steering_policy_value.freeform_tags
      health_check_monitor_id = steering_policy_value.health_check_monitor_id
      rules                   = steering_policy_value
      ttl                     = steering_policy_value.ttl
    }
  }

  provisioned_dns_rrset = {
    for rrset_key, rrset_value in oci_dns_rrset.these : rrset_key => {
      compartment_id  = rrset_value.compartment_id
      domain          = rrset_value.domain
      rtype           = rrset_value.rtype
      zone_name_or_id = rrset_value.zone_name_or_id
      view_id         = rrset_value.view_id
      scope           = rrset_value.scope
      items           = rrset_value.items
    }
  }
}

data "oci_core_vcn_dns_resolver_association" "dns_resolvers" {
  for_each   = local.one_dimension_processed_vcns
  vcn_id     = oci_core_vcn.these[each.key].id
  depends_on = [time_sleep.wait_for_dns_resolver]
}

resource "oci_dns_view" "these" {
  for_each = local.one_dimension_dns_views
    compartment_id = each.value.compartment_id
    display_name  = each.value.display_name
    scope         = "PRIVATE"
    defined_tags  = each.value.defined_tags
    freeform_tags = each.value.freeform_tags
}

resource "oci_dns_zone" "these" {
  for_each       = local.one_dimension_dns_zones
  compartment_id = each.value.compartment_id
  name           = each.value.name
  scope          = each.value.scope
  zone_type      = each.value.zone_type

  view_id = each.value.view_key != null ? (contains(keys(oci_dns_view.these),each.value.view_key) ? oci_dns_view.these[each.value.view_key].id : (length(regexall("^ocid1.*$", each.value.view_id)) > 0 ? each.value.view_id : var.network_dependency["dns_private_views"][each.value.view_id].id)) : null

  dynamic "external_downstreams" {
    for_each = each.value.external_downstreams
    iterator = downstream
    content {
      address     = downstream.value.address
      port        = downstream.value.port
      tsig_key_id = oci_dns_tsig_key.these[downstream.tsig_key].id
    }
  }

  dynamic "external_masters" {
    for_each = each.value.external_masters
    iterator = master
    content {
      address     = master.value.address
      port        = master.value.port
      tsig_key_id = oci_dns_tsig_key.these[master.tsig_key].id
    }
  }
  defined_tags  = each.value.defined_tags
  freeform_tags = each.value.freeform_tags
}

resource "oci_dns_rrset" "these" {
  for_each        = local.one_dimension_dns_rrset
  compartment_id  = each.value.compartment_id
  domain          = each.value.domain
  rtype           = each.value.rtype
  zone_name_or_id = oci_dns_zone.these[each.value.zone_key].id
  view_id         = oci_dns_view.these[each.value.view_key].id
  scope           = each.value.scope
  dynamic "items" {
    for_each = each.value.items
    iterator = item
    content {
      domain = item.value.domain
      rdata  = item.value.rdata
      rtype  = item.value.rtype
      ttl    = item.value.ttl
    }
  }
}

resource "oci_dns_tsig_key" "these" {
  for_each       = local.one_dimension_dns_tsig_keys
  compartment_id = each.value.compartment_id
  name           = each.value.name
  secret         = each.value.secret
  algorithm      = each.value.algorithm
  defined_tags   = each.value.defined_tags
  freeform_tags  = each.value.freeform_tags

}

resource "oci_dns_resolver_endpoint" "these" {
  for_each           = local.one_dimension_resolver_endpoints
  is_forwarding      = each.value.is_forwarding
  is_listening       = each.value.is_listening
  name               = each.value.name
  resolver_id        = data.oci_core_vcn_dns_resolver_association.dns_resolvers[each.value.vcn_key].dns_resolver_id
  subnet_id          = each.value.subnet
  scope              = "PRIVATE"
  endpoint_type      = each.value.endpoint_type
  forwarding_address = each.value.forwarding_address
  listening_address  = each.value.listening_address
  nsg_ids            = each.value.nsgs
}

resource "time_sleep" "wait_for_dns_resolver" {
  create_duration = "60s"
  depends_on      = [oci_core_vcn.these]
}

resource "oci_dns_resolver" "these" {
  for_each     = local.one_dimension_resolver
  resolver_id  = data.oci_core_vcn_dns_resolver_association.dns_resolvers[each.value.vcn_key].dns_resolver_id
  scope        = "PRIVATE"
  display_name = each.value.display_name

  dynamic "attached_views" {
    for_each = each.value.attached_views
    iterator = views
    content {
      view_id = views.key != null ? (contains(keys(oci_dns_view.these),views.key) ? oci_dns_view.these[views.key].id : (length(regexall("^ocid1.*$", views.value.existing_view_id)) > 0 ? views.value.existing_view_id : var.network_dependency["dns_private_views"][views.value.existing_view_id].id)) : null
    }
  }
  defined_tags  = each.value.defined_tags
  freeform_tags = each.value.freeform_tags

  dynamic "rules" {
    for_each = each.value.rules
    iterator = rule
    content {
      action                    = rule.value.action
      destination_addresses     = rule.value.destination_address
      source_endpoint_name      = oci_dns_resolver_endpoint.these[rule.value.source_endpoint_name].name
      client_address_conditions = rule.value.client_address_conditions != null ? rule.value.client_address_conditions : []
      qname_cover_conditions    = rule.value.qname_cover_conditions != null ? rule.value.qname_cover_conditions : []

    }
  }

  depends_on = [data.oci_core_vcn_dns_resolver_association.dns_resolvers]
}

resource "oci_dns_steering_policy" "these" {
  for_each       = local.one_dimension_dns_steering_policies
  compartment_id = each.value.compartment_id
  display_name   = each.value.display_name
  template       = each.value.template

  dynamic "answers" {
    for_each = each.value.answers
    iterator = answer
    content {
      name  = answer.value.name
      rdata = answer.value.rdata
      rtype = answer.value.rtype

      is_disabled = answer.value.is_disabled
      pool        = [answer.value.pool]
    }
  }

  defined_tags            = each.value.defined_tags
  freeform_tags           = each.value.freeform_tags
  health_check_monitor_id = each.value.health_check_monitor_id

  dynamic "rules" {
    for_each = each.value.rules
    iterator = rule
    content {
      rule_type = rule.value.rule_type
      dynamic "cases" {
        for_each = rule.value.cases
        iterator = case
        content {
          answer_data {
            answer_condition = case.value.answer_data.answer_condition
            should_keep      = case.value.answer_data.should_keep
            value            = case.value.answer_data.value
          }
          case_condition = case.value.case_condition
          count          = case.value.count
        }
      }
      default_answer_data {
        answer_condition = rule.value.default_answer_data.answer_condition
        should_keep      = rule.value.default_answer_data.should_keep
        value            = rule.value.default_answer_data.value
      }
      default_count = rule.value.default_count
      description   = rule.value.description
    }
  }
  ttl = each.value.ttl
}

resource "oci_dns_steering_policy_attachment" "these" {
  for_each           = local.one_dimension_dns_steering_policies
  domain_name        = each.value.domain_name
  steering_policy_id = oci_dns_steering_policy.these[each.value.steering_policy_key].id
  zone_id            = oci_dns_zone.these[each.value.zone_key].id

  display_name = each.value.display_name
}
