
# Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "nlbs" {
  description = "The NLBs"
  value       = module.vision_nlbs.nlbs
}

output "nlbs_private_ips" {
  description = "The NLBs private IP addresses."
  value = module.vision_nlbs.nlbs_private_ips
}
