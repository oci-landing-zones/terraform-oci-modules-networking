# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "provisioned_fc_vc_id" {
  description = "Provisioned networking resources"
  value       = module.terraform_oci_networking.provisioned_networking_resources.fast_connect_virtual_circuits.fast_connect_virtual_circuits["FC-FRA-VC1-1-KEY"].id
}
