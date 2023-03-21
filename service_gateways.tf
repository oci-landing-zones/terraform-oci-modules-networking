# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_core_services" "oci_services" {
}

locals {

  oci_services_details = {
    for oci_service in data.oci_core_services.oci_services.services : length(regexall("services-in-oracle-services-network", oci_service.cidr_block)) > 0 ? "all-services" : length(regexall("objectstorage", oci_service.cidr_block)) > 0 ? "objectstorage" : oci_service.cidr_block => oci_service
  }

  one_dimension_processed_service_gateways = local.one_dimension_processed_vcn_specific_gateways != null ? {
    for flat_servicegw in flatten([
      for vcn_specific_gw_key, vcn_specific_gw_value in local.one_dimension_processed_vcn_specific_gateways :
      vcn_specific_gw_value.service_gateways != null ? length(vcn_specific_gw_value.service_gateways) > 0 ? [
        for servicegw_key, servicegw_value in vcn_specific_gw_value.service_gateways : {
          compartment_id                 = servicegw_value.compartment_id != null ? servicegw_value.compartment_id : vcn_specific_gw_value.category_compartment_id != null ? vcn_specific_gw_value.category_compartment_id : vcn_specific_gw_value.default_compartment_id != null ? vcn_specific_gw_value.default_compartment_id : null
          defined_tags                   = merge(servicegw_value.defined_tags, vcn_specific_gw_value.category_defined_tags, vcn_specific_gw_value.default_defined_tags)
          freeform_tags                  = merge(servicegw_value.freeform_tags, vcn_specific_gw_value.category_freeform_tags, vcn_specific_gw_value.default_freeform_tags)
          display_name                   = servicegw_value.display_name
          route_table_id                 = null
          route_table_key                = servicegw_value.route_table_key
          network_configuration_category = vcn_specific_gw_value.network_configuration_category
          servicegw_key                  = servicegw_key
          vcn_name                       = vcn_specific_gw_value.vcn_name
          vcn_key                        = vcn_specific_gw_value.vcn_key
          vcn_id                         = null
        }
      ] : [] : []
    ]) : flat_servicegw.servicegw_key => flat_servicegw
  } : null

  one_dimension_processed_injected_service_gateways = local.one_dimension_processed_inject_vcn_specific_gateways != null ? {
    for flat_servicegw in flatten([
      for vcn_specific_gw_key, vcn_specific_gw_value in local.one_dimension_processed_inject_vcn_specific_gateways :
      vcn_specific_gw_value.service_gateways != null ? length(vcn_specific_gw_value.service_gateways) > 0 ? [
        for servicegw_key, servicegw_value in vcn_specific_gw_value.service_gateways : {
          compartment_id                 = servicegw_value.compartment_id != null ? servicegw_value.compartment_id : vcn_specific_gw_value.category_compartment_id != null ? vcn_specific_gw_value.category_compartment_id : vcn_specific_gw_value.default_compartment_id != null ? vcn_specific_gw_value.default_compartment_id : null
          defined_tags                   = merge(servicegw_value.defined_tags, vcn_specific_gw_value.category_defined_tags, vcn_specific_gw_value.default_defined_tags)
          freeform_tags                  = merge(servicegw_value.freeform_tags, vcn_specific_gw_value.category_freeform_tags, vcn_specific_gw_value.default_freeform_tags)
          display_name                   = servicegw_value.display_name
          route_table_id                 = servicegw_value.route_table_id
          route_table_key                = servicegw_value.route_table_key
          network_configuration_category = vcn_specific_gw_value.network_configuration_category
          servicegw_key                  = servicegw_key
          vcn_name                       = vcn_specific_gw_value.vcn_name
          vcn_key                        = vcn_specific_gw_value.vcn_key
          vcn_id                         = vcn_specific_gw_value.vcn_id
        }
      ] : [] : []
    ]) : flat_servicegw.servicegw_key => flat_servicegw
  } : null

  provisioned_service_gateways = {
    for sgw-key, sgw_value in oci_core_service_gateway.these : sgw-key => {
      block_traffic                  = sgw_value.block_traffic
      compartment_id                 = sgw_value.compartment_id
      defined_tags                   = sgw_value.defined_tags
      display_name                   = sgw_value.display_name
      freeform_tags                  = sgw_value.freeform_tags
      id                             = sgw_value.id
      route_table_id                 = sgw_value.route_table_id
      route_table_key                = merge(local.one_dimension_processed_service_gateways, local.one_dimension_processed_injected_service_gateways)[sgw-key].route_table_key
      route_table_name               = merge(local.one_dimension_processed_service_gateways, local.one_dimension_processed_injected_service_gateways)[sgw-key].route_table_key != null ? oci_core_route_table.these_gw_attached[merge(local.one_dimension_processed_service_gateways, local.one_dimension_processed_injected_service_gateways)[sgw-key].route_table_key].display_name : null
      services                       = sgw_value.services
      state                          = sgw_value.state
      time_created                   = sgw_value.time_created
      timeouts                       = sgw_value.timeouts
      vcn_id                         = sgw_value.vcn_id
      vcn_name                       = merge(local.one_dimension_processed_service_gateways, local.one_dimension_processed_injected_service_gateways)[sgw-key].vcn_name
      vcn_key                        = merge(local.one_dimension_processed_service_gateways, local.one_dimension_processed_injected_service_gateways)[sgw-key].vcn_key
      network_configuration_category = merge(local.one_dimension_processed_service_gateways, local.one_dimension_processed_injected_service_gateways)[sgw-key].network_configuration_category
      sgw-key                        = sgw-key
    }
  }
}


resource "oci_core_service_gateway" "these" {

  for_each = merge(local.one_dimension_processed_service_gateways, local.one_dimension_processed_injected_service_gateways)
  #Required
  compartment_id = each.value.compartment_id
  services {
    service_id = local.oci_services_details["objectstorage"].id
  }
  vcn_id = each.value.vcn_id != null ? each.value.vcn_id : oci_core_vcn.these[each.value.vcn_key].id

  #Optional
  defined_tags   = each.value.defined_tags
  display_name   = each.value.display_name
  freeform_tags  = each.value.freeform_tags
  route_table_id = each.value.route_table_id != null ? each.value.route_table_id : each.value.route_table_key != null ? oci_core_route_table.these_gw_attached[each.value.route_table_key].id : null
}
