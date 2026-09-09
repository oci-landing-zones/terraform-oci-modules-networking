terraform {
  required_version = ">= 1.3.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "= 6.23.0"
    }
  }
}

provider "oci" {
  region = "us-ashburn-1"
}

module "nlb" {
  source = "../../modules/nlb"

  nlb_configuration = null
}
