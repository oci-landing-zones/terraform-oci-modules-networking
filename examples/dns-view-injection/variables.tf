# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# tenancy details
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "private_key_password" {}
variable "region" {}

variable "network_configuration" {
  type = any
}

variable "network_dependency" {
  description = "An object containing the externally managed network resources this module may depend on. Supported resources are 'vcns', 'dynamic_routing_gateways', 'drg_attachments', 'local_peering_gateways', 'remote_peering_connections', and 'dns_private_views', represented as map of objects. Each object, when defined, must have an 'id' attribute of string type set with the VCN, DRG OCID, DRG Attachment OCID, Local Peering Gateway OCID or Remote Peering Connection OCID. 'remote_peering_connections' must also pass the peer region name in the region_name attribute. See External Dependencies section in README.md (https://github.com/oci-landing-zones/terraform-oci-modules-networking#ext-dep) for details."
  type = any
  default = null
}


