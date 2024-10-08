# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Thu Nov 23 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

network_configuration = {
  default_compartment_id    = "ocid1.compartment.oc1....."
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
            // Callout 5 - Traffic leaving Subnet H
            // Subnet Egress Route Table
            SUBNET-H-RT-KEY = {
              display_name = "subnet-h-rt"
              route_rules = {
                TO-ON-PREMISES-KEY = {
                  network_entity_key = "DRG-HUB-KEY"
                  description        = "Route for accessing the on-premises environment through the DRG"
                  destination        = "172.16.0.0/16"
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
            // Ingress Routes table - from DRGA-VCN-HUB to HUB-VCN
            // To be attahed to the VCN-HUB-DRG-Attachment
            // Sending all traffic that enters the HUB VCN, from the DRG, to the NFW for N-S and E-W inspection
            // You need this Route table only if you have a FW(Native or 3rd party) in the HUB-VCN for N-S and E-W traffic inspection
            VCN-H-INGRESS-RT-KEY = {
              display_name = "vcn-h-ingress-rt"
              // The route rules bellow will be provisioned in 2 steps:
              //    - STEP 1: Run the configuration with no route rules in this route table
              //    - STEP 2: After STEP 1 run succesfully, copy the private_ip OCID of the NFW from the STEP 1 output, and use that to replace the content 
              //              of network_entity_id for all the 4 route rules bellow.   
              route_rules = {
                /*
                ON-PREMISES-TO-NFW-PrivateIP-KEY = {
                  network_entity_id = "ocid1.privateip.oc1.eu-frankfurt-1.abtheljsvivbkzts7cim5cjttqlw2dv24h6l75naqc7sgp4oegod32odiqwa"
                  description       = "Route for fwd-ing traffic that has as destination the on-premises through the NFW"
                  destination       = "172.16.0.0/16"
                  destination_type  = "CIDR_BLOCK"
                }
                VCN-A-TO-NFW-PrivateIP-KEY = {
                  network_entity_id = "ocid1.privateip.oc1.eu-frankfurt-1.abtheljsvivbkzts7cim5cjttqlw2dv24h6l75naqc7sgp4oegod32odiqwa"
                  description       = "Route for fwd-ing traffic that has as destination the VCN-A through the NFW"
                  destination       = "192.168.10.0/24"
                  destination_type  = "CIDR_BLOCK"
                }
                VCN-B-TO-NFW-PrivateIP-KEY = {
                  network_entity_id = "ocid1.privateip.oc1.eu-frankfurt-1.abtheljsvivbkzts7cim5cjttqlw2dv24h6l75naqc7sgp4oegod32odiqwa"
                  description       = "Route for fwd-ing traffic that has as destination the VCN-B through the NFW"
                  destination       = "192.168.20.0/24"
                  destination_type  = "CIDR_BLOCK"
                }
                VCN-C-TO-NFW-PrivateIP-KEY = {
                  network_entity_id = "ocid1.privateip.oc1.eu-frankfurt-1.abtheljsvivbkzts7cim5cjttqlw2dv24h6l75naqc7sgp4oegod32odiqwa"
                  description       = "Route for fwd-ing traffic that has as destination the VCN-C through the NFW"
                  destination       = "192.168.30.0/24"
                  destination_type  = "CIDR_BLOCK"
                }
                */
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
              // Callout 5 - Traffic leaving Subnet H
              // Subnet Egress Route Table
              route_table_key    = "SUBNET-H-RT-KEY"
              security_list_keys = ["default_security_list"]
            }
          }
        }
      }
      non_vcn_specific_gateways = {
        dynamic_routing_gateways = {
          DRG-HUB-KEY = {
            display_name = "drg-hub"
            drg_route_tables = {
              // Callout 1
              // DRG ingress - from DRG-Attachments to DRG
              // Attached to the DRG Attachments - expect the HUB-VCN DRG-Attachment
              // Sending all default traffic to the HUB VCN via the DRG-Attachment
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
              // Callout 2
              // Ingress Routes table - entering DRG through DRG-A-VCN-HUB
              // BGP - dynamic routing
              DRG-RT-HUB-KEY = {
                display_name    = "drg-rt-hub"
                is_ecmp_enabled = false
                // Import dynamic routes
                import_drg_route_distribution_key = "IMPORT-HUB-RTD-KEY",
                route_rules = {
                  // NO STATIC ROUTES NEEDED
                }
              }
            }
            drg_route_distributions = {
              IMPORT-HUB-RTD-KEY = {
                distribution_type = "IMPORT"
                display_name      = "import_hub_rtd"
                statements = {
                  ROUTE-TO-VCN-A-KEY = {
                    action = "ACCEPT",
                    match_criteria = {
                      match_type         = "DRG_ATTACHMENT_ID",
                      attachment_type    = "VCN",
                      drg_attachment_key = "DRG-HUB-VCN-A-ATTACH-KEY"
                    }
                    priority = 10
                  }
                  ROUTE-TO-VCN-B-KEY = {
                    action = "ACCEPT",
                    match_criteria = {
                      match_type         = "DRG_ATTACHMENT_ID",
                      attachment_type    = "VCN",
                      drg_attachment_key = "DRG-HUB-VCN-B-ATTACH-KEY"
                    }
                    priority = 20
                  }
                  ROUTE-TO-VCN-C-KEY = {
                    action = "ACCEPT",
                    match_criteria = {
                      match_type         = "DRG_ATTACHMENT_ID",
                      attachment_type    = "VCN",
                      drg_attachment_key = "DRG-HUB-VCN-C-ATTACH-KEY"
                    }
                    priority = 30
                  }
                  ROUTE-TO-ON-PREMISES-FC-KEY = {
                    action = "ACCEPT",
                    match_criteria = {
                      match_type         = "DRG_ATTACHMENT_ID",
                      attachment_type    = "VIRTUAL_CIRCUIT",
                      drg_attachment_key = "VISON-FC-VC-1-KEY"
                    }
                    priority = 40
                  }
                }
              }
            }
            drg_attachments = {
              DRG-HUB-VCN-H-ATTACH-KEY = {
                display_name = "drg-hub-vcn-h-attach"
                // Ingress Routes table - entering DRG through DRG-A-VCN-HUB
                drg_route_table_key = "DRG-RT-HUB-KEY"
                network_details = {
                  attached_resource_key = "VCN-HUB-KEY"
                  type                  = "VCN"
                  // Egress Routes table - from DRGA-VCN-HUB to HUB-VCN
                  // Route traffic than enters HUB VCN to the NFW
                  route_table_key = "VCN-H-INGRESS-RT-KEY"
                }
              }
              DRG-HUB-VCN-A-ATTACH-KEY = {
                display_name = "drg-hub-vcn-a-attach"
                // Ingress Routes table - entering DRG through DRG-A-VCN-B
                drg_route_table_key = "DRG-RT-SPOKE-KEY"
                network_details = {
                  attached_resource_key = "VCN-A-KEY"
                  type                  = "VCN"
                }
              }
              DRG-HUB-VCN-B-ATTACH-KEY = {
                display_name = "drg-hub-vcn-b-attach"
                // Ingress Routes table - entering DRG through DRG-A-VCN-B
                drg_route_table_key = "DRG-RT-SPOKE-KEY"
                network_details = {
                  attached_resource_key = "VCN-B-KEY"
                  type                  = "VCN"
                }
              }
              DRG-HUB-VCN-C-ATTACH-KEY = {
                display_name = "drg-hub-vcn-c-attach"
                // Ingress Routes table - entering DRG through DRG-A-VCN-C
                drg_route_table_key = "DRG-RT-SPOKE-KEY"
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
        network_firewalls_configuration = {
          network_firewalls = {
            HUB-NFW-KEY = {
              display_name                = "hub_nfw"
              subnet_key                  = "SUBNET-H-KEY"
              ipv4address                 = "10.0.0.10"
              network_firewall_policy_key = "HUB-NFW-POLICY"
            }
          }
          network_firewall_policies = {
            HUB-NFW-POLICY = {
              display_name = "hubnfw-policy"
              applications = {
                HUBNFW-APP-1 = {
                  name      = "hubnfw-app-1"
                  type      = "ICMP"
                  icmp_type = "128"
                }
              }
              application_lists = {
                HUBNFW-APP-LIST = {
                  name = "hubnfw-app-list"
                  applications = ["HUBNFW-APP-1"]
                }
              }
              address_lists = {
                HUBNFW-IP-LIST = {
                  name      = "hubnfw-ip-list"
                  addresses = ["10.0.0.1"]
                  type      = "IP"
                }
              }
              url_lists = {
                HUBNFW-URL-1 = {
                  name    = "hubnfw-url-1",
                  type    = "SIMPLE"
                  pattern = "www.oracle.com"
                }
                HUBNFW-URL-2 = {
                  name    = "hubnfw-url-2",
                  type    = "SIMPLE"
                  pattern = "www.google.com"
                }
              }
              security_rules = {
                SECURITY-RULE-A = {
                  action              = "ALLOW"
                  name                = "security-rule-a"
                  application_lists         = []
                  destination_address_lists = ["HUBNFW-IP-LIST"]
                  source_address_lists      = []
                  url_lists                 = ["HUBNFW-URL-1"]
                }
                SECURITY-RULE-B = {
                  action              = "INSPECT"
                  inspection          = "INTRUSION_DETECTION"
                  name                = "security-rule-b"
                  application         = ["HUBNFW-APP-LIST"]
                  destination_address = []
                  source_address      = ["HUBNFW-IP-LIST"]
                  url_lists           = ["HUBNFW-URL-2"]
                }
              }
            }
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
            // Callout 3 - Traffic leaving Subnet 1
            SUBNET-1-RT-KEY = {
              display_name = "subnet-1-rt"
              route_rules = {
                TO-ON-PREMISES-KEY = {
                  network_entity_key = "DRG-HUB-KEY"
                  description        = "Route for accessing the on-premises environment through the DRG"
                  destination        = "172.16.0.0/16"
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
              // Callout 3 - Traffic leaving Subnet 1
              route_table_key    = "SUBNET-1-RT-KEY"
              security_list_keys = ["default_security_list"]
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
            // Callout 6 - Traffic leaving Subnet 2
            SUBNET-2-RT-KEY = {
              display_name = "subnet-2-rt"
              route_rules = {
                TO-ON-PREMISES-KEY = {
                  network_entity_key = "DRG-HUB-KEY"
                  description        = "Route for accessing the on-premises environment through the DRG"
                  destination        = "172.16.0.0/16"
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
              // Callout 6 - Traffic leaving Subnet 2
              route_table_key    = "SUBNET-2-RT-KEY"
              security_list_keys = ["default_security_list"]
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
            // Callout 7 - Traffic leaving Subnet 3
            SUBNET-3-RT-KEY = {
              display_name = "subnet-3-rt"
              route_rules = {
                TO-ON-PREMISES-KEY = {
                  network_entity_key = "DRG-HUB-KEY"
                  description        = "Route for accessing the on-premises environment through the DRG"
                  destination        = "172.16.0.0/16"
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
              // Callout 7 - Traffic leaving Subnet 3
              route_table_key    = "SUBNET-3-RT-KEY"
              security_list_keys = ["default_security_list"]
            }
          }
        }
      }
    }
  }
}