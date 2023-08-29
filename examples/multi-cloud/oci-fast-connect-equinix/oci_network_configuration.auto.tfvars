network_configuration = {
  default_compartment_id = "ocid1.compartment.oc1........"  # To be provided
  default_freeform_tags = {
    "vision-environment" = "vision"
  }
  default_enable_cis_checks = false

  network_configuration_categories = {
    demo = {
      category_freeform_tags = {
        "vision-oci-fastconnect" = "demo"
      }

      vcns = {
        VISION-VCN-KEY = {
          display_name                     = "vision-vcn"
          is_ipv6enabled                   = false
          is_oracle_gua_allocation_enabled = false
          cidr_blocks                      = ["10.0.0.0/18"],
          dns_label                        = "visionvcn"
          is_create_igw                    = false
          is_attach_drg                    = false
          block_nat_traffic                = false

          security_lists = {

            SECLIST-LB-KEY = {
              display_name = "sl-lb"

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
            },

            SECLIST-APP-KEY = {
              display_name = "sl-app"

              egress_rules = [
                {
                  description = "egress to 0.0.0.0/0 over TCP"
                  stateless   = false
                  protocol    = "TCP"
                  dst         = "0.0.0.0/0"
                  dst_type    = "CIDR_BLOCK"
                }
              ]

              ingress_rules = [
                {
                  description  = "ingress from 172.16.0.0/16 over TCP22"
                  stateless    = false
                  protocol     = "TCP"
                  src          = "172.16.0.0/16"
                  src_type     = "CIDR_BLOCK"
                  dst_port_min = 22
                  dst_port_max = 22
                },
                {
                  description  = "ingress from 172.16.0.0/16 over HTTP80"
                  stateless    = false
                  protocol     = "TCP"
                  src          = "172.16.0.0/16"
                  src_type     = "CIDR_BLOCK"
                  dst_port_min = 80
                  dst_port_max = 80
                },
                {
                  description = "ingress from 172.16.0.0/16 over ICMP"
                  stateless   = false
                  protocol    = "ICMP"
                  src         = "172.16.0.0/16"
                  src_type    = "CIDR_BLOCK"
                }
              ]
            }
            SECLIST-DB-KEY = {
              display_name = "sl-db"

              egress_rules = [
                {
                  description = "egress to 0.0.0.0/0 over TCP"
                  stateless   = false
                  protocol    = "TCP"
                  dst         = "0.0.0.0/0"
                  dst_type    = "CIDR_BLOCK"
                }
              ]

              ingress_rules = [
                {
                  description = "ingress from 10.0.2.0/24 over TCP22"
                  stateless   = false
                  protocol    = "TCP"
                  src         = "10.0.2.0/24"
                  src_type    = "CIDR_BLOCK"
                },
                {
                  description  = "ingress from 10.0.2.0/24 over TCP:1521"
                  stateless    = false
                  protocol     = "TCP"
                  src          = "10.0.2.0/24"
                  src_type     = "CIDR_BLOCK"
                  dst_port_min = 1521
                  dst_port_max = 1521
                }
              ]
            }
          }

          route_tables = {
            RT-01-KEY = {
              display_name = "rt-01"
              route_rules = {
                internet_route = {
                  network_entity_key = "IGW-KEY"
                  description        = "Route for internet access"
                  destination        = "0.0.0.0/0"
                  destination_type   = "CIDR_BLOCK"
                }
              }
            }
            RT-02-KEY = {
              display_name = "rt-02"
              route_rules = {
                sgw-route = {
                  network_entity_key = "SGW-KEY"
                  description        = "Route for sgw"
                  destination        = "oci-fra-objectstorage"
                  destination_type   = "SERVICE_CIDR_BLOCK"
                },
                natgw-route = {
                  network_entity_key = "NATGW-KEY"
                  description        = "Route for internet access via NAT GW"
                  destination        = "0.0.0.0/0"
                  destination_type   = "CIDR_BLOCK"
                }
                drg-route-mc = {
                  network_entity_key = "DRG-VISION-KEY"
                  description        = "Route for Secondary Cloud via DRG"
                  destination        = "172.16.0.0/16"
                  destination_type   = "CIDR_BLOCK"
                },
                drg-route-partner = {
                  network_entity_key = "DRG-VISION-KEY"
                  description        = "Route to Connetcivity Partner via DRG"
                  destination        = "192.168.0.0/16"
                  destination_type   = "CIDR_BLOCK"
                }
              }
            }
          }

          subnets = {
            PUBLIC-LB-SUBNET-KEY = {
              cidr_block                 = "10.0.3.0/24"
              dhcp_options_key           = "default_dhcp_options"
              display_name               = "sub-public-lb"
              dns_label                  = "publiclb"
              ipv6cidr_blocks            = []
              prohibit_internet_ingress  = false
              prohibit_public_ip_on_vnic = false
              route_table_key            = "RT-01-KEY"
              security_list_keys         = ["SECLIST-LB-KEY"]
            }
            PRIVATE-APP-SUBNET-KEY = {
              cidr_block                 = "10.0.2.0/24"
              dhcp_options_key           = "default_dhcp_options"
              display_name               = "sub-private-app"
              dns_label                  = "privateapp"
              ipv6cidr_blocks            = []
              prohibit_internet_ingress  = true
              prohibit_public_ip_on_vnic = true
              route_table_key            = "RT-02-KEY"
              security_list_keys         = ["SECLIST-APP-KEY"]
            }
            PRIVATE-DB-SUBNET-KEY = {
              cidr_block                 = "10.0.1.0/24"
              dhcp_options_key           = "default_dhcp_options"
              display_name               = "sub-private-db"
              dns_label                  = "privatedb"
              ipv6cidr_blocks            = []
              prohibit_internet_ingress  = true
              prohibit_public_ip_on_vnic = true
              route_table_id             = null
              route_table_key            = "RT-02-KEY"
              security_list_keys         = ["SECLIST-DB-KEY"]
            }
          }

          network_security_groups = {
            NSG-LB-KEY = {
              display_name = "nsg-lb"
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
            },

            NSG-APP-KEY = {
              display_name = "nsg-app"
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
                  src          = "NSG-LB-KEY"
                  src_type     = "NETWORK_SECURITY_GROUP"
                  dst_port_min = 22
                  dst_port_max = 22
                }

                http_8080 = {
                  description  = "ingress from 0.0.0.0/0 over HTTP8080"
                  stateless    = false
                  protocol     = "TCP"
                  src          = "NSG-LB-KEY"
                  src_type     = "NETWORK_SECURITY_GROUP"
                  dst_port_min = 8080
                  dst_port_max = 8080
                }
              }
            }

            NSG-DB-KEY = {
              display_name = "nsg-db"
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
                  src          = "NSG-APP-KEY"
                  src_type     = "NETWORK_SECURITY_GROUP"
                  dst_port_min = 22
                  dst_port_max = 22
                }

                http_8080 = {
                  description  = "ingress from 0.0.0.0/0 over TCP:1521"
                  stateless    = false
                  protocol     = "TCP"
                  src          = "NSG-APP-KEY"
                  src_type     = "NETWORK_SECURITY_GROUP"
                  dst_port_min = 1521
                  dst_port_max = 1521
                }
              }
            }
          }

          vcn_specific_gateways = {
            internet_gateways = {
              IGW-KEY = {
                enabled      = true
                display_name = "igw-prod-vcn"
              }
            }
            nat_gateways = {
              NATGW-KEY = {
                block_traffic = false
                display_name  = "natgw-prod-vcn"
              }
            }
            service_gateways = {
              SGW-KEY = {
                display_name = "sgw-prod-vcn"
              }
            }
          }
        }
      }

      non_vcn_specific_gateways = {
        dynamic_routing_gateways = {
          DRG-VISION-KEY = {
            display_name = "drg-vision"
            drg_attachments = {
              DRG-VCN-ATTACH-VISION-KEY = {
                display_name = "drg-vcn-attach-vision"
                network_details = {
                  attached_resource_key = "VISION-VCN-KEY"
                  type                  = "VCN"
                }
              }
            }
          }
        }
        fast_connect_virtual_circuits = {
          FC-FRA-VC1-1-KEY = {
            type                                        = "PRIVATE",
            provision_fc_virtual_circuit                = true
            show_available_fc_virtual_circuit_providers = false
            #Optional
            bandwidth_shape_name = "1 Gbps",
            provider_service_id  = "ocid1.providerservice.oc1.eu-frankfurt-1..........", # Follow this procedure for getting the ocid https://docs.oracle.com/en-us/iaas/tools/oci-cli/3.31.1/oci_cli_docs/cmdref/network/fast-connect-provider-service/list.html
            customer_asn         = "65000"
            cross_connect_mappings = {
              MAPPING-1-KEY = {
                #Optional
                customer_bgp_peering_ip = "192.168.3.1/30"
                oracle_bgp_peering_ip   = "192.168.3.2/30"
              }
            }
            display_name = "VISION_VC_1"
            gateway_key  = "DRG-VISION-KEY"
          }
        }
      }
    }
  }
}
