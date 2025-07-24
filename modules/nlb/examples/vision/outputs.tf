
# Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "nlbs" {
  description = "The NLBs"
  value       = module.vision_nlbs.nlbs
}

output "nlbs_primary_private_ips" {
  description = "The NLBs primary private IP addresses."
  value = module.vision_nlbs.nlbs_primary_private_ips
}

output "nlbs_public_ips" {
  description = "The NLBs public IP addresses."
  value = module.vision_nlbs.nlbs_public_ips
}
