# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  one_dimension_processed_subnets = local.one_dimension_processed_vcns != null ? {
    for flat_subnet in flatten([
      for vcn_key, vcn_value in local.one_dimension_processed_vcns : vcn_value.subnets != null ? length(vcn_value.subnets) > 0 ? [
        for subnet_key, subnet_value in vcn_value.subnets : {
          cidr_block              = subnet_value.cidr_block
          compartment_id          = subnet_value.compartment_id != null ? subnet_value.compartment_id : vcn_value.category_compartment_id != null ? vcn_value.category_compartment_id : vcn_value.default_compartment_id != null ? vcn_value.default_compartment_id : null
          default_compartment_id  = vcn_value.default_compartment_id
          category_compartment_id = vcn_value.category_compartment_id
          defined_tags            = merge(subnet_value.defined_tags, vcn_value.category_defined_tags, vcn_value.default_defined_tags)
          default_defined_tags    = vcn_value.default_defined_tags
          category_defined_tags   = vcn_value.category_defined_tags
          availability_domain     = subnet_value.availability_domain
          dhcp_options_key        = subnet_value.dhcp_options_key
          dhcp_options_id = subnet_value.dhcp_options_key != null ? merge(
            {
              for dhcp_opt_key, dhcp_opt_value in oci_core_dhcp_options.these : dhcp_opt_key => {
                id = dhcp_opt_value.id
              }
            },
            {
              "default_dhcp_options" = {
                id = oci_core_vcn.these[vcn_key].default_dhcp_options_id
              }
            }
          )[subnet_value.dhcp_options_key].id : null
          display_name               = subnet_value.display_name
          dns_label                  = subnet_value.dns_label
          freeform_tags              = merge(subnet_value.freeform_tags, vcn_value.category_freeform_tags, vcn_value.default_freeform_tags)
          category_freeform_tags     = vcn_value.category_freeform_tags
          default_freeform_tags      = vcn_value.default_freeform_tags
          ipv6cidr_block             = subnet_value.ipv6cidr_block
          ipv6cidr_blocks            = subnet_value.ipv6cidr_blocks
          prohibit_internet_ingress  = subnet_value.prohibit_internet_ingress
          prohibit_public_ip_on_vnic = subnet_value.prohibit_public_ip_on_vnic
          route_table_key            = subnet_value.route_table_key
          route_table_id             = null
          #route_table_id             = subnet_value.route_table_key != null ? merge(oci_core_route_table.these_gw_attached, oci_core_route_table.these_no_gw_attached, local.default_route_tables)[subnet_value.route_table_key].id : null
          security_list_keys = subnet_value.security_list_keys
          security_list_ids = subnet_value.security_list_keys != null ? length(subnet_value.security_list_keys) > 0 ? [
            for seclistname in subnet_value.security_list_keys : oci_core_security_list.these[seclistname].id
          ] : [] : []
          network_configuration_category = vcn_value.network_configuration_category
          vcn_key                        = vcn_key
          vcn_name                       = vcn_value.display_name
          subnet_key                     = subnet_key
          vcn_id                         = oci_core_vcn.these[vcn_key].id
        }
      ] : [] : []
    ]) : flat_subnet.subnet_key => flat_subnet
  } : null

  one_dimension_processed_injected_subnets = local.one_dimension_processed_existing_vcns != null ? {
    for flat_subnet in flatten([
      for vcn_key, vcn_value in local.one_dimension_processed_existing_vcns : vcn_value.subnets != null ? length(vcn_value.subnets) > 0 ? [
        for subnet_key, subnet_value in vcn_value.subnets : {
          cidr_block              = subnet_value.cidr_block
          compartment_id          = subnet_value.compartment_id != null ? subnet_value.compartment_id : vcn_value.category_compartment_id != null ? vcn_value.category_compartment_id : vcn_value.default_compartment_id != null ? vcn_value.default_compartment_id : null
          default_compartment_id  = vcn_value.default_compartment_id
          category_compartment_id = vcn_value.category_compartment_id
          defined_tags            = merge(subnet_value.defined_tags, vcn_value.category_defined_tags, vcn_value.default_defined_tags)
          default_defined_tags    = vcn_value.default_defined_tags
          category_defined_tags   = vcn_value.category_defined_tags
          availability_domain     = subnet_value.availability_domain
          dhcp_options_key        = subnet_value.dhcp_options_key
          dhcp_options_id = subnet_value.dhcp_options_id != null ? subnet_value.dhcp_options_id : subnet_value.dhcp_options_key != null ? merge(
            {
              for dhcp_opt_key, dhcp_opt_value in oci_core_dhcp_options.these : dhcp_opt_key => {
                id = dhcp_opt_value.id
              }
            },
            {
              "default_dhcp_options" = {
                id = [
                  for inject_vcn_key, inject_vcn_value in data.oci_core_vcn.existing_vcns : {
                    id = inject_vcn_value.default_dhcp_options_id
                  } if inject_vcn_value.id == vcn_value.vcn_id
                ][0].id
              }
            }
          )[subnet_value.dhcp_options_key].id : null
          display_name               = subnet_value.display_name
          dns_label                  = subnet_value.dns_label
          freeform_tags              = merge(subnet_value.freeform_tags, vcn_value.category_freeform_tags, vcn_value.default_freeform_tags)
          category_freeform_tags     = vcn_value.category_freeform_tags
          default_freeform_tags      = vcn_value.default_freeform_tags
          ipv6cidr_block             = subnet_value.ipv6cidr_block
          ipv6cidr_blocks            = subnet_value.ipv6cidr_blocks
          prohibit_internet_ingress  = subnet_value.prohibit_internet_ingress
          prohibit_public_ip_on_vnic = subnet_value.prohibit_public_ip_on_vnic
          route_table_key            = subnet_value.route_table_key
          route_table_id             = null
          #route_table_id             = subnet_value.route_table_id != null ? subnet_value.route_table_id : subnet_value.route_table_key != null ? merge(oci_core_route_table.these_gw_attached, oci_core_route_table.these_no_gw_attached, local.default_route_tables)[subnet_value.route_table_key].id : null
          security_list_keys = subnet_value.security_list_keys
          security_list_ids = concat(
            subnet_value.security_list_keys != null ? [
              for seclistname in subnet_value.security_list_keys : oci_core_security_list.these[seclistname].id
            ] : [],

            subnet_value.security_list_ids != null ? subnet_value.security_list_ids : []
          )
          network_configuration_category = vcn_value.network_configuration_category
          vcn_key                        = vcn_key
          vcn_name                       = vcn_value.vcn_name
          subnet_key                     = subnet_key
          vcn_id                         = vcn_value.vcn_id
        }
      ] : [] : []
    ]) : flat_subnet.subnet_key => flat_subnet
  } : null

  aux_provisioned_subnets = {
    for subnet_key, subnet_value in oci_core_subnet.these : subnet_key => {
      availability_domain        = subnet_value.availability_domain
      cidr_block                 = subnet_value.cidr_block
      compartment_id             = subnet_value.compartment_id
      defined_tags               = subnet_value.defined_tags
      dhcp_options_id            = subnet_value.dhcp_options_id
      dhcp_options_key           = merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)[subnet_key].dhcp_options_key != null ? merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)[subnet_key].dhcp_options_key : "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
      display_name               = subnet_value.display_name
      dns_label                  = subnet_value.dns_label
      freeform_tags              = subnet_value.freeform_tags
      id                         = subnet_value.id
      ipv6cidr_block             = subnet_value.ipv6cidr_block
      ipv6cidr_blocks            = subnet_value.ipv6cidr_blocks
      ipv6virtual_router_ip      = subnet_value.ipv6virtual_router_ip
      prohibit_internet_ingress  = subnet_value.prohibit_internet_ingress
      prohibit_public_ip_on_vnic = subnet_value.prohibit_public_ip_on_vnic
      route_table_id             = subnet_value.route_table_id
      route_table_key            = merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)[subnet_key].route_table_key != null ? merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)[subnet_key].route_table_key : "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"

      security_lists = flatten(subnet_value.security_list_ids != null ? [
        for sec_list_id in subnet_value.security_list_ids : contains([
          for sec_list_key, sec_list_value in oci_core_security_list.these : sec_list_value.id
          ],

          sec_list_id) ? [
          for sec_list_key, sec_list_value in oci_core_security_list.these : {
            display_name = sec_list_value.display_name
            sec_list_key = sec_list_key
            sec_list_id  = sec_list_id
          } if sec_list_value.id == sec_list_id] : [
          {
            display_name = "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
            sec_list_key = "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
            sec_list_id  = sec_list_id
          }
        ]
      ] : [])

      state                          = subnet_value.state
      subnet_domain_name             = subnet_value.subnet_domain_name
      time_created                   = subnet_value.time_created
      timeouts                       = subnet_value.timeouts
      vcn_id                         = subnet_value.vcn_id
      vcn_key                        = merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)[subnet_key].vcn_key
      vcn_name                       = merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)[subnet_key].vcn_name
      network_configuration_category = merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)[subnet_key].network_configuration_category
      virtual_router_ip              = subnet_value.virtual_router_ip
      virtual_router_mac             = subnet_value.virtual_router_mac
      subnet_key                     = subnet_key
    }
  }

  provisioned_subnets = {
    for subnet_key, subnet_value in local.aux_provisioned_subnets : subnet_key => {
      availability_domain        = subnet_value.availability_domain
      cidr_block                 = subnet_value.cidr_block
      compartment_id             = subnet_value.compartment_id
      defined_tags               = subnet_value.defined_tags
      dhcp_options_id            = subnet_value.dhcp_options_id
      dhcp_options_key           = merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)[subnet_key].dhcp_options_key
      dhcp_options_name          = merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)[subnet_key].dhcp_options_key != null ? merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)[subnet_key].dhcp_options_key == "default_dhcp_options" ? "default_dhcp_options" : can(oci_core_dhcp_options.these[merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)[subnet_key].dhcp_options_key].display_name) ? oci_core_dhcp_options.these[merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)[subnet_key].dhcp_options_key].display_name : "CANNOT BE DETERMINED AS NOT CREATED BY THIS AUTOMATION" : "CANNOT BE DETERMINED AS NOT CREATED BY THIS AUTOMATION"
      display_name               = subnet_value.display_name
      dns_label                  = subnet_value.dns_label
      freeform_tags              = subnet_value.freeform_tags
      id                         = subnet_value.id
      ipv6cidr_block             = subnet_value.ipv6cidr_block
      ipv6cidr_blocks            = subnet_value.ipv6cidr_blocks
      ipv6virtual_router_ip      = subnet_value.ipv6virtual_router_ip
      prohibit_internet_ingress  = subnet_value.prohibit_internet_ingress
      prohibit_public_ip_on_vnic = subnet_value.prohibit_public_ip_on_vnic
      #route_table_id             = subnet_value.route_table_id
      route_table_id   = oci_core_route_table_attachment.these[subnet_key].route_table_id
      route_table_key  = merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)[subnet_key].route_table_key != null ? merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)[subnet_key].route_table_key : "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
      route_table_name = merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)[subnet_key].route_table_key != null ? merge(oci_core_route_table.these_gw_attached, oci_core_route_table.these_no_gw_attached, local.default_route_tables)[merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)[subnet_key].route_table_key].display_name : "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
      security_lists = {
        for sec_list in subnet_value.security_lists : sec_list.sec_list_id => {
          display_name = sec_list.display_name
          sec_list_key = sec_list.sec_list_key
        }
      }
      state                          = subnet_value.state
      subnet_domain_name             = subnet_value.subnet_domain_name
      time_created                   = subnet_value.time_created
      timeouts                       = subnet_value.timeouts
      vcn_id                         = subnet_value.vcn_id
      vcn_key                        = merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)[subnet_key].vcn_key
      vcn_name                       = merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)[subnet_key].vcn_name
      network_configuration_category = merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)[subnet_key].network_configuration_category
      virtual_router_ip              = subnet_value.virtual_router_ip
      virtual_router_mac             = subnet_value.virtual_router_mac
      subnet_key                     = subnet_key
    }
  }
}

resource "oci_core_subnet" "these" {
  for_each = merge(local.one_dimension_processed_subnets, local.one_dimension_processed_injected_subnets)
  #Required
  cidr_block     = each.value.cidr_block
  compartment_id = each.value.compartment_id
  vcn_id         = each.value.vcn_id

  #Optional
  availability_domain        = each.value.availability_domain
  defined_tags               = each.value.defined_tags
  dhcp_options_id            = each.value.dhcp_options_id
  display_name               = each.value.display_name
  dns_label                  = each.value.dns_label
  freeform_tags              = each.value.freeform_tags
  ipv6cidr_block             = each.value.ipv6cidr_block
  ipv6cidr_blocks            = each.value.ipv6cidr_blocks
  prohibit_internet_ingress  = each.value.prohibit_internet_ingress
  prohibit_public_ip_on_vnic = each.value.prohibit_public_ip_on_vnic
  #route_table_id             = data.oci_core_route_tables.these_default_route_tables[each.value.vcn_key].id
  security_list_ids = each.value.security_list_ids
}
