# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

/* 
------------------------------- Describing the complex algorithm for avoiding graph cycles with route tables --------------------------------------------

1. Problem Description

  - When creating all defined route tables under a single "oci_core_route_table" resources, practically we'll get one single node in the TF graph - let's name this RTS-Node 
  - Route Tables can be attached to the following elemets: IGW, NAT-GW, SGW, DRG, LPG, SUBNET. We'll be creating those under different resources getting 6 different nodes in the graph named as follows:
    IGWS-Node, NATGWS-Node, SGWS-Node, DRGS-Node, LPGS-Node, SUBNETS-Node
  - BUT - The route table route rules have the option to target the 6 nodes described above, creating the possibility for cycles in the graph.
  - Terraform first builds the graph and with all the potential options - calling that POTENTIAL GRAPH.
  - After POTENTIAL GRAPH is build the actual desired configuration is evaluated.
  - POTENTIAL GRAPH is checked for cycles. Cycles are not supported in the POTENTIAL GRAPH and they are erorred out at terraform plan - as cycle graph errors.
  - One route table can be attached to multiple elements - the solution should not duplicate route tables

2. Solution

  - In the same way as terraform graph do not support cycles, in networking cycles or loops are not supported as well - and if one tries to configure those in OCI. OCI will catch those
and report them as errors
  - To solve our problem described above we need not to rely anymore on OCI to catch those routing cycles/loops. We need to implement those checks in terraform.
  - The main impact of implementing those checks will be:
       - we'll split the the single RTS-Node into different nodes(5) and each of those nodes will NOT be in a cycle graph relation(referencing one another) with any of the 6 RT attachable entities nodes:
         IGWS-Node, NATGWS-Node, SGWS-Node, DRGS-Node, LPGS-Node, SUBNETS-Node
       - The split criteria will follow the exact logic of OCI components without adding any limitations in OCI route rules configuration and functionality

2.1. Describing the RTS-Node splitting in 5 nodes:
      - RT-NODE-1-IGW-NATGW-Atachable-RTs:
          - This will contain all the RTs that are attachable to IGWs or NATGWs
          - The route rules of these route tables will only be able to target: private_ips, OCIDs(outside private IPs) or no route rules in the route table.
      - RT-NODE-2-SGW-Atachable-RTs:
          - This will contain not all* but specific RTs that are attachable to SGWs - specific SGWs route tables
          - The route rules of these route tables will only be able to target: 
                  - just DRGS 
                      OR
                  - DRGS AND any of the available targets for NODE 1 - IGW-NATGW-Atachable-RTs
      - RT-NODE-3-LPG-Atachable-RTs:
          - This will contain not all* but specific RTs that are attachable to LPGs - specific LPGs route tables
          - The route rules of these route tables will only be able to target: 
                  - just SGWS 
                      OR
                  - SGWS AND any of the available targets for NODE 1 - IGW-NATGW-Atachable-RTs
      - RT-NODE-4-DRGA-Atachable-RTs:
          - This will contain not all* but specific RTs that are attachable to LPGs - specific LPGs route tables
          - The route rules of these route tables will only be able to target: 
                  - just LPGS 
                      OR
                  - LPGS AND any of the available targets for NODE 3 - LPG-Atachable-RTs:
      - RT-NODE-5-REMAINING-RTS: The remaining RTs that do not fit into the criteria for NODES 1-4.
                 - These will only be attachable to SUBNETS

2.2. Describing the relation in between 6 RT attachable entities nodes and the the 5 RTS-Node splitted nodes:

     -  6 RT attachable entities nodes
          - AT-NODE-1-IGWS and AT-NODE-1-NATGW
                - can refer: RT-NODE-1-IGW-NATGW-Atachable-RTs route tables
                - can be reffered by: RT-NODE-5-REMAINING-RTS route rules
          - AT-NODE-2-SGW:
                - can refer: RT-NODE-1-IGW-NATGW-Atachable-RTs and RT-NODE-2-SGW-Atachable-RTs route tables
                - can be reffered by: RT-NODE-2-LPG-Atachable-RTs and RT-NODE-2-DRGA-Atachable-RTs route rules
          - AT-NODE-3-LPG:
                - can refer: RT-NODE-1-IGW-NATGW-Atachable-RTs and RT-NODE-2-LPG-Atachable-RTs route tables
                - can be reffered by:  RT-NODE-4-DRGA-Atachable-RTs route rules
          - AT-NODE-4-DRGA:
                - can refer: RT-NODE-1-IGW-NATGW-Atachable-RTs, RT-NODE-2-LPG-Atachable-RTs and RT-NODE-2-DRGA-Atachable-RTs route tables
                - can be reffered by:  RT-NODE-4-SGW-Atachable-RTs route rules
          - AT-NODE-5-SUBNET:
                - can refer: RT-NODE-1-IGW-NATGW-Atachable-RTs, RT-NODE-2-LPG-Atachable-RTs, RT-NODE-2-SGW-Atachable-RTs, RT-NODE-5-REMAINING-RTS and RT-NODE-2-DRGA-Atachable-RTs route tables
                - can be reffered by:  NONE
      - Notice that there is no loop/cycle in between the nodes described above and, in the same time, no limitation in the OCI functionality

3. Limitations

3.1. Once a route table update will generate a switch from one RT-NODE to another one, and the initial node is referenced by an AT-NODE, this will generate an error as terraform will
attempt to delete the RT from the current node and recreated as part of a different node without updating the AT-NODE(referencing node)
  - The workaround will be to 1st delete manualy the refereance from the *tfvars/json/yaml configuration, run terraform apply and them update and apply the RT with an update that will generate
a move from one RT-NODE to another one.
  - This limitation will also, as said, generate a recreation of the object and not just an update of the RT object.

3.2. Subnets are created with their VCN default route table. The internal network-completion module creates route tables after same-stack private IP targets exist, then applies the final subnet association. A fresh apply can therefore have a short default-route interval.

4. Default route tables

4.1. Customized default route tables use the same five-partition algorithm.
            
*/



