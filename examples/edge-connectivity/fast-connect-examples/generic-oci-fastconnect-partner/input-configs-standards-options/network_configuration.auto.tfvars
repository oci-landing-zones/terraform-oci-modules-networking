

network_configuration = {
  default_compartment_id = "ocid1.compartment.oc1..aaaaaaaaqgesrpmt675pazv7mjz7sscaruh4z5yoww7jupwbeizsqm4yl7ea"
  default_freeform_tags = {
  "cotud_environment" = "test" }
  default_enable_cis_checks = false

  network_configuration_categories = {
    production = {
      category_compartment_id = "ocid1.compartment.oc1..aaaaaaaaqgesrpmt675pazv7mjz7sscaruh4z5yoww7jupwbeizsqm4yl7ea"
      category_freeform_tags  = { "cotud_sub_environment" = "prod" }

      vcns = {
        prod_vcn_01 = {
          display_name                     = "prod_vcn_01"
          is_ipv6enabled                   = false
          is_oracle_gua_allocation_enabled = false
          cidr_blocks                      = ["10.0.0.0/18", "192.168.0.0/18"],
          dns_label                        = "prodvcn01"
          is_create_igw                    = false
          is_attach_drg                    = false
          block_nat_traffic                = false

          security_lists = {

            seclist_01_prod_vcn_01 = {
              display_name = "seclist_01_prod_vcn_01"

              egress_rules = [
                {
                  description = "egress to 0.0.0.0/0 over ALL protocols"
                  stateless   = false
                  protocol    = "ALL"
                  dst         = "0.0.0.0/0"
                  dst_type    = "CIDR_BLOCK"
                },
                {
                  description = "egress to 0.0.0.0/0 over any protocol"
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
                }
              ]
            },

            seclist_02_prod_vcn_01 = {
              display_name = "seclist_02_prod_vcn_01"

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
                  description = "ingress from 0.0.0.0/0 over TCP22"
                  stateless   = false
                  protocol    = "TCP"
                  src         = "0.0.0.0/0"
                  src_type    = "CIDR_BLOCK"
                },
                {
                  description  = "ingress from 0.0.0.0/0 over HTTP8080"
                  stateless    = false
                  protocol     = "TCP"
                  src          = "0.0.0.0/0"
                  src_type     = "CIDR_BLOCK"
                  dst_port_min = 80
                  dst_port_max = 80
                }
              ]
            }
          }

          route_tables = {
            rt_01_prod_vcn_01 = {
              display_name = "rt_01_prod_vcn_01"
              route_rules = {
                internet_route = {
                  network_entity_key = "prod_vcn_01_ig_01"
                  description        = "Route for internet access"
                  destination        = "0.0.0.0/0"
                  destination_type   = "CIDR_BLOCK"
                }
              }
            }

            rt_02_prod_vcn_01 = {
              display_name = "rt_02_prod_vcn_01"
              route_rules = {
                rpc_route_table = {
                  network_entity_key = "drg_02_prod"
                  description        = "Route for internet access"
                  destination        = "148.20.57.0/30"
                  destination_type   = "CIDR_BLOCK"
                }
              }

            }

            rt_03_prod_vcn_01 = {
              display_name = "rt_03_prod_vcn_01"
              route_rules = {
                sgw_route = {
                  network_entity_key = "service_gw_01_prod_vcn_01"
                  description        = "Route for sgw"
                  destination        = "oci-fra-objectstorage"
                  destination_type   = "SERVICE_CIDR_BLOCK"
                }
              }
            }
          }

          dhcp_options = {
            prod_vcn_01_dhcp_option_01 = {
              display_name     = "prod_vcn_01_dhcp_option_01"
              domain_name_type = "test"
              options = {
                options_1 = {
                  type               = "DomainNameServer"
                  server_type        = "CustomDnsServer"
                  custom_dns_servers = ["192.168.0.3", "192.168.0.4"]
                }
                options_2 = {
                  type                = "SearchDomain"
                  search_domain_names = ["test.com"]
                }
              }
            }

            prod_vcn_01_dhcp_option_02 = {
              display_name     = "prod_vcn_01_dhcp_option_02"
              domain_name_type = "test"
              options = {
                options_1 = {
                  type               = "DomainNameServer"
                  server_type        = "CustomDnsServer"
                  custom_dns_servers = ["10.0.0.3", "10.0.0.4"]
                }
                options_2 = {
                  type                = "SearchDomain"
                  search_domain_names = ["test.com"]
                }
              }
            }
          }

          vcn_specific_gateways = {
            internet_gateways = {
              prod_vcn_01_ig_01 = {
                enabled      = true
                display_name = "prod_vcn_01_ig_01"
              }
            }
            nat_gateways = {}
            service_gateways = {
              service_gw_01_prod_vcn_01 = {
                display_name = "service_gw_01_prod_vcn_01"
              }
            }
          }
        }
      }

      non_vcn_specific_gateways = {
        dynamic_routing_gateways = {
          drg_02_prod = {
            display_name = "drg_02_prod"
            drg_attachments = {
              drg_attachment_prod_drg02_prod_vcn_01 = {
                display_name        = "drg_attachment_prod_drg02_prod_vcn_01"
                drg_route_table_key = "drg01rt1_drg02_prod"
                network_details = {
                  attached_resource_key = "prod_vcn_01"
                  type                  = "VCN"
                  route_table_key       = "rt_03_prod_vcn_01"
                }
              }
            }
            drg_route_tables = {
              drg01rt1_drg02_prod = {
                display_name    = "drg01rt1_drg02_prod"
                is_ecmp_enabled = false
                route_rules = {
                  route_rule_02 = {
                    destination                 = "172.168.0.0/24"
                    destination_type            = "CIDR_BLOCK"
                    next_hop_drg_attachment_id  = null
                    next_hop_drg_attachment_key = "drg_attachment_prod_drg02_prod_vcn_01"
                  }
                }
              }
            }
            drg_route_distributions = {
              drd_test_01 = {
                display_name      = "drd_test_01"
                distribution_type = "IMPORT"
                statements = {
                  stm_1 = {
                    action   = "ACCEPT"
                    priority = 4
                    match_criteria = {
                      criteria_1 = {
                        match_type         = "MATCH_ALL"
                        attachment_type    = "VCN"
                        drg_attachment_key = "drg_attachment_prod_drg02_prod_vcn_01"
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}