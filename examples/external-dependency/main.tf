# Copyright (c) 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "vision_network" {
  #source = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking?ref=release-0..6.5"
  source = "../../"
  network_configuration   = var.network_configuration
  compartments_dependency = jsondecode(file("./dependencies/vision-compartments.json"))
  network_dependency      = jsondecode(file("./dependencies/vision-network.json"))
  private_ips_dependency  = jsondecode(file("./dependencies/vision-nlbs.json"))
}  