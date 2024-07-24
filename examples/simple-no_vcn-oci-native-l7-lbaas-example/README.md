<!-- BEGIN_TF_DOCS -->
# Simple OCI Native Application(L7) Load Balancer provisioned on an existing VCN/subnet 

## Description

This is an example for a simple/basic provisioning of a OCI Native L7 Load Balancer on an existing VCN/subnet.

For detailed description of the ```terraform-oci-landing-zones-networking``` networking core module please refer to the core module specific [README.md](../../README.md) and [SPEC.md](../../SPEC.md).

This example is leveraging the fully dynamic characteristics of the complex networking module input to describe the following networking topology:

- OCI Application LBaaS construct provisioned on a single compartment
- single networking category defined(production)
- no VCN created
- under the ```non_vcn_specific_gateways``` we're going to create a single OCI Native Application LBaaS that will contain:
    - one ```backend set``` with 2 ```backends```
    - one ```cipher suite```
    - one ```path route set```
    - two ```host names```
    - one ```routing policy```
    - one ```rule set```
    - one ```certificate```
    - two ```listeners```


- It is also creating a ```public_ip``` reservation and attaching it to the ```load balancer```.

__NOTE 1:__ Please note that the entire configuration is a single complex input parameter and you're able to edit it and change the resources names and any of their configuration (like VCN and subnet CIDR blocks, dns labels...) and, also, you're able to change the input configuration topology/structure like adding more categories, more VCNs inside a category, more subnets inside a VCN or inject new resources into existing VCNs and this will reflect into the topology that terraform will provision.

## Diagram of the provisioned networking topology

![](diagrams/public-lb.png)

## Instantiation

For clarity and proper separation and isolation we've separated the input parameters into 2 files by leveraging terraform ```*.auto.tfvars``` feature:

- [terraform.tfvars](./terraform.tfvars.template)


- [network_configuration.auto.tfvars](./network_configuration.auto.tfvars)

### Using the Module with ORM**

