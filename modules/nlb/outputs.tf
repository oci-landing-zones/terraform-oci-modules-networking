# Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "nlbs" {
  description = "The Network Load Balancers (NLBs)."
  value       = var.enable_output ? oci_network_load_balancer_network_load_balancer.these : null
}

output "nlb_listeners" {
  description = "The NLB listeners."
  value       = var.enable_output ? oci_network_load_balancer_listener.these : null
}

output "nlb_backend_sets" {
  description = "The NLB backend sets."
  value       = var.enable_output ? oci_network_load_balancer_backend_set.these : null
}

output "nlb_backends" {
  description = "The NLB backends."
  value       = var.enable_output ? oci_network_load_balancer_backend.these : null
}

output "nlbs_primary_private_ips" {
  description = "The NLBs primary private IP addresses."
  value       = data.oci_core_private_ips.these
}

output "route_target_private_ips" {
  description = "The NLBs primary private IP addresses, available after their listeners, backend sets, and configured backends are created."
  value = {
    for nlb_key, private_ips in data.oci_core_private_ips.these : nlb_key => {
      id = one(private_ips.private_ips).id
    }
  }

  depends_on = [
    oci_network_load_balancer_listener.these,
    oci_network_load_balancer_backend.these,
  ]
}

output "nlbs_public_ips" {
  description = "The NLBs public IP addresses."
  value       = data.oci_core_public_ip.these
}
