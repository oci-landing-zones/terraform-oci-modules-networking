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

variable "subnet_dependency" {
  type = any
  default = {
    display_name = "sn-fra-lz-hub-lb"
    id           = "ocid1.subnet.oc1.iad.fixture"
    vcn_id       = "ocid1.vcn.oc1.iad.fixture"
    vcn_key      = "VCN-FRA-LZ-HUB-KEY"
    vcn_name     = "vcn-fra-lz-hub"
  }
}

# Pre-completion subnet attributes consumed by the L7 module.
module "l7_load_balancers" {
  source = "../../modules/l7_load_balancers"

  l7_load_balancers_configuration = {
    dependencies = {
      subnets = {
        "SN-FRA-LZ-HUB-LB-KEY" = var.subnet_dependency
      }
    }
    l7_load_balancers = {}
  }
}

# Verify that the completed networking subnet output remains input-compatible.
# Terraform discards attributes outside the L7 subnet object type.
module "l7_load_balancers_completed_output_compatibility" {
  source = "../../modules/l7_load_balancers"

  l7_load_balancers_configuration = {
    dependencies = {
      subnets = {
        "COMPLETED-SUBNET-KEY" = {
          dhcp_options_name = "default_dhcp_options"
          display_name      = "completed-subnet"
          id                = "ocid1.subnet.oc1.iad.completed-fixture"
          route_table_name  = "completed-route-table"
          security_lists    = {}
          vcn_id            = "ocid1.vcn.oc1.iad.completed-fixture"
          vcn_key           = "COMPLETED-VCN-KEY"
          vcn_name          = "completed-vcn"
        }
      }
    }
    l7_load_balancers = {}
  }
}
