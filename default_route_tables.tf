# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

locals {
  //------------------------------- COMMON ALGORITHM LOCALS ELEMENTS ----------------------------------------------------
  one_dimension_processed_default_route_tables = local.one_dimension_processed_vcns != null ? {
    for flat_default_route_tables in flatten([
      for vcn_key, vcn_value in local.one_dimension_processed_vcns : [
        {
          compartment_id                 = vcn_value.default_route_table.compartment_id != null ? vcn_value.default_route_table.compartment_id : vcn_value.category_compartment_id != null ? vcn_value.category_compartment_id : vcn_value.default_compartment_id != null ? vcn_value.default_compartment_id : null
          default_compartment_id         = vcn_value.default_compartment_id
          category_compartment_id        = vcn_value.category_compartment_id
          defined_tags                   = merge(vcn_value.default_route_table.defined_tags, vcn_value.category_defined_tags, vcn_value.default_defined_tags)
          default_defined_tags           = vcn_value.default_defined_tags
          category_defined_tags          = vcn_value.category_defined_tags
          freeform_tags                  = merge(vcn_value.default_route_table.freeform_tags, vcn_value.category_freeform_tags, vcn_value.default_freeform_tags)
          category_freeform_tags         = vcn_value.category_freeform_tags
          default_freeform_tags          = vcn_value.default_freeform_tags
          display_name                   = vcn_value.default_route_table.display_name
          network_configuration_category = vcn_value.network_configuration_category
          vcn_key                        = vcn_key
          vcn_id                         = oci_core_vcn.these[vcn_key].id
          vcn_name                       = vcn_value.display_name
          default_route_table_key        = "CUSTOM-DEFAULT-ROUTE-TABLE-${vcn_key}"
          route_rules = vcn_value.default_route_table.route_rules != null ? {
            for rr_key, rr_value in vcn_value.default_route_table.route_rules : rr_key => {
              destination        = rr_value.destination_type != "SERVICE_CIDR_BLOCK" ? rr_value.destination : local.oci_services_details[rr_value.destination].cidr_block
              destination_type   = rr_value.destination_type
              network_entity_id  = rr_value.network_entity_id
              network_entity_key = rr_value.network_entity_key
              description        = rr_value.description
            }
          } : {}
          route_tables_route_rules_targets = vcn_value.default_route_table.route_rules != null ? length(vcn_value.default_route_table.route_rules) > 0 ? distinct(flatten([
            [for rr_key, rr_value in vcn_value.default_route_table.route_rules : local.route_tables_route_rules_targets.igw if contains(keys(local.merged_one_dimension_processed_internet_gateways), coalesce(rr_value.network_entity_key, " "))],
            [for rr_key, rr_value in vcn_value.default_route_table.route_rules : local.route_tables_route_rules_targets.natgw if contains(keys(local.merged_one_dimension_processed_nat_gateways), coalesce(rr_value.network_entity_key, " "))],
            [for rr_key, rr_value in vcn_value.default_route_table.route_rules : local.route_tables_route_rules_targets.sgw if contains(keys(local.merged_one_dimension_processed_service_gateways), coalesce(rr_value.network_entity_key, " "))],
            [for rr_key, rr_value in vcn_value.default_route_table.route_rules : local.route_tables_route_rules_targets.drg if contains(keys(merge(local.one_dimension_dynamic_routing_gateways, local.one_dimension_inject_into_existing_drgs)), coalesce(rr_value.network_entity_key, " "))],
            [for rr_key, rr_value in vcn_value.default_route_table.route_rules : local.route_tables_route_rules_targets.lpg if contains(keys(local.merged_one_dimension_processed_local_peering_gateways), coalesce(rr_value.network_entity_key, " "))],
            [for rr_key, rr_value in vcn_value.default_route_table.route_rules : local.route_tables_route_rules_targets.private_ip if length(regexall("ocid1.privateip", coalesce(rr_value.network_entity_id, " "))) > 0],
            [for rr_key, rr_value in vcn_value.default_route_table.route_rules : local.route_tables_route_rules_targets.null_target if rr_value.network_entity_id == null && rr_value.network_entity_key == null],
            [for rr_key, rr_value in vcn_value.default_route_table.route_rules : local.route_tables_route_rules_targets.ocid_non_private_ip_target if rr_value.network_entity_key == null && rr_value.network_entity_id != null && length(regexall("ocid1.privateip", coalesce(rr_value.network_entity_id, " "))) <= 0],
            [for rr_key, rr_value in vcn_value.default_route_table.route_rules : local.route_tables_route_rules_targets.target_not_found if !contains(keys(local.merged_one_dimension_processed_internet_gateways), coalesce(rr_value.network_entity_key, " ")) && !contains(keys(local.merged_one_dimension_processed_nat_gateways), coalesce(rr_value.network_entity_key, " ")) && !contains(keys(local.merged_one_dimension_processed_service_gateways), coalesce(rr_value.network_entity_key, " ")) && !contains(keys(merge(local.one_dimension_dynamic_routing_gateways, local.one_dimension_inject_into_existing_drgs)), coalesce(rr_value.network_entity_key, " ")) && !contains(keys(local.merged_one_dimension_processed_local_peering_gateways), coalesce(rr_value.network_entity_key, " ")) && rr_value.network_entity_id == null && rr_value.network_entity_key != null]
          ])) : [local.route_tables_route_rules_targets.no_route_rules] : [local.route_tables_route_rules_targets.no_route_rules]
        }
      ] if vcn_value.default_route_table != null
    ]) : flat_default_route_tables.default_route_table_key => flat_default_route_tables
  } : null

  one_dimension_processed_injected_default_route_tables = local.one_dimension_processed_existing_vcns != null ? {
    for flat_default_route_tables in flatten([
      for vcn_key, vcn_value in local.one_dimension_processed_existing_vcns : [
        {
          compartment_id                 = vcn_value.default_route_table.compartment_id != null ? vcn_value.default_route_table.compartment_id : vcn_value.category_compartment_id != null ? vcn_value.category_compartment_id : vcn_value.default_compartment_id != null ? vcn_value.default_compartment_id : null
          default_compartment_id         = vcn_value.default_compartment_id
          category_compartment_id        = vcn_value.category_compartment_id
          defined_tags                   = merge(vcn_value.default_route_table.defined_tags, vcn_value.category_defined_tags, vcn_value.default_defined_tags)
          default_defined_tags           = vcn_value.default_defined_tags
          category_defined_tags          = vcn_value.category_defined_tags
          freeform_tags                  = merge(vcn_value.default_route_table.freeform_tags, vcn_value.category_freeform_tags, vcn_value.default_freeform_tags)
          category_freeform_tags         = vcn_value.category_freeform_tags
          default_freeform_tags          = vcn_value.default_freeform_tags
          display_name                   = vcn_value.default_route_table.display_name
          network_configuration_category = vcn_value.network_configuration_category
          vcn_key                        = vcn_key
          vcn_id                         = vcn_value.vcn_id
          vcn_name                       = vcn_value.vcn_name
          default_route_table_key        = "CUSTOM-DEFAULT-ROUTE-TABLE-${vcn_key}"
          route_rules = vcn_value.default_route_table.route_rules != null ? {
            for rr_key, rr_value in vcn_value.default_route_table.route_rules : rr_key => {
              destination        = rr_value.destination_type != "SERVICE_CIDR_BLOCK" ? rr_value.destination : local.oci_services_details[rr_value.destination].cidr_block
              destination_type   = rr_value.destination_type
              network_entity_id  = rr_value.network_entity_id
              network_entity_key = rr_value.network_entity_key
              description        = rr_value.description
            }
          } : {}
          route_tables_route_rules_targets = vcn_value.default_route_table.route_rules != null ? length(vcn_value.default_route_table.route_rules) > 0 ? distinct(flatten([
            [for rr_key, rr_value in vcn_value.default_route_table.route_rules : local.route_tables_route_rules_targets.igw if contains(keys(local.merged_one_dimension_processed_internet_gateways), coalesce(rr_value.network_entity_key, " "))],
            [for rr_key, rr_value in vcn_value.default_route_table.route_rules : local.route_tables_route_rules_targets.natgw if contains(keys(local.merged_one_dimension_processed_nat_gateways), coalesce(rr_value.network_entity_key, " "))],
            [for rr_key, rr_value in vcn_value.default_route_table.route_rules : local.route_tables_route_rules_targets.sgw if contains(keys(local.merged_one_dimension_processed_service_gateways), coalesce(rr_value.network_entity_key, " "))],
            [for rr_key, rr_value in vcn_value.default_route_table.route_rules : local.route_tables_route_rules_targets.drg if contains(keys(merge(local.one_dimension_dynamic_routing_gateways, local.one_dimension_inject_into_existing_drgs)), coalesce(rr_value.network_entity_key, " "))],
            [for rr_key, rr_value in vcn_value.default_route_table.route_rules : local.route_tables_route_rules_targets.lpg if contains(keys(local.merged_one_dimension_processed_local_peering_gateways), coalesce(rr_value.network_entity_key, " "))],
            [for rr_key, rr_value in vcn_value.default_route_table.route_rules : local.route_tables_route_rules_targets.private_ip if length(regexall("ocid1.privateip", coalesce(rr_value.network_entity_id, " "))) > 0],
            [for rr_key, rr_value in vcn_value.default_route_table.route_rules : local.route_tables_route_rules_targets.null_target if rr_value.network_entity_id == null && rr_value.network_entity_key == null],
            [for rr_key, rr_value in vcn_value.default_route_table.route_rules : local.route_tables_route_rules_targets.ocid_non_private_ip_target if rr_value.network_entity_key == null && rr_value.network_entity_id != null && length(regexall("ocid1.privateip", coalesce(rr_value.network_entity_id, " "))) <= 0],
            [for rr_key, rr_value in vcn_value.default_route_table.route_rules : local.route_tables_route_rules_targets.target_not_found if !contains(keys(local.merged_one_dimension_processed_internet_gateways), coalesce(rr_value.network_entity_key, " ")) && !contains(keys(local.merged_one_dimension_processed_nat_gateways), coalesce(rr_value.network_entity_key, " ")) && !contains(keys(local.merged_one_dimension_processed_service_gateways), coalesce(rr_value.network_entity_key, " ")) && !contains(keys(merge(local.one_dimension_dynamic_routing_gateways, local.one_dimension_inject_into_existing_drgs)), coalesce(rr_value.network_entity_key, " ")) && !contains(keys(local.merged_one_dimension_processed_local_peering_gateways), coalesce(rr_value.network_entity_key, " ")) && rr_value.network_entity_id == null && rr_value.network_entity_key != null]
          ])) : [local.route_tables_route_rules_targets.no_route_rules] : [local.route_tables_route_rules_targets.no_route_rules]
        }
      ] if vcn_value.default_route_table != null
    ]) : flat_default_route_tables.default_route_table_key => flat_default_route_tables
  } : null

  //merging new VCNs defined route tables with existing VCNs defined route tables into a single map
  merged_one_dimension_processed_default_route_tables = merge(local.one_dimension_processed_default_route_tables, local.one_dimension_processed_injected_default_route_tables)

  //----------------------------------------------------------------------------------------------------------------------------


  //------------------------------- IGW and NATGW ALGORITHM LOCALS ELEMENTS ----------------------------------------------------


  // Search for all the route tables that have route rules that satisfy ANY of the criterias for being attached to a IGW/NAT-GW considering their route rules target   
  igw_natgw_attachable_specific_default_route_tables = local.merged_one_dimension_processed_default_route_tables != null ? length(local.merged_one_dimension_processed_default_route_tables) > 0 ? {
    for route_table_key, route_table_value in local.merged_one_dimension_processed_default_route_tables : route_table_key => route_table_value if length(setsubtract(route_table_value.route_tables_route_rules_targets, local.natgw_igw_attachable_specific_route_tables_route_rules_targets)) == 0
  } : null : null

  provisioned_igw_natgw_specific_default_route_tables = {
    for route_table_key, route_value in oci_core_default_route_table.igw_natgw_specific_default_route_tables : route_table_key => {
      compartment_id                 = route_value.compartment_id
      defined_tags                   = route_value.defined_tags
      display_name                   = route_value.display_name
      freeform_tags                  = route_value.freeform_tags
      id                             = route_value.id
      route_rules                    = route_value.route_rules
      state                          = route_value.state
      time_created                   = route_value.time_created
      timeouts                       = route_value.timeouts
      vcn_id                         = local.igw_natgw_attachable_specific_default_route_tables[route_table_key].vcn_id
      vcn_key                        = local.igw_natgw_attachable_specific_default_route_tables[route_table_key].vcn_key
      vcn_name                       = local.igw_natgw_attachable_specific_default_route_tables[route_table_key].vcn_name
      network_configuration_category = local.igw_natgw_attachable_specific_default_route_tables[route_table_key].network_configuration_category
      route_table_key                = route_table_key
    }
  }


  //------------------------------------------------------------------------------------------------------------------

  //------------------------------- SGW ALGORITHM LOCALS ELEMENTS ----------------------------------------------------

  // Search for all the sgw specific route tables that have route rules that satisfy:
  //      1. CONDITION 1
  //            1.1. have at least one Route rule targeting a DRG  
  //                 AND
  //            1.2. if any other route rules their targets should be part of the follwing list [natgw_igw_attachable_specific_route_tables_route_rules_targets]
  //
  //         OR
  //
  //     2. CONDITION 2 
  //         all the route rules are targeting the DRG
  //        
  sgw_attachable_specific_default_route_tables = local.merged_one_dimension_processed_default_route_tables != null ? length(local.merged_one_dimension_processed_default_route_tables) > 0 ? {
    for route_table_key, route_table_value in local.merged_one_dimension_processed_default_route_tables : route_table_key => route_table_value if(
      (
        length(
          setsubtract(
            setsubtract(
              route_table_value.route_tables_route_rules_targets,
              [local.route_tables_route_rules_targets.drg]
            ),
            local.natgw_igw_attachable_specific_route_tables_route_rules_targets
          )
        ) == 0 && contains(route_table_value.route_tables_route_rules_targets, local.route_tables_route_rules_targets.drg)
        ) || (
      length(route_table_value.route_tables_route_rules_targets) == 1 && contains(route_table_value.route_tables_route_rules_targets, local.route_tables_route_rules_targets.drg))
    )
  } : null : null

  provisioned_sgw_specific_default_route_tables = {
    for route_table_key, route_value in oci_core_default_route_table.sgw_specific_default_route_tables : route_table_key => {
      compartment_id                 = route_value.compartment_id
      defined_tags                   = route_value.defined_tags
      display_name                   = route_value.display_name
      freeform_tags                  = route_value.freeform_tags
      id                             = route_value.id
      route_rules                    = route_value.route_rules
      state                          = route_value.state
      time_created                   = route_value.time_created
      timeouts                       = route_value.timeouts
      vcn_id                         = local.sgw_attachable_specific_default_route_tables[route_table_key].vcn_id
      vcn_key                        = local.sgw_attachable_specific_default_route_tables[route_table_key].vcn_key
      vcn_name                       = local.sgw_attachable_specific_default_route_tables[route_table_key].vcn_name
      network_configuration_category = local.sgw_attachable_specific_default_route_tables[route_table_key].network_configuration_category
      route_table_key                = route_table_key
    }
  }

  //------------------------------------------------------------------------------------------------------------------

  //------------------------------- LPG Attachment ALGORITHM LOCALS ELEMENTS -----------------------------------------

  // Search for all the lpg specific route tables that have route rules that satisfy:
  //      1. CONDITION 1
  //            1.1. have at least one Route rule targeting a SGW  
  //                 AND
  //            1.2. if any other route rules their targets should be part of the folling list [igw_natgw_attachable_specific_default_route_tables_route_rules_targets]
  //
  //         OR
  //
  //     2. CONDITION 2 
  //         all the route rules are targeting the SGW
  //        
  lpg_attachable_specific_default_route_tables = local.merged_one_dimension_processed_default_route_tables != null ? length(local.merged_one_dimension_processed_default_route_tables) > 0 ? {
    for route_table_key, route_table_value in local.merged_one_dimension_processed_default_route_tables : route_table_key => route_table_value if(
      (
        length(
          setsubtract(
            setsubtract(
              route_table_value.route_tables_route_rules_targets,
              [local.route_tables_route_rules_targets.sgw]
            ),
            local.natgw_igw_attachable_specific_route_tables_route_rules_targets
          )
        ) == 0 && contains(route_table_value.route_tables_route_rules_targets, local.route_tables_route_rules_targets.sgw)
        ) || (
      length(route_table_value.route_tables_route_rules_targets) == 1 && contains(route_table_value.route_tables_route_rules_targets, local.route_tables_route_rules_targets.sgw))
    )
  } : null : null

  provisioned_lpg_specific_default_route_tables = {
    for route_table_key, route_value in oci_core_default_route_table.lpg_specific_default_route_tables : route_table_key => {
      compartment_id                 = route_value.compartment_id
      defined_tags                   = route_value.defined_tags
      display_name                   = route_value.display_name
      freeform_tags                  = route_value.freeform_tags
      id                             = route_value.id
      route_rules                    = route_value.route_rules
      state                          = route_value.state
      time_created                   = route_value.time_created
      timeouts                       = route_value.timeouts
      vcn_id                         = local.lpg_attachable_specific_default_route_tables[route_table_key].vcn_id
      vcn_key                        = local.lpg_attachable_specific_default_route_tables[route_table_key].vcn_key
      vcn_name                       = local.lpg_attachable_specific_default_route_tables[route_table_key].vcn_name
      network_configuration_category = local.lpg_attachable_specific_default_route_tables[route_table_key].network_configuration_category
      route_table_key                = route_table_key
    }
  }

  //------------------------------------------------------------------------------------------------------------------

  //------------------------------- DRG Attachment ALGORITHM LOCALS ELEMENTS -----------------------------------------

  // Search for all the lpg specific route tables that have route rules that satisfy:
  //      1. CONDITION 1
  //            1.1. have at least one Route rule targeting a LPG  
  //                 AND
  //            1.2. if any other route rules their targets should be part of the folling list [lpg_attachable_specific_default_route_tables_route_rules_targets]
  //
  //         OR
  //
  //     2. CONDITION 2 
  //         all the route rules are targeting the LPG
  //        
  drga_attachable_specific_default_route_tables = local.merged_one_dimension_processed_default_route_tables != null ? length(local.merged_one_dimension_processed_default_route_tables) > 0 ? {
    for route_table_key, route_table_value in local.merged_one_dimension_processed_default_route_tables : route_table_key => route_table_value if(
      (
        length(
          setsubtract(
            setsubtract(
              route_table_value.route_tables_route_rules_targets,
              [local.route_tables_route_rules_targets.lpg]
            ),
            local.lpg_attachable_specific_route_tables_route_rules_targets
          )
        ) == 0 && contains(route_table_value.route_tables_route_rules_targets, local.route_tables_route_rules_targets.lpg)
        ) || (
      length(route_table_value.route_tables_route_rules_targets) == 1 && contains(route_table_value.route_tables_route_rules_targets, local.route_tables_route_rules_targets.lpg))
    )
  } : null : null

  provisioned_drga_specific_default_route_tables = {
    for route_table_key, route_value in oci_core_default_route_table.drga_specific_default_route_tables : route_table_key => {
      compartment_id                 = route_value.compartment_id
      defined_tags                   = route_value.defined_tags
      display_name                   = route_value.display_name
      freeform_tags                  = route_value.freeform_tags
      id                             = route_value.id
      route_rules                    = route_value.route_rules
      state                          = route_value.state
      time_created                   = route_value.time_created
      timeouts                       = route_value.timeouts
      vcn_id                         = local.drga_attachable_specific_default_route_tables[route_table_key].vcn_id
      vcn_key                        = local.drga_attachable_specific_default_route_tables[route_table_key].vcn_key
      vcn_name                       = local.drga_attachable_specific_default_route_tables[route_table_key].vcn_name
      network_configuration_category = local.drga_attachable_specific_default_route_tables[route_table_key].network_configuration_category
      route_table_key                = route_table_key
    }
  }

  //------------------------------------------------------------------------------------------------------------------

  //------------------------------- Remaining non-specific RTs ALGORITHM LOCALS ELEMENTS -----------------------------------------

  // Search for the route tables that do not fit the criterias for for specific IGW, NATGW, SGW, DRG Attachment and LPG specific attachamble RTs
  // Those RTs will be the remaing ones after the filtering above is applied
  non_gw_specific_remaining_default_route_tables = local.merged_one_dimension_processed_default_route_tables != null ? length(local.merged_one_dimension_processed_default_route_tables) > 0 ? {
    for route_table_key, route_table_value in local.merged_one_dimension_processed_default_route_tables : route_table_key => route_table_value if !contains(
      keys(
        merge(
          local.igw_natgw_attachable_specific_default_route_tables,
          local.sgw_attachable_specific_default_route_tables,
          local.drga_attachable_specific_default_route_tables,
          local.lpg_attachable_specific_default_route_tables
        )
      ),
      route_table_key
    )
  } : null : null


  provisioned_non_gw_specific_remaining_default_route_tables = {
    for route_table_key, route_value in oci_core_default_route_table.non_gw_specific_remaining_default_route_tables : route_table_key => {
      compartment_id                 = route_value.compartment_id
      defined_tags                   = route_value.defined_tags
      display_name                   = route_value.display_name
      freeform_tags                  = route_value.freeform_tags
      id                             = route_value.id
      route_rules                    = route_value.route_rules
      state                          = route_value.state
      time_created                   = route_value.time_created
      timeouts                       = route_value.timeouts
      vcn_id                         = local.non_gw_specific_remaining_default_route_tables[route_table_key].vcn_id
      vcn_key                        = local.non_gw_specific_remaining_default_route_tables[route_table_key].vcn_key
      vcn_name                       = local.non_gw_specific_remaining_default_route_tables[route_table_key].vcn_name
      network_configuration_category = local.non_gw_specific_remaining_default_route_tables[route_table_key].network_configuration_category
      route_table_key                = route_table_key
    }
  }

  //------------------------------------------------------------------------------------------------------------------

  /*
  provisioned_route_tables_attachments = {
    for rta_key, rta_value in oci_core_route_table_attachment.these : rta_key => {
      id              = rta_value.id
      route_table_id  = rta_value.route_table_id
      route_table_key = local.merged_one_dimension_processed_subnets[rta_key].route_table_key
      route_table_name = local.merged_one_dimension_processed_subnets[rta_key].route_table_key != null ? merge(
        local.provisioned_non_gw_specific_remaining_default_route_tables,
        local.provisioned_drga_specific_default_route_tables,
        local.provisioned_lpg_specific_default_route_tables,
        local.provisioned_sgw_specific_default_route_tables,
        local.provisioned_igw_natgw_specific_default_route_tables
      )[local.merged_one_dimension_processed_subnets[rta_key].route_table_key].display_name : null
      subnet_id                      = rta_value.subnet_id
      subnet_key                     = rta_key
      subnet_name                    = can(local.provisioned_subnets[rta_key].display_name) ? local.provisioned_subnets[rta_key].display_name : null
      timeouts                       = rta_value.timeouts
      rta_key                        = rta_key
      vcn_key                        = local.merged_one_dimension_processed_subnets[rta_key].vcn_key
      vcn_name                       = local.merged_one_dimension_processed_subnets[rta_key].vcn_name
      network_configuration_category = local.merged_one_dimension_processed_subnets[rta_key].network_configuration_category
    }
  }*/
}


