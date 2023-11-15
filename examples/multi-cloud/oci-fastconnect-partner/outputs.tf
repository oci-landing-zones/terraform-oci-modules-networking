# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #


output "provisioned_networking_resources" {
  description = "Provisioned networking resources"
  value       = module.terraform_oci_networking.provisioned_networking_resources
}

/*
output "provisioned_fc_vc_id" {
  description = "Provisioned networking resources"
  value       = module.terraform_oci_networking.provisioned_networking_resources.fast_connect_virtual_circuits.fast_connect_virtual_circuits["FC-FRA-VC1-1-KEY"].id
}
*/