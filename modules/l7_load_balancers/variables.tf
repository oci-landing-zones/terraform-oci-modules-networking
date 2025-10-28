# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

variable "l7_load_balancers_configuration" {

  type = object({
    dependencies = optional(object({
      subnets = optional(map(object({
        availability_domain            = string,
        cidr_block                     = string,
        compartment_id                 = string,
        defined_tags                   = map(string),
        dhcp_options_id                = string,
        dhcp_options_key               = string,
        dhcp_options_name              = string,
        display_name                   = string,
        dns_label                      = string,
        freeform_tags                  = map(string),
        id                             = string,
        ipv6cidr_block                 = string,
        ipv6cidr_blocks                = list(string),
        ipv6virtual_router_ip          = string,
        prohibit_internet_ingress      = string,
        prohibit_public_ip_on_vnic     = string,
        route_table_id                 = string,
        route_table_key                = string,
        route_table_name               = string,
        security_lists                 = map(object({})),
        state                          = string,
        subnet_domain_name             = string,
        time_created                   = string,
        timeouts                       = object({}),
        vcn_id                         = string,
        vcn_key                        = string,
        vcn_name                       = string,
        network_configuration_category = string,
        virtual_router_ip              = string,
        virtual_router_mac             = string,
        subnet_key                     = string
      }))),
      public_ips = optional(map(object({
        assigned_entity_id             = string,
        assigned_entity_type           = string,
        availability_domain            = string,
        compartment_id                 = string,
        defined_tags                   = map(string),
        display_name                   = string,
        freeform_tags                  = map(string),
        id                             = string,
        ip_address                     = string
        lifetime                       = string,
        private_ip_id                  = string,
        public_ip_pool_id              = string,
        public_ip_pool_key             = string,
        scope                          = string,
        state                          = string,
        time_created                   = string,
        pubips_key                     = string,
        network_configuration_category = string
      })))
      network_security_groups = optional(map(object({
        compartment_id                 = string,
        defined_tags                   = map(string),
        display_name                   = string,
        freeform_tags                  = map(string),
        id                             = string,
        nsg_key                        = string,
        state                          = string,
        time_created                   = string,
        timeouts                       = object({}),
        vcn_id                         = string,
        vcn_key                        = string,
        vcn_name                       = string,
        network_configuration_category = string
      }))),
    })),
    l7_load_balancers = map(object({
      compartment_id                 = optional(string),
      display_name                   = string,
      shape                          = string,
      subnet_ids                     = list(string),
      subnet_keys                    = list(string),
      defined_tags                   = optional(map(string)),
      freeform_tags                  = optional(map(string)),
      ip_mode                        = optional(string),
      is_private                     = optional(bool),
      network_security_group_ids     = optional(list(string)),
      network_security_group_keys    = optional(list(string)),
      reserved_ips_ids               = optional(list(string)),
      reserved_ips_keys              = optional(list(string)),
      network_configuration_category = string,
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
    }))
  })
}

variable "module_name" {
  description = "The module name."
  type        = string
  default     = "networking-l7-load-balancers"
}

variable "compartments_dependency" {
  description = "A map of objects containing the externally managed compartments this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute (representing the compartment OCID) of string type."
  type = map(object({
    id = string # the compartment OCID
  }))
  default = null
}

variable "network_dependency" {
  description = "An object containing the externally managed network resources this module may depend on. Supported resources are 'subnets' represented as map of objects. Each object, when defined, must have an 'id' attribute of string type set with the subnet OCID."
  type = object({
    subnets = optional(map(object({
      id = string # the subnet OCID
    })))
  })
  default = null
}