### Specific IGW/NAT GW Route tables
resource "oci_core_default_route_table" "igw_natgw_specific_default_route_tables" {
  for_each = local.igw_natgw_attachable_specific_default_route_tables != null ? local.igw_natgw_attachable_specific_default_route_tables : {}

  display_name               = each.value.display_name
  manage_default_resource_id = merge(local.provisioned_vcns, local.one_dimension_processed_existing_vcns)[each.value.vcn_key].default_route_table_id
  compartment_id             = each.value.compartment_id
  defined_tags               = each.value.defined_tags
  freeform_tags              = each.value.freeform_tags
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
      network_entity_id = rule.value.network_entity_id != null ? rule.value.network_entity_id : rule.value.network_entity_key != null ? local.route_rules_targets_for_IGW_NATGW_specific_RTs[rule.value.network_entity_key].id : null
      description       = rule.value.description
    }
  }
}

### Specific SGW Route tables
resource "oci_core_default_route_table" "sgw_specific_default_route_tables" {
  for_each = local.sgw_attachable_specific_default_route_tables != null ? local.sgw_attachable_specific_default_route_tables : {}

  display_name               = each.value.display_name
  manage_default_resource_id = merge(local.provisioned_vcns, local.one_dimension_processed_existing_vcns)[each.value.vcn_key].default_route_table_id
  compartment_id             = each.value.compartment_id
  defined_tags               = each.value.defined_tags
  freeform_tags              = each.value.freeform_tags
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
      network_entity_id = rule.value.network_entity_id != null ? rule.value.network_entity_id : rule.value.network_entity_key != null ? local.route_rules_targets_for_SGW_specific_RTs[rule.value.network_entity_key].id : null
      description       = rule.value.description
    }
  }
}

