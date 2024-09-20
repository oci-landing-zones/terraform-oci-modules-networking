# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  one_dimension_processed_nfw_policies = local.one_dimension_processed_non_vcn_specific_gateways != null ? {
    for flat_nfwp in flatten([
      for vcn_non_specific_gw_key, vcn_non_specific_gw_value in local.one_dimension_processed_non_vcn_specific_gateways :
      vcn_non_specific_gw_value.network_firewalls_configuration != null ? vcn_non_specific_gw_value.network_firewalls_configuration.network_firewall_policies != null ? length(vcn_non_specific_gw_value.network_firewalls_configuration.network_firewall_policies) > 0 ? [
        for nfwp_key, nfwp_value in vcn_non_specific_gw_value.network_firewalls_configuration.network_firewall_policies : {
          network_configuration_category = vcn_non_specific_gw_value.network_configuration_category
          compartment_id                 = nfwp_value.compartment_id != null ? nfwp_value.compartment_id : vcn_non_specific_gw_value.category_compartment_id != null ? vcn_non_specific_gw_value.category_compartment_id : vcn_non_specific_gw_value.default_compartment_id != null ? vcn_non_specific_gw_value.default_compartment_id : null
          category_compartment_id        = vcn_non_specific_gw_value.category_compartment_id
          default_compartment_id         = vcn_non_specific_gw_value.default_compartment_id
          defined_tags                   = merge(nfwp_value.defined_tags, vcn_non_specific_gw_value.category_defined_tags, vcn_non_specific_gw_value.default_defined_tags)
          category_defined_tags          = vcn_non_specific_gw_value.category_defined_tags
          default_defined_tags           = vcn_non_specific_gw_value.default_defined_tags
          freeform_tags                  = merge(nfwp_value.freeform_tags, vcn_non_specific_gw_value.category_freeform_tags, vcn_non_specific_gw_value.default_freeform_tags)
          category_freeform_tags         = vcn_non_specific_gw_value.category_freeform_tags
          default_freeform_tags          = vcn_non_specific_gw_value.default_freeform_tags
          defined_tags                   = nfwp_value.defined_tags
          display_name                   = nfwp_value.display_name
          freeform_tags                  = nfwp_value.freeform_tags
          applications                   = nfwp_value.applications
          application_lists              = nfwp_value.application_lists
          decryption_profiles            = nfwp_value.decryption_profiles
          decryption_rules               = nfwp_value.decryption_rules
          address_lists                  = nfwp_value.address_lists
          mapped_secrets                 = nfwp_value.mapped_secrets
          security_rules                 = nfwp_value.security_rules
          url_lists                      = nfwp_value.url_lists
          services                       = nfwp_value.services
          service_lists                  = nfwp_value.service_lists
          nfwp_key                       = nfwp_key
        }
      ] : [] : [] : []
    ]) : flat_nfwp.nfwp_key => flat_nfwp
  } : null

  nfw_policy_services = flatten([
    for policy_key, policy_value in coalesce(local.one_dimension_processed_nfw_policies,{}) : [
      for service_key, service_value in (coalesce(policy_value.services,{})) : {
        key        = "${policy_key}.${service_key}"
        policy_key = policy_key
        name       = service_value.name
        type       = service_value.type
        minimum_port  = service_value.minimum_port
        maximum_port  = service_value.maximum_port
      }
    ]
  ])

  nfw_policy_service_lists = flatten([
    for policy_key, policy_value in coalesce(local.one_dimension_processed_nfw_policies,{}) : [
      for serv_key, serv_value in (coalesce(policy_value.service_lists,{})) : {
        key        = "${policy_key}.${serv_key}"
        policy_key = policy_key
        name       = serv_value.name
        services   = serv_value.services
      }
    ]
  ])

  nfw_policy_applications = flatten([
    for policy_key, policy_value in coalesce(local.one_dimension_processed_nfw_policies,{}) : [
      for app_key, app_value in (coalesce(policy_value.applications,{})) : {
        key        = "${policy_key}.${app_key}"
        policy_key = policy_key
        name       = app_value.name
        type       = app_value.type
        icmp_type  = app_value.icmp_type
        icmp_code  = app_value.icmp_code
      }
    ]
  ])

  nfw_policy_application_lists = flatten([
    for policy_key, policy_value in coalesce(local.one_dimension_processed_nfw_policies,{}) : [
      for applist_key, applist_value in (coalesce(policy_value.application_lists,{})) : {
        key        = "${policy_key}.${applist_key}"
        policy_key = policy_key
        name       = applist_value.name
        apps       = applist_value.applications
      }
    ]
  ])

  nfw_policy_decryption_profiles = flatten([
    for policy_key, policy_value in coalesce(local.one_dimension_processed_nfw_policies,{}) : [
      for prof_key, prof_value in (coalesce(policy_value.decryption_profiles,{})) : {
        key        = "${policy_key}.${prof_key}"
        policy_key = policy_key
        type = prof_value.type
        name = prof_value.name
        is_out_of_capacity_blocked            = prof_value.is_out_of_capacity_blocked
        is_unsupported_cipher_blocked         = prof_value.is_unsupported_cipher_blocked
        is_unsupported_version_blocked        = prof_value.is_unsupported_version_blocked
        are_certificate_extensions_restricted = prof_value.are_certificate_extensions_restricted
        is_auto_include_alt_name              = prof_value.is_auto_include_alt_name
        is_expired_certificate_blocked        = prof_value.is_expired_certificate_blocked
        is_revocation_status_timeout_blocked  = prof_value.is_revocation_status_timeout_blocked
        is_unknown_revocation_status_blocked  = prof_value.is_unknown_revocation_status_blocked
        is_untrusted_issuer_blocked           = prof_value.is_untrusted_issuer_blocked
      }
    ]
  ])

  nfw_policy_address_lists = flatten([
    for policy_key, policy_value in coalesce(local.one_dimension_processed_nfw_policies,{}) : [
      for add_key, add_value in (coalesce(policy_value.address_lists,{})) : {
        key        = "${policy_key}.${add_key}"
        policy_key = policy_key
        name       = add_value.name
        type       = add_value.type
        addresses  = add_value.addresses
      }
    ]
  ])

  nfw_policy_decryption_rules = flatten([
    for policy_key, policy_value in coalesce(local.one_dimension_processed_nfw_policies,{}) : [
      for rule_key, rule_value in (coalesce(policy_value.decryption_rules,{})) : {
        key        = "${policy_key}.${rule_key}"
        policy_key = policy_key
        action     = rule_value.action
        name       = rule_value.name
        secret     = rule_value.secret
        decryption_profile_id       = rule_value.decryption_profile_id
        destination_ip_address_list = rule_value.destination_ip_address_list
        source_ip_address_list      = rule_value.source_ip_address_list
      }
    ]
  ])

  nfw_policy_mapped_secrets = flatten([
    for policy_key, policy_value in coalesce(local.one_dimension_processed_nfw_policies,{}) : [
      for secret_key, secret_value in (coalesce(policy_value.mapped_secrets,{})) : {
        key = "${policy_key}.${secret_key}"
        policy_key = policy_key
        name = secret_value.name
        source = secret_value.source
        type = secret_value.type
        vault_secret_id = secret_value.vault_secret_id
        version_number = secret_value.version_number
      }
    ]
  ])

  nfw_policy_url_lists = flatten([
    for policy_key, policy_value in coalesce(local.one_dimension_processed_nfw_policies,{}) : [
      for url_key, url_value in (coalesce(policy_value.url_lists,{})) : {
        key = "${policy_key}.${url_key}"
        policy_key = policy_key
        name = url_value.name
        pattern = url_value.pattern
        type = url_value.type
      }
    ]
  ])

  nfw_policy_security_rules = flatten([
    for policy_key, policy_value in coalesce(local.one_dimension_processed_nfw_policies,{}) : [
      for security_key, security_value in (coalesce(policy_value.security_rules,{})) : {
        key                       = "${policy_key}.${security_key}"
        policy_key                = policy_key
        action                    = security_value.action
        name                      = security_value.name
        application_lists         = security_value.application_lists
        destination_address_lists = security_value.destination_address_lists
        service_lists             = security_value.service_lists
        source_address_lists      = security_value.source_address_lists
        url_lists                 = security_value.url_lists
        inspection                = security_value.inspection
        after_rule                = security_value.after_rule
        before_rule               = security_value.before_rule
      }
    ]
  ])

  provisioned_oci_network_firewall_network_firewall_policies = {
    for nfw_pol_key, nfw_pol_value in oci_network_firewall_network_firewall_policy.these : nfw_pol_key => {
      #application_lists              = nfw_pol_value.application_lists
      compartment_id                 = nfw_pol_value.compartment_id
      #decryption_profiles            = nfw_pol_value.decryption_profiles
      #decryption_rules               = nfw_pol_value.decryption_rules
      defined_tags                   = nfw_pol_value.defined_tags
      display_name                   = nfw_pol_value.display_name
      freeform_tags                  = nfw_pol_value.freeform_tags
      id                             = nfw_pol_value.id
      #address_lists               = nfw_pol_value.address_lists
      #is_firewall_attached           = nfw_pol_value.is_firewall_attached
      lifecycle_details              = nfw_pol_value.lifecycle_details
      #mapped_secrets                 = nfw_pol_value.mapped_secrets
      #security_rules                 = nfw_pol_value.security_rules
      state                          = nfw_pol_value.state
      system_tags                    = nfw_pol_value.system_tags
      time_created                   = nfw_pol_value.time_created
      time_updated                   = nfw_pol_value.time_updated
      timeouts                       = nfw_pol_value.timeouts
      #url_lists                      = nfw_pol_value.url_lists
      network_configuration_category = local.one_dimension_processed_nfw_policies[nfw_pol_key].network_configuration_category
      nfwp_key                       = nfw_pol_key
    }
  }
}


