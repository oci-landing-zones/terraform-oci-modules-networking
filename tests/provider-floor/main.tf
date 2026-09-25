terraform {
  required_version = ">= 1.3.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "= 7.27.0"
    }
  }
}

provider "oci" {
  region = "us-ashburn-1"
}

module "networking" {
  source = "../.."

  network_configuration = null
}
