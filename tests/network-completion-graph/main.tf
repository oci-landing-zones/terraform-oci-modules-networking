terraform {
  required_version = ">= 1.4.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "= 8.27.0"
    }
  }
}

provider "oci" {
  region = "us-ashburn-1"
}

# terraform_data models plan-time-unknown IDs returned by VCN, firewall, VM, and
# NLB resources without requiring OCI credentials.
resource "terraform_data" "vcn" {
  input = "ocid1.vcn.oc1.iad.fixture"
}

resource "terraform_data" "subnet" {
  input = terraform_data.vcn.output
}

resource "terraform_data" "no_firewall_subnet" {
  input = terraform_data.vcn.output
}

resource "terraform_data" "managed_private_ip" {
  input = terraform_data.subnet.output
}

resource "terraform_data" "network_firewall_policy_content" {
  input = "policy-content"
}

resource "terraform_data" "network_firewall" {
  input      = terraform_data.subnet.output
  depends_on = [terraform_data.network_firewall_policy_content]
}

resource "terraform_data" "network_firewall_private_ip" {
  input = terraform_data.network_firewall.output
}

resource "terraform_data" "firewall_vm" {
  for_each = toset(["PANF-1", "PANF-2"])
  input    = terraform_data.subnet.output
}

# Model the cis-compute-storage secondary_vnics output contract, keyed by
# "${instance_key}.${secondary_vnic_key}". Private-IP resolution occurs before
# the resulting dependency is passed to the NLB module.
locals {
  workload_secondary_vnic_configuration = {
    "PANF-1.INDOOR"  = { instance_key = "PANF-1", private_ip_address = "10.0.1.11" }
    "PANF-1.OUTDOOR" = { instance_key = "PANF-1", private_ip_address = "10.0.2.11" }
    "PANF-2.INDOOR"  = { instance_key = "PANF-2", private_ip_address = "10.0.1.12" }
    "PANF-2.OUTDOOR" = { instance_key = "PANF-2", private_ip_address = "10.0.2.12" }
  }
}

resource "terraform_data" "workload_secondary_vnic" {
  for_each = local.workload_secondary_vnic_configuration
  input = {
    instance_id        = terraform_data.firewall_vm[each.value.instance_key].id
    private_ip_address = each.value.private_ip_address
  }
}

locals {
  nlb_backend_configuration = {
    "INDOOR-1"  = "PANF-1.INDOOR"
    "INDOOR-2"  = "PANF-2.INDOOR"
    "OUTDOOR-1" = "PANF-1.OUTDOOR"
    "OUTDOOR-2" = "PANF-2.OUTDOOR"
  }

  private_ip_targets_dependency = {
    for key, private_ip in terraform_data.vnic_primary_private_ip : key => {
      id = private_ip.output.id
    }
  }
}

resource "terraform_data" "vnic_primary_private_ip" {
  for_each = toset(values(local.nlb_backend_configuration))
  input = {
    vnic_id = terraform_data.workload_secondary_vnic[each.key].id
    id      = "ocid1.privateip.oc1.iad.${lower(replace(each.key, ".", "-"))}"
  }
}

resource "terraform_data" "nlb_backend" {
  for_each = local.nlb_backend_configuration
  input = {
    ip_address = null
    target_id  = local.private_ip_targets_dependency[each.value].id
  }
}

resource "terraform_data" "nlb_route_target" {
  for_each   = toset(["INDOOR-NLB", "OUTDOOR-NLB"])
  input      = "ocid1.privateip.oc1.iad.${lower(each.key)}"
  depends_on = [terraform_data.nlb_backend]
}

resource "terraform_data" "internet_gateway" {
  input = {
    vcn_id = terraform_data.vcn.output
    route_table_ids = [
      module.completion.provisioned_igw_natgw_specific_route_tables["RT1"].id,
    ]
  }
}

resource "terraform_data" "nat_gateway" {
  input = {
    vcn_id = terraform_data.vcn.output
    route_table_ids = [
      module.completion.provisioned_igw_natgw_specific_route_tables["RT1"].id,
    ]
  }
}

resource "terraform_data" "service_gateway" {
  input = {
    vcn_id = terraform_data.vcn.output
    route_table_ids = [
      module.completion.provisioned_igw_natgw_specific_route_tables["RT1"].id,
      module.completion.provisioned_sgw_specific_route_tables["RT2"].id,
    ]
  }
}