resource "oci_network_firewall_network_firewall_policy" "these" {
  for_each       = local.one_dimension_processed_nfw_policies != null && length(local.one_dimension_processed_nfw_policies) > 0 ? local.one_dimension_processed_nfw_policies : {}
    compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
    defined_tags   = each.value.defined_tags
    display_name   = each.value.display_name
    freeform_tags  = merge(local.cislz_module_tag, each.value.freeform_tags)
}

resource "oci_network_firewall_network_firewall_policy_service" "these" {
  for_each = { for v in local.nfw_policy_services : v.key => {
    policy_key = v.policy_key
    name       = v.name
    type       = v.type
    minimum_port  = v.minimum_port
    maximum_port  = v.maximum_port
  } }
  network_firewall_policy_id = oci_network_firewall_network_firewall_policy.these[each.value.policy_key].id
  name      = each.value.name
  type      = each.value.type
  port_ranges {
    minimum_port = each.value.minimum_port
    maximum_port = each.value.maximum_port
  }
}

resource "oci_network_firewall_network_firewall_policy_service_list" "these" {
  for_each = { for v in local.nfw_policy_service_lists : v.key => {
    policy_key = v.policy_key
    name       = v.name
    services   = v.services
  } }
  network_firewall_policy_id = oci_network_firewall_network_firewall_policy.these[each.value.policy_key].id
  name      = each.value.name
  services  = [for service in each.value.services : oci_network_firewall_network_firewall_policy_service.these["${each.value.policy_key}.${service}"].name]
}

