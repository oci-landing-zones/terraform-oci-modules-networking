l7_load_balancers_configuration = {
  l7_load_balancers = {
    LBAAS-EXAMPLE-01-KEY = {
      compartment_id             = "ocid1.compartment...",
      display_name               = "lbaas-example-01"
      shape                      = "flexible"
      subnet_keys                = null
      subnet_ids                 = ["ocid1.subnet.oc1..."]
      ip_mode                    = "IPV4",
      is_private                 = false,
      network_security_group_ids = ["ocid1.networksecuritygroup.oc1..."],
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