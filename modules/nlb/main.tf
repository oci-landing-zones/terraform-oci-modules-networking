# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Create NLBs
resource "oci_network_load_balancer_network_load_balancer" "these" {
  for_each = var.nlb_configuration.nlbs
    compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : (length(regexall("^ocid1.*$", var.nlb_configuration.default_compartment_id)) > 0 ? var.nlb_configuration.default_compartment_id : var.compartments_dependency[var.nlb_configuration.default_compartment_id].id)
    display_name   = each.value.display_name
    is_private     = each.value.is_private 
    subnet_id      = each.value.subnet_id != null ? (length(regexall("^ocid1.*$", each.value.subnet_id)) > 0 ? each.value.subnet_id : var.network_dependency["subnets"][each.value.subnet_id].id) : (length(regexall("^ocid1.*$", var.nlb_configuration.default_subnet_id)) > 0 ? var.nlb_configuration.default_subnet_id : var.network_dependency["subnets"][var.nlb_configuration.default_subnet_id].id)
    network_security_group_ids = each.value.network_security_group_ids != null ? [for nsg in coalesce(each.value.network_security_group_ids,[]) : (length(regexall("^ocid1.*$", nsg)) > 0 ? nsg : var.network_dependency["network_security_groups"][nsg].id)] : null
    dynamic "reserved_ips" {
      for_each = each.value.reserved_ips != null ? each.value.reserved_ips : []
      content {
        id = each.value.id
      }
    }
    is_preserve_source_destination = coalesce(each.value.skip_source_dest_check,true)
    defined_tags  = each.value.defined_tags != null ? each.value.defined_tags : var.nlb_configuration.default_defined_tags
    freeform_tags = merge(local.cislz_module_tag, each.value.freeform_tags != null ? each.value.freeform_tags : var.nlb_configuration.default_freeform_tags)
}

locals {
  listeners = flatten([
    for nlb_key, nlb_value in var.nlb_configuration.nlbs : [
      for listener_key, listener_value in nlb_value.listeners : {
        nlb_key      = nlb_key
        listener_key = listener_key
        name         = listener_value.name
        protocol     = listener_value.protocol
        port         = listener_value.port
        ip_version   = listener_value.ip_version
        backend_set  =  listener_value.backend_set
      }
    ]
  ])
}

# Create listeners for each NLB
resource "oci_network_load_balancer_listener" "these" {
  for_each = { for l in local.listeners : "${l.nlb_key}.${l.listener_key}" => {
                 nlb_key      = l.nlb_key
                 listener_key = l.listener_key
                 name         = l.name
                 protocol     = l.protocol
                 port         = l.port
                 ip_version   = l.ip_version
  }}
    default_backend_set_name = oci_network_load_balancer_backend_set.these["${each.value.nlb_key}.${each.value.listener_key}.BACKENDSET"].name
    network_load_balancer_id = oci_network_load_balancer_network_load_balancer.these[each.value.nlb_key].id
    name = each.value.name != null ? each.value.name : "${oci_network_load_balancer_network_load_balancer.these[each.value.nlb_key].display_name}-listener"
    protocol = each.value.protocol
    port = each.value.port
    ip_version = each.value.ip_version
}

# Create backend set for each listener
resource "oci_network_load_balancer_backend_set" "these" {
  for_each = { for l in local.listeners : "${l.nlb_key}.${l.listener_key}.BACKENDSET" => {
                nlb_key         = l.nlb_key
                name            = l.backend_set.name
                policy          = coalesce(l.backend_set.policy,"FIVE_TUPLE")
                hc_protocol     = l.backend_set.health_checker.protocol
                hc_interval     = l.backend_set.health_checker.interval_in_millis
                hc_port         = l.backend_set.health_checker.port
                hc_request_data = l.backend_set.health_checker.request_data
                hc_response_body_regex = l.backend_set.health_checker.response_body_regex
                hc_response_data = l.backend_set.health_checker.response_data
                hc_retries       = l.backend_set.health_checker.retries
                hc_return_code   = l.backend_set.health_checker.return_code
                hc_timeout       = l.backend_set.health_checker.timeout_in_millis
                hc_url_path      = coalesce(l.backend_set.health_checker.url_path,"/")
  }}  

  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.these[each.value.nlb_key].id
  name = each.value.name
  policy = each.value.policy
  health_checker {
    protocol           = each.value.hc_protocol
    interval_in_millis = each.value.hc_interval
    port               = each.value.hc_port
    request_data       = each.value.hc_request_data
    response_body_regex = each.value.hc_response_body_regex
    response_data       = each.value.hc_response_data
    retries             = each.value.hc_retries
    return_code         = each.value.hc_return_code
    timeout_in_millis   = each.value.hc_timeout
    url_path            = each.value.hc_url_path
  }
}

locals {
  backends = flatten([
    for nlb_key, nlb_value in var.nlb_configuration.nlbs : [
      for listener_key, listener_value in nlb_value.listeners : [
        for backend_key, backend_value in listener_value.backend_set.backends : {
          nlb_key         = nlb_key
          listener_key    = listener_key
          backend_key     = backend_key
          name            = backend_value.name
          port            = backend_value.port
          weight          = backend_value.weight
          ip_address      = backend_value.ip_address
          is_backup       = backend_value.is_backup
          is_drain        = backend_value.is_drain
          is_offline      = backend_value.is_offline
          target_id       = backend_value.target_id
        }  
      ]
    ]
  ])
}
# Create backends for each backend set
resource "oci_network_load_balancer_backend" "these" {
  for_each = { for b in local.backends : "${b.nlb_key}.${b.listener_key}.BACKENDSET.${b.backend_key}" => {
                nlb_key         = b.nlb_key
                listener_key    = b.listener_key
                backend_key     = b.backend_key
                name            = b.name
                port            = b.port
                weight          = b.weight
                ip_address      = b.ip_address
                is_backup       = b.is_backup
                is_drain        = b.is_drain
                is_offline      = b.is_offline
                target_id       = b.target_id
  }} 
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.these["${each.value.nlb_key}"].id
  backend_set_name = oci_network_load_balancer_backend_set.these["${each.value.nlb_key}.${each.value.listener_key}.BACKENDSET"].name
  name             = each.value.name
  ip_address       = each.value.ip_address != null ? (length(regexall("(\\d{1,3}?).(\\d{1,3}?).(\\d{1,3}?).(\\d{1,3}?)", each.value.ip_address)) > 0 ? each.value.ip_address : var.instances_dependency[each.value.ip_address].private_ip) : null
  port             = each.value.port
  weight           = each.value.weight
  is_backup        = coalesce(each.value.is_backup,false)
  is_drain         = coalesce(each.value.is_drain,false)
  is_offline       = coalesce(each.value.is_offline,false)
  target_id        = each.value.target_id != null ? (length(regexall("^ocid1.*$", each.value.target_id)) > 0 ? each.value.target_id : var.instances_dependency[each.value.target_id].id) : null
}

data "oci_core_private_ips" "these" {
  for_each = {for k, v in oci_network_load_balancer_network_load_balancer.these : k => v if v.is_private == true}
    ip_address = [for a in each.value.ip_addresses: a.ip_address][0]
    subnet_id = each.value.subnet_id
}

data "oci_core_public_ip" "these" {
  for_each = {for k, v in oci_network_load_balancer_network_load_balancer.these : k => v if v.is_private == false}
    ip_address = [for a in each.value.ip_addresses: a.ip_address][0]
}    