resource "oci_network_firewall_network_firewall_policy_application" "these" {
  for_each = { for v in local.nfw_policy_applications : v.key => {
                                                            policy_key = v.policy_key
                                                            name       = v.name
                                                            type       = v.type
                                                            icmp_code  = v.icmp_code
                                                            icmp_type  = v.icmp_type
                                                         } }
    network_firewall_policy_id = oci_network_firewall_network_firewall_policy.these[each.value.policy_key].id
    name      = each.value.name
    type      = each.value.type
    icmp_type = each.value.icmp_type
    icmp_code = each.value.icmp_code
}

resource "oci_network_firewall_network_firewall_policy_application_group" "these" {
  for_each = { for v in local.nfw_policy_application_lists : v.key => {
                                                            policy_key = v.policy_key
                                                            name       = v.name
                                                            apps       = v.apps
                                                          } }
    network_firewall_policy_id = oci_network_firewall_network_firewall_policy.these[each.value.policy_key].id
    name      = each.value.name
    apps      = [for app in each.value.apps : oci_network_firewall_network_firewall_policy_application.these["${each.value.policy_key}.${app}"].name]
}

resource "oci_network_firewall_network_firewall_policy_decryption_profile" "these" {
  for_each = { for v in local.nfw_policy_decryption_profiles : v.key => {
                                                            policy_key = v.policy_key
                                                            type = v.type
                                                            name = v.name
                                                            is_out_of_capacity_blocked            = v.is_out_of_capacity_blocked
                                                            is_unsupported_cipher_blocked         = v.is_unsupported_cipher_blocked
                                                            is_unsupported_version_blocked        = v.is_unsupported_version_blocked
                                                            are_certificate_extensions_restricted = v.are_certificate_extensions_restricted
                                                            is_auto_include_alt_name              = v.is_auto_include_alt_name
                                                            is_expired_certificate_blocked        = v.is_expired_certificate_blocked
                                                            is_revocation_status_timeout_blocked  = v.is_revocation_status_timeout_blocked
                                                            is_unknown_revocation_status_blocked  = v.is_unknown_revocation_status_blocked
                                                            is_untrusted_issuer_blocked           = v.is_untrusted_issuer_blocked
                                                         } }
    network_firewall_policy_id = oci_network_firewall_network_firewall_policy.these[each.value.policy_key].id
    name = each.value.name
    type = each.value.type # Valid values: "SSL_FORWARD_PROXY", "SSL_INBOUND_INSPECTION"
    # Optional attributes
    is_out_of_capacity_blocked            = each.value.is_out_of_capacity_blocked
    is_unsupported_cipher_blocked         = each.value.is_unsupported_cipher_blocked
    is_unsupported_version_blocked        = each.value.is_unsupported_version_blocked
    are_certificate_extensions_restricted = each.value.are_certificate_extensions_restricted
    is_auto_include_alt_name              = each.value.is_auto_include_alt_name
    is_expired_certificate_blocked        = each.value.is_expired_certificate_blocked
    is_revocation_status_timeout_blocked  = each.value.is_revocation_status_timeout_blocked
    is_unknown_revocation_status_blocked  = each.value.is_unknown_revocation_status_blocked
    is_untrusted_issuer_blocked           = each.value.is_untrusted_issuer_blocked
}

