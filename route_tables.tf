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

3.2. Route tables that contain route rules that target private IPs need, for now, to specify the OCIDs for those IPs under network entity IDs. Creating RTs with route rules targeting private IPs will
require multiple terraform applies. It is not possible to address this limitation without hitting cycle graphs.


4. TO DOs

4.1. Add the bellow functionality for default_route_tables
            
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

  // Define What are the entities to which a route table can be attached
  route_tables_attachable_to = {
    igw    = "IGW",
    natgw  = "NATGW",
    sgw    = "SGW",
    drga   = "DRG-ATTACHMENT",
    lpg    = "LPG",
    subnet = "SUBNET"
  }

  // defining all posible route rules targets
  all_route_rules_targets = merge(
    local.provisioned_internet_gateways,
    local.provisioned_nat_gateways,
    local.provisioned_service_gateways,
    local.provisioned_dynamic_gateways,
    local.provisioned_local_peering_gateways,
    coalesce(var.private_ips_dependency,{}),
    coalesce(try(var.network_dependency["dynamic_routing_gateways"],null),{})
  )

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
              destination        = rr_value.destination_type != "SERVICE_CIDR_BLOCK" ? rr_value.destination : local.oci_services_details[rr_value.destination].cidr_block
              destination_type   = rr_value.destination_type
              network_entity_id  = rr_value.network_entity_id
              network_entity_key = rr_value.network_entity_key
              description        = rr_value.description
            }
          } : {}
          route_tables_route_rules_targets = route_table_value.route_rules != null ? length(route_table_value.route_rules) > 0 ? distinct(flatten([
            [for rr_key, rr_value in route_table_value.route_rules : local.route_tables_route_rules_targets.igw if contains(keys(local.merged_one_dimension_processed_internet_gateways), coalesce(rr_value.network_entity_key, " "))],
            [for rr_key, rr_value in route_table_value.route_rules : local.route_tables_route_rules_targets.natgw if contains(keys(local.merged_one_dimension_processed_nat_gateways), coalesce(rr_value.network_entity_key, " "))],
            [for rr_key, rr_value in route_table_value.route_rules : local.route_tables_route_rules_targets.sgw if contains(keys(local.merged_one_dimension_processed_service_gateways), coalesce(rr_value.network_entity_key, " "))],
            [for rr_key, rr_value in route_table_value.route_rules : local.route_tables_route_rules_targets.drg if contains(keys(merge(local.one_dimension_dynamic_routing_gateways, local.one_dimension_inject_into_existing_drgs)), coalesce(rr_value.network_entity_key, " "))],
            [for rr_key, rr_value in route_table_value.route_rules : local.route_tables_route_rules_targets.lpg if contains(keys(local.merged_one_dimension_processed_local_peering_gateways), coalesce(rr_value.network_entity_key, " "))],
            [for rr_key, rr_value in route_table_value.route_rules : local.route_tables_route_rules_targets.private_ip if length(regexall("ocid1.privateip", coalesce(rr_value.network_entity_id, " "))) > 0],
            [for rr_key, rr_value in route_table_value.route_rules : local.route_tables_route_rules_targets.null_target if rr_value.network_entity_id == null && rr_value.network_entity_key == null],
            [for rr_key, rr_value in route_table_value.route_rules : local.route_tables_route_rules_targets.ocid_non_private_ip_target if rr_value.network_entity_key == null && rr_value.network_entity_id != null && length(regexall("ocid1.privateip", coalesce(rr_value.network_entity_id, " "))) <= 0],
            [for rr_key, rr_value in route_table_value.route_rules : local.route_tables_route_rules_targets.target_not_found if !contains(keys(local.merged_one_dimension_processed_internet_gateways), coalesce(rr_value.network_entity_key, " ")) && !contains(keys(local.merged_one_dimension_processed_nat_gateways), coalesce(rr_value.network_entity_key, " ")) && !contains(keys(local.merged_one_dimension_processed_service_gateways), coalesce(rr_value.network_entity_key, " ")) && !contains(keys(merge(local.one_dimension_dynamic_routing_gateways, local.one_dimension_inject_into_existing_drgs)), coalesce(rr_value.network_entity_key, " ")) && !contains(keys(local.merged_one_dimension_processed_local_peering_gateways), coalesce(rr_value.network_entity_key, " ")) && rr_value.network_entity_id == null && rr_value.network_entity_key != null]
          ])) : [local.route_tables_route_rules_targets.no_route_rules] : [local.route_tables_route_rules_targets.no_route_rules]
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
              destination        = rr_value.destination_type != "SERVICE_CIDR_BLOCK" ? rr_value.destination : local.oci_services_details[rr_value.destination].cidr_block
              destination_type   = rr_value.destination_type
              network_entity_id  = rr_value.network_entity_id
              network_entity_key = rr_value.network_entity_key
              description        = rr_value.description
            }
          } : {}
          route_tables_route_rules_targets = route_table_value.route_rules != null ? length(route_table_value.route_rules) > 0 ? distinct(flatten([
            [for rr_key, rr_value in route_table_value.route_rules : local.route_tables_route_rules_targets.igw if contains(keys(local.merged_one_dimension_processed_internet_gateways), coalesce(rr_value.network_entity_key, " "))],
            [for rr_key, rr_value in route_table_value.route_rules : local.route_tables_route_rules_targets.natgw if contains(keys(local.merged_one_dimension_processed_nat_gateways), coalesce(rr_value.network_entity_key, " "))],
            [for rr_key, rr_value in route_table_value.route_rules : local.route_tables_route_rules_targets.sgw if contains(keys(local.merged_one_dimension_processed_service_gateways), coalesce(rr_value.network_entity_key, " "))],
            [for rr_key, rr_value in route_table_value.route_rules : local.route_tables_route_rules_targets.drg if contains(keys(merge(local.one_dimension_dynamic_routing_gateways, local.one_dimension_inject_into_existing_drgs)), coalesce(rr_value.network_entity_key, " "))],
            [for rr_key, rr_value in route_table_value.route_rules : local.route_tables_route_rules_targets.lpg if contains(keys(local.merged_one_dimension_processed_local_peering_gateways), coalesce(rr_value.network_entity_key, " "))],
            [for rr_key, rr_value in route_table_value.route_rules : local.route_tables_route_rules_targets.private_ip if length(regexall("ocid1.privateip", coalesce(rr_value.network_entity_id, " "))) > 0],
            [for rr_key, rr_value in route_table_value.route_rules : local.route_tables_route_rules_targets.null_target if rr_value.network_entity_id == null && rr_value.network_entity_key == null],
            [for rr_key, rr_value in route_table_value.route_rules : local.route_tables_route_rules_targets.ocid_non_private_ip_target if rr_value.network_entity_key == null && rr_value.network_entity_id != null && length(regexall("ocid1.privateip", coalesce(rr_value.network_entity_id, " "))) <= 0],
            [for rr_key, rr_value in route_table_value.route_rules : local.route_tables_route_rules_targets.target_not_found if !contains(keys(local.merged_one_dimension_processed_internet_gateways), coalesce(rr_value.network_entity_key, " ")) && !contains(keys(local.merged_one_dimension_processed_nat_gateways), coalesce(rr_value.network_entity_key, " ")) && !contains(keys(local.merged_one_dimension_processed_service_gateways), coalesce(rr_value.network_entity_key, " ")) && !contains(keys(merge(local.one_dimension_dynamic_routing_gateways, local.one_dimension_inject_into_existing_drgs)), coalesce(rr_value.network_entity_key, " ")) && !contains(keys(local.merged_one_dimension_processed_local_peering_gateways), coalesce(rr_value.network_entity_key, " ")) && rr_value.network_entity_id == null && rr_value.network_entity_key != null]
          ])) : [local.route_tables_route_rules_targets.no_route_rules] : [local.route_tables_route_rules_targets.no_route_rules]
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

  // defining all posible route rules targets for IGW specific route tables
  // MARKING an external dependency on subnets and IP addresses for searching for private IP OCID for Private IP targets
  #route_rules_targets_for_IGW_NATGW_specific_RTs = {}
  route_rules_targets_for_IGW_NATGW_specific_RTs = merge(coalesce(var.private_ips_dependency,{}),coalesce(try(var.network_dependency["dynamic_routing_gateways"],null),{}))

  // Search for all the route tables that have route rules that satisfy ANY of the criterias for being attached to a IGW/NAT-GW considering their route rules target   
  igw_natgw_attachable_specific_route_tables = local.merged_one_dimension_processed_route_tables != null ? length(local.merged_one_dimension_processed_route_tables) > 0 ? {
    for route_table_key, route_table_value in local.merged_one_dimension_processed_route_tables : route_table_key => route_table_value if length(setsubtract(route_table_value.route_tables_route_rules_targets, local.natgw_igw_attachable_specific_route_tables_route_rules_targets)) == 0
  } : null : null

  provisioned_igw_natgw_specific_route_tables = {
    for route_table_key, route_value in oci_core_route_table.igw_natgw_specific_route_tables : route_table_key => {
      compartment_id                 = route_value.compartment_id
      defined_tags                   = route_value.defined_tags
      display_name                   = route_value.display_name
      freeform_tags                  = route_value.freeform_tags
      id                             = route_value.id
      route_rules                    = route_value.route_rules
      state                          = route_value.state
      time_created                   = route_value.time_created
      timeouts                       = route_value.timeouts
      vcn_id                         = route_value.vcn_id
      vcn_key                        = local.igw_natgw_attachable_specific_route_tables[route_table_key].vcn_key
      vcn_name                       = local.igw_natgw_attachable_specific_route_tables[route_table_key].vcn_name
      network_configuration_category = local.igw_natgw_attachable_specific_route_tables[route_table_key].network_configuration_category
      route_table_key                = route_table_key
    }
  }


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

  // defining all posible route rules targets for SGW specific route tables
  #route_rules_targets_for_SGW_specific_RTs = merge(local.provisioned_dynamic_gateways)
  route_rules_targets_for_SGW_specific_RTs = merge(local.provisioned_dynamic_gateways,coalesce(var.private_ips_dependency,{}),coalesce(try(var.network_dependency["dynamic_routing_gateways"],null),{}))

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

  provisioned_sgw_specific_route_tables = {
    for route_table_key, route_value in oci_core_route_table.sgw_specific_route_tables : route_table_key => {
      compartment_id                 = route_value.compartment_id
      defined_tags                   = route_value.defined_tags
      display_name                   = route_value.display_name
      freeform_tags                  = route_value.freeform_tags
      id                             = route_value.id
      route_rules                    = route_value.route_rules
      state                          = route_value.state
      time_created                   = route_value.time_created
      timeouts                       = route_value.timeouts
      vcn_id                         = route_value.vcn_id
      vcn_key                        = local.sgw_attachable_specific_route_tables[route_table_key].vcn_key
      vcn_name                       = local.sgw_attachable_specific_route_tables[route_table_key].vcn_name
      network_configuration_category = local.sgw_attachable_specific_route_tables[route_table_key].network_configuration_category
      route_table_key                = route_table_key
    }
  }

  //------------------------------------------------------------------------------------------------------------------

  //------------------------------- LPG Attachment ALGORITHM LOCALS ELEMENTS -----------------------------------------

  // defining all posible route rules targets for LPG specific route tables
  #route_rules_targets_for_LPG_specific_RTs = local.provisioned_service_gateways
  route_rules_targets_for_LPG_specific_RTs = merge(local.provisioned_service_gateways, var.private_ips_dependency)


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

  provisioned_lpg_specific_route_tables = {
    for route_table_key, route_value in oci_core_route_table.lpg_specific_route_tables : route_table_key => {
      compartment_id                 = route_value.compartment_id
      defined_tags                   = route_value.defined_tags
      display_name                   = route_value.display_name
      freeform_tags                  = route_value.freeform_tags
      id                             = route_value.id
      route_rules                    = route_value.route_rules
      state                          = route_value.state
      time_created                   = route_value.time_created
      timeouts                       = route_value.timeouts
      vcn_id                         = route_value.vcn_id
      vcn_key                        = local.lpg_attachable_specific_route_tables[route_table_key].vcn_key
      vcn_name                       = local.lpg_attachable_specific_route_tables[route_table_key].vcn_name
      network_configuration_category = local.lpg_attachable_specific_route_tables[route_table_key].network_configuration_category
      route_table_key                = route_table_key
    }
  }

  //------------------------------------------------------------------------------------------------------------------

  //------------------------------- DRG Attachment ALGORITHM LOCALS ELEMENTS -----------------------------------------

  // defining all posible route rules targets for DRGA specific route tables
  # route_rules_targets_for_DRGA_specific_RTs = merge(
  #   local.provisioned_local_peering_gateways,
  #   local.provisioned_service_gateways
  # )
   route_rules_targets_for_DRGA_specific_RTs = merge(
    local.provisioned_local_peering_gateways,
    local.provisioned_service_gateways,
    var.private_ips_dependency
  )

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

  provisioned_drga_specific_route_tables = {
    for route_table_key, route_value in oci_core_route_table.drga_specific_route_tables : route_table_key => {
      compartment_id                 = route_value.compartment_id
      defined_tags                   = route_value.defined_tags
      display_name                   = route_value.display_name
      freeform_tags                  = route_value.freeform_tags
      id                             = route_value.id
      route_rules                    = route_value.route_rules
      state                          = route_value.state
      time_created                   = route_value.time_created
      timeouts                       = route_value.timeouts
      vcn_id                         = route_value.vcn_id
      vcn_key                        = local.drga_attachable_specific_route_tables[route_table_key].vcn_key
      vcn_name                       = local.drga_attachable_specific_route_tables[route_table_key].vcn_name
      network_configuration_category = local.drga_attachable_specific_route_tables[route_table_key].network_configuration_category
      route_table_key                = route_table_key
    }
  }

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


  provisioned_non_gw_specific_remaining_route_tables = {
    for route_table_key, route_value in oci_core_route_table.non_gw_specific_remaining_route_tables : route_table_key => {
      compartment_id                 = route_value.compartment_id
      defined_tags                   = route_value.defined_tags
      display_name                   = route_value.display_name
      freeform_tags                  = route_value.freeform_tags
      id                             = route_value.id
      route_rules                    = route_value.route_rules
      state                          = route_value.state
      time_created                   = route_value.time_created
      timeouts                       = route_value.timeouts
      vcn_id                         = route_value.vcn_id
      vcn_key                        = local.non_gw_specific_remaining_route_tables[route_table_key].vcn_key
      vcn_name                       = local.non_gw_specific_remaining_route_tables[route_table_key].vcn_name
      network_configuration_category = local.non_gw_specific_remaining_route_tables[route_table_key].network_configuration_category
      route_table_key                = route_table_key
    }
  }

  //------------------------------------------------------------------------------------------------------------------


  provisioned_route_tables_attachments = {
    for rta_key, rta_value in oci_core_route_table_attachment.these : rta_key => {
      id                             = rta_value.id
      route_table_id                 = rta_value.route_table_id
      route_table_key                = local.merged_one_dimension_processed_subnets[rta_key].route_table_key
      route_table_name               = local.provisioned_subnets[rta_key].route_table_name
      subnet_id                      = rta_value.subnet_id
      subnet_key                     = rta_key
      subnet_name                    = can(local.provisioned_subnets[rta_key].display_name) ? local.provisioned_subnets[rta_key].display_name : null
      timeouts                       = rta_value.timeouts
      rta_key                        = rta_key
      vcn_key                        = local.merged_one_dimension_processed_subnets[rta_key].vcn_key
      vcn_name                       = local.merged_one_dimension_processed_subnets[rta_key].vcn_name
      network_configuration_category = local.merged_one_dimension_processed_subnets[rta_key].network_configuration_category
    }
  }
}