locals {

  //------------------------------- COMMON ALGORITHM LOCALS ELEMENTS ----------------------------------------------------

  // Define all possible targets for the route rules(multiple) inside a route table(single)
  route_tables_route_rules_targets = {
    igw                        = "IGW",
    natgw                      = "NATGW",
    sgw                        = "SGW",
    drg                        = "DRG",
    lpg                        = "LPG",
    private_ip                 = "PRIVATE IP",
    null_target                = "NULL TARGET",
    ocid_non_private_ip_target = "OCID NON PRIVATE IP TARGET",
    no_route_rules             = "NO ROUTE RULES",
    target_not_found           = "TARGET NOT FOUND"
  }

  # Select route-table partitions from configured target keys. Referencing target
  # resource values here would add private-IP and firewall dependencies to every
  # partition; their OCIDs are passed separately to the applicable partition.
  private_ip_dependency_target_keys = toset(concat(
    keys(coalesce(var.private_ips_dependency, {})),
    flatten([
      for ips_value in values(local.one_dimension_processed_IPs) :
      keys(coalesce(ips_value.private_ips, {}))
    ]),
    keys(coalesce(local.aux_one_dimension_network_firewalls, {}))
  ))

  # Route-rule target keys share one namespace across gateway and private-IP
  # resources. This lookup identifies the target type without reading its OCID.
  route_rule_target_types_by_key = merge(
    { for key in keys(local.merged_one_dimension_processed_internet_gateways) : key => local.route_tables_route_rules_targets.igw },
    { for key in keys(local.merged_one_dimension_processed_nat_gateways) : key => local.route_tables_route_rules_targets.natgw },
    { for key in keys(local.merged_one_dimension_processed_service_gateways) : key => local.route_tables_route_rules_targets.sgw },
    { for key in keys(merge(local.one_dimension_dynamic_routing_gateways, local.one_dimension_inject_into_existing_drgs, coalesce(try(var.network_dependency["dynamic_routing_gateways"], null), {}))) : key => local.route_tables_route_rules_targets.drg },
    { for key in keys(local.merged_one_dimension_processed_local_peering_gateways) : key => local.route_tables_route_rules_targets.lpg },
    { for key in local.private_ip_dependency_target_keys : key => local.route_tables_route_rules_targets.private_ip }
  )

  // Define What are the entities to which a route table can be attached
  route_tables_attachable_to = {
    igw    = "IGW",
    natgw  = "NATGW",
    sgw    = "SGW",
    drga   = "DRG-ATTACHMENT",
    lpg    = "LPG",
    subnet = "SUBNET"
  }

  // Process the input for the route tables defined as part of the newly defined VCNs. 
  // Add a new attribute route_tables_route_rules_targets - which will contain a list of distinct elements representing all the targets used by the route rules of the current route table. The list will not contain duplicates.
  one_dimension_processed_route_tables = local.one_dimension_processed_vcns != null ? length(local.one_dimension_processed_vcns) > 0 ? {
    for flat_route_table in flatten([
      for vcn_key, vcn_value in local.one_dimension_processed_vcns : vcn_value.route_tables != null ? length(vcn_value.route_tables) > 0 ? [
        for route_table_key, route_table_value in vcn_value.route_tables : {
          compartment_id          = route_table_value.compartment_id != null ? route_table_value.compartment_id : vcn_value.category_compartment_id != null ? vcn_value.category_compartment_id : vcn_value.default_compartment_id != null ? vcn_value.default_compartment_id : null
          default_compartment_id  = vcn_value.default_compartment_id
          category_compartment_id = vcn_value.category_compartment_id
          defined_tags            = merge(route_table_value.defined_tags, vcn_value.category_defined_tags, vcn_value.default_defined_tags)
          default_defined_tags    = vcn_value.default_defined_tags
          category_defined_tags   = vcn_value.category_defined_tags
          freeform_tags           = merge(route_table_value.freeform_tags, vcn_value.category_freeform_tags, vcn_value.default_freeform_tags)
          category_freeform_tags  = vcn_value.category_freeform_tags
          default_freeform_tags   = vcn_value.default_freeform_tags
          display_name            = route_table_value.display_name
          route_rules = route_table_value.route_rules != null ? {
            for rr_key, rr_value in route_table_value.route_rules : rr_key => {
              destination      = rr_value.destination_type != "SERVICE_CIDR_BLOCK" ? rr_value.destination : local.oci_services_details[rr_value.destination].cidr_block
              destination_type = rr_value.destination_type
              # network_entity_id accepts either a literal OCID or a configured
              # resource key. network_entity_key remains supported for existing
              # configurations.
              network_entity_id = rr_value.network_entity_id != null ? (
                startswith(rr_value.network_entity_id, "ocid1.") ? rr_value.network_entity_id : null
              ) : null
              network_entity_key = rr_value.network_entity_id != null ? (
                startswith(rr_value.network_entity_id, "ocid1.") ? rr_value.network_entity_key : rr_value.network_entity_id
              ) : rr_value.network_entity_key
              description = rr_value.description
            }
          } : {}
          route_tables_route_rules_targets = route_table_value.route_rules != null ? length(route_table_value.route_rules) > 0 ? distinct([
            for rr_value in values(route_table_value.route_rules) :
            rr_value.network_entity_id != null ? (
              startswith(rr_value.network_entity_id, "ocid1.privateip") ? local.route_tables_route_rules_targets.private_ip :
              startswith(rr_value.network_entity_id, "ocid1.") ? local.route_tables_route_rules_targets.ocid_non_private_ip_target :
              lookup(local.route_rule_target_types_by_key, rr_value.network_entity_id, local.route_tables_route_rules_targets.target_not_found)
              ) : rr_value.network_entity_key != null ? (
              lookup(local.route_rule_target_types_by_key, rr_value.network_entity_key, local.route_tables_route_rules_targets.target_not_found)
            ) : local.route_tables_route_rules_targets.null_target
          ]) : [local.route_tables_route_rules_targets.no_route_rules] : [local.route_tables_route_rules_targets.no_route_rules]
          network_configuration_category = vcn_value.network_configuration_category
          vcn_key                        = vcn_key
          vcn_name                       = vcn_value.display_name
          route_table_key                = route_table_key
          vcn_id                         = local.provisioned_vcns[vcn_key].id
        }
      ] : [] : []
    ]) : flat_route_table.route_table_key => flat_route_table
  } : null : null


  // Process the input for the route tables defined as part of existing VCNs. 
  // Add a new attribute route_tables_route_rules_targets - which will contain a list of distinct elements representing all the targets used by the route rules of the current route table. The list will not contain duplicates.
  one_dimension_processed_injected_route_tables = local.one_dimension_processed_existing_vcns != null ? {
    for flat_route_table in flatten([
      for vcn_key, vcn_value in local.one_dimension_processed_existing_vcns : vcn_value.route_tables != null ? length(vcn_value.route_tables) > 0 ? [
        for route_table_key, route_table_value in vcn_value.route_tables : {
          compartment_id          = route_table_value.compartment_id != null ? route_table_value.compartment_id : vcn_value.category_compartment_id != null ? vcn_value.category_compartment_id : vcn_value.default_compartment_id != null ? vcn_value.default_compartment_id : null
          default_compartment_id  = vcn_value.default_compartment_id
          category_compartment_id = vcn_value.category_compartment_id
          defined_tags            = merge(route_table_value.defined_tags, vcn_value.category_defined_tags, vcn_value.default_defined_tags)
          default_defined_tags    = vcn_value.default_defined_tags
          category_defined_tags   = vcn_value.category_defined_tags
          freeform_tags           = merge(route_table_value.freeform_tags, vcn_value.category_freeform_tags, vcn_value.default_freeform_tags)
          category_freeform_tags  = vcn_value.category_freeform_tags
          default_freeform_tags   = vcn_value.default_freeform_tags
          display_name            = route_table_value.display_name
          route_rules = route_table_value.route_rules != null ? {
            for rr_key, rr_value in route_table_value.route_rules : rr_key => {
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
          route_tables_route_rules_targets = route_table_value.route_rules != null ? length(route_table_value.route_rules) > 0 ? distinct([
            for rr_value in values(route_table_value.route_rules) :
            rr_value.network_entity_id != null ? (
              startswith(rr_value.network_entity_id, "ocid1.privateip") ? local.route_tables_route_rules_targets.private_ip :
              startswith(rr_value.network_entity_id, "ocid1.") ? local.route_tables_route_rules_targets.ocid_non_private_ip_target :
              lookup(local.route_rule_target_types_by_key, rr_value.network_entity_id, local.route_tables_route_rules_targets.target_not_found)
              ) : rr_value.network_entity_key != null ? (
              lookup(local.route_rule_target_types_by_key, rr_value.network_entity_key, local.route_tables_route_rules_targets.target_not_found)
            ) : local.route_tables_route_rules_targets.null_target
          ]) : [local.route_tables_route_rules_targets.no_route_rules] : [local.route_tables_route_rules_targets.no_route_rules]
          network_configuration_category = vcn_value.network_configuration_category
          vcn_key                        = vcn_key
          vcn_name                       = vcn_value.vcn_name
          vcn_id                         = vcn_value.vcn_id
          route_table_key                = route_table_key
        }
      ] : [] : []
    ]) : flat_route_table.route_table_key => flat_route_table
  } : null

  //merging new VCNs defined route tables with existing VCNs defined route tables into a single map
  merged_one_dimension_processed_route_tables = merge(local.one_dimension_processed_route_tables, local.one_dimension_processed_injected_route_tables)

  //----------------------------------------------------------------------------------------------------------------------------

  //------------------------------- IGW and NATGW ALGORITHM LOCALS ELEMENTS ----------------------------------------------------

  // Define what are the route rules possible targets, inside a route table, that will allow for the row table to be attached to a IGW and NAT GW - the configuration that covers ALL of the possible options for IGW and NATGW - route rules to all the possible targets
  natgw_igw_attachable_specific_route_tables_route_rules_targets = [
    local.route_tables_route_rules_targets.private_ip,
    local.route_tables_route_rules_targets.ocid_non_private_ip_target,
    local.route_tables_route_rules_targets.null_target,
    local.route_tables_route_rules_targets.target_not_found,
    local.route_tables_route_rules_targets.no_route_rules
  ]

  // Search for all the route tables that have route rules that satisfy ANY of the criterias for being attached to a IGW/NAT-GW considering their route rules target   
  igw_natgw_attachable_specific_route_tables = local.merged_one_dimension_processed_route_tables != null ? length(local.merged_one_dimension_processed_route_tables) > 0 ? {
    for route_table_key, route_table_value in local.merged_one_dimension_processed_route_tables : route_table_key => route_table_value if length(setsubtract(route_table_value.route_tables_route_rules_targets, local.natgw_igw_attachable_specific_route_tables_route_rules_targets)) == 0
  } : null : null

  provisioned_igw_natgw_specific_route_tables = module.network_completion.provisioned_igw_natgw_specific_route_tables


  //------------------------------------------------------------------------------------------------------------------

  //------------------------------- SGW ALGORITHM LOCALS ELEMENTS ----------------------------------------------------

  // Define what are the route rules possible targets, inside a route table, that will allow for the row table to be attached to a SGW - the configuration that covers ALL the possible options for SGW - route rules to all the possible targets
  sgw_attachable_specific_route_tables_route_rules_targets = [
    // sgw specific
    local.route_tables_route_rules_targets.drg,
    // igw-natgw specific
    local.route_tables_route_rules_targets.private_ip,
    local.route_tables_route_rules_targets.null_target,
    local.route_tables_route_rules_targets.target_not_found,
    local.route_tables_route_rules_targets.no_route_rules
  ]

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
  sgw_attachable_specific_route_tables = local.merged_one_dimension_processed_route_tables != null ? length(local.merged_one_dimension_processed_route_tables) > 0 ? {
    for route_table_key, route_table_value in local.merged_one_dimension_processed_route_tables : route_table_key => route_table_value if(
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

  provisioned_sgw_specific_route_tables = module.network_completion.provisioned_sgw_specific_route_tables

  //------------------------------------------------------------------------------------------------------------------

  //------------------------------- LPG Attachment ALGORITHM LOCALS ELEMENTS -----------------------------------------

  // Define what are the route rules possible targets, inside a route table, that will allow for the row table to be attached to a LPG - the configuration that covers ALL the possible options for LPG - route rules to all the possible targets
  lpg_attachable_specific_route_tables_route_rules_targets = [

    // LPG specific
    local.route_tables_route_rules_targets.sgw,

    // igw-natgw specific
    local.route_tables_route_rules_targets.private_ip,
    local.route_tables_route_rules_targets.null_target,
    local.route_tables_route_rules_targets.target_not_found,
    local.route_tables_route_rules_targets.no_route_rules
  ]

  // Search for all the lpg specific route tables that have route rules that satisfy:
  //      1. CONDITION 1
  //            1.1. have at least one Route rule targeting a SGW  
  //                 AND
  //            1.2. if any other route rules their targets should be part of the folling list [igw_natgw_attachable_specific_route_tables_route_rules_targets]
  //
  //         OR
  //
  //     2. CONDITION 2 
  //         all the route rules are targeting the SGW
  //        
  lpg_attachable_specific_route_tables = local.merged_one_dimension_processed_route_tables != null ? length(local.merged_one_dimension_processed_route_tables) > 0 ? {
    for route_table_key, route_table_value in local.merged_one_dimension_processed_route_tables : route_table_key => route_table_value if(
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

  provisioned_lpg_specific_route_tables = module.network_completion.provisioned_lpg_specific_route_tables

  //------------------------------------------------------------------------------------------------------------------

  //------------------------------- DRG Attachment ALGORITHM LOCALS ELEMENTS -----------------------------------------

  // Define what are the route rules possible targets, inside a route table, that will allow for the row table to be attached to a DRG Attachment - the configuration that covers ALL the possible options for DRG Attachment - route rules to all the possible targets
  drga_attachable_specific_route_tables_route_rules_targets = [

    // drg specific
    local.route_tables_route_rules_targets.lpg,

    // LPG specific
    local.route_tables_route_rules_targets.sgw,

    // igw-natgw specific
    local.route_tables_route_rules_targets.private_ip,
    local.route_tables_route_rules_targets.null_target,
    local.route_tables_route_rules_targets.target_not_found,
    local.route_tables_route_rules_targets.no_route_rules
  ]

  // Search for all the lpg specific route tables that have route rules that satisfy:
  //      1. CONDITION 1
  //            1.1. have at least one Route rule targeting a LPG  
  //                 AND
  //            1.2. if any other route rules their targets should be part of the folling list [lpg_attachable_specific_route_tables_route_rules_targets]
  //
  //         OR
  //
  //     2. CONDITION 2 
  //         all the route rules are targeting the LPG
  //        
  drga_attachable_specific_route_tables = local.merged_one_dimension_processed_route_tables != null ? length(local.merged_one_dimension_processed_route_tables) > 0 ? {
    for route_table_key, route_table_value in local.merged_one_dimension_processed_route_tables : route_table_key => route_table_value if(
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

  provisioned_drga_specific_route_tables = module.network_completion.provisioned_drga_specific_route_tables

  //------------------------------------------------------------------------------------------------------------------

  //------------------------------- Remaining non-specific RTs ALGORITHM LOCALS ELEMENTS -----------------------------------------

  // Search for the route tables that do not fit the criterias for for specific IGW, NATGW, SGW, DRG Attachment and LPG specific attachamble RTs
  // Those RTs will be the remaing ones after the filtering above is applied
  non_gw_specific_remaining_route_tables = local.merged_one_dimension_processed_route_tables != null ? length(local.merged_one_dimension_processed_route_tables) > 0 ? {
    for route_table_key, route_table_value in local.merged_one_dimension_processed_route_tables : route_table_key => route_table_value if !contains(
      keys(
        merge(
          local.igw_natgw_attachable_specific_route_tables,
          local.sgw_attachable_specific_route_tables,
          local.drga_attachable_specific_route_tables,
          local.lpg_attachable_specific_route_tables
        )
      ),
      route_table_key
    )
  } : null : null


  provisioned_non_gw_specific_remaining_route_tables = module.network_completion.provisioned_non_gw_specific_remaining_route_tables

  //------------------------------------------------------------------------------------------------------------------


  provisioned_route_tables_attachments = module.network_completion.provisioned_route_tables_attachments
}
