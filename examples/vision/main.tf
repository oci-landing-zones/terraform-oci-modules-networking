# Copyright (c) 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "vision_network" {
  #source = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking?ref=release-0.6.5"
  source = "../../"
  network_configuration = var.network_configuration
  tenancy_ocid = var.tenancy_ocid
}