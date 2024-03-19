# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #


locals {

  one_dimension_processed_default_security_lists = local.one_dimension_processed_vcns != null ? {
    for flat_default_security_list in flatten([
      for vcn_key, vcn_value in local.one_dimension_processed_vcns : [
        {
          manage_default_resource_id = local.provisioned_vcns[vcn_key].id
          compartment_id             = vcn_value.default_security_list != null ? vcn_value.default_security_list.compartment_id != null ? vcn_value.default_security_list.compartment_id : vcn_value.category_compartment_id != null ? vcn_value.category_compartment_id : vcn_value.default_compartment_id != null ? vcn_value.default_compartment_id : null : vcn_value.compartment_id
          default_compartment_id     = vcn_value.default_compartment_id
          category_compartment_id    = vcn_value.category_compartment_id
          defined_tags               = vcn_value.default_security_list != null ? merge(vcn_value.default_security_list.defined_tags, vcn_value.category_defined_tags, vcn_value.default_defined_tags) : merge(vcn_value.defined_tags, vcn_value.category_defined_tags, vcn_value.default_defined_tags)
          default_defined_tags       = vcn_value.default_defined_tags
          category_defined_tags      = vcn_value.category_defined_tags
          freeform_tags              = vcn_value.default_security_list != null ? merge(vcn_value.default_security_list.freeform_tags, vcn_value.category_freeform_tags, vcn_value.default_freeform_tags) : merge(vcn_value.freeform_tags, vcn_value.category_freeform_tags, vcn_value.default_freeform_tags)
          default_freeform_tags      = vcn_value.default_freeform_tags
          category_freeform_tags     = vcn_value.category_freeform_tags
          enable_cis_checks          = vcn_value.category_enable_cis_checks != null ? vcn_value.category_enable_cis_checks : vcn_value.default_enable_cis_checks != null ? vcn_value.default_enable_cis_checks : true
          ssh_ports_to_check         = vcn_value.category_ssh_ports_to_check != null ? vcn_value.category_ssh_ports_to_check : vcn_value.default_ssh_ports_to_check != null ? vcn_value.default_ssh_ports_to_check : local.DEFAULT_SSH_PORTS_TO_CHECK

          egress_rules = vcn_value.default_security_list != null ? vcn_value.default_security_list.egress_rules != null ? [
            for e_rule in vcn_value.default_security_list.egress_rules : {
              stateless    = e_rule.stateless
              protocol     = local.network_terminology["${e_rule.protocol}"]
              description  = e_rule.description
              dst          = e_rule.dst
              dst_type     = e_rule.dst_type
              src_port_min = e_rule.src_port_min
              src_port_max = e_rule.src_port_max
              dst_port_min = e_rule.dst_port_min
              dst_port_max = e_rule.dst_port_max
              icmp_type    = e_rule.icmp_type
              icmp_code    = e_rule.icmp_code
          }] : [] : []

          ingress_rules = vcn_value.default_security_list != null ? vcn_value.default_security_list.ingress_rules != null ? [
            for i_rule in vcn_value.default_security_list.ingress_rules : {
              stateless    = i_rule.stateless
              protocol     = local.network_terminology["${i_rule.protocol}"]
              description  = i_rule.description
              src          = i_rule.src
              src_type     = i_rule.src_type
              src_port_min = i_rule.src_port_min
              src_port_max = i_rule.src_port_max
              dst_port_min = i_rule.dst_port_min
              dst_port_max = i_rule.dst_port_max
              icmp_type    = i_rule.icmp_type
              icmp_code    = i_rule.icmp_code
            }] : [] : [
            for i_cidr in concat(vcn_value.cidr_blocks, ["0.0.0.0/0"]) : {
              stateless    = false
              protocol     = local.network_terminology["ICMP"]
              description  = i_cidr == "0.0.0.0/0" ? "ICMP type 3 code 4" : "ICMP type 3"
              src          = i_cidr
              src_type     = "CIDR_BLOCK"
              src_port_min = null
              src_port_max = null
              dst_port_min = null
              dst_port_max = null
              icmp_type    = 3
              icmp_code    = i_cidr == "0.0.0.0/0" ? 4 : null
          }]
          network_configuration_category = vcn_value.network_configuration_category
          vcn_key                        = vcn_key
          vcn_name                       = vcn_value.display_name
          vcn_id                         = oci_core_vcn.these[vcn_key].id
          security_list_key              = vcn_value.default_security_list != null ? "CUSTOM-DEFAULT-SEC-LIST-${vcn_key}" : "CIS-DEFAULT-SEC-LIST-${vcn_key}"
        }
      ]
    ]) : flat_default_security_list.security_list_key => flat_default_security_list
  } : null

  one_dimension_processed_injected_default_security_lists = local.one_dimension_processed_existing_vcns != null ? {
    for flat_default_security_list in flatten([
      for vcn_key, vcn_value in local.one_dimension_processed_existing_vcns : [
        {
          compartment_id          = vcn_value.default_security_list.compartment_id != null ? vcn_value.default_security_list.compartment_id : vcn_value.category_compartment_id != null ? vcn_value.category_compartment_id : vcn_value.default_compartment_id != null ? vcn_value.default_compartment_id : null
          default_compartment_id  = vcn_value.default_compartment_id
          category_compartment_id = vcn_value.category_compartment_id
          defined_tags            = merge(vcn_value.default_security_list.defined_tags, vcn_value.category_defined_tags, vcn_value.default_defined_tags)
          default_defined_tags    = vcn_value.default_defined_tags
          category_defined_tags   = vcn_value.category_defined_tags
          freeform_tags           = merge(vcn_value.default_security_list.freeform_tags, vcn_value.category_freeform_tags, vcn_value.default_freeform_tags)
          default_freeform_tags   = vcn_value.default_freeform_tags
          category_freeform_tags  = vcn_value.category_freeform_tags
          enable_cis_checks       = vcn_value.category_enable_cis_checks != null ? vcn_value.category_enable_cis_checks : vcn_value.default_enable_cis_checks != null ? vcn_value.default_enable_cis_checks : true
          ssh_ports_to_check      = vcn_value.category_ssh_ports_to_check != null ? vcn_value.category_ssh_ports_to_check : vcn_value.default_ssh_ports_to_check != null ? vcn_value.default_ssh_ports_to_check : local.DEFAULT_SSH_PORTS_TO_CHECK


          egress_rules = vcn_value.default_security_list.egress_rules != null ? [
            for e_rule in vcn_value.default_security_list.egress_rules : {
              stateless    = e_rule.stateless
              protocol     = local.network_terminology["${e_rule.protocol}"]
              description  = e_rule.description
              dst          = e_rule.dst
              dst_type     = e_rule.dst_type
              src_port_min = e_rule.src_port_min
              src_port_max = e_rule.src_port_max
              dst_port_min = e_rule.dst_port_min
              dst_port_max = e_rule.dst_port_max
              icmp_type    = e_rule.icmp_type
              icmp_code    = e_rule.icmp_code
          }] : []

          ingress_rules = vcn_value.default_security_list.ingress_rules != null ? [
            for i_rule in vcn_value.default_security_list.ingress_rules : {
              stateless    = i_rule.stateless
              protocol     = local.network_terminology["${i_rule.protocol}"]
              description  = i_rule.description
              src          = i_rule.src
              src_type     = i_rule.src_type
              src_port_min = i_rule.src_port_min
              src_port_max = i_rule.src_port_max
              dst_port_min = i_rule.dst_port_min
              dst_port_max = i_rule.dst_port_max
              icmp_type    = i_rule.icmp_type
              icmp_code    = i_rule.icmp_code
          }] : []

          network_configuration_category = vcn_value.network_configuration_category
          vcn_key                        = vcn_key
          vcn_name                       = vcn_value.vcn_name
          vcn_id                         = vcn_value.vcn_id
          security_list_key              = "CUSTOM-DEFAULT-SEC-LIST-${vcn_key}"
        }
      ] if vcn_value.default_security_list != null
    ]) : flat_default_security_list.security_list_key => flat_default_security_list
  } : null

  merged_one_dimension_processed_default_security_lists = merge(
    local.one_dimension_processed_default_security_lists,
    local.one_dimension_processed_injected_default_security_lists
  )

  provisioned_default_security_lists = {
    for sec_list_key, sec_list_value in oci_core_default_security_list.these : sec_list_key => {
      compartment_id                 = sec_list_value.compartment_id
      defined_tags                   = sec_list_value.defined_tags
      display_name                   = sec_list_value.display_name
      egress_security_rules          = sec_list_value.egress_security_rules
      freeform_tags                  = sec_list_value.freeform_tags
      id                             = sec_list_value.id
      ingress_security_rules         = sec_list_value.ingress_security_rules
      state                          = sec_list_value.state
      time_created                   = sec_list_value.time_created
      timeouts                       = sec_list_value.timeouts
      vcn_id                         = local.merged_one_dimension_processed_default_security_lists[sec_list_key].vcn_id
      vcn_key                        = local.merged_one_dimension_processed_default_security_lists[sec_list_key].vcn_key
      vcn_name                       = local.merged_one_dimension_processed_default_security_lists[sec_list_key].vcn_name
      network_configuration_category = local.merged_one_dimension_processed_default_security_lists[sec_list_key].network_configuration_category
      sec_list_key                   = sec_list_key
    }
  }

}