resource "terraform_data" "dynamic_gateway" {
  input = "ocid1.drg.oc1.iad.fixture"
}

resource "terraform_data" "local_peering_gateway" {
  input = {
    vcn_id = terraform_data.vcn.output
    route_table_ids = [
      module.completion.provisioned_igw_natgw_specific_route_tables["RT1"].id,
      module.completion.provisioned_lpg_specific_route_tables["RT3"].id,
    ]
  }
}

resource "terraform_data" "drg_attachment" {
  input = {
    drg_id = terraform_data.dynamic_gateway.id
    route_table_ids = [
      module.completion.provisioned_igw_natgw_specific_route_tables["RT1"].id,
      module.completion.provisioned_lpg_specific_route_tables["RT3"].id,
      module.completion.provisioned_drga_specific_route_tables["RT4"].id,
    ]
  }
}

locals {
  custom_route_table_common = {
    compartment_id                 = "ocid1.compartment.oc1..fixture"
    defined_tags                   = {}
    freeform_tags                  = {}
    network_configuration_category = "fixture"
    vcn_id                         = terraform_data.vcn.output
    vcn_key                        = "VCN"
    vcn_name                       = "fixture-vcn"
  }

  default_route_table_common = merge(local.custom_route_table_common, {
    default_route_table_key = "CUSTOM-DEFAULT-ROUTE-TABLE-VCN"
  })
}

module "completion" {
  source = "../../modules/network-completion"

  default_route_table_ids_by_vcn = {
    VCN = "ocid1.routetable.oc1.iad.default-fixture"
  }

  external_private_ip_targets = {
    for key, target in terraform_data.nlb_route_target : key => { id = target.output }
  }
  managed_private_ip_targets = {
    MANAGED-PRIVATE-IP = { id = terraform_data.managed_private_ip.output }
  }
  network_firewall_private_ip_targets = {
    NATIVE-NFW = { id = terraform_data.network_firewall_private_ip.output }
  }
  internet_gateway_targets = {
    IGW = { id = terraform_data.internet_gateway.id }
  }
  nat_gateway_targets = {
    NAT = { id = terraform_data.nat_gateway.id }
  }
  service_gateway_targets = {
    SGW = { id = terraform_data.service_gateway.id }
  }
  dynamic_gateway_targets = {
    DRG = { id = terraform_data.dynamic_gateway.id }
  }
  local_peering_gateway_targets = {
    LPG = { id = terraform_data.local_peering_gateway.id }
  }

  igw_natgw_specific_route_tables = {
    RT1 = merge(local.custom_route_table_common, {
      display_name = "rt-1"
      route_rules = {
        nlb = {
          destination        = "0.0.0.0/0"
          destination_type   = "CIDR_BLOCK"
          network_entity_id  = null
          network_entity_key = "INDOOR-NLB"
          description        = "Computed NLB private IP"
        }
        literal = {
          destination        = "10.1.0.0/16"
          destination_type   = "CIDR_BLOCK"
          network_entity_id  = "ocid1.privateip.oc1.iad.external-fixture"
          network_entity_key = null
          description        = "Literal private IP OCID"
        }
      }
    })
  }

  sgw_specific_route_tables = {
    RT2 = merge(local.custom_route_table_common, {
      display_name = "rt-2"
      route_rules = {
        drg = {
          destination        = "10.2.0.0/16"
          destination_type   = "CIDR_BLOCK"
          network_entity_id  = null
          network_entity_key = "DRG"
          description        = "DRG target"
        }
      }
    })
  }

  lpg_specific_route_tables = {
    RT3 = merge(local.custom_route_table_common, {
      display_name = "rt-3"
      route_rules = {
        sgw = {
          destination        = "all-iad-services-in-oracle-services-network"
          destination_type   = "SERVICE_CIDR_BLOCK"
          network_entity_id  = null
          network_entity_key = "SGW"
          description        = "Service gateway target"
        }
      }
    })
  }

