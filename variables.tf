# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #


variable "network_configuration" {
  type = object({
    default_compartment_id     = optional(string),
    default_defined_tags       = optional(map(string)),
    default_freeform_tags      = optional(map(string)),
    default_enable_cis_checks  = optional(bool),
    default_ssh_ports_to_check = optional(list(number)),

    network_configuration_categories = optional(map(object({
      category_compartment_id     = optional(string),
      category_defined_tags       = optional(map(string)),
      category_freeform_tags      = optional(map(string)),
      category_enable_cis_checks  = optional(bool),
      category_ssh_ports_to_check = optional(list(number)),

      vcns = optional(map(object({
        compartment_id = optional(string),
        display_name   = optional(string),
        byoipv6cidr_details = optional(map(object({
          byoipv6range_id = string
          ipv6cidr_block  = string
        })))
        ipv6private_cidr_blocks          = optional(list(string)),
        is_ipv6enabled                   = optional(bool),
        is_oracle_gua_allocation_enabled = optional(bool),
        cidr_blocks                      = optional(list(string)),
        dns_label                        = optional(string),
        block_nat_traffic                = optional(bool),
        defined_tags                     = optional(map(string)),
        freeform_tags                    = optional(map(string)),

        default_security_list = optional(object({
          compartment_id = optional(string),
          defined_tags   = optional(map(string)),
          freeform_tags  = optional(map(string)),
          ingress_rules = optional(list(object({
            stateless    = optional(bool),
            protocol     = string,
            description  = optional(string),
            src          = string,
            src_type     = string,
            src_port_min = optional(number),
            src_port_max = optional(number),
            dst_port_min = optional(number),
            dst_port_max = optional(number),
            icmp_type    = optional(number),
            icmp_code    = optional(number)
          }))),
          egress_rules = optional(list(object({
            stateless    = optional(bool),
            protocol     = string,
            description  = optional(string),
            dst          = string,
            dst_type     = string,
            src_port_min = optional(number),
            src_port_max = optional(number),
            dst_port_min = optional(number),
            dst_port_max = optional(number),
            icmp_type    = optional(number),
            icmp_code    = optional(number)
          })))
        }))

        security_lists = optional(map(object({
          compartment_id = optional(string),
          defined_tags   = optional(map(string)),
          freeform_tags  = optional(map(string)),
          display_name   = optional(string),
          ingress_rules = optional(list(object({
            stateless    = optional(bool),
            protocol     = string,
            description  = optional(string),
            src          = string,
            src_type     = string,
            src_port_min = optional(number),
            src_port_max = optional(number),
            dst_port_min = optional(number),
            dst_port_max = optional(number),
            icmp_type    = optional(number),
            icmp_code    = optional(number)
          }))),
          egress_rules = optional(list(object({
            stateless    = optional(bool),
            protocol     = string,
            description  = optional(string),
            dst          = string,
            dst_type     = string,
            src_port_min = optional(number),
            src_port_max = optional(number),
            dst_port_min = optional(number),
            dst_port_max = optional(number),
            icmp_type    = optional(number),
            icmp_code    = optional(number)
          })))
        })))

        default_route_table = optional(object({
          compartment_id = optional(string),
          defined_tags   = optional(map(string)),
          freeform_tags  = optional(map(string)),
          display_name   = optional(string),
          route_rules = optional(map(object({
            network_entity_id  = optional(string),
            network_entity_key = optional(string),
            description        = optional(string),
            // Supported values:
            //    - "a cidr block"
            //    - "objectstorage" or "all-services" - only for "SERVICE_CIDR_BLOCK"
            destination = optional(string),
            // Supported values:
            //    - "CIDR_BLOCK"
            //    - "SERVICE_CIDR_BLOCK" - only for SGW
            destination_type = optional(string),
          })))
        }))

        route_tables = optional(map(object({
          compartment_id = optional(string),
          defined_tags   = optional(map(string)),
          freeform_tags  = optional(map(string)),
          display_name   = optional(string),
          route_rules = optional(map(object({
            network_entity_id  = optional(string),
            network_entity_key = optional(string),
            description        = optional(string),
            // Supported values:
            //    - "a cidr block"
            //    - "objectstorage" or "all-services" - only for "SERVICE_CIDR_BLOCK"
            destination = optional(string),
            // Supported values:
            //    - "CIDR_BLOCK"
            //    - "SERVICE_CIDR_BLOCK" - only for SGW
            destination_type = optional(string),
          })))
        })))

        default_dhcp_options = optional(object({
          compartment_id   = optional(string),
          display_name     = optional(string),
          defined_tags     = optional(map(string)),
          freeform_tags    = optional(map(string)),
          domain_name_type = optional(string),
          options = map(object({
            type                = string,
            server_type         = optional(string),
            custom_dns_servers  = optional(list(string))
            search_domain_names = optional(list(string))
          }))
        }))

        dhcp_options = optional(map(object({
          compartment_id   = optional(string),
          display_name     = optional(string),
          defined_tags     = optional(map(string)),
          freeform_tags    = optional(map(string)),
          domain_name_type = optional(string),
          options = map(object({
            type                = string,
            server_type         = optional(string),
            custom_dns_servers  = optional(list(string))
            search_domain_names = optional(list(string))
          }))
        })))

        subnets = optional(map(object({
          cidr_block     = string,
          compartment_id = optional(string),
          #Optional
          availability_domain        = optional(string),
          defined_tags               = optional(map(string)),
          dhcp_options_key           = optional(string),
          display_name               = optional(string),
          dns_label                  = optional(string),
          freeform_tags              = optional(map(string)),
          ipv6cidr_block             = optional(string),
          ipv6cidr_blocks            = optional(list(string)),
          prohibit_internet_ingress  = optional(bool),
          prohibit_public_ip_on_vnic = optional(bool),
          route_table_key            = optional(string),
          security_list_keys         = optional(list(string))
        })))

        network_security_groups = optional(map(object({
          compartment_id = optional(string),
          display_name   = optional(string),
          defined_tags   = optional(map(string))
          freeform_tags  = optional(map(string))
          ingress_rules = optional(map(object({
            description  = optional(string),
            protocol     = string,
            stateless    = optional(bool),
            src          = optional(string),
            src_type     = optional(string),
            dst_port_min = optional(number),
            dst_port_max = optional(number),
            src_port_min = optional(number),
            src_port_max = optional(number),
            icmp_type    = optional(number),
            icmp_code    = optional(number)
          }))),
          egress_rules = optional(map(object({
            description  = optional(string),
            protocol     = string,
            stateless    = optional(bool),
            dst          = optional(string),
            dst_type     = optional(string),
            dst_port_min = optional(number),
            dst_port_max = optional(number),
            src_port_min = optional(number),
            src_port_max = optional(number),
            icmp_type    = optional(number),
            icmp_code    = optional(number)
          })))
        })))
        dns_resolver = optional(object({
          display_name  = optional(string),
          defined_tags  = optional(map(string)),
          freeform_tags = optional(map(string)),
          attached_views = optional(map(object({
            existing_view_id = optional(string) # an existing externally managed view. Assign either this attribute or the others for having this module managing the view.
            compartment_id = optional(string),
            display_name   = optional(string),
            defined_tags   = optional(map(string)),
            freeform_tags  = optional(map(string)),
            dns_zones = optional(map(object({
              compartment_id = optional(string),
              name           = optional(string),
              defined_tags   = optional(map(string)),
              freeform_tags  = optional(map(string)),
              scope          = optional(string),
              zone_type      = optional(string),
              external_downstreams = optional(list(object({
                address  = optional(string),
                ports    = optional(string),
                tsig_key = optional(string),
              }))),
              external_masters = optional(list(object({
                address  = optional(string),
                port     = optional(string),
                tsig_key = optional(string),
              }))),
              dns_records = optional(map(object({
                domain         = optional(string),
                compartment_id = optional(string),
                rtype          = optional(string),
                rdata          = optional(string),
                ttl            = optional(number),
              })))
              dns_rrset = optional(map(object({
                compartment_id = optional(string)
                domain = optional(string),
                rtype  = optional(string),
                scope  = optional(string),
                items = optional(list(object({
                  domain = optional(string),
                  rdata  = optional(string),
                  rtype  = optional(string),
                  ttl    = optional(string),
                })))
              })))
              dns_steering_policies = optional(map(object({
                compartment_id = optional(string),
                domain_name    = optional(string),
                display_name   = optional(string),
                template       = optional(string),
                answers = optional(list(object({
                  name        = optional(string),
                  rdata       = optional(string),
                  rtype       = optional(string),
                  is_disabled = optional(bool),
                  pool        = optional(string),
                }))),
                defined_tags            = optional(map(string)),
                freeform_tags           = optional(map(string)),
                health_check_monitor_id = optional(string)
                rules = optional(list(object({
                  rule_type = optional(string)
                  cases = optional(list(object({
                    answer_data = optional(object({
                      answer_condition = optional(string)
                      should_keep      = optional(string)
                      value            = optional(string)
                    })),
                    case_condition = optional(string),
                    count          = optional(number)
                  }))),
                  default_answer_data = optional(object({
                    answer_condition = optional(string),
                    should_keep      = optional(bool),
                    value            = optional(string),
                  })),
                  default_count = optional(number),
                  description   = optional(string),
                }))),
                ttl = optional(string),
              }))),
            }))),
          }))),
          rules = optional(list(object({
            action                    = optional(string),
            destination_address       = optional(list(string)),
            source_endpoint_name      = optional(string),
            client_address_conditions = optional(list(string)),
            qname_cover_conditions    = optional(list(string)),
          }))),
          resolver_endpoints = optional(map(object({
            name               = optional(string),
            is_forwarding      = optional(string),
            is_listening       = optional(string),
            subnet             = optional(string),
            endpoint_type      = optional(string),
            forwarding_address = optional(string),
            listening_address  = optional(string),
            nsg                = optional(list(string)),
          }))),
          tsig_keys = optional(map(object({
            compartment_id = optional(string),
            algorithm      = optional(string),
            name           = optional(string),
            secret         = optional(string),
            defined_tags   = optional(map(string)),
            freeform_tags  = optional(map(string)),
          }))),
        }))

        security = optional(object({
          zpr_attributes = optional(list(object({
            namespace = optional(string,"oracle-zpr")
            attr_name = string
            attr_value = string
            mode = optional(string,"enforce")
            })))
        }))
        
        dns_resolver = optional(object({
          display_name  = optional(string),
          defined_tags  = optional(map(string)),
          freeform_tags = optional(map(string)),
          attached_views = optional(map(object({
            existing_view_id = optional(string) # an existing externally managed view. Assign either this attribute or the others for having this module managing the view.
            compartment_id = optional(string),
            display_name   = optional(string),
            defined_tags   = optional(map(string)),
            freeform_tags  = optional(map(string)),
            dns_zones = optional(map(object({
              compartment_id = optional(string),
              name           = optional(string),
              defined_tags   = optional(map(string)),
              freeform_tags  = optional(map(string)),
              scope          = optional(string),
              zone_type      = optional(string),
              external_downstreams = optional(list(object({
                address  = optional(string),
                ports    = optional(string),
                tsig_key = optional(string),
              }))),
              external_masters = optional(list(object({
                address  = optional(string),
                port     = optional(string),
                tsig_key = optional(string),
              }))),
              dns_records = optional(map(object({
                domain         = optional(string),
                compartment_id = optional(string),
                rtype          = optional(string),
                rdata          = optional(string),
                ttl            = optional(number),
              })))
              dns_rrset = optional(map(object({
                compartment_id = optional(string)
                domain = optional(string),
                rtype  = optional(string),
                scope  = optional(string),
                items = optional(list(object({
                  domain = optional(string),
                  rdata  = optional(string),
                  rtype  = optional(string),
                  ttl    = optional(string),
                })))
              })))
              dns_steering_policies = optional(map(object({
                compartment_id = optional(string),
                domain_name    = optional(string),
                display_name   = optional(string),
                template       = optional(string),
                answers = optional(list(object({
                  name        = optional(string),
                  rdata       = optional(string),
                  rtype       = optional(string),
                  is_disabled = optional(bool),
                  pool        = optional(string),
                }))),
                defined_tags            = optional(map(string)),
                freeform_tags           = optional(map(string)),
                health_check_monitor_id = optional(string)
                rules = optional(list(object({
                  rule_type = optional(string)
                  cases = optional(list(object({
                    answer_data = optional(object({
                      answer_condition = optional(string)
                      should_keep      = optional(string)
                      value            = optional(string)
                    })),
                    case_condition = optional(string),
                    count          = optional(number)
                  }))),
                  default_answer_data = optional(object({
                    answer_condition = optional(string),
                    should_keep      = optional(bool),
                    value            = optional(string),
                  })),
                  default_count = optional(number),
                  description   = optional(string),
                }))),
                ttl = optional(string),
              }))),
            }))),
          }))),
          rules = optional(list(object({
            action                    = optional(string),
            destination_address       = optional(list(string)),
            source_endpoint_name      = optional(string),
            client_address_conditions = optional(list(string)),
            qname_cover_conditions    = optional(list(string)),
          }))),
          resolver_endpoints = optional(map(object({
            name               = optional(string),
            is_forwarding      = optional(string),
            is_listening       = optional(string),
            subnet             = optional(string),
            endpoint_type      = optional(string),
            forwarding_address = optional(string),
            listening_address  = optional(string),
            nsg                = optional(list(string)),
          }))),
          tsig_keys = optional(map(object({
            compartment_id = optional(string),
            algorithm      = optional(string),
            name           = optional(string),
            secret         = optional(string),
            defined_tags   = optional(map(string)),
            freeform_tags  = optional(map(string)),
          }))),
        }))

        vcn_specific_gateways = optional(object({
          internet_gateways = optional(map(object({
            compartment_id  = optional(string),
            enabled         = optional(bool),
            defined_tags    = optional(map(string)),
            display_name    = optional(string),
            freeform_tags   = optional(map(string)),
            route_table_key = optional(string)
          })))

          nat_gateways = optional(map(object({
            compartment_id  = optional(string),
            block_traffic   = optional(bool),
            defined_tags    = optional(map(string)),
            display_name    = optional(string),
            freeform_tags   = optional(map(string)),
            public_ip_id    = optional(string),
            route_table_key = optional(string)
          })))

          service_gateways = optional(map(object({
            compartment_id = optional(string),
            // SGW services value:
            //       - objectstorage - for object storage access
            //       - all-services - for all OCI internal network services access
            services        = string,
            defined_tags    = optional(map(string)),
            display_name    = optional(string),
            freeform_tags   = optional(map(string)),
            route_table_key = optional(string)
          })))

          local_peering_gateways = optional(map(object({
            compartment_id  = optional(string),
            defined_tags    = optional(map(string)),
            display_name    = optional(string),
            freeform_tags   = optional(map(string)),
            peer_id         = optional(string),
            peer_key        = optional(string),
            route_table_key = optional(string)
          })))
        }))
      })))

      inject_into_existing_vcns = optional(map(object({

        vcn_id = string,

        default_security_list = optional(object({
          compartment_id = optional(string),
          defined_tags   = optional(map(string)),
          freeform_tags  = optional(map(string)),
          ingress_rules = optional(list(object({
            stateless    = optional(bool),
            protocol     = string,
            description  = optional(string),
            src          = string,
            src_type     = string,
            src_port_min = optional(number),
            src_port_max = optional(number),
            dst_port_min = optional(number),
            dst_port_max = optional(number),
            icmp_type    = optional(number),
            icmp_code    = optional(number)
          }))),
          egress_rules = optional(list(object({
            stateless    = optional(bool),
            protocol     = string,
            description  = optional(string),
            dst          = string,
            dst_type     = string,
            src_port_min = optional(number),
            src_port_max = optional(number),
            dst_port_min = optional(number),
            dst_port_max = optional(number),
            icmp_type    = optional(number),
            icmp_code    = optional(number)
          })))
        }))

        security_lists = optional(map(object({
          compartment_id = optional(string),
          defined_tags   = optional(map(string)),
          freeform_tags  = optional(map(string)),
          display_name   = optional(string),
          ingress_rules = optional(list(object({
            stateless    = optional(bool),
            protocol     = string,
            description  = optional(string),
            src          = string,
            src_type     = string,
            src_port_min = optional(number),
            src_port_max = optional(number),
            dst_port_min = optional(number),
            dst_port_max = optional(number),
            icmp_type    = optional(number),
            icmp_code    = optional(number)
          }))),
          egress_rules = optional(list(object({
            stateless    = optional(bool),
            protocol     = string,
            description  = optional(string),
            dst          = string,
            dst_type     = string,
            src_port_min = optional(number),
            src_port_max = optional(number),
            dst_port_min = optional(number),
            dst_port_max = optional(number),
            icmp_type    = optional(number),
            icmp_code    = optional(number)
          })))
        })))

        default_route_table = optional(object({
          compartment_id = optional(string),
          defined_tags   = optional(map(string)),
          freeform_tags  = optional(map(string)),
          display_name   = optional(string),
          route_rules = optional(map(object({
            network_entity_id  = optional(string),
            network_entity_key = optional(string),
            description        = optional(string),
            // Supported values:
            //    - "a cidr block"
            //    - "objectstorage" or "all-services" - only for "SERVICE_CIDR_BLOCK"
            destination = optional(string),
            // Supported values:
            //    - "CIDR_BLOCK"
            //    - "SERVICE_CIDR_BLOCK" - only for SGW
            destination_type = optional(string),
          })))
        }))

        route_tables = optional(map(object({
          compartment_id = optional(string),
          defined_tags   = optional(map(string)),
          freeform_tags  = optional(map(string)),
          display_name   = optional(string),
          route_rules = optional(map(object({
            network_entity_id  = optional(string),
            network_entity_key = optional(string),
            description        = optional(string),
            // Supported values:
            //    - "a cidr block"
            //    - "objectstorage" or "all-services" - only for "SERVICE_CIDR_BLOCK"
            destination = optional(string),
            // Supported values:
            //    - "CIDR_BLOCK"
            //    - "SERVICE_CIDR_BLOCK" - only for SGW
            destination_type = optional(string)
          })))
        })))

        default_dhcp_options = optional(object({
          compartment_id   = optional(string),
          display_name     = optional(string),
          defined_tags     = optional(map(string)),
          freeform_tags    = optional(map(string)),
          domain_name_type = optional(string),
          options = map(object({
            type                = string,
            server_type         = optional(string),
            custom_dns_servers  = optional(list(string))
            search_domain_names = optional(list(string))
          }))
        }))

        dhcp_options = optional(map(object({
          compartment_id   = optional(string),
          display_name     = optional(string),
          defined_tags     = optional(map(string)),
          freeform_tags    = optional(map(string)),
          domain_name_type = optional(string),
          options = map(object({
            type                = string,
            server_type         = optional(string),
            custom_dns_servers  = optional(list(string))
            search_domain_names = optional(list(string))
          }))
        })))

        subnets = optional(map(object({
          cidr_block     = string,
          compartment_id = optional(string),
          #Optional
          availability_domain        = optional(string),
          defined_tags               = optional(map(string)),
          dhcp_options_id            = optional(string),
          dhcp_options_key           = optional(string),
          display_name               = optional(string),
          dns_label                  = optional(string),
          freeform_tags              = optional(map(string)),
          ipv6cidr_block             = optional(string),
          ipv6cidr_blocks            = optional(list(string)),
          prohibit_internet_ingress  = optional(bool),
          prohibit_public_ip_on_vnic = optional(bool),
          route_table_id             = optional(string),
          route_table_key            = optional(string),
          security_list_ids          = optional(list(string)),
          security_list_keys         = optional(list(string))
        })))

        network_security_groups = optional(map(object({
          compartment_id = optional(string),
          display_name   = optional(string),
          defined_tags   = optional(map(string))
          freeform_tags  = optional(map(string))
          ingress_rules = optional(map(object({
            description  = optional(string),
            protocol     = string,
            stateless    = optional(bool),
            src          = optional(string),
            src_type     = optional(string),
            dst_port_min = number,
            dst_port_max = number,
            src_port_min = optional(number),
            src_port_max = optional(number),
            icmp_type    = optional(number),
            icmp_code    = optional(number)
          }))),
          egress_rules = optional(map(object({
            description  = optional(string),
            protocol     = string,
            stateless    = optional(bool),
            dst          = optional(string),
            dst_type     = optional(string),
            dst_port_min = optional(number),
            dst_port_max = optional(number),
            src_port_min = optional(number),
            src_port_max = optional(number),
            icmp_type    = optional(number),
            icmp_code    = optional(number)
          })))
        })))

        dns_resolver = optional(object({
          display_name  = optional(string),
          defined_tags  = optional(map(string)),
          freeform_tags = optional(map(string)),
          attached_views = optional(map(object({
            compartment_id = optional(string),
            display_name   = optional(string),
            defined_tags   = optional(map(string)),
            freeform_tags  = optional(map(string)),
            dns_zones = optional(map(object({
              compartment_id = optional(string),
              name           = optional(string),
              defined_tags   = optional(map(string)),
              freeform_tags  = optional(map(string)),
              scope          = optional(string),
              zone_type      = optional(string),
              external_downstreams = optional(list(object({
                address  = optional(string),
                ports    = optional(string),
                tsig_key = optional(string),
              }))),
              external_masters = optional(list(object({
                address  = optional(string),
                port     = optional(string),
                tsig_key = optional(string),
              }))),
              dns_records = optional(map(object({
                domain         = optional(string),
                compartment_id = optional(string),
                rtype          = optional(string),
                rdata          = optional(string),
                ttl            = optional(string),
              })))
              dns_rrset = optional(map(object({
                domain = optional(string),
                rtype  = optional(string),
                scope  = optional(string),
                items = optional(list(object({
                  domain = optional(string),
                  rdata  = optional(string),
                  rtype  = optional(string),
                  ttl    = optional(string),
                })))
              })))
              dns_steering_policies = optional(map(object({
                compartment_id = optional(string),
                domain_name    = optional(string),
                display_name   = optional(string),
                template       = optional(string),
                answers = optional(list(object({
                  name        = optional(string),
                  rdata       = optional(string),
                  rtype       = optional(string),
                  is_disabled = optional(bool),
                  pool        = optional(string),
                }))),
                defined_tags            = optional(map(string)),
                freeform_tags           = optional(map(string)),
                health_check_monitor_id = optional(string)
                rules = optional(list(object({
                  rule_type = optional(string)
                  cases = optional(list(object({
                    answer_data = optional(object({
                      answer_condition = optional(string)
                      should_keep      = optional(string)
                      value            = optional(string)
                    })),
                    case_condition = optional(string),
                    count          = optional(number)
                  }))),
                  default_answer_data = optional(object({
                    answer_condition = optional(string),
                    should_keep      = optional(bool),
                    value            = optional(string),
                  })),
                  default_count = optional(number),
                  description   = optional(string),
                }))),
                ttl = optional(string),
              }))),
            }))),
          }))),
          rules = optional(list(object({
            action                   = optional(string),
            destination_address      = optional(string),
            source_endpoint_name     = optional(string),
            client_address_condition = optional(string),
            qname_cover_condtions    = optional(string),
          }))),
          resolver_endpoints = optional(map(object({
            name               = optional(string),
            is_forwarding      = optional(bool),
            is_listening       = optional(bool),
            subnet             = optional(string),
            endpoint_type      = optional(string),
            forwarding_address = optional(string),
            listening_address  = optional(string),
            nsg                = optional(string),
          }))),
          tsig_keys = optional(map(object({
            compartment_id = optional(string),
            algorithm      = optional(string),
            name           = optional(string),
            secret         = optional(string),
            defined_tags   = optional(map(string)),
            freeform_tags  = optional(map(string)),
          }))),
        }))

        vcn_specific_gateways = optional(object({
          internet_gateways = optional(map(object({
            compartment_id  = optional(string),
            enabled         = optional(bool),
            defined_tags    = optional(map(string)),
            display_name    = optional(string),
            freeform_tags   = optional(map(string)),
            route_table_id  = optional(string),
            route_table_key = optional(string)
          })))

          nat_gateways = optional(map(object({
            compartment_id  = optional(string),
            block_traffic   = optional(bool),
            defined_tags    = optional(map(string)),
            display_name    = optional(string),
            freeform_tags   = optional(map(string)),
            public_ip_id    = optional(string),
            route_table_id  = optional(string),
            route_table_key = optional(string)
          })))

          service_gateways = optional(map(object({
            compartment_id = optional(string),
            // SGW services value:
            //       - objectstorage - for object storage access
            //       - all-services - for all OCI internal network services access
            services        = string,
            defined_tags    = optional(map(string)),
            display_name    = optional(string),
            freeform_tags   = optional(map(string)),
            route_table_id  = optional(string),
            route_table_key = optional(string)
          })))

          local_peering_gateways = optional(map(object({
            compartment_id  = optional(string),
            defined_tags    = optional(map(string)),
            display_name    = optional(string),
            freeform_tags   = optional(map(string)),
            peer_id         = optional(string),
            peer_key        = optional(string),
            route_table_id  = optional(string),
            route_table_key = optional(string)
          })))
        }))
      })))

      IPs = optional(object({

        public_ips_pools = optional(map(object({
          compartment_id = optional(string),
          defined_tags   = optional(map(string)),
          display_name   = optional(string),
          freeform_tags  = optional(map(string)),
        })))

        public_ips = optional(map(object({
          compartment_id     = optional(string),
          lifetime           = string,
          defined_tags       = optional(map(string)),
          display_name       = optional(string),
          freeform_tags      = optional(map(string)),
          private_ip_id      = optional(string),
          public_ip_pool_id  = optional(string),
          public_ip_pool_key = optional(string)
        })))
      }))



      non_vcn_specific_gateways = optional(object({

        dynamic_routing_gateways = optional(map(object({
          compartment_id = optional(string),
          defined_tags   = optional(map(string)),
          display_name   = optional(string),
          freeform_tags  = optional(map(string)),

          remote_peering_connections = optional(map(object({
            compartment_id   = optional(string),
            defined_tags     = optional(map(string)),
            display_name     = optional(string),
            freeform_tags    = optional(map(string)),
            peer_id          = optional(string),
            peer_key         = optional(string),
            peer_region_name = optional(string)
          })))

          drg_attachments = optional(map(object({
            defined_tags        = optional(map(string)),
            display_name        = optional(string),
            freeform_tags       = optional(map(string)),
            drg_route_table_id  = optional(string),
            drg_route_table_key = optional(string),
            network_details = optional(object({
              attached_resource_id  = optional(string),
              attached_resource_key = optional(string),
              type                  = string,
              route_table_id        = optional(string),
              route_table_key       = optional(string),
              vcn_route_type        = optional(string)
            }))
          })))

          drg_route_tables = optional(map(object({
            defined_tags                      = optional(map(string)),
            display_name                      = optional(string),
            freeform_tags                     = optional(map(string)),
            import_drg_route_distribution_id  = optional(string),
            import_drg_route_distribution_key = optional(string),
            is_ecmp_enabled                   = optional(bool),
            route_rules = optional(map(object({
              destination                 = string,
              destination_type            = string,
              next_hop_drg_attachment_id  = optional(string),
              next_hop_drg_attachment_key = optional(string),
            })))
          })))

          drg_route_distributions = optional(map(object({
            distribution_type = string,
            defined_tags      = optional(map(string)),
            display_name      = optional(string),
            freeform_tags     = optional(map(string))
            statements = optional(map(object({
              action = string,
              match_criteria = optional(object({
                match_type         = string,
                attachment_type    = optional(string),
                drg_attachment_id  = optional(string),
                drg_attachment_key = optional(string)
              }))
              priority = optional(number)
            })))
          })))
        })))

        customer_premises_equipments = optional(map(object({
          compartment_id               = optional(string),
          ip_address                   = string,
          defined_tags                 = optional(map(string)),
          display_name                 = optional(string),
          freeform_tags                = optional(map(string)),
          cpe_device_shape_id          = optional(string),
          cpe_device_shape_vendor_name = optional(string)
        })))

        ipsecs = optional(map(object({
          compartment_id            = optional(string),
          cpe_id                    = optional(string),
          cpe_key                   = optional(string),
          drg_id                    = optional(string),
          drg_key                   = optional(string),
          static_routes             = list(string),
          cpe_local_identifier      = optional(string),
          cpe_local_identifier_type = optional(string),
          defined_tags              = optional(map(string)),
          display_name              = optional(string),
          freeform_tags             = optional(map(string)),
          tunnels_management = optional(object({
            tunnel_1 = optional(object({
              routing = string,
              bgp_session_info = optional(object({
                customer_bgp_asn      = optional(string),
                customer_interface_ip = optional(string),
                oracle_interface_ip   = optional(string)
              }))
              encryption_domain_config = optional(object({
                cpe_traffic_selector    = optional(string),
                oracle_traffic_selector = optional(string)
              }))
              shared_secret = optional(string),
              ike_version   = optional(string)
            })),
            tunnel_2 = optional(object({
              routing = string,
              bgp_session_info = optional(object({
                customer_bgp_asn      = optional(string),
                customer_interface_ip = optional(string),
                oracle_interface_ip   = optional(string)
              }))
              encryption_domain_config = optional(object({
                cpe_traffic_selector    = optional(string),
                oracle_traffic_selector = optional(string)
              }))
              shared_secret = optional(string),
              ike_version   = optional(string)
            }))
          }))
        })))

        fast_connect_virtual_circuits = optional(map(object({
          #Required
          compartment_id                              = optional(string),
          provision_fc_virtual_circuit                = bool,
          show_available_fc_virtual_circuit_providers = bool,
          type                                        = string,
          #Optional
          bandwidth_shape_name = optional(string),
          bgp_admin_state      = optional(string),
          cross_connect_mappings = optional(map(object({
            #Optional
            bgp_md5auth_key                          = optional(string)
            cross_connect_or_cross_connect_group_id  = optional(string)
            cross_connect_or_cross_connect_group_key = optional(string)
            customer_bgp_peering_ip                  = optional(string)
            customer_bgp_peering_ipv6                = optional(string)
            oracle_bgp_peering_ip                    = optional(string)
            oracle_bgp_peering_ipv6                  = optional(string)
            vlan                                     = optional(string)
          })))
          customer_asn              = optional(string)
          defined_tags              = optional(map(string))
          display_name              = optional(string)
          freeform_tags             = optional(map(string))
          ip_mtu                    = optional(number)
          is_bfd_enabled            = optional(bool)
          gateway_id                = optional(string)
          gateway_key               = optional(string)
          provider_service_id       = optional(string)
          provider_service_key      = optional(string)
          provider_service_key_name = optional(string)
          public_prefixes = optional(map(object({
            #Required
            cidr_block = string,
          })))
          region         = optional(string)
          routing_policy = optional(list(string))
        })))

        cross_connect_groups = optional(map(object({
          compartment_id          = optional(string),
          customer_reference_name = optional(string),
          defined_tags            = optional(map(string)),
          display_name            = optional(string),
          freeform_tags           = optional(map(string)),
          cross_connects = optional(map(object({
            compartment_id                                = optional(string),
            location_name                                 = string,
            port_speed_shape_name                         = string,
            customer_reference_name                       = optional(string),
            defined_tags                                  = optional(map(string))
            display_name                                  = optional(string),
            far_cross_connect_or_cross_connect_group_id   = optional(string),
            far_cross_connect_or_cross_connect_group_key  = optional(string),
            freeform_tags                                 = optional(map(string))
            near_cross_connect_or_cross_connect_group_id  = optional(string),
            near_cross_connect_or_cross_connect_group_key = optional(string),
          })))
        })))

        inject_into_existing_drgs = optional(map(object({
          drg_id = string,

          remote_peering_connections = optional(map(object({
            compartment_id   = optional(string),
            defined_tags     = optional(map(string)),
            display_name     = optional(string),
            freeform_tags    = optional(map(string)),
            peer_id          = optional(string),
            peer_key         = optional(string),
            peer_region_name = optional(string)
          })))

          drg_attachments = optional(map(object({
            defined_tags        = optional(map(string)),
            display_name        = optional(string),
            freeform_tags       = optional(map(string)),
            drg_route_table_id  = optional(string),
            drg_route_table_key = optional(string),
            network_details = optional(object({
              attached_resource_id  = optional(string),
              attached_resource_key = optional(string),
              type                  = string,
              route_table_id        = optional(string),
              route_table_key       = optional(string),
              vcn_route_type        = optional(string)
            }))
          })))

          drg_route_tables = optional(map(object({
            defined_tags                      = optional(map(string)),
            display_name                      = optional(string),
            freeform_tags                     = optional(map(string)),
            import_drg_route_distribution_id  = optional(string),
            import_drg_route_distribution_key = optional(string),
            is_ecmp_enabled                   = optional(bool),
            route_rules = optional(map(object({
              destination                 = string,
              destination_type            = string,
              next_hop_drg_attachment_id  = optional(string),
              next_hop_drg_attachment_key = optional(string),
            })))
          })))

          drg_route_distributions = optional(map(object({
            distribution_type = string,
            defined_tags      = optional(map(string)),
            display_name      = optional(string),
            freeform_tags     = optional(map(string))
            statements = optional(map(object({
              action = string,
              match_criteria = optional(object({
                match_type         = string,
                attachment_type    = optional(string),
                drg_attachment_id  = optional(string),
                drg_attachment_key = optional(string)
              }))
              priority = number
            })))
          })))
        })))

        network_firewalls_configuration = optional(object({
          network_firewalls = optional(map(object({
            availability_domain         = optional(number),
            compartment_id              = optional(string),
            defined_tags                = optional(map(string)),
            display_name                = optional(string),
            freeform_tags               = optional(map(string)),
            ipv4address                 = optional(string),
            ipv6address                 = optional(string),
            network_security_group_ids  = optional(list(string)),
            network_security_group_keys = optional(list(string)),
            subnet_id                   = optional(string),
            subnet_key                  = optional(string),
            network_firewall_policy_id  = optional(string),
            network_firewall_policy_key = optional(string)
          }))),

          network_firewall_policies = optional(map(object({
            compartment_id = optional(string),
            defined_tags   = optional(map(string)),
            display_name   = optional(string),
            freeform_tags  = optional(map(string)),
            services = optional(map(object({
              name = string
              type = optional(string) # Valid values: "TCP_SERVICE" or "UDP_SERVICE"
              minimum_port = number
              maximum_port = optional(number)
            })))
            service_lists = optional(map(object({
              name     = string
              services = list(string)
            })))
            applications = optional(map(object({
              name      = string,
              type      = string,
              icmp_type = number,
              icmp_code = optional(number),
            })))
            application_lists = optional(map(object({
              name = string,
              applications = list(string)
            }))),
            mapped_secrets = optional(map(object({
              name            = string,
              type            = string, # Valid values: SSL_FORWARD_PROXY, SSL_INBOUND_INSPECTION
              source          = string, # Valid value: OCI_VAULT
              vault_secret_id = string,
              version_number  = string,
            }))),
            decryption_profiles = optional(map(object({
              type                                  = string, # Valid values: "SSL_FORWARD_PROXY", "SSL_INBOUND_INSPECTION"
              name                                  = string,
              is_out_of_capacity_blocked            = optional(bool),
              is_unsupported_cipher_blocked         = optional(bool),
              is_unsupported_version_blocked        = optional(bool),
              are_certificate_extensions_restricted = optional(bool), # Applicable only when type = "SSL_FORWARD_PROXY"
              is_auto_include_alt_name              = optional(bool), # Applicable only when type = "SSL_FORWARD_PROXY"
              is_expired_certificate_blocked        = optional(bool), # Applicable only when type = "SSL_FORWARD_PROXY"
              is_revocation_status_timeout_blocked  = optional(bool), # Applicable only when type = "SSL_FORWARD_PROXY"
              is_unknown_revocation_status_blocked  = optional(bool), # Applicable only when type = "SSL_FORWARD_PROXY"
              is_untrusted_issuer_blocked           = optional(bool)  # Applicable only when type = "SSL_FORWARD_PROXY"
            }))),
            decryption_rules = optional(map(object({
              name                        = string,
              action                      = string,
              decryption_profile_id       = optional(string),
              secret                      = optional(string),
              source_ip_address_list      = optional(string),
              destination_ip_address_list = optional(string)
            }))),
            address_lists = optional(map(object({
              name = string,
              type = string, # Valid values: "FQND", "IP"
              addresses = list(string)
            })))
            url_lists = optional(map(object({
              name    = string,
              pattern = string,
              type    = string # Valid value: SIMPLE
            }))),
            security_rules = optional(map(object({
              action = string, # Valid values: ALLOW,DROP,REJECT,INSPECT
              name   = string,
              application_lists         = optional(list(string)),
              destination_address_lists = optional(list(string)),
              service_lists             = optional(list(string)),
              source_address_lists      = optional(list(string)),
              url_lists                 = optional(list(string)),
              inspection  = optional(string), # This is only applicable if action is INSPECT
              after_rule  = optional(string),
              before_rule = optional(string)
            })))
          })))
        }))

        l7_load_balancers = optional(map(object({
          compartment_id              = optional(string),
          display_name                = string,
          shape                       = string,
          subnet_ids                  = list(string),
          subnet_keys                 = list(string),
          defined_tags                = optional(map(string)),
          freeform_tags               = optional(map(string)),
          ip_mode                     = optional(string),
          is_private                  = optional(bool),
          network_security_group_ids  = optional(list(string)),
          network_security_group_keys = optional(list(string)),
          reserved_ips_ids            = optional(list(string)),
          reserved_ips_keys           = optional(list(string))
          shape_details = optional(object({
            maximum_bandwidth_in_mbps = number,
            minimum_bandwidth_in_mbps = number
          }))
          backend_sets = optional(map(object({
            health_checker = object({
              protocol            = string,
              interval_ms         = number,
              is_force_plain_text = bool,
              port                = number,
              response_body_regex = optional(string),
              retries             = number,
              return_code         = number,
              timeout_in_millis   = number,
              url_path            = optional(string)
            })
            name   = string,
            policy = string,
            lb_cookie_session_persistence_configuration = optional(object({
              cookie_name        = optional(string),
              disable_fallback   = optional(bool),
              domain             = optional(string),
              is_http_only       = optional(bool),
              is_secure          = optional(bool),
              max_age_in_seconds = optional(number),
              path               = optional(string),
            }))
            session_persistence_configuration = optional(object({
              cookie_name      = string,
              disable_fallback = optional(bool)
            }))
            ssl_configuration = optional(object({
              certificate_ids                    = optional(list(string)),
              certificate_keys                   = optional(list(string)),
              certificate_name                   = optional(string),
              cipher_suite_name                  = optional(string),
              protocols                          = optional(list(string)),
              server_order_preference            = optional(string),
              trusted_certificate_authority_ids  = optional(list(string)),
              trusted_certificate_authority_keys = optional(list(string)),
              verify_depth                       = optional(number),
              verify_peer_certificate            = optional(bool),
            }))
            backends = optional(map(object({
              ip_address = string,
              port       = number,
              backup     = optional(bool),
              drain      = optional(bool),
              offline    = optional(bool),
              weight     = optional(number)
            })))
          })))
          cipher_suites = optional(map(object({
            ciphers = list(string),
            name    = string
          })))
          path_route_sets = optional(map(object({
            name = string,
            path_routes = map(object({
              backend_set_key = string,
              path            = string,
              path_match_type = object({
                match_type = string
              })
            }))
          })))
          host_names = optional(map(object({
            hostname = string,
            name     = string
          })))
          routing_policies = optional(map(object({
            condition_language_version = string,
            name                       = string,
            rules = map(object({
              actions = map(object({
                backend_set_key = string,
                name            = string,
              }))
              condition = string,
              name      = string
            }))
          })))
          rule_sets = optional(map(object({
            name = string,
            items = map(object({
              action                         = string,
              allowed_methods                = optional(list(string)),
              are_invalid_characters_allowed = optional(bool),
              conditions = optional(map(object({
                attribute_name  = string,
                attribute_value = string,
                operator        = optional(string)
              })))
              description                  = optional(string),
              header                       = optional(string),
              http_large_header_size_in_kb = optional(number),
              prefix                       = optional(string),
              redirect_uri = optional(object({
                host     = optional(string, )
                path     = optional(string),
                port     = optional(number),
                protocol = optional(string),
                query    = optional(string)
              }))
              response_code = optional(number)
              status_code   = optional(number),
              suffix        = optional(string),
              value         = optional(string)
            }))
          })))
          certificates = optional(map(object({
            #Required
            certificate_name = string,
            #Optional
            ca_certificate     = optional(string),
            passphrase         = optional(string),
            private_key        = optional(string),
            public_certificate = optional(string)
          })))
          listeners = optional(map(object({
            default_backend_set_key = string,
            name                    = string,
            port                    = string,
            protocol                = string,
            connection_configuration = optional(object({
              idle_timeout_in_seconds            = number,
              backend_tcp_proxy_protocol_version = optional(string)
            }))
            hostname_keys      = optional(list(string)),
            path_route_set_key = optional(string),
            routing_policy_key = optional(string),
            rule_set_keys      = optional(list(string)),
            ssl_configuration = optional(object({
              certificate_key                   = optional(string),
              certificate_ids                   = optional(list(string)),
              cipher_suite_key                  = optional(string),
              protocols                         = optional(list(string)),
              server_order_preference           = optional(string),
              trusted_certificate_authority_ids = optional(list(string)),
              verify_depth                      = optional(number),
              verify_peer_certificate           = optional(bool)
            }))
          })))
        })))
      }))
      }
    )))
  })
}