# OCI RESOURCE
resource "oci_core_default_security_list" "these" {
  for_each = local.merged_one_dimension_processed_default_security_lists

  lifecycle {
    precondition {
      condition = length([for ir in each.value.ingress_rules : ir if coalesce(ir.dst_port_min, local.TCP_PORT_MIN) <= coalesce(ir.dst_port_max, local.TCP_PORT_MAX)]) > 0
      error_message = "VALIDATION FAILURE: Invalid configuration in Security List [${each.key}]: dst_port_min [${join(
        ",",
        [
          for ir in each.value.ingress_rules : coalesce(ir.dst_port_min, local.TCP_PORT_MIN)
        ]
        )
        }] must be less than or equal to dst_port_max [${join(
          ",",
          [
            for ir in each.value.ingress_rules : coalesce(ir.dst_port_max, local.TCP_PORT_MAX)
          ]
        )
      }]."
    }
    precondition {
      condition = each.value.enable_cis_checks ? (
        length(flatten(
          [for ir in each.value.ingress_rules :
            [
              for p in each.value.ssh_ports_to_check : p
              if p >= coalesce(ir.dst_port_min, local.TCP_PORT_MIN) && p <= coalesce(ir.dst_port_max, local.TCP_PORT_MAX)
            ]
            if contains(["6", "all"], ir.protocol) && ir.src_type == "CIDR_BLOCK" && ir.src == local.network_terminology["ANYWHERE"]
          ]
        )) > 0 ? false : true
      ) : true
      error_message = "VALIDATION FAILURE (CIS BENCHMARK NETWORKING 2.3/2.4): Provided Security List [${each.key}] ingress rule violates CIS Benchmark recommendation 2.3/2.4: ingress from CIDR 0.0.0.0/0 on port(s) ${join(
        ", ", flatten(
          [
            for ir in each.value.ingress_rules :
            [
              for p in each.value.ssh_ports_to_check : p
              if p >= coalesce(ir.dst_port_min, 1) && p <= coalesce(ir.dst_port_max, local.TCP_PORT_MAX)
            ]
            if contains(["6", "all"], ir.protocol) && ir.src_type == "CIDR_BLOCK" && ir.src == local.network_terminology["ANYWHERE"]
          ]
      ))} over TCP(6) or ALL(all) protocols should be avoided. Either fix the rule in your configuration by scoping down the CIDR range, or specify your actual SSH/RDP ports (default is [22,3389]) using default_ssh_ports_to_check/category_ssh_ports_to_check attributes, or disable module CIS checks altogether by setting default_enable_cis_checks/category_enable_cis_checks attributes to false."
    }
  }

  #Required
  compartment_id             = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : null
  manage_default_resource_id = merge(local.provisioned_vcns, local.one_dimension_processed_existing_vcns)[each.value.vcn_key].default_security_list_id

  #Optional
  defined_tags  = each.value.defined_tags
  freeform_tags = merge(local.cislz_module_tag, each.value.freeform_tags)

  # egress, protocol: ICMP with ICMP type
  dynamic "egress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto : x.protocol
        dst : x.dst
        dst_type : x.dst_type
        stateless : x.stateless
        icmp_type : x.icmp_type
        icmp_code : x.icmp_code
        description : x.description

    } if x.protocol == "1" && x.icmp_type != null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
      description      = rule.value.description
      icmp_options {
        type = rule.value.icmp_type
        code = rule.value.icmp_code
      }
    }
  }

  # egress, protocol: ICMP without ICMP type
  dynamic "egress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto : x.protocol
        dst : x.dst
        dst_type : x.dst_type
        stateless : x.stateless
        icmp_type : x.icmp_type
        icmp_code : x.icmp_code
        description : x.description

    } if x.protocol == "1" && x.icmp_type == null && x.icmp_code == null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
      description      = rule.value.description
    }
  }

  #  egress, proto: TCP  - no src port, no dst port
  dynamic "egress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto : x.protocol
        dst : x.dst
        dst_type : x.dst_type
        stateless : x.stateless
        description : x.description
    } if x.protocol == "6" && x.src_port_min == null && x.src_port_max == null && x.dst_port_min == null && x.dst_port_max == null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
      description      = rule.value.description
    }
  }

  #  egress, proto: all  - no src port, no dst port
  dynamic "egress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto : x.protocol
        dst : x.dst
        dst_type : x.dst_type
        stateless : x.stateless
        description : x.description
    } if x.protocol == "all" && x.src_port_min == null && x.src_port_max == null && x.dst_port_min == null && x.dst_port_max == null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
      description      = rule.value.description
    }
  }

  #  egress, proto: TCP  - src port, no dst port
  dynamic "egress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto : x.protocol
        dst : x.dst
        dst_type : x.dst_type
        stateless : x.stateless
        src_port_min : x.src_port_min
        src_port_max : x.src_port_max
        description : x.description
    } if x.protocol == "6" && x.src_port_min != null && x.src_port_max != null && x.dst_port_min == null && x.dst_port_max == null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
      description      = rule.value.description

      tcp_options {
        source_port_range {
          max = rule.value.src_port_max
          min = rule.value.src_port_min
        }
      }
    }
  }

  #  egress, proto: all  - src port, no dst port
  dynamic "egress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto : x.protocol
        dst : x.dst
        dst_type : x.dst_type
        stateless : x.stateless
        src_port_min : x.src_port_min
        src_port_max : x.src_port_max
        description : x.description
    } if x.protocol == "all" && x.src_port_min != null && x.src_port_max != null && x.dst_port_min == null && x.dst_port_max == null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
      description      = rule.value.description

      tcp_options {
        source_port_range {
          max = rule.value.src_port_max
          min = rule.value.src_port_min
        }
      }
    }
  }

  #  egress, proto: TCP  - no src port, dst port
  dynamic "egress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto : x.protocol
        dst : x.dst
        dst_type : x.dst_type
        stateless : x.stateless
        dst_port_min : x.dst_port_min
        dst_port_max : x.dst_port_max
        description : x.description
    } if x.protocol == "6" && x.src_port_min == null && x.src_port_max == null && x.dst_port_min != null && x.dst_port_max != null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
      description      = rule.value.description

      tcp_options {
        max = rule.value.dst_port_max
        min = rule.value.dst_port_min
      }
    }
  }

  #  egress, proto: all  - no src port, dst port
  dynamic "egress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto : x.protocol
        dst : x.dst
        dst_type : x.dst_type
        stateless : x.stateless
        dst_port_min : x.dst_port_min
        dst_port_max : x.dst_port_max
        description : x.description
    } if x.protocol == "all" && x.src_port_min == null && x.src_port_max == null && x.dst_port_min != null && x.dst_port_max != null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
      description      = rule.value.description

      tcp_options {
        max = rule.value.dst_port_max
        min = rule.value.dst_port_min
      }
    }
  }

  #  egress, proto: TCP  - src port, dst port
  dynamic "egress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto : x.protocol
        dst : x.dst
        dst_type : x.dst_type
        stateless : x.stateless
        src_port_min : x.src_port_min
        src_port_max : x.src_port_max
        dst_port_min : x.dst_port_min
        dst_port_max : x.dst_port_max
        description : x.description
    } if x.protocol == "6" && x.src_port_min != null && x.src_port_max != null && x.dst_port_min != null && x.dst_port_max != null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
      description      = rule.value.description

      tcp_options {
        max = rule.value.dst_port_max
        min = rule.value.dst_port_min

        source_port_range {
          max = rule.value.src_port_max
          min = rule.value.src_port_min
        }
      }
    }
  }

  #  egress, proto: all  - src port, dst port
  dynamic "egress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto : x.protocol
        dst : x.dst
        dst_type : x.dst_type
        stateless : x.stateless
        src_port_min : x.src_port_min
        src_port_max : x.src_port_max
        dst_port_min : x.dst_port_min
        dst_port_max : x.dst_port_max
        description : x.description
    } if x.protocol == "all" && x.src_port_min != null && x.src_port_max != null && x.dst_port_min != null && x.dst_port_max != null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
      description      = rule.value.description

      tcp_options {
        max = rule.value.dst_port_max
        min = rule.value.dst_port_min

        source_port_range {
          max = rule.value.src_port_max
          min = rule.value.src_port_min
        }
      }
    }
  }
  #  egress, proto: UDP  - no src port, no dst port
  dynamic "egress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto : x.protocol
        dst : x.dst
        dst_type : x.dst_type
        stateless : x.stateless
        description : x.description
    } if x.protocol == "17" && x.src_port_min == null && x.src_port_max == null && x.dst_port_min == null && x.dst_port_max == null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
      description      = rule.value.description
    }
  }

  #  egress, proto: UDP  - src port, no dst port
  dynamic "egress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto : x.protocol
        dst : x.dst
        dst_type : x.dst_type
        stateless : x.stateless
        src_port_min : x.src_port_min
        src_port_max : x.src_port_max
        description : x.description
    } if x.protocol == "17" && x.src_port_min != null && x.src_port_max != null && x.dst_port_min == null && x.dst_port_max == null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
      description      = rule.value.description

      udp_options {
        source_port_range {
          max = rule.value.src_port_max
          min = rule.value.src_port_min
        }
      }
    }
  }

  #  egress, proto: UDP  - no src port, dst port
  dynamic "egress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto : x.protocol
        dst : x.dst
        dst_type : x.dst_type
        stateless : x.stateless
        dst_port_min : x.dst_port_min
        dst_port_max : x.dst_port_max
        description : x.description
    } if x.protocol == "17" && x.src_port_min == null && x.src_port_max == null && x.dst_port_min != null && x.dst_port_max != null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
      description      = rule.value.description

      udp_options {
        max = rule.value.dst_port_max
        min = rule.value.dst_port_min
      }
    }
  }

  #  egress, proto: UDP  - src port, dst port
  dynamic "egress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto : x.protocol
        dst : x.dst
        dst_type : x.dst_type
        stateless : x.stateless
        src_port_min : x.src_port_min
        src_port_max : x.src_port_max
        dst_port_min : x.dst_port_min
        dst_port_max : x.dst_port_max
        description : x.description
    } if x.protocol == "17" && x.src_port_min != null && x.src_port_max != null && x.dst_port_min != null && x.dst_port_max != null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
      description      = rule.value.description

      udp_options {
        max = rule.value.dst_port_max
        min = rule.value.dst_port_min

        source_port_range {
          max = rule.value.src_port_max
          min = rule.value.src_port_min
        }
      }
    }
  }

  # ingress, protocol: ICMP with ICMP type
  dynamic "ingress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto : x.protocol
        src : x.src
        src_type : x.src_type
        stateless : x.stateless
        icmp_type : x.icmp_type
        icmp_code : x.icmp_code
        description : x.description

    } if x.protocol == "1" && x.icmp_type != null]

    content {
      protocol    = rule.value.proto
      source      = rule.value.src
      source_type = rule.value.src_type
      stateless   = rule.value.stateless
      description = rule.value.description
      icmp_options {
        type = rule.value.icmp_type
        code = rule.value.icmp_code
      }
    }
  }

  # ingress, protocol: ICMP without ICMP type
  dynamic "ingress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto : x.protocol
        src : x.src
        src_type : x.src_type
        stateless : x.stateless
        icmp_type : x.icmp_type
        icmp_code : x.icmp_code
        description : x.description

    } if x.protocol == "1" && x.icmp_type == null && x.icmp_code == null]

    content {
      protocol    = rule.value.proto
      source      = rule.value.src
      source_type = rule.value.src_type
      stateless   = rule.value.stateless
      description = rule.value.description
    }
  }


  #  ingress, proto: TCP  - no src port, no dst port
  dynamic "ingress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto : x.protocol
        src : x.src
        src_type : x.src_type
        stateless : x.stateless
        description : x.description
    } if x.protocol == "6" && x.src_port_min == null && x.src_port_max == null && x.dst_port_min == null && x.dst_port_max == null]

    content {
      protocol    = rule.value.proto
      source      = rule.value.src
      source_type = rule.value.src_type
      stateless   = rule.value.stateless
      description = rule.value.description
    }
  }

  #  ingress, proto: all  - no src port, no dst port
  dynamic "ingress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto : x.protocol
        src : x.src
        src_type : x.src_type
        stateless : x.stateless
        description : x.description
    } if x.protocol == "all" && x.src_port_min == null && x.src_port_max == null && x.dst_port_min == null && x.dst_port_max == null]

    content {
      protocol    = rule.value.proto
      source      = rule.value.src
      source_type = rule.value.src_type
      stateless   = rule.value.stateless
      description = rule.value.description
    }
  }

  #  ingress, proto: TCP  - src port, no dst port
  dynamic "ingress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto : x.protocol
        src : x.src
        src_type : x.src_type
        stateless : x.stateless
        src_port_min : x.src_port_min
        src_port_max : x.src_port_max
        description : x.description
    } if x.protocol == "6" && x.src_port_min != null && x.src_port_max != null && x.dst_port_min == null && x.dst_port_max == null]

    content {
      protocol    = rule.value.proto
      source      = rule.value.src
      source_type = rule.value.src_type
      stateless   = rule.value.stateless
      description = rule.value.description

      tcp_options {
        source_port_range {
          max = rule.value.src_port_max
          min = rule.value.src_port_min
        }
      }
    }
  }

  #  ingress, proto: all  - src port, no dst port
  dynamic "ingress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto : x.protocol
        src : x.src
        src_type : x.src_type
        stateless : x.stateless
        src_port_min : x.src_port_min
        src_port_max : x.src_port_max
        description : x.description
    } if x.protocol == "all" && x.src_port_min != null && x.src_port_max != null && x.dst_port_min == null && x.dst_port_max == null]

    content {
      protocol    = rule.value.proto
      source      = rule.value.src
      source_type = rule.value.src_type
      stateless   = rule.value.stateless
      description = rule.value.description

      tcp_options {
        source_port_range {
          max = rule.value.src_port_max
          min = rule.value.src_port_min
        }
      }
    }
  }

  #  ingress, proto: TCP  - no src port, dst port
  dynamic "ingress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto : x.protocol
        src : x.src
        src_type : x.src_type
        stateless : x.stateless
        dst_port_min : x.dst_port_min
        dst_port_max : x.dst_port_max
        description : x.description
    } if x.protocol == "6" && x.src_port_min == null && x.src_port_max == null && x.dst_port_min != null && x.dst_port_max != null]

    content {
      protocol    = rule.value.proto
      source      = rule.value.src
      source_type = rule.value.src_type
      stateless   = rule.value.stateless
      description = rule.value.description

      tcp_options {
        max = rule.value.dst_port_max
        min = rule.value.dst_port_min
      }
    }
  }

  #  ingress, proto: all  - no src port, dst port
  dynamic "ingress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto : x.protocol
        src : x.src
        src_type : x.src_type
        stateless : x.stateless
        dst_port_min : x.dst_port_min
        dst_port_max : x.dst_port_max
        description : x.description
    } if x.protocol == "all" && x.src_port_min == null && x.src_port_max == null && x.dst_port_min != null && x.dst_port_max != null]

    content {
      protocol    = rule.value.proto
      source      = rule.value.src
      source_type = rule.value.src_type
      stateless   = rule.value.stateless
      description = rule.value.description

      tcp_options {
        max = rule.value.dst_port_max
        min = rule.value.dst_port_min
      }
    }
  }

  #  ingress, proto: TCP  - src port, dst port
  dynamic "ingress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto : x.protocol
        src : x.src
        src_type : x.src_type
        stateless : x.stateless
        src_port_min : x.src_port_min
        src_port_max : x.src_port_max
        dst_port_min : x.dst_port_min
        dst_port_max : x.dst_port_max
        description : x.description
    } if x.protocol == "6" && x.src_port_min != null && x.src_port_max != null && x.dst_port_min != null && x.dst_port_max != null]

    content {
      protocol    = rule.value.proto
      source      = rule.value.src
      source_type = rule.value.src_type
      stateless   = rule.value.stateless
      description = rule.value.description

      tcp_options {
        max = rule.value.dst_port_max
        min = rule.value.dst_port_min

        source_port_range {
          max = rule.value.src_port_max
          min = rule.value.src_port_min
        }
      }
    }
  }

  #  ingress, proto: all  - src port, dst port
  dynamic "ingress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto : x.protocol
        src : x.src
        src_type : x.src_type
        stateless : x.stateless
        src_port_min : x.src_port_min
        src_port_max : x.src_port_max
        dst_port_min : x.dst_port_min
        dst_port_max : x.dst_port_max
        description : x.description
    } if x.protocol == "all" && x.src_port_min != null && x.src_port_max != null && x.dst_port_min != null && x.dst_port_max != null]

    content {
      protocol    = rule.value.proto
      source      = rule.value.src
      source_type = rule.value.src_type
      stateless   = rule.value.stateless
      description = rule.value.description

      tcp_options {
        max = rule.value.dst_port_max
        min = rule.value.dst_port_min

        source_port_range {
          max = rule.value.src_port_max
          min = rule.value.src_port_min
        }
      }
    }
  }
  #  ingress, proto: UDP  - no src port, no dst port
  dynamic "ingress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto : x.protocol
        src : x.src
        src_type : x.src_type
        stateless : x.stateless
        description : x.description
    } if x.protocol == "17" && x.src_port_min == null && x.src_port_max == null && x.dst_port_min == null && x.dst_port_max == null]

    content {
      protocol    = rule.value.proto
      source      = rule.value.src
      source_type = rule.value.src_type
      stateless   = rule.value.stateless
      description = rule.value.description
    }
  }

  #  ingress, proto: UDP  - src port, no dst port
  dynamic "ingress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto : x.protocol
        src : x.src
        src_type : x.src_type
        stateless : x.stateless
        src_port_min : x.src_port_min
        src_port_max : x.src_port_max
        description : x.description
    } if x.protocol == "17" && x.src_port_min != null && x.src_port_max != null && x.dst_port_min == null && x.dst_port_max == null]

    content {
      protocol    = rule.value.proto
      source      = rule.value.src
      source_type = rule.value.src_type
      stateless   = rule.value.stateless
      description = rule.value.description

      udp_options {
        source_port_range {
          max = rule.value.src_port_max
          min = rule.value.src_port_min
        }
      }
    }
  }

  #  ingress, proto: UDP  - no src port, dst port
  dynamic "ingress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto : x.protocol
        src : x.src
        src_type : x.src_type
        stateless : x.stateless
        dst_port_min : x.dst_port_min
        dst_port_max : x.dst_port_max
        description : x.description
    } if x.protocol == "17" && x.src_port_min == null && x.src_port_max == null && x.dst_port_min != null && x.dst_port_max != null]

    content {
      protocol    = rule.value.proto
      source      = rule.value.src
      source_type = rule.value.src_type
      stateless   = rule.value.stateless
      description = rule.value.description

      udp_options {
        max = rule.value.dst_port_max
        min = rule.value.dst_port_min
      }
    }
  }

  #  ingress, proto: UDP  - src port, dst port
  dynamic "ingress_security_rules" {
    iterator = rule
    for_each = [
      for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto : x.protocol
        src : x.src
        src_type : x.src_type
        stateless : x.stateless
        src_port_min : x.src_port_min
        src_port_max : x.src_port_max
        dst_port_min : x.dst_port_min
        dst_port_max : x.dst_port_max
        description : x.description
    } if x.protocol == "17" && x.src_port_min != null && x.src_port_max != null && x.dst_port_min != null && x.dst_port_max != null]

    content {
      protocol    = rule.value.proto
      source      = rule.value.src
      source_type = rule.value.src_type
      stateless   = rule.value.stateless
      description = rule.value.description

      udp_options {
        max = rule.value.dst_port_max
        min = rule.value.dst_port_min

        source_port_range {
          max = rule.value.src_port_max
          min = rule.value.src_port_min
        }
      }
    }
  }
}