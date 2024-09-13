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
          decryption_profiles            = nfwp_value.decryption_profiles
          decryption_rules               = nfwp_value.decryption_rules
          ip_address_lists               = nfwp_value.ip_address_lists
          mapped_secrets                 = nfwp_value.mapped_secrets
          security_rules                 = nfwp_value.security_rules
          url_lists                      = nfwp_value.url_lists
          nfwp_key                       = nfwp_key
        }
      ] : [] : [] : []
    ]) : flat_nfwp.nfwp_key => flat_nfwp
  } : null

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
      for add_key, add_value in (coalesce(policy_value.ip_address_lists,{})) : {
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
        key                 = "${policy_key}.${security_key}"
        policy_key          = policy_key
        action              = security_value.action
        name                = security_value.name
        application         = security_value.application
        destination_address = security_value.destination_address
        service             = security_value.service
        source_address      = security_value.source_address
        url                 = security_value.url
        inspection          = security_value.inspection
        after_rule          = security_value.after_rule
        before_rule         = security_value.before_rule
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
      #ip_address_lists               = nfw_pol_value.ip_address_lists
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
    type = each.value.tyep
  }
}

resource "oci_network_firewall_network_firewall_policy_security_rule" "these" {
  for_each = {
    for v in local.nfw_policy_security_rules : v.key => {
                                                          policy_key          = v.policy_key
                                                          action              = v.action
                                                          name                = v.name
                                                          application         = v.application
                                                          destination_address = v.destination_address
                                                          service             = v.service
                                                          source_address      = v.source_address
                                                          url                 = v.url
                                                          inspection          = v.inspection
                                                          after_rule          = v.after_rule
                                                          before_rule         = v.before_rule
                                                        }}
  lifecycle {
    ignore_changes = [position]
  }
  #Required
  action = each.value.action
  name = each.value.name
  condition {
    application = each.value.application
    destination_address = each.value.destination_address
    service = each.value.service
    source_address = each.value.source_address
    url = each.value.url
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

/* resource "oci_network_firewall_network_firewall_policy" "these" {

  for_each = local.one_dimension_processed_nfw_policies != null ? length(local.one_dimension_processed_nfw_policies) > 0 ? local.one_dimension_processed_nfw_policies : {} : {}

  compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
  defined_tags   = each.value.defined_tags
  display_name   = each.value.display_name
  freeform_tags  = merge(local.cislz_module_tag, each.value.freeform_tags)

  dynamic "application_lists" {
    for_each = each.value.application_lists != null ? length(each.value.application_lists) > 0 ? [
      for app_list_key, app_list_value in each.value.application_lists : {
        application_list_name = app_list_value.application_list_name
        application_values    = app_list_value.application_values
    }] : [] : []
    iterator = application_list

    content {
      application_list_name = application_list.value.application_list_name

      dynamic "application_values" {
        for_each = application_list.value.application_values != null ? application_list.value.application_values != null ? [
          for app_value_key, app_value_value in application_list.value.application_values : {
            type         = app_value_value.type
            icmp_type    = app_value_value.icmp_type
            icmp_code    = app_value_value.icmp_code
            minimum_port = app_value_value.minimum_port
            maximum_port = app_value_value.maximum_port
        }] : [] : []
        iterator = application_value

        content {
          type         = application_value.value.type
          icmp_type    = application_value.value.icmp_type
          icmp_code    = application_value.value.icmp_code
          minimum_port = application_value.value.minimum_port
          maximum_port = application_value.value.maximum_port
        }
      }
    }
  }

  dynamic "decryption_profiles" {
    for_each = each.value.decryption_profiles != null ? length(each.value.decryption_profiles) > 0 ? [
      for d_profile_key, d_profile_value in each.value.decryption_profiles : {
        is_out_of_capacity_blocked     = d_profile_value.is_out_of_capacity_blocked
        is_unsupported_cipher_blocked  = d_profile_value.is_unsupported_cipher_blocked
        is_unsupported_version_blocked = d_profile_value.is_unsupported_version_blocked
        type                           = d_profile_value.type
        key                            = d_profile_value.key
        #Optional
        are_certificate_extensions_restricted = d_profile_value.are_certificate_extensions_restricted
        is_auto_include_alt_name              = d_profile_value.is_auto_include_alt_name
        is_expired_certificate_blocked        = d_profile_value.is_expired_certificate_blocked
        is_revocation_status_timeout_blocked  = d_profile_value.is_revocation_status_timeout_blocked
        is_unknown_revocation_status_blocked  = d_profile_value.is_unknown_revocation_status_blocked
        is_untrusted_issuer_blocked           = d_profile_value.is_untrusted_issuer_blocked
    }] : [] : []
    iterator = decryption_profile

    content {
      is_out_of_capacity_blocked     = decryption_profile.value.is_out_of_capacity_blocked
      is_unsupported_cipher_blocked  = decryption_profile.value.is_unsupported_cipher_blocked
      is_unsupported_version_blocked = decryption_profile.value.is_unsupported_version_blocked
      type                           = decryption_profile.value.type
      key                            = decryption_profile.value.key

      #Optional
      are_certificate_extensions_restricted = decryption_profile.value.are_certificate_extensions_restricted
      is_auto_include_alt_name              = decryption_profile.value.is_auto_include_alt_name
      is_expired_certificate_blocked        = decryption_profile.value.is_expired_certificate_blocked
      is_revocation_status_timeout_blocked  = decryption_profile.value.is_revocation_status_timeout_blocked
      is_unknown_revocation_status_blocked  = decryption_profile.value.is_unknown_revocation_status_blocked
      is_untrusted_issuer_blocked           = decryption_profile.value.is_untrusted_issuer_blocked
    }
  }


  dynamic "decryption_rules" {
    for_each = each.value.decryption_rules != null ? length(each.value.decryption_rules) > 0 ? [
      for d_rule_key, d_rule_value in each.value.decryption_rules : {
        action             = d_rule_value.action
        name               = d_rule_value.name
        decryption_profile = d_rule_value.decryption_profile
        secret             = d_rule_value.secret
        conditions         = d_rule_value.conditions
    }] : [] : []
    iterator = decryption_rule

    content {
      action             = decryption_rule.value.action
      name               = decryption_rule.value.name
      decryption_profile = decryption_rule.value.decryption_profile
      secret             = decryption_rule.value.secret
      dynamic "condition" {
        for_each = decryption_rule.value != null ? length(decryption_rule.value) > 0 ? [
          for cond_key, cond_value in decryption_rule.value.conditions : {
            destinations = cond_value.destinations
            sources      = cond_value.sources
        }] : [] : []
        iterator = cond
        content {
          destinations = cond.value.destinations
          sources      = cond.value.sources
        }
      }
    }
  }

  dynamic "ip_address_lists" {
    for_each = each.value.ip_address_lists != null ? length(each.value.ip_address_lists) > 0 ? [
      for ipa_list_key, ipa_list_value in each.value.ip_address_lists : {
        ip_address_list_name  = ipa_list_value.ip_address_list_name
        ip_address_list_value = ipa_list_value.ip_address_list_value
    }] : [] : []
    iterator = ip_address_list

    content {
      ip_address_list_name  = ip_address_list.value.ip_address_list_name
      ip_address_list_value = ip_address_list.value.ip_address_list_value
    }
  }

  dynamic "mapped_secrets" {
    for_each = each.value.mapped_secrets != null ? length(each.value.mapped_secrets) > 0 ? [
      for ms_key, ms_value in each.value.mapped_secrets : {
        key             = ms_value.key
        type            = ms_value.type
        vault_secret_id = ms_value.vault_secret_id
        version_number  = ms_value.version_number
    }] : [] : []
    iterator = mapped_secret

    content {
      type            = mapped_secret.value.type
      key             = mapped_secret.value.key
      vault_secret_id = mapped_secret.value.vault_secret_id
      version_number  = mapped_secret.value.version_number
    }
  }

  dynamic "security_rules" {
    for_each = each.value.security_rules != null ? length(each.value.security_rules) > 0 ? [
      for sr_key, sr_value in each.value.security_rules : {
        action     = sr_value.action
        conditions = sr_value.conditions
        name       = sr_value.name
        inspection = sr_value.inspection
    }] : [] : []
    iterator = security_rule

    content {
      action     = security_rule.value.action
      name       = security_rule.value.name
      inspection = security_rule.value.inspection

      dynamic "condition" {
        for_each = security_rule.value.conditions != null ? security_rule.value.conditions != null ? [
          for cond_key, cond_value in security_rule.value.conditions : {
            applications = cond_value.applications
            destinations = cond_value.destinations
            sources      = cond_value.sources
            urls         = cond_value.urls
        }] : [] : []
        iterator = condition

        content {
          applications = condition.value.applications
          destinations = condition.value.destinations
          sources      = condition.value.sources
          urls         = condition.value.urls
        }
      }
    }
  }

  dynamic "url_lists" {
    for_each = each.value.url_lists != null ? length(each.value.url_lists) > 0 ? [
      for urll in each.value.url_lists : {
        url_list_name   = urll.url_list_name
        url_list_values = urll.url_list_values
    }] : [] : []
    iterator = url_list

    content {
      url_list_name = url_list.value.url_list_name

      dynamic "url_list_values" {
        for_each = url_list.value.url_list_values != null ? length(url_list.value.url_list_values) > 0 ? [
          for urllv in url_list.value.url_list_values : {
            type    = urllv.type
            pattern = urllv.pattern
        }] : [] : []
        iterator = url_list_value

        content {
          type    = url_list_value.value.type
          pattern = url_list_value.value.pattern
        }
      }
    }
  }
} */