variable module_name {
  description = "The module name."
  type = string
  default = "networking"
}

variable "compartments_dependency" {
  description = "A map of objects containing the externally managed compartments this module may depend on. All map objects must have the same type and must contain an 'id' attribute of string type set with the compartment OCID. See External Dependencies section in README.md (https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking#ext-dep) for details."
  type = map(object({
    id = string
  }))
  default = null
}

variable "network_dependency" {
  description = "An object containing the externally managed network resources this module may depend on. Supported resources are 'vcns', 'dynamic_routing_gateways', 'drg_attachments', 'local_peering_gateways', 'remote_peering_connections', and 'dns_private_views', represented as map of objects. Each object, when defined, must have an 'id' attribute of string type set with the VCN, DRG OCID, DRG Attachment OCID, Local Peering Gateway OCID or Remote Peering Connection OCID. 'remote_peering_connections' must also pass the peer region name in the region_name attribute. See External Dependencies section in README.md (https://github.com/oci-landing-zones/terraform-oci-modules-networking#ext-dep) for details."
  type = object({
    vcns = optional(map(object({
      id = string # the VCN OCID
    })))
    dynamic_routing_gateways = optional(map(object({
      id = string # the DRG OCID
    })))
    drg_attachments = optional(map(object({
      id = string # the DRG attachment OCID
    })))
    local_peering_gateways = optional(map(object({
      id = string # the LPG OCID
    })))
    remote_peering_connections = optional(map(object({
      id = string # the peer RPC OCID
      region_name = string # the peer RPC region name
    })))
    dns_private_views = optional(map(object({
      id = string # the DNS private view OCID
    })))
  })
  default = null
}

variable "private_ips_dependency" {
  description = "An object containing the externally managed Private IP resources this module may depend on. All map objects must have the same type and must contain an 'id' attribute of string type set with the Private IP OCID. See External Dependencies section in README.md (https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking#ext-dep) for details."
  type = map(object({
    id = string
  }))
  default = null
}

variable "tenancy_ocid" {
  description = "The tenancy OCID"
  default = null
}