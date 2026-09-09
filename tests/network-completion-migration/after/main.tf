terraform {
  required_version = ">= 1.4.0"
}

module "oci_lz_network" {
  count  = 1
  source = "./modules/network"
}