  drga_specific_route_tables = {
    RT4 = merge(local.custom_route_table_common, {
      display_name = "rt-4"
      route_rules = {
        lpg = {
          destination        = "10.4.0.0/16"
          destination_type   = "CIDR_BLOCK"
          network_entity_id  = null
          network_entity_key = "LPG"
          description        = "LPG target"
        }
      }
    })
  }

  non_gw_specific_remaining_route_tables = {
    RT5 = merge(local.custom_route_table_common, {
      display_name = "rt-5"
      route_rules = {
        igw = {
          destination        = "0.0.0.0/0"
          destination_type   = "CIDR_BLOCK"
          network_entity_id  = null
          network_entity_key = "IGW"
          description        = "Internet gateway target"
        }
        nat = {
          destination        = "10.5.0.0/16"
          destination_type   = "CIDR_BLOCK"
          network_entity_id  = null
          network_entity_key = "NAT"
          description        = "NAT gateway target"
        }
        native_nfw = {
          destination        = "10.6.0.0/16"
          destination_type   = "CIDR_BLOCK"
          network_entity_id  = null
          network_entity_key = "NATIVE-NFW"
          description        = "Native firewall target"
        }
      }
    })
  }

  igw_natgw_specific_default_route_tables = {
    DRT1 = merge(local.default_route_table_common, {
      display_name = "default-rt-1"
      route_rules = {
        managed = {
          destination        = "10.11.0.0/16"
          destination_type   = "CIDR_BLOCK"
          network_entity_id  = null
          network_entity_key = "MANAGED-PRIVATE-IP"
          description        = "Managed private IP target"
        }
      }
    })
  }

  sgw_specific_default_route_tables = {
    DRT2 = merge(local.default_route_table_common, {
      display_name = "default-rt-2"
      route_rules = {
        drg = {
          destination        = "10.12.0.0/16"
          destination_type   = "CIDR_BLOCK"
          network_entity_id  = null
          network_entity_key = "DRG"
          description        = "DRG target"
        }
      }
    })
  }

  lpg_specific_default_route_tables = {
    DRT3 = merge(local.default_route_table_common, {
      display_name = "default-rt-3"
      route_rules = {
        sgw = {
          destination        = "all-iad-services-in-oracle-services-network"
          destination_type   = "SERVICE_CIDR_BLOCK"
          network_entity_id  = null
          network_entity_key = "SGW"
          description        = "Service gateway target"
        }
      }
    })
  }

  drga_specific_default_route_tables = {
    DRT4 = merge(local.default_route_table_common, {
      display_name = "default-rt-4"
      route_rules = {
        lpg = {
          destination        = "10.14.0.0/16"
          destination_type   = "CIDR_BLOCK"
          network_entity_id  = null
          network_entity_key = "LPG"
          description        = "LPG target"
        }
      }
    })
  }

  non_gw_specific_remaining_default_route_tables = {
    DRT5 = merge(local.default_route_table_common, {
      display_name = "default-rt-5"
      route_rules = {
        igw = {
          destination        = "0.0.0.0/0"
          destination_type   = "CIDR_BLOCK"
          network_entity_id  = null
          network_entity_key = "IGW"
          description        = "Internet gateway target"
        }
      }
    })
  }

  route_table_attachments = {
    SUBNET = {
      default_route_table_id         = "ocid1.routetable.oc1.iad.default-fixture"
      network_configuration_category = "fixture"
      route_table_id                 = null
      route_table_key                = "RT5"
      subnet_id                      = terraform_data.subnet.output
      subnet_name                    = "fixture-subnet"
      vcn_key                        = "VCN"
      vcn_name                       = "fixture-vcn"
    }
  }
}

# Verify that empty firewall and custom route-table partitions remain valid.
module "completion_without_firewalls" {
  source = "../../modules/network-completion"

  default_route_table_ids_by_vcn = {
    VCN = "ocid1.routetable.oc1.iad.default-fixture"
  }

  route_table_attachments = {
    NO-FIREWALL-SUBNET = {
      default_route_table_id         = "ocid1.routetable.oc1.iad.default-fixture"
      network_configuration_category = "fixture"
      route_table_id                 = null
      route_table_key                = "default_route_table"
      subnet_id                      = terraform_data.no_firewall_subnet.output
      subnet_name                    = "no-firewall-subnet"
      vcn_key                        = "VCN"
      vcn_name                       = "fixture-vcn"
    }
  }
}
