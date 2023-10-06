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
        VISION-GENERIC-FC-VCN-KEY = {
          display_name                     = "vision-generic-fc-vcn"
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
                  attached_resource_key = "VISION-GENERIC-FC-VCN-KEY"
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
                customer_bgp_peering_ip = "192.168.3.1/30"
                oracle_bgp_peering_ip   = "192.168.3.2/30"
              }
            }
            display_name = "vision_fc_vc_01"
            gateway_key  = "DRG-VISION-KEY"
          }
        }
      }
    }
  }
}