### Specific LPG Route tables
resource "oci_core_default_route_table" "lpg_specific_default_route_tables" {
  for_each = local.lpg_attachable_specific_default_route_tables != null ? local.lpg_attachable_specific_default_route_tables : {}

  display_name               = each.value.display_name
  manage_default_resource_id = merge(local.provisioned_vcns, local.one_dimension_processed_existing_vcns)[each.value.vcn_key].default_route_table_id
  compartment_id             = each.value.compartment_id
  defined_tags               = each.value.defined_tags
  freeform_tags              = each.value.freeform_tags
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
      network_entity_id = rule.value.network_entity_id != null ? rule.value.network_entity_id : rule.value.network_entity_key != null ? local.route_rules_targets_for_LPG_specific_RTs[rule.value.network_entity_key].id : null
      description       = rule.value.description
    }
  }
}

### Specific DRGA Route tables
resource "oci_core_default_route_table" "drga_specific_default_route_tables" {
  for_each = local.drga_attachable_specific_default_route_tables != null ? local.drga_attachable_specific_default_route_tables : {}

  display_name               = each.value.display_name
  manage_default_resource_id = merge(local.provisioned_vcns, local.one_dimension_processed_existing_vcns)[each.value.vcn_key].default_route_table_id
  compartment_id             = each.value.compartment_id
  defined_tags               = each.value.defined_tags
  freeform_tags              = each.value.freeform_tags
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
      network_entity_id = rule.value.network_entity_id != null ? rule.value.network_entity_id : rule.value.network_entity_key != null ? local.route_rules_targets_for_LPG_specific_RTs[rule.value.network_entity_key].id : null
      description       = rule.value.description
    }
  }
}

### non_gw_specific_remaining Route tables
resource "oci_core_default_route_table" "non_gw_specific_remaining_default_route_tables" {

  for_each = local.non_gw_specific_remaining_default_route_tables != null ? local.non_gw_specific_remaining_default_route_tables : {}

  display_name               = each.value.display_name
  manage_default_resource_id = merge(local.provisioned_vcns, local.one_dimension_processed_existing_vcns)[each.value.vcn_key].default_route_table_id
  compartment_id             = each.value.compartment_id
  defined_tags               = each.value.defined_tags
  freeform_tags              = merge(local.cislz_module_tag,each.value.freeform_tags)
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
      network_entity_id = rule.value.network_entity_id != null ? rule.value.network_entity_id : rule.value.network_entity_key != null ? local.all_route_rules_targets[rule.value.network_entity_key].id : null
      description       = rule.value.description
    }
  }
}