resource "oci_network_firewall_network_firewall_policy_address_list" "these" {
  for_each = { for v in local.nfw_policy_address_lists : v.key => {
                                                            policy_key = v.policy_key
                                                            name       = v.name
                                                            type       = v.type
                                                            addresses  = v.addresses
                                                         } }
    network_firewall_policy_id = oci_network_firewall_network_firewall_policy.these[each.value.policy_key].id
    name      = each.value.name
    type      = each.value.type
    addresses = each.value.addresses
}

resource "oci_network_firewall_network_firewall_policy_decryption_rule" "these" {
  for_each = { for v in local.nfw_policy_decryption_rules : v.key => {
                                                            policy_key = v.policy_key
                                                            name       = v.name
                                                            action     = v.action
                                                            secret     = v.secret
                                                            decryption_profile_id = v.decryption_profile_id
                                                            destination_ip_address_list = v.destination_ip_address_list
                                                            source_ip_address_list      = v.source_ip_address_list
                                                         } }
    network_firewall_policy_id = oci_network_firewall_network_firewall_policy.these[each.value.policy_key].id
    action                     = each.value.action
    name                       = each.value.name
    decryption_profile         = each.value.decryption_profile_id != null ? oci_network_firewall_network_firewall_policy_decryption_profile.these["${each.value.policy_key}.${each.value.decryption_profile_id}"].id : null
    secret                     = each.value.secret

    condition {
      destination_address = each.value.destination_ip_address_list != null ? [oci_network_firewall_network_firewall_policy_address_list.these["${each.value.policy_key}.${each.value.destination_ip_address_list}"].name] : null
      source_address      = each.value.source_ip_address_list != null ? [oci_network_firewall_network_firewall_policy_address_list.these["${each.value.policy_key}.${each.value.source_ip_address_list}"].name] : null
    }
}

