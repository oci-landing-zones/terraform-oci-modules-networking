# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Tue Dec 19 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

data "oci_core_services" "oci_services" {
  count = var.network_configuration != null ? 1 : 0
}

locals {

  // Search for available services by the following keys:
  //   - all-services
  //   - objectstorage
  oci_services_details = {
    for oci_service in length(data.oci_core_services.oci_services) > 0 ? data.oci_core_services.oci_services[0].services : [] : length(regexall("services-in-oracle-services-network", oci_service.cidr_block)) > 0 ? "all-services" : length(regexall("objectstorage", oci_service.cidr_block)) > 0 ? "objectstorage" : oci_service.cidr_block => oci_service
  }

  one_dimension_processed_service_gateways = local.one_dimension_processed_vcn_specific_gateways != null ? {
    for flat_servicegw in flatten([
      for vcn_specific_gw_key, vcn_specific_gw_value in local.one_dimension_processed_vcn_specific_gateways :
      vcn_specific_gw_value.service_gateways != null ? length(vcn_specific_gw_value.service_gateways) > 0 ? [
        for servicegw_key, servicegw_value in vcn_specific_gw_value.service_gateways : {
          compartment_id                 = servicegw_value.compartment_id != null ? servicegw_value.compartment_id : vcn_specific_gw_value.category_compartment_id != null ? vcn_specific_gw_value.category_compartment_id : vcn_specific_gw_value.default_compartment_id != null ? vcn_specific_gw_value.default_compartment_id : null
          services_key                   = local.oci_services_details[servicegw_value.services].id
          services                       = servicegw_value.services
          defined_tags                   = merge(servicegw_value.defined_tags, vcn_specific_gw_value.category_defined_tags, vcn_specific_gw_value.default_defined_tags)
          freeform_tags                  = merge(servicegw_value.freeform_tags, vcn_specific_gw_value.category_freeform_tags, vcn_specific_gw_value.default_freeform_tags)
          display_name                   = servicegw_value.display_name
          route_table_id                 = null
          route_table_key                = servicegw_value.route_table_key
          network_configuration_category = vcn_specific_gw_value.network_configuration_category
          servicegw_key                  = servicegw_key
          vcn_name                       = vcn_specific_gw_value.vcn_name
          vcn_key                        = vcn_specific_gw_value.vcn_key
          vcn_id                         = local.provisioned_vcns[vcn_specific_gw_value.vcn_key].id
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
          services_key                   = local.oci_services_details[servicegw_value.services].id
          services                       = servicegw_value.services
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


  //merging new VCNs defined SGWs with existing VCNs defined SGWs into a single map
  merged_one_dimension_processed_service_gateways = merge(local.one_dimension_processed_service_gateways, local.one_dimension_processed_injected_service_gateways)

  provisioned_service_gateways = {
    for sgw_key, sgw_value in oci_core_service_gateway.these : sgw_key => {
      block_traffic  = sgw_value.block_traffic
      compartment_id = sgw_value.compartment_id
      defined_tags   = sgw_value.defined_tags
      display_name   = sgw_value.display_name
      freeform_tags  = sgw_value.freeform_tags
      id             = sgw_value.id
      route_table_id = sgw_value.route_table_id
      route_table_key = sgw_value.route_table_id == merge(
        local.provisioned_vcns,
        local.one_dimension_processed_existing_vcns
      )[local.merged_one_dimension_processed_service_gateways[sgw_key].vcn_key].default_route_table_id ? "default_route_table" : local.merged_one_dimension_processed_service_gateways[sgw_key].route_table_key == null ? local.merged_one_dimension_processed_service_gateways[sgw_key].route_table_id != null ? "CANNOT BE DETERMINED AS NOT CREATED BY THIS AUTOMATION" : null : local.merged_one_dimension_processed_service_gateways[sgw_key].route_table_key
      route_table_name = sgw_value.route_table_id == merge(
        local.provisioned_vcns,
        local.one_dimension_processed_existing_vcns
        )[local.merged_one_dimension_processed_service_gateways[sgw_key].vcn_key].default_route_table_id ? "default_route_table" : local.merged_one_dimension_processed_service_gateways[sgw_key].route_table_key == null ? local.merged_one_dimension_processed_service_gateways[sgw_key].route_table_id != null ? "CANNOT BE DETERMINED AS NOT CREATED BY THIS AUTOMATION" : null : can(
        merge(
          local.provisioned_igw_natgw_specific_route_tables,
          local.provisioned_sgw_specific_route_tables
        )[local.merged_one_dimension_processed_service_gateways[sgw_key].route_table_key].display_name) ? merge(
        local.provisioned_igw_natgw_specific_route_tables,
        local.provisioned_sgw_specific_route_tables
      )[local.merged_one_dimension_processed_service_gateways[sgw_key].route_table_key].display_name : "CANNOT BE DETERMINED AS NOT CREATED BY THIS AUTOMATION"
      services                       = local.merged_one_dimension_processed_service_gateways[sgw_key].services
      services_details               = sgw_value.services
      state                          = sgw_value.state
      time_created                   = sgw_value.time_created
      timeouts                       = sgw_value.timeouts
      vcn_id                         = sgw_value.vcn_id
      vcn_name                       = local.merged_one_dimension_processed_service_gateways[sgw_key].vcn_name
      vcn_key                        = local.merged_one_dimension_processed_service_gateways[sgw_key].vcn_key
      network_configuration_category = local.merged_one_dimension_processed_service_gateways[sgw_key].network_configuration_category
      sgw_key                        = sgw_key
    }
  }
}

resource "oci_core_service_gateway" "these" {

  for_each = local.merged_one_dimension_processed_service_gateways
  #Required
  compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
  services {
    service_id = each.value.services_key
  }
  vcn_id = each.value.vcn_id

  #Optional
  defined_tags  = each.value.defined_tags
  display_name  = each.value.display_name
  freeform_tags = merge(local.cislz_module_tag, each.value.freeform_tags)
  // Searching for the id based on the key in the:
  //       - IGW and NAT GW specific route tables: local.provisioned_igw_natgw_specific_route_tables
  //       - SGW specific route tables: local.provisioned_sgw_specific_route_tables + the default route table
  route_table_id = each.value.route_table_id != null ? each.value.route_table_id : each.value.route_table_key != null ? merge(
    {
      for rt_key, rt_value in merge(
        local.provisioned_igw_natgw_specific_route_tables,
        local.provisioned_sgw_specific_route_tables
        ) : rt_key => {
        id = rt_value.id
      }
    },
    {
      "default_route_table" = {
        id = oci_core_vcn.these[each.value.vcn_key].default_route_table_id
      }
    }
  )[each.value.route_table_key].id : null
}
