# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


output "provisioned_networking_resources" {
  description = "Provisioned networking resources"
  value       = module.terraform_oci_networking.provisioned_networking_resources
}

