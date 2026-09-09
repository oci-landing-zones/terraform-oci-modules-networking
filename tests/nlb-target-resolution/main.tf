terraform {
  required_version = ">= 1.3.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "6.23.0"
    }
  }
}

provider "oci" {
  region = "eu-frankfurt-1"
}

variable "composite_target_id" {
  type    = string
  default = "FW-1.UNTRUST"
}

variable "legacy_target_id" {
  type    = string
  default = null
}

variable "literal_target_id" {
  type    = string
  default = "ocid1.privateip.oc1.eu-frankfurt-1.fixture"
}

variable "primary_private_ip_id" {
  type    = string
  default = "ocid1.privateip.oc1.eu-frankfurt-1.primary-fixture"
}

variable "untrust_private_ip_id" {
  type    = string
  default = "ocid1.privateip.oc1.eu-frankfurt-1.untrust-fixture"
}

resource "terraform_data" "compartment" {
  input = "ocid1.compartment.oc1..fixture"
}

resource "terraform_data" "subnet" {
  input = "ocid1.subnet.oc1.eu-frankfurt-1.fixture"
}

module "nlb" {
  source = "../../modules/nlb"

  compartments_dependency = {
    CMP = {
      id = terraform_data.compartment.output
    }
  }

  network_dependency = {
    subnets = {
      NLB = {
        id = terraform_data.subnet.output
      }
    }
  }

  instances_dependency = {
    FW-1 = {
      id = "ocid1.instance.oc1.eu-frankfurt-1.primary-fixture"
    }
    FW-LEGACY = {
      id = "ocid1.instance.oc1.eu-frankfurt-1.legacy-fixture"
    }
  }

  private_ips_dependency = {
    FW-1 = {
      id = var.primary_private_ip_id
    }
    "FW-1.UNTRUST" = {
      id = var.untrust_private_ip_id
    }
  }

  nlb_configuration = {
    nlbs = {
      FIREWALL = {
        compartment_id = "CMP"
        display_name   = "firewall-fixture"
        is_private     = true
        subnet_id      = "NLB"
        listeners = {
          TCP = {
            port     = 443
            protocol = "TCP"
            backend_set = {
              name = "firewall-backends"
              health_checker = {
                protocol = "TCP"
              }
              backends = {
                LEGACY = {
                  name       = "legacy"
                  port       = 443
                  ip_address = "10.0.0.10"
                  target_id  = var.legacy_target_id
                }
                PRIMARY = {
                  name      = "primary"
                  port      = 443
                  target_id = "FW-1"
                }
                INSTANCE_FALLBACK = {
                  name      = "instance-fallback"
                  port      = 443
                  target_id = "FW-LEGACY"
                }
                UNTRUST = {
                  name      = "untrust"
                  port      = 443
                  target_id = var.composite_target_id
                }
                OCID = {
                  name      = "ocid"
                  port      = 443
                  target_id = var.literal_target_id
                }
              }
            }
          }
        }
      }
    }
  }
}
