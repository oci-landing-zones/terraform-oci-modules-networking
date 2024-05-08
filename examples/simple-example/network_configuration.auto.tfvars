# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Thu Jan 04 2024                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

network_configuration = {
  default_compartment_id = "ocid1.compartment.oc1..aaaaaaaaj5g7v2ookfz2rkfaxsfdr2odmygwubwposcsnuu6pnnncv2i4vaa"
  default_freeform_tags = {
    "vision-environment" = "vision"
  }
  default_enable_cis_checks = false

  network_configuration_categories = {
    production = {
      category_freeform_tags = {
        "vision-sub-environment" = "prod"
      }

      vcns = {
        SIMPLE-VCN-KEY = {
          display_name                     = "vcn-simple"
          is_ipv6enabled                   = false
          is_oracle_gua_allocation_enabled = false
          cidr_blocks                      = ["10.0.0.0/18"],
          dns_label                        = "vcnsimple"
          is_create_igw                    = false
          is_attach_drg                    = false
          block_nat_traffic                = false
          default_security_list = {
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
          }

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
                  description = "ingress from 10.0.3.0/24 over TCP22"
                  stateless   = false
                  protocol    = "TCP"
                  src         = "10.0.3.0/24"
                  src_type    = "CIDR_BLOCK"
                },
                {
                  description  = "ingress from 10.0.3.0/24 over HTTP80"
                  stateless    = false
                  protocol     = "TCP"
                  src          = "10.0.3.0/24"
                  src_type     = "CIDR_BLOCK"
                  dst_port_min = 80
                  dst_port_max = 80
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
              display_name = "rt-02-prod-vcn-01"
              route_rules = {
                sgw-route = {
                  network_entity_key = "SGW-KEY"
                  description        = "Route for sgw"
                  destination        = "objectstorage"
                  destination_type   = "SERVICE_CIDR_BLOCK"
                },
                natgw-route = {
                  network_entity_key = "NATGW-KEY"
                  description        = "Route for internet access via NAT GW"
                  destination        = "0.0.0.0/0"
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
              security_list_keys         = ["default_security_list"]
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
                  dst_port_min = 80
                  dst_port_max = 80
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
                services     = "objectstorage"
              }
            }
          }
        }
      }
    }
  }
}