### Specific IGW/NAT GW Route tables
resource "oci_core_route_table" "igw_natgw_specific_route_tables" {
  for_each = local.igw_natgw_attachable_specific_route_tables != null ? local.igw_natgw_attachable_specific_route_tables : {}

  display_name   = each.value.display_name
  compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
  vcn_id         = each.value.vcn_id
  defined_tags   = each.value.defined_tags
  freeform_tags  = each.value.freeform_tags
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
resource "oci_core_route_table" "sgw_specific_route_tables" {
  for_each = local.sgw_attachable_specific_route_tables != null ? local.sgw_attachable_specific_route_tables : {}

  display_name   = each.value.display_name
  vcn_id         = each.value.vcn_id
  compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
  defined_tags   = each.value.defined_tags
  freeform_tags  = each.value.freeform_tags
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
resource "oci_core_route_table" "lpg_specific_route_tables" {
  for_each = local.lpg_attachable_specific_route_tables != null ? local.lpg_attachable_specific_route_tables : {}

  display_name   = each.value.display_name
  compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
  vcn_id         = each.value.vcn_id
  defined_tags   = each.value.defined_tags
  freeform_tags  = each.value.freeform_tags
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
resource "oci_core_route_table" "drga_specific_route_tables" {
  for_each = local.drga_attachable_specific_route_tables != null ? local.drga_attachable_specific_route_tables : {}

  display_name   = each.value.display_name
  vcn_id         = each.value.vcn_id
  compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
  defined_tags   = each.value.defined_tags
  freeform_tags  = each.value.freeform_tags
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
resource "oci_core_route_table" "non_gw_specific_remaining_route_tables" {

  for_each = local.non_gw_specific_remaining_route_tables != null ? local.non_gw_specific_remaining_route_tables : {}

  display_name   = each.value.display_name
  vcn_id         = each.value.vcn_id
  compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
  defined_tags   = each.value.defined_tags
  freeform_tags  = merge(local.cislz_module_tag, each.value.freeform_tags)
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


### Route Table Attachments
resource "oci_core_route_table_attachment" "these" {
  for_each       = local.provisioned_subnets
  subnet_id      = each.value.id
  route_table_id = each.value.route_table_id

}