# Copyright (c) 2024 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "networking_resources" {
  description = "Networking resources"
  value       = module.rpc_requestor.provisioned_networking_resources
}