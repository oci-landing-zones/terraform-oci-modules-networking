network_configuration = {
  default_freeform_tags = {
    "vision-environment" = "vision"
  }
  default_enable_cis_checks = false

  network_configuration_categories = {
    demo = {
      category_freeform_tags = {
        "vision-oci-aws-ipsec" = "demo"
      }

      vcns = {
        VISION-GENERIC-VPN-VCN-KEY = {
          display_name                     = "vision-generic-vpn-vcn"
          is_ipv6enabled                   = false
          is_oracle_gua_allocation_enabled = false
          cidr_blocks                      = ["172.16.0.0/24"],
          dns_label                        = "visionvcn"
          is_create_igw                    = false
          is_attach_drg                    = false
          block_nat_traffic                = false

          security_lists = {

            SECLIST-01-KEY = {
              display_name = "prv-subnet"

              egress_rules = [
                {
                  description = "egress to 10.0.0.0/16 over all TCP ports"
                  stateless   = false
                  protocol    = "TCP"
                  dst         = "10.0.0.0/16"
                  dst_type    = "CIDR_BLOCK"
                }
              ]

              ingress_rules = [
                {
                  description  = "ingress from 10.0.0.0/16 over TCP:22"
                  stateless    = false
                  protocol     = "TCP"
                  src          = "10.0.0.0/16"
                  src_type     = "CIDR_BLOCK"
                  dst_port_min = 22
                  dst_port_max = 22
                },
                {
                  description = "ingress from 10.0.0.0/16 over ICMP:all"
                  stateless   = false
                  protocol    = "ICMP"
                  src         = "10.0.0.0/16"
                  src_type    = "CIDR_BLOCK"
                }
              ]
            }
          }

          route_tables = {
            RT-01-KEY = {
              display_name = "rt-01"
              route_rules = {
                drg_route = {
                  network_entity_key = "DRG-VISION-KEY"
                  description        = "Route for on-premises over IPSEC VPN"
                  destination        = "10.0.0.0/16"
                  destination_type   = "CIDR_BLOCK"
                }
              }
            }
          }

          subnets = {
            PRIVATE-REGIONAL-SUBNET-KEY = {
              cidr_block                 = "172.16.0.0/24"
              dhcp_options_key           = "default_dhcp_options"
              display_name               = "private-regional-sub"
              dns_label                  = "prv"
              ipv6cidr_blocks            = []
              prohibit_internet_ingress  = true
              prohibit_public_ip_on_vnic = true
              route_table_key            = "RT-01-KEY"
              security_list_keys         = ["SECLIST-01-KEY"]
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
                  attached_resource_key = "VISION-GENERIC-VPN-VCN-KEY"
                  type                  = "VCN"
                }
              }
            }
          }
        }
        customer_premises_equipments = {
          CPE-VISION-KEY = {
            ip_address                   = "142.34.145.37",
            display_name                 = "cpe-vision",
            cpe_device_shape_vendor_name = "Fortinet"
          }
        }
        ipsecs = {
          VISION-OCI-AWS-IPSEC-VPN-KEY = {
            cpe_key       = "CPE-VISION-KEY"
            drg_key       = "DRG-VISION-KEY",
            display_name  = "vision-oci-aws-ipsec-vpn"
            static_routes = ["0.0.0.0/0"]
            tunnels_management = {
              tunnel_1 = {
                routing = "BGP",
                bgp_session_info = {
                  customer_bgp_asn      = "12345",
                  customer_interface_ip = "10.0.0.16/31",
                  oracle_interface_ip   = "10.0.0.17/31"
                }
                shared_secret = "test1",
                ike_version   = "V1"
              },
              tunnel_2 = {
                routing = "BGP",
                bgp_session_info = {
                  customer_bgp_asn      = "12345",
                  customer_interface_ip = "10.0.0.18/31",
                  oracle_interface_ip   = "10.0.0.19/31"
                }
                shared_secret = "test2",
                ike_version   = "V2"
              }
            }
          }
        }
      }
    }
  }
}