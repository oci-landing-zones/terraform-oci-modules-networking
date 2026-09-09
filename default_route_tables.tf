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
              destination      = rr_value.destination_type != "SERVICE_CIDR_BLOCK" ? rr_value.destination : local.oci_services_details[rr_value.destination].cidr_block
              destination_type = rr_value.destination_type
              network_entity_id = rr_value.network_entity_id != null ? (
                startswith(rr_value.network_entity_id, "ocid1.") ? rr_value.network_entity_id : null
              ) : null
              network_entity_key = rr_value.network_entity_id != null ? (
                startswith(rr_value.network_entity_id, "ocid1.") ? rr_value.network_entity_key : rr_value.network_entity_id
              ) : rr_value.network_entity_key
              description = rr_value.description
            }
          } : {}
          route_tables_route_rules_targets = vcn_value.default_route_table.route_rules != null ? length(vcn_value.default_route_table.route_rules) > 0 ? distinct([
            for rr_value in values(vcn_value.default_route_table.route_rules) :
            rr_value.network_entity_id != null ? (
              startswith(rr_value.network_entity_id, "ocid1.privateip") ? local.route_tables_route_rules_targets.private_ip :
              startswith(rr_value.network_entity_id, "ocid1.") ? local.route_tables_route_rules_targets.ocid_non_private_ip_target :
              lookup(local.route_rule_target_types_by_key, rr_value.network_entity_id, local.route_tables_route_rules_targets.target_not_found)
              ) : rr_value.network_entity_key != null ? (
              lookup(local.route_rule_target_types_by_key, rr_value.network_entity_key, local.route_tables_route_rules_targets.target_not_found)
            ) : local.route_tables_route_rules_targets.null_target
          ]) : [local.route_tables_route_rules_targets.no_route_rules] : [local.route_tables_route_rules_targets.no_route_rules]
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
              destination      = rr_value.destination_type != "SERVICE_CIDR_BLOCK" ? rr_value.destination : local.oci_services_details[rr_value.destination].cidr_block
              destination_type = rr_value.destination_type
              network_entity_id = rr_value.network_entity_id != null ? (
                startswith(rr_value.network_entity_id, "ocid1.") ? rr_value.network_entity_id : null
              ) : null
              network_entity_key = rr_value.network_entity_id != null ? (
                startswith(rr_value.network_entity_id, "ocid1.") ? rr_value.network_entity_key : rr_value.network_entity_id
              ) : rr_value.network_entity_key
              description = rr_value.description
            }
          } : {}
          route_tables_route_rules_targets = vcn_value.default_route_table.route_rules != null ? length(vcn_value.default_route_table.route_rules) > 0 ? distinct([
            for rr_value in values(vcn_value.default_route_table.route_rules) :
            rr_value.network_entity_id != null ? (
              startswith(rr_value.network_entity_id, "ocid1.privateip") ? local.route_tables_route_rules_targets.private_ip :
              startswith(rr_value.network_entity_id, "ocid1.") ? local.route_tables_route_rules_targets.ocid_non_private_ip_target :
              lookup(local.route_rule_target_types_by_key, rr_value.network_entity_id, local.route_tables_route_rules_targets.target_not_found)
              ) : rr_value.network_entity_key != null ? (
              lookup(local.route_rule_target_types_by_key, rr_value.network_entity_key, local.route_tables_route_rules_targets.target_not_found)
            ) : local.route_tables_route_rules_targets.null_target
          ]) : [local.route_tables_route_rules_targets.no_route_rules] : [local.route_tables_route_rules_targets.no_route_rules]
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

  provisioned_igw_natgw_specific_default_route_tables = module.network_completion.provisioned_igw_natgw_specific_default_route_tables


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

  provisioned_sgw_specific_default_route_tables = module.network_completion.provisioned_sgw_specific_default_route_tables

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

  provisioned_lpg_specific_default_route_tables = module.network_completion.provisioned_lpg_specific_default_route_tables

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

  provisioned_drga_specific_default_route_tables = module.network_completion.provisioned_drga_specific_default_route_tables

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


  provisioned_non_gw_specific_remaining_default_route_tables = module.network_completion.provisioned_non_gw_specific_remaining_default_route_tables

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
