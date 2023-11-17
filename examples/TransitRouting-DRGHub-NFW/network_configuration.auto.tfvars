# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Fri Nov 17 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

network_configuration = {
  default_compartment_id = "ocid1.compartment.oc1..aaaaaaaaqgesrpmt675pazv7mjz7sscaruh4z5yoww7jupwbeizsqm4yl7ea"
  default_freeform_tags = {
    "vision-environment" = "vision"
  }
  default_enable_cis_checks = false

  network_configuration_categories = {
    HUB = {
      category_freeform_tags = {
        "vision-sub-environment" = "hub"
      }
      vcns = {
        VCN-HUB-KEY = {
          display_name                     = "VCN-Hub"
          is_ipv6enabled                   = false
          is_oracle_gua_allocation_enabled = false
          cidr_blocks                      = ["10.0.0.0/24"],
          dns_label                        = "vcnhub"
          is_create_igw                    = false
          is_attach_drg                    = false
          block_nat_traffic                = false
          default-security-list = {
            egress_rules = [
              {
                description = "egress to 0.0.0.0/0 over ALL protocols"
                stateless   = false
                protocol    = "ALL"
                dst         = "0.0.0.0/0"
                dst_type    = "CIDR_BLOCK"
              }
            ]

            ingress_rules = [
              {
                description  = "ingress from 0.0.0.0/0 over TCP22"
                stateless    = false
                protocol     = "TCP"
                src          = "0.0.0.0/0"
                src_type     = "CIDR_BLOCK"
                dst_port_min = 22
                dst_port_max = 22
              },
              {
                description  = "ingress from 0.0.0.0/0 over TCP443"
                stateless    = false
                protocol     = "TCP"
                src          = "0.0.0.0/0"
                src_type     = "CIDR_BLOCK"
                dst_port_min = 443
                dst_port_max = 443
              }
            ]
          }

          route_tables = {
            SUBNET-H-RT-KEY = {
              display_name = "subnet-h-rt"
              route_rules = {
                TO-ON-PREMISES-KEY = {
                  network_entity_key = "DRG-HUB-KEY"
                  description        = "Route for accessing the on-premises environment through the DRG"
                  destination        = "0.0.0.0/0"
                  destination_type   = "CIDR_BLOCK"
                }
                TO-VCN-A-KEY = {
                  network_entity_key = "DRG-HUB-KEY"
                  description        = "Route for accessing VCN-A through the DRG"
                  destination        = "192.168.10.0/24"
                  destination_type   = "CIDR_BLOCK"
                }
                TO-VCN-B-KEY = {
                  network_entity_key = "DRG-HUB-KEY"
                  description        = "Route for accessing VCN-B through the DRG"
                  destination        = "192.168.20.0/24"
                  destination_type   = "CIDR_BLOCK"
                }
                TO-VCN-C-KEY = {
                  network_entity_key = "DRG-HUB-KEY"
                  description        = "Route for accessing VCN-c through the DRG"
                  destination        = "192.168.30.0/24"
                  destination_type   = "CIDR_BLOCK"
                }
              }
            }
            VCN-H-INGRESS-RT-KEY = {
              display_name = "vcn-h-ingress-rt"
              route_rules = {
                /*ON-PREMISES-TO-NFW-PrivateIP-KEY = {
                  network_entity_id = "OCID of the NFW Private IP"
                  description        = "Route for fwd-ing traffic that has as destination the on-premises through the NFW"
                  destination        = "0.0.0.0/0"
                  destination_type   = "CIDR_BLOCK"
                }
                VCN-A-TO-NFW-PrivateIP-KEY = {
                  network_entity_id = "OCID of the NFW Private IP"
                  description        = "Route for fwd-ing traffic that has as destination the VCN-A through the NFW"
                  destination        = "192.168.10.0/24"
                  destination_type   = "CIDR_BLOCK"
                }
                VCN-B-TO-NFW-PrivateIP-KEY = {
                  network_entity_id = "OCID of the NFW Private IP"
                  description        = "Route for fwd-ing traffic that has as destination the VCN-B through the NFW"
                  destination        = "192.168.20.0/24"
                  destination_type   = "CIDR_BLOCK"
                }
                VCN-C-TO-NFW-PrivateIP-KEY = {
                  network_entity_id = "OCID of the NFW Private IP"
                  description        = "Route for fwd-ing traffic that has as destination the VCN-C through the NFW"
                  destination        = "192.168.30.0/24"
                  destination_type   = "CIDR_BLOCK"
                }*/
              }
            }
          }

          subnets = {
            SUBNET-H-KEY = {
              cidr_block                 = "10.0.0.0/24"
              dhcp_options_key           = "default_dhcp_options"
              display_name               = "subneth-vcn-h"
              dns_label                  = "subnethvcnh"
              ipv6cidr_blocks            = []
              prohibit_internet_ingress  = true
              prohibit_public_ip_on_vnic = true
              route_table_key            = "SUBNET-H-RT-KEY"
              security_list_keys         = ["default_security_list"]
            }
          }

          network_security_groups = {
            NSG-VCN-H-KEY = {
              display_name = "nsg-vcn-h"
              egress_rules = {
                anywhere = {
                  description = "egress to 0.0.0.0/0 over TCP"
                  stateless   = false
                  protocol    = "TCP"
                  dst         = "0.0.0.0/0"
                  dst_type    = "CIDR_BLOCK"
                }
              }
              ingress_rules = {
                ssh_22 = {
                  description  = "ingress from 0.0.0.0/0 over TCP22"
                  stateless    = false
                  protocol     = "TCP"
                  src          = "0.0.0.0/0"
                  src_type     = "CIDR_BLOCK"
                  dst_port_min = 22
                  dst_port_max = 22
                }
                http_443 = {
                  description  = "ingress from 0.0.0.0/0 over https:443"
                  stateless    = false
                  protocol     = "TCP"
                  src          = "0.0.0.0/0"
                  src_type     = "CIDR_BLOCK"
                  dst_port_min = 443
                  dst_port_max = 443
                }
              }
            }
          }
        }
      }
      non_vcn_specific_gateways = {
        dynamic_routing_gateways = {
          DRG-HUB-KEY = {
            display_name = "drg-hub"
            drg_route_tables = {
              DRG-RT-SPOKE-KEY = {
                display_name    = "drg-rt-spoke"
                is_ecmp_enabled = false
                route_rules = {
                  ALL-TRAFFIC-FROM-SPOKES-TO-HUB-KEY = {
                    destination                 = "0.0.0.0/0"
                    destination_type            = "CIDR_BLOCK"
                    next_hop_drg_attachment_key = "DRG-HUB-VCN-H-ATTACH-KEY"
                  }
                }
              }
              DRG-RT-HUB-KEY = {
                display_name    = "drg-rt-hub"
                is_ecmp_enabled = false
                route_rules = {
                  TO-FC-VC-KEY = {
                    destination                 = "172.16.0.0/16"
                    destination_type            = "CIDR_BLOCK"
                    next_hop_drg_attachment_key = "VISON-FC-VC-1-KEY"
                  }
                  TO-VCN-A-KEY = {
                    destination                 = "192.168.10.0/24"
                    destination_type            = "CIDR_BLOCK"
                    next_hop_drg_attachment_key = "DRG-HUB-VCN-A-ATTACH-KEY"
                  }
                  TO-VCN-B-KEY = {
                    destination                 = "192.168.20.0/24"
                    destination_type            = "CIDR_BLOCK"
                    next_hop_drg_attachment_key = "DRG-HUB-VCN-B-ATTACH-KEY"
                  }
                  TO-VCN-C-KEY = {
                    destination                 = "192.168.30.0/24"
                    destination_type            = "CIDR_BLOCK"
                    next_hop_drg_attachment_key = "DRG-HUB-VCN-C-ATTACH-KEY"
                  }
                }
              }
            }
            drg_attachments = {
              DRG-HUB-VCN-H-ATTACH-KEY = {
                display_name = "drg-hub-vcn-h-attach"
                network_details = {
                  attached_resource_key = "VCN-HUB-KEY"
                  type                  = "VCN"
                }
              }
              DRG-HUB-VCN-A-ATTACH-KEY = {
                display_name = "drg-hub-vcn-a-attach"
                network_details = {
                  attached_resource_key = "VCN-A-KEY"
                  type                  = "VCN"
                }
              }
              DRG-HUB-VCN-B-ATTACH-KEY = {
                display_name = "drg-hub-vcn-b-attach"
                network_details = {
                  attached_resource_key = "VCN-B-KEY"
                  type                  = "VCN"
                }
              }
              DRG-HUB-VCN-C-ATTACH-KEY = {
                display_name = "drg-hub-vcn-c-attach"
                network_details = {
                  attached_resource_key = "VCN-C-KEY"
                  type                  = "VCN"
                }
              }
            }

          }
        }
        fast_connect_virtual_circuits = {
          VISON-FC-VC-1-KEY = {
            type                                        = "PRIVATE",
            provision_fc_virtual_circuit                = true
            show_available_fc_virtual_circuit_providers = false
            #Optional
            bandwidth_shape_name = "1 Gbps",
            # provider_service_id  = "ocid1.providerservice.oc1.eu-frankfurt-1.aaaaaaaauyqhkug34caqfdamhfyt7gnrwlkghwnm5q2xkazvuj7zkyntgilq", # Follow this procedure for getting the ocid https://docs.oracle.com/en-us/iaas/tools/oci-cli/3.31.1/oci_cli_docs/cmdref/network/fast-connect-provider-service/list.html
            provider_service_key = "VISION-FC-VC-01-EQUINIX-FABRIC-KEY"
            customer_asn         = "65000"
            cross_connect_mappings = {
              MAPPING-1-KEY = {
                #Optional
                customer_bgp_peering_ip = "172.168.3.1/30"
                oracle_bgp_peering_ip   = "172.168.3.2/30"
              }
            }
            display_name = "vision_fc_vc_01"
            gateway_key  = "DRG-HUB-KEY"
          }
        }
      }
    }

    SPOKES = {
      category_freeform_tags = {
        "vision-sub-environment" = "spokes"
      }
      vcns = {
        VCN-A-KEY = {
          display_name                     = "VCN-A"
          is_ipv6enabled                   = false
          is_oracle_gua_allocation_enabled = false
          cidr_blocks                      = ["192.168.10.0/24"],
          dns_label                        = "vcna"
          is_create_igw                    = false
          is_attach_drg                    = false
          block_nat_traffic                = false
          default-security-list = {
            egress_rules = [
              {
                description = "egress to 0.0.0.0/0 over ALL protocols"
                stateless   = false
                protocol    = "ALL"
                dst         = "0.0.0.0/0"
                dst_type    = "CIDR_BLOCK"
              }
            ]

            ingress_rules = [
              {
                description  = "ingress from 0.0.0.0/0 over TCP22"
                stateless    = false
                protocol     = "TCP"
                src          = "0.0.0.0/0"
                src_type     = "CIDR_BLOCK"
                dst_port_min = 22
                dst_port_max = 22
              },
              {
                description  = "ingress from 0.0.0.0/0 over TCP443"
                stateless    = false
                protocol     = "TCP"
                src          = "0.0.0.0/0"
                src_type     = "CIDR_BLOCK"
                dst_port_min = 443
                dst_port_max = 443
              }
            ]
          }

          route_tables = {
            SUBNET-1-RT-KEY = {
              display_name = "subnet-1-rt"
              route_rules = {
                TO-ON-PREMISES-KEY = {
                  network_entity_key = "DRG-HUB-KEY"
                  description        = "Route for accessing the on-premises environment through the DRG"
                  destination        = "0.0.0.0/0"
                  destination_type   = "CIDR_BLOCK"
                }
                TO-VCN-B-KEY = {
                  network_entity_key = "DRG-HUB-KEY"
                  description        = "Route for accessing VCN-B through the DRG"
                  destination        = "192.168.20.0/24"
                  destination_type   = "CIDR_BLOCK"
                }
                TO-VCN-C-KEY = {
                  network_entity_key = "DRG-HUB-KEY"
                  description        = "Route for accessing VCN-c through the DRG"
                  destination        = "192.168.30.0/24"
                  destination_type   = "CIDR_BLOCK"
                }
              }
            }
          }

          subnets = {
            SUBNET-1-KEY = {
              cidr_block                 = "192.168.10.0/24"
              dhcp_options_key           = "default_dhcp_options"
              display_name               = "subnet1"
              dns_label                  = "subnet1"
              ipv6cidr_blocks            = []
              prohibit_internet_ingress  = true
              prohibit_public_ip_on_vnic = true
              route_table_key            = "SUBNET-1-RT-KEY"
              security_list_keys         = ["default_security_list"]
            }
          }

          network_security_groups = {
            NSG-VCN-A-KEY = {
              display_name = "nsg-vcn-a"
              egress_rules = {
                anywhere = {
                  description = "egress to 0.0.0.0/0 over TCP"
                  stateless   = false
                  protocol    = "TCP"
                  dst         = "0.0.0.0/0"
                  dst_type    = "CIDR_BLOCK"
                }
              }
              ingress_rules = {
                ssh_22 = {
                  description  = "ingress from 0.0.0.0/0 over TCP22"
                  stateless    = false
                  protocol     = "TCP"
                  src          = "0.0.0.0/0"
                  src_type     = "CIDR_BLOCK"
                  dst_port_min = 22
                  dst_port_max = 22
                }
                http_443 = {
                  description  = "ingress from 0.0.0.0/0 over https:443"
                  stateless    = false
                  protocol     = "TCP"
                  src          = "0.0.0.0/0"
                  src_type     = "CIDR_BLOCK"
                  dst_port_min = 443
                  dst_port_max = 443
                }
              }
            }
          }
        }

        VCN-B-KEY = {
          display_name                     = "VCN-B"
          is_ipv6enabled                   = false
          is_oracle_gua_allocation_enabled = false
          cidr_blocks                      = ["192.168.20.0/24"],
          dns_label                        = "vcnb"
          is_create_igw                    = false
          is_attach_drg                    = false
          block_nat_traffic                = false
          default-security-list = {
            egress_rules = [
              {
                description = "egress to 0.0.0.0/0 over ALL protocols"
                stateless   = false
                protocol    = "ALL"
                dst         = "0.0.0.0/0"
                dst_type    = "CIDR_BLOCK"
              }
            ]

            ingress_rules = [
              {
                description  = "ingress from 0.0.0.0/0 over TCP22"
                stateless    = false
                protocol     = "TCP"
                src          = "0.0.0.0/0"
                src_type     = "CIDR_BLOCK"
                dst_port_min = 22
                dst_port_max = 22
              },
              {
                description  = "ingress from 0.0.0.0/0 over TCP443"
                stateless    = false
                protocol     = "TCP"
                src          = "0.0.0.0/0"
                src_type     = "CIDR_BLOCK"
                dst_port_min = 443
                dst_port_max = 443
              }
            ]
          }

          route_tables = {
            SUBNET-2-RT-KEY = {
              display_name = "subnet-2-rt"
              route_rules = {
                TO-ON-PREMISES-KEY = {
                  network_entity_key = "DRG-HUB-KEY"
                  description        = "Route for accessing the on-premises environment through the DRG"
                  destination        = "0.0.0.0/0"
                  destination_type   = "CIDR_BLOCK"
                }
                TO-VCN-A-KEY = {
                  network_entity_key = "DRG-HUB-KEY"
                  description        = "Route for accessing VCN-A through the DRG"
                  destination        = "192.168.10.0/24"
                  destination_type   = "CIDR_BLOCK"
                }
                TO-VCN-C-KEY = {
                  network_entity_key = "DRG-HUB-KEY"
                  description        = "Route for accessing VCN-c through the DRG"
                  destination        = "192.168.30.0/24"
                  destination_type   = "CIDR_BLOCK"
                }
              }
            }
          }

          subnets = {
            SUBNET-2-KEY = {
              cidr_block                 = "192.168.20.0/24"
              dhcp_options_key           = "default_dhcp_options"
              display_name               = "subnet2"
              dns_label                  = "subnet2"
              ipv6cidr_blocks            = []
              prohibit_internet_ingress  = true
              prohibit_public_ip_on_vnic = true
              route_table_key            = "SUBNET-2-RT-KEY"
              security_list_keys         = ["default_security_list"]
            }
          }

          network_security_groups = {
            NSG-VCN-B-KEY = {
              display_name = "nsg-vcn-b"
              egress_rules = {
                anywhere = {
                  description = "egress to 0.0.0.0/0 over TCP"
                  stateless   = false
                  protocol    = "TCP"
                  dst         = "0.0.0.0/0"
                  dst_type    = "CIDR_BLOCK"
                }
              }
              ingress_rules = {
                ssh_22 = {
                  description  = "ingress from 0.0.0.0/0 over TCP22"
                  stateless    = false
                  protocol     = "TCP"
                  src          = "0.0.0.0/0"
                  src_type     = "CIDR_BLOCK"
                  dst_port_min = 22
                  dst_port_max = 22
                }
                http_443 = {
                  description  = "ingress from 0.0.0.0/0 over https:443"
                  stateless    = false
                  protocol     = "TCP"
                  src          = "0.0.0.0/0"
                  src_type     = "CIDR_BLOCK"
                  dst_port_min = 443
                  dst_port_max = 443
                }
              }
            }
          }
        }

        VCN-C-KEY = {
          display_name                     = "VCN-C"
          is_ipv6enabled                   = false
          is_oracle_gua_allocation_enabled = false
          cidr_blocks                      = ["192.168.30.0/24"],
          dns_label                        = "vcnc"
          is_create_igw                    = false
          is_attach_drg                    = false
          block_nat_traffic                = false
          default-security-list = {
            egress_rules = [
              {
                description = "egress to 0.0.0.0/0 over ALL protocols"
                stateless   = false
                protocol    = "ALL"
                dst         = "0.0.0.0/0"
                dst_type    = "CIDR_BLOCK"
              }
            ]

            ingress_rules = [
              {
                description  = "ingress from 0.0.0.0/0 over TCP22"
                stateless    = false
                protocol     = "TCP"
                src          = "0.0.0.0/0"
                src_type     = "CIDR_BLOCK"
                dst_port_min = 22
                dst_port_max = 22
              },
              {
                description  = "ingress from 0.0.0.0/0 over TCP443"
                stateless    = false
                protocol     = "TCP"
                src          = "0.0.0.0/0"
                src_type     = "CIDR_BLOCK"
                dst_port_min = 443
                dst_port_max = 443
              }
            ]
          }

          route_tables = {
            SUBNET-3-RT-KEY = {
              display_name = "subnet-3-rt"
              route_rules = {
                TO-ON-PREMISES-KEY = {
                  network_entity_key = "DRG-HUB-KEY"
                  description        = "Route for accessing the on-premises environment through the DRG"
                  destination        = "0.0.0.0/0"
                  destination_type   = "CIDR_BLOCK"
                }
                TO-VCN-A-KEY = {
                  network_entity_key = "DRG-HUB-KEY"
                  description        = "Route for accessing VCN-A through the DRG"
                  destination        = "192.168.10.0/24"
                  destination_type   = "CIDR_BLOCK"
                }
                TO-VCN-C-KEY = {
                  network_entity_key = "DRG-HUB-KEY"
                  description        = "Route for accessing VCN-B through the DRG"
                  destination        = "192.168.20.0/24"
                  destination_type   = "CIDR_BLOCK"
                }
              }
            }
          }

          subnets = {
            SUBNET-3-KEY = {
              cidr_block                 = "192.168.30.0/24"
              dhcp_options_key           = "default_dhcp_options"
              display_name               = "subnet3"
              dns_label                  = "subnet3"
              ipv6cidr_blocks            = []
              prohibit_internet_ingress  = true
              prohibit_public_ip_on_vnic = true
              route_table_key            = "SUBNET-3-RT-KEY"
              security_list_keys         = ["default_security_list"]
            }
          }

          network_security_groups = {
            NSG-VCN-C-KEY = {
              display_name = "nsg-vcn-c"
              egress_rules = {
                anywhere = {
                  description = "egress to 0.0.0.0/0 over TCP"
                  stateless   = false
                  protocol    = "TCP"
                  dst         = "0.0.0.0/0"
                  dst_type    = "CIDR_BLOCK"
                }
              }
              ingress_rules = {
                ssh_22 = {
                  description  = "ingress from 0.0.0.0/0 over TCP22"
                  stateless    = false
                  protocol     = "TCP"
                  src          = "0.0.0.0/0"
                  src_type     = "CIDR_BLOCK"
                  dst_port_min = 22
                  dst_port_max = 22
                }
                http_443 = {
                  description  = "ingress from 0.0.0.0/0 over https:443"
                  stateless    = false
                  protocol     = "TCP"
                  src          = "0.0.0.0/0"
                  src_type     = "CIDR_BLOCK"
                  dst_port_min = 443
                  dst_port_max = 443
                }
              }
            }
          }
        }
      }
    }
  }
}