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