For an ad-hoc use where you can select your resources, follow these guidelines:
1. [![Deploy_To_OCI](../../images/DeployToOCI.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking/archive/refs/heads/main.zip&zipUrlVariables={"input_config_file_url":"https://raw.githubusercontent.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking/main/examples/simple-no_vcn-oci-native-l7-lbaas-example/input-configs-standards-options/network_configuration.json"})
2. Accept terms,  wait for the configuration to load. 
3. Set the working directory to “orm-facade”. 
4. Set the stack name you prefer.
5. Set the terraform version to 1.2.x. Click Next. 
6. Add your json/yaml configuration files. Click Next.
8. Un-check run apply. Click Create.


## Output Example:

```
provisioned_networking_resources = {
  "dhcp_options" = {}
  "drg_attachments" = {}
  "drg_route_distributions" = {}
  "drg_route_distributions_statements" = {}
  "drg_route_table_route_rules" = {}
  "drg_route_tables" = {}
  "dynamic_routing_gateways" = {}
  "internet_gateways" = {}
  "l7_load_balancers" = {
    "l7_lb_back_ends" = {
      "EXAMPLE-01-LB-BCK-END-SET-01-BE-01" = {
        "backendset_key" = "EXAMPLE-01-LB-BCK-END-SET-01"
        "backendset_name" = "backend-set-01"
        "backup" = false
        "drain" = false
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq/backendSets/backend-set-01/backends/10.0.2.128:80"
        "ip_address" = "10.0.2.128"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq"
        "l7lb_key" = "EXAMPLE-011_LB_KEY"
        "l7lb_name" = "example-01-tst"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq"
        "name" = "10.0.2.128:80"
        "network_configuration_category" = "production"
        "offline" = false
        "port" = 80
        "state" = "SUCCEEDED"
        "timeouts" = null /* object */
        "weight" = 1
      }
      "EXAMPLE-01-LB-BCK-END-SET-01-BE-02" = {
        "backendset_key" = "EXAMPLE-01-LB-BCK-END-SET-01"
        "backendset_name" = "backend-set-01"
        "backup" = false
        "drain" = false
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq/backendSets/backend-set-01/backends/10.0.2.94:80"
        "ip_address" = "10.0.2.94"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq"
        "l7lb_key" = "EXAMPLE-011_LB_KEY"
        "l7lb_name" = "example-01-tst"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq"
        "name" = "10.0.2.94:80"
        "network_configuration_category" = "production"
        "offline" = false
        "port" = 80
        "state" = "SUCCEEDED"
        "timeouts" = null /* object */
        "weight" = 1
      }
    }
    "l7_lb_backend_sets" = {
      "EXAMPLE-01-LB-BCK-END-SET-01" = {
        "backend" = toset([])
        "health_checker" = tolist([
          {
            "interval_ms" = 10000
            "is_force_plain_text" = false
            "port" = 80
            "protocol" = "HTTP"
            "response_body_regex" = ".*"
            "retries" = 3
            "return_code" = 200
            "timeout_in_millis" = 3000
            "url_path" = "/"
          },
        ])
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq/backendSets/backend-set-01"
        "l7lb_backendset_key" = "EXAMPLE-01-LB-BCK-END-SET-01"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq"
        "l7lb_key" = "EXAMPLE-011_LB_KEY"
        "l7lb_name" = "example-01-tst"
        "lb_cookie_session_persistence_configuration" = tolist([
          {
            "cookie_name" = "example_cookie"
            "disable_fallback" = false
            "domain" = "Set-cookie"
            "is_http_only" = true
            "is_secure" = false
            "max_age_in_seconds" = 3600
            "path" = "/"
          },
        ])
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq"
        "name" = "backend-set-01"
        "network_configuration_category" = "production"
        "policy" = "LEAST_CONNECTIONS"
        "session_persistence_configuration" = tolist([])
        "ssl_configuration" = tolist([])
        "state" = "SUCCEEDED"
        "timeouts" = null /* object */
      }
    }
    "l7_lb_certificates" = {
      "LB-1-CERT-1-KEY" = {
        "ca_certificate" = "~/certs/ca.crt"
        "certificate_name" = "lb1-cert1"
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq/certificates/lb1-cert1"
        "l7lb_certificate_key" = "LB-1-CERT-1-KEY"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq"
        "l7lb_key" = "EXAMPLE-011_LB_KEY"
        "l7lb_name" = "example-01-tst"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq"
        "network_configuration_category" = "production"
        "passphrase" = tostring(null)
        "private_key" = "~/certs/my_cert.key"
        "public_certificate" = "~/certs/my_cert.crt"
        "state" = "SUCCEEDED"
        "timeouts" = null /* object */
      }
    }
    "l7_lb_cipher_suites" = {
      "EXAMPLE-01-LB-CIPHER-SUITE-01-KEY" = {
        "ciphers" = tolist([
          "ECDHE-RSA-AES256-GCM-SHA384",
          "ECDHE-ECDSA-AES256-GCM-SHA384",
          "ECDHE-RSA-AES128-GCM-SHA256",
        ])
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq/sslCipherSuites/cipher_suite_01"
        "l7lb_cs_key" = "EXAMPLE-01-LB-CIPHER-SUITE-01-KEY"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq"
        "l7lb_key" = "EXAMPLE-011_LB_KEY"
        "l7lb_name" = "example-01-tst"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq"
        "name" = "cipher_suite_01"
        "network_configuration_category" = "production"
        "state" = "SUCCEEDED"
        "timeouts" = null /* object */
      }
    }
    "l7_lb_hostnames" = {
      "LB1-HOSTNAME-1-KEY" = {
        "hostname" = "lb1test1.com"
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq/hostnames/lb1test1"
        "l7lb_hostname_key" = "LB1-HOSTNAME-1-KEY"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq"
        "l7lb_key" = "EXAMPLE-011_LB_KEY"
        "l7lb_name" = "example-01-tst"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq"
        "name" = "lb1test1"
        "network_configuration_category" = "production"
        "state" = "SUCCEEDED"
        "timeouts" = null /* object */
      }
      "LB1-HOSTNAME-2-KEY" = {
        "hostname" = "lb1test2.com"
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq/hostnames/lb1test2"
        "l7lb_hostname_key" = "LB1-HOSTNAME-2-KEY"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq"
        "l7lb_key" = "EXAMPLE-011_LB_KEY"
        "l7lb_name" = "example-01-tst"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq"
        "name" = "lb1test2"
        "network_configuration_category" = "production"
        "state" = "SUCCEEDED"
        "timeouts" = null /* object */
      }
    }
    "l7_lb_listeners" = {
      "LB1-LSNR-1-80" = {
        "connection_configuration" = tolist([
          {
            "backend_tcp_proxy_protocol_version" = 0
            "idle_timeout_in_seconds" = "1200"
          },
        ])
        "default_backend_set_name" = "backend-set-01"
        "hostname_names" = tolist([])
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq/listeners/lb1-lsnr1-80"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq"
        "l7lb_key" = "EXAMPLE-011_LB_KEY"
        "l7lb_listener_key" = "LB1-LSNR-1-80"
        "l7lb_name" = "example-01-tst"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq"
        "name" = "lb1-lsnr1-80"
        "network_configuration_category" = "production"
        "path_route_set_name" = tostring(null)
        "port" = 80
        "protocol" = "HTTP"
        "routing_policy_name" = tostring(null)
        "rule_set_names" = tolist([])
        "ssl_configuration" = tolist([])
        "state" = "SUCCEEDED"
        "timeouts" = null /* object */
      }
      "LB1-LSNR-2-443" = {
        "connection_configuration" = tolist([
          {
            "backend_tcp_proxy_protocol_version" = 0
            "idle_timeout_in_seconds" = "1200"
          },
        ])
        "default_backend_set_name" = "backend-set-01"
        "hostname_names" = tolist([
          "lb1test1",
          "lb1test2",
        ])
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq/listeners/lb1-lsnr2-443"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq"
        "l7lb_key" = "EXAMPLE-011_LB_KEY"
        "l7lb_listener_key" = "LB1-LSNR-2-443"
        "l7lb_name" = "example-01-tst"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq"
        "name" = "lb1-lsnr2-443"
        "network_configuration_category" = "production"
        "path_route_set_name" = "path_route_set_01"
        "port" = 443
        "protocol" = "HTTP"
        "routing_policy_name" = "V1"
        "rule_set_names" = tolist([
          "example_rule_set",
        ])
        "ssl_configuration" = tolist([
          {
            "certificate_ids" = tolist(null) /* of string */
            "certificate_name" = "lb1-cert1"
            "cipher_suite_name" = "oci-default-ssl-cipher-suite-v1"
            "protocols" = tolist([
              "TLSv1.2",
            ])
            "server_order_preference" = "ENABLED"
            "trusted_certificate_authority_ids" = tolist(null) /* of string */
            "verify_depth" = 3
            "verify_peer_certificate" = false
          },
        ])
        "state" = "SUCCEEDED"
        "timeouts" = null /* object */
      }
    }
    "l7_lb_path_route_sets" = {
      "EXMPL_01_PATH_ROUTE_SET_01_KEY" = {
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq/pathRouteSets/path_route_set_01"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq"
        "l7lb_key" = "EXAMPLE-011_LB_KEY"
        "l7lb_name" = "example-01-tst"
        "l7lb_prs_key" = "EXMPL_01_PATH_ROUTE_SET_01_KEY"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq"
        "name" = "path_route_set_01"
        "network_configuration_category" = "production"
        "path_routes" = tolist([
          {
            "backend_set_name" = "backend-set-01"
            "path" = "/example/video/123"
            "path_match_type" = tolist([
              {
                "match_type" = "EXACT_MATCH"
              },
            ])
          },
          {
            "backend_set_name" = "backend-set-01"
            "path" = "/"
            "path_match_type" = tolist([
              {
                "match_type" = "EXACT_MATCH"
              },
            ])
          },
        ])
        "state" = "SUCCEEDED"
        "timeouts" = null /* object */
      }
    }
    "l7_lb_routing_policies" = {
      "LB1-ROUTE-POLICY-1-KEY" = {
        "condition_language_version" = "V1"
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq/routingPolicies/V1"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq"
        "l7lb_key" = "EXAMPLE-011_LB_KEY"
        "l7lb_name" = "example-01-tst"
        "l7lb_routing_policy_key" = "LB1-ROUTE-POLICY-1-KEY"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq"
        "name" = "V1"
        "network_configuration_category" = "production"
        "rules" = tolist([
          {
            "actions" = tolist([
              {
                "backend_set_name" = "backend-set-01"
                "name" = "FORWARD_TO_BACKENDSET"
              },
            ])
            "condition" = "any(http.request.url.path eq (i '/documents'), http.request.headers[(i 'host')] eq (i 'doc.myapp.com'))"
            "name" = "Documents_rule"
          },
          {
            "actions" = tolist([
              {
                "backend_set_name" = "backend-set-01"
                "name" = "FORWARD_TO_BACKENDSET"
              },
            ])
            "condition" = "all(http.request.headers[(i 'user-agent')] eq (i 'mobile'), http.request.url.query[(i 'department')] eq (i 'HR'))"
            "name" = "HR_mobile_user_rule"
          },
        ])
        "state" = "SUCCEEDED"
        "timeouts" = null /* object */
      }
    }
    "l7_lb_rule_sets" = {
      "LB1-RULE-SET-1-KEY" = {
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq/ruleSets/example_rule_set"
        "items" = toset([
          {
            "action" = "ADD_HTTP_REQUEST_HEADER"
            "allowed_methods" = toset([])
            "are_invalid_characters_allowed" = false
            "conditions" = tolist([])
            "description" = ""
            "header" = "example_header_name"
            "http_large_header_size_in_kb" = 0
            "prefix" = ""
            "redirect_uri" = tolist([])
            "response_code" = 0
            "status_code" = 0
            "suffix" = ""
            "value" = "example_value"
          },
          {
            "action" = "EXTEND_HTTP_REQUEST_HEADER_VALUE"
            "allowed_methods" = toset([])
            "are_invalid_characters_allowed" = false
            "conditions" = tolist([])
            "description" = ""
            "header" = "example_header_name2"
            "http_large_header_size_in_kb" = 0
            "prefix" = "example_prefix_value"
            "redirect_uri" = tolist([])
            "response_code" = 0
            "status_code" = 0
            "suffix" = "example_suffix_value"
            "value" = ""
          },
        ])
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq"
        "l7lb_key" = "EXAMPLE-011_LB_KEY"
        "l7lb_name" = "example-01-tst"
        "l7lb_rule_set_key" = "LB1-RULE-SET-1-KEY"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq"
        "name" = "example_rule_set"
        "network_configuration_category" = "production"
        "state" = "SUCCEEDED"
        "timeouts" = null /* object */
      }
    }
    "l7_load_balancers" = {
      "EXAMPLE-011_LB_KEY" = {
        "compartment_id" = "ocid1.compartment.oc1..aaaaaaaawwhpzd5kxd7dcd56kiuuxeaa46icb44cnu7osq3mbclo2pnv3dpq"
        "defined_tags" = tomap({
          "CCA_Basic_Tag.email" = "oracleidentitycloudservice/cosmin.tudor@oracle.com"
        })
        "display_name" = "example-01-tst"
        "freeform_tags" = tomap({
          "vision-environment" = "vision"
          "vision-sub-environment" = "prod"
        })
        "id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaas2rvttptgse2bqmsxfvrrcrobsq4ii67jkhlzdbwxajmbdnxwufq"
        "ip_mode" = "IPV4"
        "is_private" = false
        "network_configuration_category" = "production"
        "network_security_group_ids" = toset([
          "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaafk3jky5ex2ro55wjflyehdmscyywu2vwxagaklpnivdua46fziwq",
        ])
        "network_security_groups" = {
          "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaafk3jky5ex2ro55wjflyehdmscyywu2vwxagaklpnivdua46fziwq" = {
            "display_name" = "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
            "nsg_id" = "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaafk3jky5ex2ro55wjflyehdmscyywu2vwxagaklpnivdua46fziwq"
            "nsg_key" = "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
          }
        }
        "reserved_ips" = tolist([])
        "reserved_public_ips" = {}
        "shape" = "flexible"
        "shape_details" = tolist([
          {
            "maximum_bandwidth_in_mbps" = 100
            "minimum_bandwidth_in_mbps" = 10
          },
        ])
        "subnet_ids" = tolist([
          "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaarfak6ybbvej3jlceaqcsuisvijnr5wydqrcvph4vcapppvpr3ymq",
        ])
        "subnets" = {
          "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaarfak6ybbvej3jlceaqcsuisvijnr5wydqrcvph4vcapppvpr3ymq" = {
            "display_name" = "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
            "subnet_id" = "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaarfak6ybbvej3jlceaqcsuisvijnr5wydqrcvph4vcapppvpr3ymq"
            "subnet_key" = "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
            "vcn_id" = "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
            "vcn_key" = "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
            "vcn_name" = "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
          }
        }
      }
    }
  }
  "local_peering_gateways" = {}
  "nat_gateways" = {}
  "network_security_groups" = {}
  "network_security_groups_egress_rules" = {}
  "network_security_groups_ingress_rules" = {}
  "oci_network_firewall_network_firewall_policies" = {}
  "oci_network_firewall_network_firewalls" = {}
  "public_ips" = {
    "PROD-IP-LB-1-KEY" = {
      "assigned_entity_id" = tostring(null)
      "assigned_entity_type" = ""
      "availability_domain" = tostring(null)
      "compartment_id" = "ocid1.compartment.oc1..aaaaaaaawwhpzd5kxd7dcd56kiuuxeaa46icb44cnu7osq3mbclo2pnv3dpq"
      "defined_tags" = tomap({
        "CCA_Basic_Tag.email" = "oracleidentitycloudservice/cosmin.tudor@oracle.com"
      })
      "display_name" = "prod_ip_lb_1"
      "freeform_tags" = tomap({
        "vision-environment" = "vision"
        "vision-sub-environment" = "prod"
      })
      "id" = "ocid1.publicip.oc1.eu-frankfurt-1.amaaaaaattkvkkia4hxfajz4l2oo2euewxc4iru5zwppcwf3xvqo3xwxs37a"
      "ip_address" = "130.162.251.96"
      "lifetime" = "RESERVED"
      "network_configuration_category" = "production"
      "private_ip_id" = tostring(null)
      "pubips_key" = "PROD-IP-LB-1-KEY"
      "public_ip_pool_id" = tostring(null)
      "public_ip_pool_key" = "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
      "scope" = "REGION"
      "state" = "AVAILABLE"
      "time_created" = "2023-05-26 12:11:57.609 +0000 UTC"
    }
  }
  "public_ips_pools" = {}
  "remote_peering_connections" = {}
  "route_tables" = {}
  "route_tables_attachments" = {}
  "security_lists" = {}
  "service_gateways" = {}
  "subnets" = {}
  "vcns" = {}
}
```