resource "oci_network_firewall_network_firewall_policy_mapped_secret" "these" {
  for_each = { for v in local.nfw_policy_mapped_secrets : v.key => {
                                                                      policy_key = v.policy_key
                                                                      name       = v.name
                                                                      source     = v.source
                                                                      type       = v.type
                                                                      vault_secret_id = v.vault_secret_id
                                                                      version_number = v.version_number
                                                                    } }
  name = each.value.name
  network_firewall_policy_id = oci_network_firewall_network_firewall_policy.these[each.value.policy_key].id
  source = each.value.source
  type = each.value.type
  vault_secret_id = each.value.vault_secret_id
  version_number = each.value.version_number
}

resource "oci_network_firewall_network_firewall_policy_url_list" "these" {
  for_each = { for v in local.nfw_policy_url_lists : v.key => {
                                                                policy_key = v.policy_key
                                                                name = v.name
                                                                pattern = v.pattern
                                                                type = v.type
                                                              }}
  name = each.value.name
  network_firewall_policy_id = oci_network_firewall_network_firewall_policy.these[each.value.policy_key].id
  urls {
    pattern = each.value.pattern
    type = each.value.type
  }
}

resource "oci_network_firewall_network_firewall_policy_security_rule" "these" {
  for_each = {
    for v in local.nfw_policy_security_rules : v.key => {
                                                          policy_key                = v.policy_key
                                                          action                    = v.action
                                                          name                      = v.name
                                                          application_lists         = v.application_lists
                                                          destination_address_lists = v.destination_address_lists
                                                          service_lists             = v.service_lists
                                                          source_address_lists      = v.source_address_lists
                                                          url_lists                 = v.url_lists
                                                          inspection                = v.inspection
                                                          after_rule                = v.after_rule
                                                          before_rule               = v.before_rule
                                                        }}
  lifecycle {
    ignore_changes = [position]
  }
  #Required
  action = each.value.action
  name = each.value.name
  condition {
    application         = each.value.application_lists != null ? [for app_list in each.value.application_lists: oci_network_firewall_network_firewall_policy_application_group.these["${each.value.policy_key}.${app_list}"].name ] : null
    destination_address = each.value.destination_address_lists != null ? [for dest_list in each.value.destination_address_lists: oci_network_firewall_network_firewall_policy_address_list.these["${each.value.policy_key}.${dest_list}"].name ] : null
    source_address      = each.value.source_address_lists != null ? [for source_list in each.value.source_address_lists: oci_network_firewall_network_firewall_policy_address_list.these["${each.value.policy_key}.${source_list}"].name ] : null
    url                 = each.value.url_lists != null ? [for url_list in each.value.url_lists: oci_network_firewall_network_firewall_policy_url_list.these["${each.value.policy_key}.${url_list}"].name ] : null
    service             = each.value.service_lists != null ? [for service_list in each.value.service_lists: oci_network_firewall_network_firewall_policy_service_list.these["${each.value.policy_key}.${service_list}"].name ] : null
}
  network_firewall_policy_id = oci_network_firewall_network_firewall_policy.these[each.value.policy_key].id

  #Optional
  inspection = each.value.inspection
  position {

    #Optional
    after_rule = each.value.after_rule
    before_rule = each.value.before_rule
  }
}
