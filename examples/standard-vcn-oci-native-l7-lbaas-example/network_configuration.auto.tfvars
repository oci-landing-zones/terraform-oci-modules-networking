# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

network_configuration = {
  default_compartment_id = "ocid1.compartment.oc1..."
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
                },
                {
                  description  = "ingress from 0.0.0.0/0 over TCP80"
                  stateless    = false
                  protocol     = "TCP"
                  src          = "0.0.0.0/0"
                  src_type     = "CIDR_BLOCK"
                  dst_port_min = 80
                  dst_port_max = 80
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
                  description  = "ingress from 10.0.3.0/24 over TCP22"
                  stateless    = false
                  protocol     = "TCP"
                  src          = "10.0.3.0/24"
                  src_type     = "CIDR_BLOCK"
                  dst_port_min = 22
                  dst_port_max = 22
                },
                {
                  description  = "ingress from 10.0.3.0/24 over HTTP80"
                  stateless    = false
                  protocol     = "TCP"
                  src          = "10.0.3.0/24"
                  src_type     = "CIDR_BLOCK"
                  dst_port_min = 80
                  dst_port_max = 80
                },
                {
                  description  = "ingress from 10.0.2.0/24 over HTTP80"
                  stateless    = false
                  protocol     = "TCP"
                  src          = "10.0.2.0/24"
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
                },
                http_443 = {
                  description  = "ingress from 0.0.0.0/0 over https:443"
                  stateless    = false
                  protocol     = "TCP"
                  src          = "0.0.0.0/0"
                  src_type     = "CIDR_BLOCK"
                  dst_port_min = 443
                  dst_port_max = 443
                },
                http_80 = {
                  description  = "ingress from 0.0.0.0/0 over https:80"
                  stateless    = false
                  protocol     = "TCP"
                  src          = "0.0.0.0/0"
                  src_type     = "CIDR_BLOCK"
                  dst_port_min = 80
                  dst_port_max = 80
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
      non_vcn_specific_gateways = {
        l7_load_balancers = {
          EXAMPLE-011_LB_KEY = {
            compartment_id              = null,
            display_name                = "example-01-tst"
            shape                       = "flexible"
            subnet_ids                  = null,
            subnet_keys                 = ["PUBLIC-LB-SUBNET-KEY"],
            defined_tags                = null,
            freeform_tags               = null,
            ip_mode                     = "IPV4",
            is_private                  = false,
            network_security_group_keys = ["NSG-LB-KEY"],
            reserved_ips_ids            = null,
            reserved_ips_keys           = null,
            shape_details = {
              maximum_bandwidth_in_mbps = 100,
              minimum_bandwidth_in_mbps = 10
            }
            backend_sets = {
              EXAMPLE-01-LB-BCK-END-SET-01 = {
                health_checker = {
                  protocol            = "HTTP",
                  interval_ms         = 10000,
                  is_force_plain_text = true,
                  port                = 80,
                  retries             = 3,
                  return_code         = 200,
                  timeout_in_millis   = 3000,
                  url_path            = "/"
                }
                name   = "backend-set-01",
                policy = "LEAST_CONNECTIONS",
                lb_cookie_session_persistence_configuration = {
                  cookie_name        = "example_cookie",
                  disable_fallback   = false,
                  domain             = "Set-cookie",
                  is_http_only       = true,
                  is_secure          = false,
                  max_age_in_seconds = 3600,
                  path               = "/",
                }
                backends = {
                  EXAMPLE-01-LB-BCK-END-SET-01-BE-01 = {
                    ip_address = "10.0.2.128",
                    port       = 80,
                  },
                  EXAMPLE-01-LB-BCK-END-SET-01-BE-02 = {
                    ip_address = "10.0.2.94",
                    port       = 80,
                  }
                }
              }
            }
            cipher_suites = {
              EXAMPLE-01-LB-CIPHER-SUITE-01-KEY = {
                name = "cipher_suite_01",
                ciphers = [
                  "ECDHE-RSA-AES256-GCM-SHA384",
                  "ECDHE-ECDSA-AES256-GCM-SHA384",
                  "ECDHE-RSA-AES128-GCM-SHA256"
                ]
              }
            }
            path_route_sets = {
              EXMPL_01_PATH_ROUTE_SET_01_KEY = {
                name = "path_route_set_01",
                path_routes = {
                  DEFAULT-KEY = {
                    backend_set_key = "EXAMPLE-01-LB-BCK-END-SET-01",
                    path            = "/"
                    path_match_type = {
                      match_type = "EXACT_MATCH"
                    }
                  }
                  CUSTOM-KEY = {
                    backend_set_key = "EXAMPLE-01-LB-BCK-END-SET-01",
                    path            = "/example/video/123"
                    path_match_type = {
                      match_type = "EXACT_MATCH"
                    }
                  }
                }
              }
            }
            host_names = {
              LB1-HOSTNAME-1-KEY = {
                hostname = "lb1test1.com",
                name     = "lb1test1"
              }
              LB1-HOSTNAME-2-KEY = {
                hostname = "lb1test2.com",
                name     = "lb1test2"
              }
            }
            routing_policies = {
              LB1-ROUTE-POLICY-1-KEY = {
                condition_language_version = "V1",
                name                       = "example_routing_rules",
                rules = {
                  HR-RULE-KEY = {
                    name      = "HR_mobile_user_rule"
                    condition = "all(http.request.headers[(i 'user-agent')] eq (i 'mobile'), http.request.url.query[(i 'department')] eq (i 'HR'))",
                    actions = {
                      ACTION-1-KEY = {
                        backend_set_key = "EXAMPLE-01-LB-BCK-END-SET-01",
                        name            = "FORWARD_TO_BACKENDSET",
                      }
                    }
                  }
                  DOCUMENTS-RULE-KEY = {
                    name      = "Documents_rule"
                    condition = "any(http.request.url.path eq (i '/documents'), http.request.headers[(i 'host')] eq (i 'doc.myapp.com'))",
                    actions = {
                      ACTION-1-KEY = {
                        backend_set_key = "EXAMPLE-01-LB-BCK-END-SET-01",
                        name            = "FORWARD_TO_BACKENDSET",
                      }
                    }
                  }
                }
              }
            }
            rule_sets = {
              LB1-RULE-SET-1-KEY = {
                name = "example_rule_set",
                items = {
                  ITEM-1-KEY = {
                    action = "ADD_HTTP_REQUEST_HEADER",
                    header = "example_header_name",
                    value  = "example_value"
                  }
                  ITEM-2-KEY = {
                    action = "EXTEND_HTTP_REQUEST_HEADER_VALUE",
                    header = "example_header_name2",
                    value  = "example_value",
                    prefix : "example_prefix_value",
                    suffix : "example_suffix_value"
                  }
                }
              }
            }
            certificates = {
              LB-1-CERT-1-KEY = {
                #Required
                certificate_name = "lb1-cert1",
                #Optional
                ca_certificate     = "~/certs/ca.crt"
                private_key        = "~/certs/my_cert.key"
                public_certificate = "~/certs/my_cert.crt"
              }
            }
            listeners = {
              LB1-LSNR-1-80 = {
                default_backend_set_key = "EXAMPLE-01-LB-BCK-END-SET-01",
                name                    = "lb1-lsnr1-80",
                port                    = "80",
                protocol                = "HTTP",
                connection_configuration = {
                  idle_timeout_in_seconds = 1200,
                }
              }
              LB1-LSNR-2-443 = {
                default_backend_set_key = "EXAMPLE-01-LB-BCK-END-SET-01",
                name                    = "lb1-lsnr2-443",
                port                    = "443",
                protocol                = "HTTP",
                connection_configuration = {
                  idle_timeout_in_seconds = 1200,
                }
                hostname_keys      = ["LB1-HOSTNAME-1-KEY", "LB1-HOSTNAME-2-KEY"],
                path_route_set_key = "EXMPL_01_PATH_ROUTE_SET_01_KEY",
                routing_policy_key = "LB1-ROUTE-POLICY-1-KEY",
                rule_set_keys      = ["LB1-RULE-SET-1-KEY"],
                ssl_configuration = {
                  certificate_key         = "LB-1-CERT-1-KEY",
                  protocols               = ["TLSv1.2"],
                  server_order_preference = "ENABLED",
                  verify_depth            = 3
                  verify_peer_certificate = false
                }
              }
            }
          }
        }
      }
      IPs = {
        public_ips = {
          PROD-IP-LB-1-KEY = {
            compartment_id     = null,
            lifetime           = "RESERVED"
            defined_tags       = null
            display_name       = "prod_ip_lb_1"
            freeform_tags      = null
            private_ip_id      = null
            public_ip_pool_id  = null
            public_ip_pool_key = null
          }
        }
      }
    }

    development = {
      category_freeform_tags = {
        "vision-sub-environment" = "dev"
      }
      non_vcn_specific_gateways = {
        l7_load_balancers = {
          EXAMPLE-02_LB_KEY = {
            compartment_id              = null,
            display_name                = "example-02"
            shape                       = "flexible"
            subnet_ids                  = null,
            subnet_keys                 = ["PRIVATE-APP-SUBNET-KEY"],
            defined_tags                = null,
            freeform_tags               = null,
            ip_mode                     = "IPV4",
            is_private                  = true,
            network_security_group_ids  = null,
            network_security_group_keys = ["NSG-APP-KEY"],
            reserved_ips_ids            = null,
            reserved_ips_keys           = null,
            shape_details = {
              maximum_bandwidth_in_mbps = 100,
              minimum_bandwidth_in_mbps = 10
            }

            backend_sets = {
              EXAMPLE-02-LB-BCK-END-SET-01 = {
                health_checker = {
                  protocol            = "HTTP",
                  interval_ms         = 10000,
                  is_force_plain_text = true,
                  port                = 80,
                  retries             = 3,
                  return_code         = 200,
                  timeout_in_millis   = 3000,
                  url_path            = "/"
                }
                name   = "backend-set-01",
                policy = "LEAST_CONNECTIONS",
                session_persistence_configuration = {
                  cookie_name      = "example_cookie_2",
                  disable_fallback = false
                }
                backends = {
                  EXAMPLE-02-LB-BCK-END-SET-01-BE-01 = {
                    ip_address = "10.0.2.55",
                    port       = 80,
                  },
                  EXAMPLE-02-LB-BCK-END-SET-01-BE-02 = {
                    ip_address = "10.0.2.116",
                    port       = 80,
                  }
                }
              }
            }
            cipher_suites = {
              EXAMPLE-02-LB-CIPHER-SUITE-01-KEY = {
                name = "cipher_suite_01",
                ciphers = [
                  "ECDHE-RSA-AES256-GCM-SHA384",
                  "ECDHE-ECDSA-AES256-GCM-SHA384",
                  "ECDHE-RSA-AES128-GCM-SHA256"
                ]
              }
            }
            path_route_sets = {
              EXMPL_02_PATH_ROUTE_SET_01_KEY = {
                name = "path_route_set_01",
                path_routes = {
                  DEFAULT-KEY = {
                    backend_set_key = "EXAMPLE-02-LB-BCK-END-SET-01",
                    path            = "/"
                    path_match_type = {
                      match_type = "EXACT_MATCH"
                    }
                  }
                  CUSTOM-KEY = {
                    backend_set_key = "EXAMPLE-02-LB-BCK-END-SET-01",
                    path            = "/example/video/123"
                    path_match_type = {
                      match_type = "EXACT_MATCH"
                    }
                  }
                }
              }
            }
            host_names = {
              LB2-HOSTNAME-1-KEY = {
                hostname = "lb2test1.com",
                name     = "lb2test1"
              }
              LB2-HOSTNAME-2-KEY = {
                hostname = "lb2test2.com",
                name     = "lb2test2"
              }
            }
            routing_policies = {
              LB2-ROUTE-POLICY-1-KEY = {
                condition_language_version = "V1",
                name                       = "example_routing_rules",
                rules = {
                  HR-RULE-KEY = {
                    name      = "HR_mobile_user_rule"
                    condition = "all(http.request.headers[(i 'user-agent')] eq (i 'mobile'), http.request.url.query[(i 'department')] eq (i 'HR'))",
                    actions = {
                      ACTION-1-KEY = {
                        backend_set_key = "EXAMPLE-02-LB-BCK-END-SET-01",
                        name            = "FORWARD_TO_BACKENDSET",
                      }
                    }
                  }
                  DOCUMENTS-RULE-KEY = {
                    name      = "Documents_rule"
                    condition = "any(http.request.url.path eq (i '/documents'), http.request.headers[(i 'host')] eq (i 'doc.myapp.com'))",
                    actions = {
                      ACTION-1-KEY = {
                        backend_set_key = "EXAMPLE-02-LB-BCK-END-SET-01",
                        name            = "FORWARD_TO_BACKENDSET",
                      }
                    }
                  }
                }
              }
            }
            rule_sets = {
              LB2-RULE-SET-1-KEY = {
                name = "example_rule_set",
                items = {
                  ITEM-1-KEY = {
                    action = "ADD_HTTP_REQUEST_HEADER",
                    header = "example_header_name",
                    value  = "example_value"
                  }
                  ITEM-2-KEY = {
                    action = "EXTEND_HTTP_REQUEST_HEADER_VALUE",
                    header = "example_header_name2",
                    value  = "example_value",
                    prefix : "example_prefix_value",
                    suffix : "example_suffix_value"
                  }
                  ITEM_3_KEY = {
                    action = "ADD_HTTP_RESPONSE_HEADER",
                    header = "example_header_name",
                    value  = "example_value"
                  }
                  ITEM_4_KEY = {
                    action      = "ALLOW",
                    description = "permitted internet clients",
                    conditions : {
                      CONDITION-1-KEY = {
                        attribute_name  = "SOURCE_IP_ADDRESS",
                        attribute_value = "192.168.0.0/16"
                      }
                    }
                  }
                  ITEM_5_KEY = {
                    action          = "CONTROL_ACCESS_USING_HTTP_METHODS",
                    allowed_methods = ["GET", "PUT", "POST", "PROPFIND"]
                  }
                  ITEM_6_KEY = {
                    action = "EXTEND_HTTP_REQUEST_HEADER_VALUE",
                    header = "example_header_name",
                    prefix = "example_prefix_value",
                    suffix = "example_suffix_value"
                  }
                  ITEM_7_KEY = {
                    action = "EXTEND_HTTP_RESPONSE_HEADER_VALUE",
                    header = "example_header_name",
                    prefix = "example_prefix_value",
                    suffix = "example_suffix_value"
                  }
                  ITEM_8_KEY = {
                    action = "HTTP_HEADER",
                    are_invalid_characters_allowed : false,
                    http_large_header_size_in_kb : 32
                  }
                  ITEM_9_KEY = {
                    action = "REDIRECT",
                    conditions = {
                      CONDITION-1-KEY = {
                        attribute_name  = "PATH",
                        attribute_value = "/example",
                        operator        = "SUFFIX_MATCH"
                      }
                    },
                    redirect_uri = {
                      protocol = "{protocol}",
                      host     = "in{host}",
                      port     = 8081,
                      path     = "{path}/video",
                      query    = "{query}"
                    },
                    response_code = 302
                  }
                  ITEM_10_KEY = {
                    action = "REMOVE_HTTP_REQUEST_HEADER",
                    header = "example_header_name"
                  }
                  ITEM_11_KEY = {
                    action = "REMOVE_HTTP_RESPONSE_HEADER",
                    header = "example_header_name"
                  }
                }
              }
            }
            certificates = {
              LB-2-CERT-1-KEY = {
                #Required
                certificate_name = "lb2-cert1",
                #Optional
                ca_certificate     = "~/certs/ca.crt"
                private_key        = "~/certs/my_cert.key"
                public_certificate = "~/certs/my_cert.crt"
              }
            }
            listeners = {
              LB2-LSNR-1-80 = {
                default_backend_set_key = "EXAMPLE-02-LB-BCK-END-SET-01",
                name                    = "lb2-lsnr1-80",
                port                    = "80",
                protocol                = "HTTP",
                connection_configuration = {
                  idle_timeout_in_seconds = 1200,
                }
              }
              LB2-LSNR-2-443 = {
                default_backend_set_key = "EXAMPLE-02-LB-BCK-END-SET-01",
                name                    = "lb2-lsnr2-443",
                port                    = "443",
                protocol                = "HTTP",
                connection_configuration = {
                  idle_timeout_in_seconds = 1200,
                }
                hostname_keys      = ["LB2-HOSTNAME-1-KEY", "LB2-HOSTNAME-2-KEY"],
                path_route_set_key = "EXMPL_02_PATH_ROUTE_SET_01_KEY",
                routing_policy_key = "LB2-ROUTE-POLICY-1-KEY",
                rule_set_keys      = ["LB2-RULE-SET-1-KEY"],
                ssl_configuration = {
                  certificate_key         = "LB-2-CERT-1-KEY",
                  cipher_suite_key        = "EXAMPLE-02-LB-CIPHER-SUITE-01-KEY"
                  protocols               = ["TLSv1.2"],
                  server_order_preference = "ENABLED",
                  verify_depth            = 3
                  verify_peer_certificate = true
                }
              }
            }
          }
        }
      }
      IPs = {
        public_ips = {
          DEV-IP-LB-1-KEY = {
            compartment_id     = null,
            lifetime           = "RESERVED"
            defined_tags       = null
            display_name       = "dev_ip_lb_1"
            freeform_tags      = null
            private_ip_id      = null
            public_ip_pool_id  = null
            public_ip_pool_key = null
          }
        }
      }
    }
  }
}