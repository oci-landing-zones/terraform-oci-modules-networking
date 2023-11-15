# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #


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
          application_lists              = nfwp_value.application_lists
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

  provisioned_oci_network_firewall_network_firewall_policies = {
    for nfw_pol_key, nfw_pol_value in oci_network_firewall_network_firewall_policy.these : nfw_pol_key => {
      application_lists              = nfw_pol_value.application_lists
      compartment_id                 = nfw_pol_value.compartment_id
      decryption_profiles            = nfw_pol_value.decryption_profiles
      decryption_rules               = nfw_pol_value.decryption_rules
      defined_tags                   = nfw_pol_value.defined_tags
      display_name                   = nfw_pol_value.display_name
      freeform_tags                  = nfw_pol_value.freeform_tags
      id                             = nfw_pol_value.id
      ip_address_lists               = nfw_pol_value.ip_address_lists
      is_firewall_attached           = nfw_pol_value.is_firewall_attached
      lifecycle_details              = nfw_pol_value.lifecycle_details
      mapped_secrets                 = nfw_pol_value.mapped_secrets
      security_rules                 = nfw_pol_value.security_rules
      state                          = nfw_pol_value.state
      system_tags                    = nfw_pol_value.system_tags
      time_created                   = nfw_pol_value.time_created
      time_updated                   = nfw_pol_value.time_updated
      timeouts                       = nfw_pol_value.timeouts
      url_lists                      = nfw_pol_value.url_lists
      network_configuration_category = local.one_dimension_processed_nfw_policies[nfw_pol_key].network_configuration_category
      nfwp_key                       = nfw_pol_key
    }
  }
}


resource "oci_network_firewall_network_firewall_policy" "these" {

  for_each = local.one_dimension_processed_nfw_policies != null ? length(local.one_dimension_processed_nfw_policies) > 0 ? local.one_dimension_processed_nfw_policies : {} : {}

  compartment_id = each.value.compartment_id
  defined_tags   = each.value.defined_tags
  display_name   = each.value.display_name
  freeform_tags  = each.value.freeform_tags

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
}
