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
                  description = "ingress from Secondary Cloud over TCP22"
                  stateless   = false
                  protocol    = "TCP"
                  src         = "172.16.0.0/16"
                  src_type    = "CIDR_BLOCK"
                  dst_port_min = 1521
                  dst_port_max = 1521
                },
                {
                  description  = "Ping from Secondary Cloud and Multicloud Router"
                  stateless    = false
                  protocol     = "ICMP"
                  src          = "172.16.0.0/16"
                  src_type     = "CIDR_BLOCK"
                },
                {
                  description  = "Ping from Multicloud Router"
                  stateless    = false
                  protocol     = "ICMP"
                  src          = "192.168.3.0/30"
                  src_type     = "CIDR_BLOCK"
                  dst_port_min = 1521
                  dst_port_max = 1521
                },
              ]
            }
          }

          route_tables = {
            RT-02-KEY = {
              display_name = "rt-02"
              route_rules = {
                drg-route-multicloud = {
                  network_entity_key = "DRG-VISION-KEY"
                  description        = "Route for Secondary Cloud via DRG"
                  destination        = "172.16.0.0/16"
                  destination_type   = "CIDR_BLOCK"
                },
                drg-route-partner = {
                  network_entity_key = "DRG-VISION-KEY"
                  description        = "Route to Connetcivity Partner via DRG"
                  destination        = "192.168.3.0/30"
                  destination_type   = "CIDR_BLOCK"
                }
              }
            }
          }

          subnets = {
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
            provider_service_id  = "ocid1.providerservice.oc1.eu-frankfurt-1..........", # For getting this value set the "show_available_fc_virtual_circuit_providers" to true and uncomment the "provisioned_networking_resources" in outputs.tf file. 
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