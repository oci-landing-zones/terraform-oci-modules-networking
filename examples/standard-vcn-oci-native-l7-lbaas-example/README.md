<!-- BEGIN_TF_DOCS -->
# Standard OCI Native Application(L7) Load Balancer provisioned toghether with the underlying network infrastructure

## Description

This is an example for a simple/basic instantiation of the ```terraform-oci-landing-zones-networking``` networking core module, provisioning a complete VCN construct and a complete OCI Native LBaaS construct on top of the respective VCN.

For detailed description of the ```terraform-oci-landing-zones-networking``` networking core module please refer to the core module specific [README.md](../../README.md) and [SPEC.md](../../SPEC.md).

This example is leveraging the fully dynamic characteristics of the complex networking module input to describe the following networking topology:

- networking construct provisioned on a single compartment
- single networking category defined
- the category will contain one single VCN (10.0.0.0/18)
- the VCN will contain the following a 3 tier topology (load balancer, application and database) as follows:
    - Three security lists:
        - a load balancer security list allowing ingress from anywhere for https:443 and ssh:22
        - an application security list allowing ingress from the lb subnet CIDR over http:80 and ssh:22
        - a database security list allowing ingress from the db subnet CIDR over TCP(jdbc):1521 and ssh:22
    - All three security lists contain an egress rule to allow egress traffic over any port to anywhere.
    - Three gateways:
        - One Internet Gateway
        - One NAT Gateway
        - One Service Gateway
    - Two route tables:
        - ```rt-01``` defines a route to the Internet Gateway
        - ```rt-02``` defines two routes:
            - a route to the NAT GW;
            - a route to the Service GW;
    - Three Network Security Groups (NSGs)
        - ```lb-nsg``` allowing ingress from anywhere for https:443 and ssh:22;
        - ```app-nsg``` allowing ingress from the ```lb-nsg``` over http:80 and ssh:22;
        - ```db-nsg``` allowing ingress from the ```app-nsg``` over TCP (jdbc):1521 and ssh:22 
    - all NSGs contain an egress rule to allow egress traffic over any port to anywhere.
    - Three subnets:
        - ```lb-subnet``` (10.0.3.0/24) for the load balancer tier. This subnet will be using the ```rt-01``` route table, default VCN DHCP options and the lb security list.
        -  ```app-subnet``` (10.0.2.0/24) for the application tier. This subnet will be using the ```rt-02``` route table, default VCN DHCP options and the app security list.
        - ```db-subnet``` (10.0.1.0/24) for the database tier. This subnet will be using the ```rt-02``` route table, default VCN DHCP options and the db security list.
- 2 OCI Application LBaaS construct provisioned in 2 different categories
- under the ```non_vcn_specific_gateways``` we're going to create a single OCI Native Application LBaaS, per category, that will contain:
    - one ```backend set``` with 2 ```backends```
    - one ```cipher suite```
    - one ```path route set```
    - two ```host names```
    - one ```routing policy```
    - one ```rule set```
    - one ```certificate```
    - two ```listeners```
- 2 ```public_ip``` reservations, one per category, each being associated with a respective OCI LBaaS.
- Please note that the load balancer in the ```production``` category is created on top of the VCN construct created under the same category while the load balancer in the "development" category is created on top of the same VCN created under the ```production``` category.

__NOTE 1:__ Please note the redudancy in defining both security lists and NSGs. We've intentionally chosed to define both, for example purposes, but you'll just need to define one or the other, depending on your usecase.

__NOTE 2:__ Please note that the entire configuration is a single complex input parameter and you're able to edit it and change the resources names and any of their configuration (like VCN and subnet CIDR blocks, dns labels...) and, also, you're able to change the input configuration topology/structure like adding more categories, more VCNs inside a category, more subnets inside a VCN or inject new resources into existing VCNs and this will reflect into the topology that terraform will provision.

## Diagram of the provisioned networking topology

![](diagrams/public-lb.png)

## Instantiation

For clarity and proper separation and isolation we've separated the input parameters into 2 files by leveraging terraform ```*.auto.tfvars``` feature:

- [terraform.tfvars](./terraform.tfvars.template)


- [network_configuration.auto.tfvars](./network_configuration.auto.tfvars)

### Using the Module with ORM**

For an ad-hoc use where you can select your resources, follow these guidelines:
1. [![Deploy_To_OCI](../../images/DeployToOCI.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking/archive/refs/heads/main.zip&zipUrlVariables={"input_config_file_url":"https://raw.githubusercontent.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking/main/examples/standard-vcn-oci-native-l7-lbaas-example/input-configs-standards-options/network_configuration.json"})
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
  "internet_gateways" = {
    "IGW-KEY" = {
      "compartment_id" = "ocid1.compartment.oc1..aaaaaaaawwhpzd5kxd7dcd56kiuuxeaa46icb44cnu7osq3mbclo2pnv3dpq"
      "defined_tags" = tomap({
        "CCA_Basic_Tag.email" = "oracleidentitycloudservice/cosmin.tudor@oracle.com"
      })
      "display_name" = "igw-prod-vcn"
      "enabled" = true
      "freeform_tags" = tomap({
        "vision-environment" = "vision"
        "vision-sub-environment" = "prod"
      })
      "id" = "ocid1.internetgateway.oc1.eu-frankfurt-1.aaaaaaaat4bg6xc46jslhdo6jgcixzdafx7nnke3mlxpdb7rrabiephpddsa"
      "igw_key" = "IGW-KEY"
      "network_configuration_category" = "production"
      "route_table_id" = tostring(null)
      "route_table_key" = tostring(null)
      "route_table_name" = null
      "state" = "AVAILABLE"
      "time_created" = "2023-05-26 12:39:49.39 +0000 UTC"
      "timeouts" = null /* object */
      "vcn_id" = "ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaattkvkkiaostwdsz7tbjnklmsm2htaqesvd7ut5udmh2ivltztjka"
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
    }
  }
  "l7_load_balancers" = {
    "l7_lb_back_ends" = {
      "EXAMPLE-01-LB-BCK-END-SET-01-BE-01" = {
        "backendset_key" = "EXAMPLE-01-LB-BCK-END-SET-01"
        "backendset_name" = "backend-set-01"
        "backup" = false
        "drain" = false
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka/backendSets/backend-set-01/backends/10.0.2.128:80"
        "ip_address" = "10.0.2.128"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka"
        "l7lb_key" = "EXAMPLE-011_LB_KEY"
        "l7lb_name" = "example-01-tst"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka"
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
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka/backendSets/backend-set-01/backends/10.0.2.94:80"
        "ip_address" = "10.0.2.94"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka"
        "l7lb_key" = "EXAMPLE-011_LB_KEY"
        "l7lb_name" = "example-01-tst"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka"
        "name" = "10.0.2.94:80"
        "network_configuration_category" = "production"
        "offline" = false
        "port" = 80
        "state" = "SUCCEEDED"
        "timeouts" = null /* object */
        "weight" = 1
      }
      "EXAMPLE-02-LB-BCK-END-SET-01-BE-01" = {
        "backendset_key" = "EXAMPLE-02-LB-BCK-END-SET-01"
        "backendset_name" = "backend-set-01"
        "backup" = false
        "drain" = false
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq/backendSets/backend-set-01/backends/10.0.2.55:80"
        "ip_address" = "10.0.2.55"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq"
        "l7lb_key" = "EXAMPLE-02_LB_KEY"
        "l7lb_name" = "example-02"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq"
        "name" = "10.0.2.55:80"
        "network_configuration_category" = "development"
        "offline" = false
        "port" = 80
        "state" = "SUCCEEDED"
        "timeouts" = null /* object */
        "weight" = 1
      }
      "EXAMPLE-02-LB-BCK-END-SET-01-BE-02" = {
        "backendset_key" = "EXAMPLE-02-LB-BCK-END-SET-01"
        "backendset_name" = "backend-set-01"
        "backup" = false
        "drain" = false
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq/backendSets/backend-set-01/backends/10.0.2.116:80"
        "ip_address" = "10.0.2.116"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq"
        "l7lb_key" = "EXAMPLE-02_LB_KEY"
        "l7lb_name" = "example-02"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq"
        "name" = "10.0.2.116:80"
        "network_configuration_category" = "development"
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
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka/backendSets/backend-set-01"
        "l7lb_backendset_key" = "EXAMPLE-01-LB-BCK-END-SET-01"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka"
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
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka"
        "name" = "backend-set-01"
        "network_configuration_category" = "production"
        "policy" = "LEAST_CONNECTIONS"
        "session_persistence_configuration" = tolist([])
        "ssl_configuration" = tolist([])
        "state" = "SUCCEEDED"
        "timeouts" = null /* object */
      }
      "EXAMPLE-02-LB-BCK-END-SET-01" = {
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
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq/backendSets/backend-set-01"
        "l7lb_backendset_key" = "EXAMPLE-02-LB-BCK-END-SET-01"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq"
        "l7lb_key" = "EXAMPLE-02_LB_KEY"
        "l7lb_name" = "example-02"
        "lb_cookie_session_persistence_configuration" = tolist([])
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq"
        "name" = "backend-set-01"
        "network_configuration_category" = "development"
        "policy" = "LEAST_CONNECTIONS"
        "session_persistence_configuration" = tolist([
          {
            "cookie_name" = "example_cookie_2"
            "disable_fallback" = false
          },
        ])
        "ssl_configuration" = tolist([])
        "state" = "SUCCEEDED"
        "timeouts" = null /* object */
      }
    }
    "l7_lb_certificates" = {
      "LB-1-CERT-1-KEY" = {
        "ca_certificate" = "~/certs/ca.crt"
        "certificate_name" = "lb1-cert1"
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka/certificates/lb1-cert1"
        "l7lb_certificate_key" = "LB-1-CERT-1-KEY"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka"
        "l7lb_key" = "EXAMPLE-011_LB_KEY"
        "l7lb_name" = "example-01-tst"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka"
        "network_configuration_category" = "production"
        "passphrase" = tostring(null)
        "private_key" = "~/certs/my_cert.key"
        "public_certificate" = "~/certs/my_cert.crt"
        "state" = "SUCCEEDED"
        "timeouts" = null /* object */
      }
      "LB-2-CERT-1-KEY" = {
        "ca_certificate" = "~/certs/ca.crt"
        "certificate_name" = "lb2-cert1"
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq/certificates/lb2-cert1"
        "l7lb_certificate_key" = "LB-2-CERT-1-KEY"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq"
        "l7lb_key" = "EXAMPLE-02_LB_KEY"
        "l7lb_name" = "example-02"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq"
        "network_configuration_category" = "development"
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
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka/sslCipherSuites/cipher_suite_01"
        "l7lb_cs_key" = "EXAMPLE-01-LB-CIPHER-SUITE-01-KEY"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka"
        "l7lb_key" = "EXAMPLE-011_LB_KEY"
        "l7lb_name" = "example-01-tst"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka"
        "name" = "cipher_suite_01"
        "network_configuration_category" = "production"
        "state" = "SUCCEEDED"
        "timeouts" = null /* object */
      }
      "EXAMPLE-02-LB-CIPHER-SUITE-01-KEY" = {
        "ciphers" = tolist([
          "ECDHE-RSA-AES256-GCM-SHA384",
          "ECDHE-ECDSA-AES256-GCM-SHA384",
          "ECDHE-RSA-AES128-GCM-SHA256",
        ])
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq/sslCipherSuites/cipher_suite_01"
        "l7lb_cs_key" = "EXAMPLE-02-LB-CIPHER-SUITE-01-KEY"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq"
        "l7lb_key" = "EXAMPLE-02_LB_KEY"
        "l7lb_name" = "example-02"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq"
        "name" = "cipher_suite_01"
        "network_configuration_category" = "development"
        "state" = "SUCCEEDED"
        "timeouts" = null /* object */
      }
    }
    "l7_lb_hostnames" = {
      "LB1-HOSTNAME-1-KEY" = {
        "hostname" = "lb1test1.com"
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka/hostnames/lb1test1"
        "l7lb_hostname_key" = "LB1-HOSTNAME-1-KEY"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka"
        "l7lb_key" = "EXAMPLE-011_LB_KEY"
        "l7lb_name" = "example-01-tst"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka"
        "name" = "lb1test1"
        "network_configuration_category" = "production"
        "state" = "SUCCEEDED"
        "timeouts" = null /* object */
      }
      "LB1-HOSTNAME-2-KEY" = {
        "hostname" = "lb1test2.com"
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka/hostnames/lb1test2"
        "l7lb_hostname_key" = "LB1-HOSTNAME-2-KEY"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka"
        "l7lb_key" = "EXAMPLE-011_LB_KEY"
        "l7lb_name" = "example-01-tst"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka"
        "name" = "lb1test2"
        "network_configuration_category" = "production"
        "state" = "SUCCEEDED"
        "timeouts" = null /* object */
      }
      "LB2-HOSTNAME-1-KEY" = {
        "hostname" = "lb2test1.com"
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq/hostnames/lb2test1"
        "l7lb_hostname_key" = "LB2-HOSTNAME-1-KEY"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq"
        "l7lb_key" = "EXAMPLE-02_LB_KEY"
        "l7lb_name" = "example-02"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq"
        "name" = "lb2test1"
        "network_configuration_category" = "development"
        "state" = "SUCCEEDED"
        "timeouts" = null /* object */
      }
      "LB2-HOSTNAME-2-KEY" = {
        "hostname" = "lb2test2.com"
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq/hostnames/lb2test2"
        "l7lb_hostname_key" = "LB2-HOSTNAME-2-KEY"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq"
        "l7lb_key" = "EXAMPLE-02_LB_KEY"
        "l7lb_name" = "example-02"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq"
        "name" = "lb2test2"
        "network_configuration_category" = "development"
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
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka/listeners/lb1-lsnr1-80"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka"
        "l7lb_key" = "EXAMPLE-011_LB_KEY"
        "l7lb_listener_key" = "LB1-LSNR-1-80"
        "l7lb_name" = "example-01-tst"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka"
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
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka/listeners/lb1-lsnr2-443"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka"
        "l7lb_key" = "EXAMPLE-011_LB_KEY"
        "l7lb_listener_key" = "LB1-LSNR-2-443"
        "l7lb_name" = "example-01-tst"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka"
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
      "LB2-LSNR-1-80" = {
        "connection_configuration" = tolist([
          {
            "backend_tcp_proxy_protocol_version" = 0
            "idle_timeout_in_seconds" = "1200"
          },
        ])
        "default_backend_set_name" = "backend-set-01"
        "hostname_names" = tolist([])
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq/listeners/lb2-lsnr1-80"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq"
        "l7lb_key" = "EXAMPLE-02_LB_KEY"
        "l7lb_listener_key" = "LB2-LSNR-1-80"
        "l7lb_name" = "example-02"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq"
        "name" = "lb2-lsnr1-80"
        "network_configuration_category" = "development"
        "path_route_set_name" = tostring(null)
        "port" = 80
        "protocol" = "HTTP"
        "routing_policy_name" = tostring(null)
        "rule_set_names" = tolist([])
        "ssl_configuration" = tolist([])
        "state" = "SUCCEEDED"
        "timeouts" = null /* object */
      }
      "LB2-LSNR-2-443" = {
        "connection_configuration" = tolist([
          {
            "backend_tcp_proxy_protocol_version" = 0
            "idle_timeout_in_seconds" = "1200"
          },
        ])
        "default_backend_set_name" = "backend-set-01"
        "hostname_names" = tolist([
          "lb2test1",
          "lb2test2",
        ])
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq/listeners/lb2-lsnr2-443"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq"
        "l7lb_key" = "EXAMPLE-02_LB_KEY"
        "l7lb_listener_key" = "LB2-LSNR-2-443"
        "l7lb_name" = "example-02"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq"
        "name" = "lb2-lsnr2-443"
        "network_configuration_category" = "development"
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
            "certificate_name" = "lb2-cert1"
            "cipher_suite_name" = "cipher_suite_01"
            "protocols" = tolist([
              "TLSv1.2",
            ])
            "server_order_preference" = "ENABLED"
            "trusted_certificate_authority_ids" = tolist(null) /* of string */
            "verify_depth" = 3
            "verify_peer_certificate" = true
          },
        ])
        "state" = "SUCCEEDED"
        "timeouts" = null /* object */
      }
    }
    "l7_lb_path_route_sets" = {
      "EXMPL_01_PATH_ROUTE_SET_01_KEY" = {
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka/pathRouteSets/path_route_set_01"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka"
        "l7lb_key" = "EXAMPLE-011_LB_KEY"
        "l7lb_name" = "example-01-tst"
        "l7lb_prs_key" = "EXMPL_01_PATH_ROUTE_SET_01_KEY"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka"
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
      "EXMPL_02_PATH_ROUTE_SET_01_KEY" = {
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq/pathRouteSets/path_route_set_01"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq"
        "l7lb_key" = "EXAMPLE-02_LB_KEY"
        "l7lb_name" = "example-02"
        "l7lb_prs_key" = "EXMPL_02_PATH_ROUTE_SET_01_KEY"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq"
        "name" = "path_route_set_01"
        "network_configuration_category" = "development"
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
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka/routingPolicies/V1"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka"
        "l7lb_key" = "EXAMPLE-011_LB_KEY"
        "l7lb_name" = "example-01-tst"
        "l7lb_routing_policy_key" = "LB1-ROUTE-POLICY-1-KEY"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka"
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
      "LB2-ROUTE-POLICY-1-KEY" = {
        "condition_language_version" = "V1"
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq/routingPolicies/V1"
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq"
        "l7lb_key" = "EXAMPLE-02_LB_KEY"
        "l7lb_name" = "example-02"
        "l7lb_routing_policy_key" = "LB2-ROUTE-POLICY-1-KEY"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq"
        "name" = "V1"
        "network_configuration_category" = "development"
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
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka/ruleSets/example_rule_set"
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
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka"
        "l7lb_key" = "EXAMPLE-011_LB_KEY"
        "l7lb_name" = "example-01-tst"
        "l7lb_rule_set_key" = "LB1-RULE-SET-1-KEY"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka"
        "name" = "example_rule_set"
        "network_configuration_category" = "production"
        "state" = "SUCCEEDED"
        "timeouts" = null /* object */
      }
      "LB2-RULE-SET-1-KEY" = {
        "id" = "loadBalancers/ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq/ruleSets/example_rule_set"
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
            "action" = "ADD_HTTP_RESPONSE_HEADER"
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
            "action" = "ALLOW"
            "allowed_methods" = toset([])
            "are_invalid_characters_allowed" = false
            "conditions" = tolist([
              {
                "attribute_name" = "SOURCE_IP_ADDRESS"
                "attribute_value" = "192.168.0.0/16"
                "operator" = ""
              },
            ])
            "description" = "permitted internet clients"
            "header" = ""
            "http_large_header_size_in_kb" = 0
            "prefix" = ""
            "redirect_uri" = tolist([])
            "response_code" = 0
            "status_code" = 0
            "suffix" = ""
            "value" = ""
          },
          {
            "action" = "CONTROL_ACCESS_USING_HTTP_METHODS"
            "allowed_methods" = toset([
              "GET",
              "POST",
              "PROPFIND",
              "PUT",
            ])
            "are_invalid_characters_allowed" = false
            "conditions" = tolist([])
            "description" = ""
            "header" = ""
            "http_large_header_size_in_kb" = 0
            "prefix" = ""
            "redirect_uri" = tolist([])
            "response_code" = 0
            "status_code" = 405
            "suffix" = ""
            "value" = ""
          },
          {
            "action" = "EXTEND_HTTP_REQUEST_HEADER_VALUE"
            "allowed_methods" = toset([])
            "are_invalid_characters_allowed" = false
            "conditions" = tolist([])
            "description" = ""
            "header" = "example_header_name"
            "http_large_header_size_in_kb" = 0
            "prefix" = "example_prefix_value"
            "redirect_uri" = tolist([])
            "response_code" = 0
            "status_code" = 0
            "suffix" = "example_suffix_value"
            "value" = ""
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
          {
            "action" = "EXTEND_HTTP_RESPONSE_HEADER_VALUE"
            "allowed_methods" = toset([])
            "are_invalid_characters_allowed" = false
            "conditions" = tolist([])
            "description" = ""
            "header" = "example_header_name"
            "http_large_header_size_in_kb" = 0
            "prefix" = "example_prefix_value"
            "redirect_uri" = tolist([])
            "response_code" = 0
            "status_code" = 0
            "suffix" = "example_suffix_value"
            "value" = ""
          },
          {
            "action" = "HTTP_HEADER"
            "allowed_methods" = toset([])
            "are_invalid_characters_allowed" = false
            "conditions" = tolist([])
            "description" = ""
            "header" = ""
            "http_large_header_size_in_kb" = 32
            "prefix" = ""
            "redirect_uri" = tolist([])
            "response_code" = 0
            "status_code" = 0
            "suffix" = ""
            "value" = ""
          },
          {
            "action" = "REDIRECT"
            "allowed_methods" = toset([])
            "are_invalid_characters_allowed" = false
            "conditions" = tolist([
              {
                "attribute_name" = "PATH"
                "attribute_value" = "/example"
                "operator" = "SUFFIX_MATCH"
              },
            ])
            "description" = ""
            "header" = ""
            "http_large_header_size_in_kb" = 0
            "prefix" = ""
            "redirect_uri" = tolist([
              {
                "host" = "in{host}"
                "path" = "{path}/video"
                "port" = 8081
                "protocol" = "{protocol}"
                "query" = "{query}"
              },
            ])
            "response_code" = 302
            "status_code" = 0
            "suffix" = ""
            "value" = ""
          },
          {
            "action" = "REMOVE_HTTP_REQUEST_HEADER"
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
            "value" = ""
          },
          {
            "action" = "REMOVE_HTTP_RESPONSE_HEADER"
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
            "value" = ""
          },
        ])
        "l7lb_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq"
        "l7lb_key" = "EXAMPLE-02_LB_KEY"
        "l7lb_name" = "example-02"
        "l7lb_rule_set_key" = "LB2-RULE-SET-1-KEY"
        "load_balancer_id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq"
        "name" = "example_rule_set"
        "network_configuration_category" = "development"
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
        "id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa5vrv4okn4hqqxzbjg3jk2qxavnxgfdqnnd5sbehpvxs2z46wikka"
        "ip_mode" = "IPV4"
        "is_private" = false
        "network_configuration_category" = "production"
        "network_security_group_ids" = toset([
          "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaavssk2haxavs5x4snsajpnafdbqdn4hqlc46l6aqyq7a33lslankq",
        ])
        "network_security_groups" = {
          "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaavssk2haxavs5x4snsajpnafdbqdn4hqlc46l6aqyq7a33lslankq" = {
            "display_name" = "nsg-lb"
            "nsg_id" = "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaavssk2haxavs5x4snsajpnafdbqdn4hqlc46l6aqyq7a33lslankq"
            "nsg_key" = "NSG-LB-KEY"
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
          "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaalreuoqee3m6binowztulilhdrirn5y4jnguuqon4zswhv7fxx4wq",
        ])
        "subnets" = {
          "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaalreuoqee3m6binowztulilhdrirn5y4jnguuqon4zswhv7fxx4wq" = {
            "display_name" = "sub-public-lb"
            "subnet_id" = "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaalreuoqee3m6binowztulilhdrirn5y4jnguuqon4zswhv7fxx4wq"
            "subnet_key" = "PUBLIC-LB-SUBNET-KEY"
            "vcn_id" = "ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaattkvkkiaostwdsz7tbjnklmsm2htaqesvd7ut5udmh2ivltztjka"
            "vcn_key" = "SIMPLE-VCN-KEY"
            "vcn_name" = "vcn-simple"
          }
        }
      }
      "EXAMPLE-02_LB_KEY" = {
        "compartment_id" = "ocid1.compartment.oc1..aaaaaaaawwhpzd5kxd7dcd56kiuuxeaa46icb44cnu7osq3mbclo2pnv3dpq"
        "defined_tags" = tomap({
          "CCA_Basic_Tag.email" = "oracleidentitycloudservice/cosmin.tudor@oracle.com"
        })
        "display_name" = "example-02"
        "freeform_tags" = tomap({
          "vision-environment" = "vision"
          "vision-sub-environment" = "dev"
        })
        "id" = "ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaamzpl4qul42qc446xrhw4fofxoaudrikam5opvzh2u2y2ocxtk4tq"
        "ip_mode" = "IPV4"
        "is_private" = true
        "network_configuration_category" = "development"
        "network_security_group_ids" = toset([
          "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaahkexkdbmawopykhfej2bpuiyrfnxxgp6n7dwbkqkpzurgqcj3q3a",
        ])
        "network_security_groups" = {
          "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaahkexkdbmawopykhfej2bpuiyrfnxxgp6n7dwbkqkpzurgqcj3q3a" = {
            "display_name" = "nsg-app"
            "nsg_id" = "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaahkexkdbmawopykhfej2bpuiyrfnxxgp6n7dwbkqkpzurgqcj3q3a"
            "nsg_key" = "NSG-APP-KEY"
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
          "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaa3ylvsxn7vsblnuz57z2l4ii2yirighelq3feyhv5kplqo7yderma",
        ])
        "subnets" = {
          "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaa3ylvsxn7vsblnuz57z2l4ii2yirighelq3feyhv5kplqo7yderma" = {
            "display_name" = "sub-private-app"
            "subnet_id" = "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaa3ylvsxn7vsblnuz57z2l4ii2yirighelq3feyhv5kplqo7yderma"
            "subnet_key" = "PRIVATE-APP-SUBNET-KEY"
            "vcn_id" = "ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaattkvkkiaostwdsz7tbjnklmsm2htaqesvd7ut5udmh2ivltztjka"
            "vcn_key" = "SIMPLE-VCN-KEY"
            "vcn_name" = "vcn-simple"
          }
        }
      }
    }
  }
  "local_peering_gateways" = {}
  "nat_gateways" = {
    "NATGW-KEY" = {
      "block_traffic" = false
      "compartment_id" = "ocid1.compartment.oc1..aaaaaaaawwhpzd5kxd7dcd56kiuuxeaa46icb44cnu7osq3mbclo2pnv3dpq"
      "defined_tags" = tomap({
        "CCA_Basic_Tag.email" = "oracleidentitycloudservice/cosmin.tudor@oracle.com"
      })
      "display_name" = "natgw-prod-vcn"
      "freeform_tags" = tomap({
        "vision-environment" = "vision"
        "vision-sub-environment" = "prod"
      })
      "id" = "ocid1.natgateway.oc1.eu-frankfurt-1.aaaaaaaatzsbreq4fbbzowxi5mwb6xew3mk3t2iukbujyettcyus7m4e2v7q"
      "nat_ip" = "130.162.60.55"
      "natgw_key" = "NATGW-KEY"
      "network_configuration_category" = "production"
      "public_ip_id" = "ocid1.publicip.oc1.eu-frankfurt-1.aaaaaaaau7llvfdkvbdohjkbujjdlvf4jfc56nol54ghz7oqeztcvghtascq"
      "route_table_id" = tostring(null)
      "route_table_key" = tostring(null)
      "route_table_name" = null
      "state" = "AVAILABLE"
      "time_created" = "2023-05-26 12:39:49.427 +0000 UTC"
      "timeouts" = null /* object */
      "vcn_id" = "ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaattkvkkiaostwdsz7tbjnklmsm2htaqesvd7ut5udmh2ivltztjka"
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
    }
  }
  "network_security_groups" = {
    "NSG-APP-KEY" = {
      "compartment_id" = "ocid1.compartment.oc1..aaaaaaaawwhpzd5kxd7dcd56kiuuxeaa46icb44cnu7osq3mbclo2pnv3dpq"
      "defined_tags" = tomap({
        "CCA_Basic_Tag.email" = "oracleidentitycloudservice/cosmin.tudor@oracle.com"
      })
      "display_name" = "nsg-app"
      "freeform_tags" = tomap({
        "vision-environment" = "vision"
        "vision-sub-environment" = "prod"
      })
      "id" = "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaahkexkdbmawopykhfej2bpuiyrfnxxgp6n7dwbkqkpzurgqcj3q3a"
      "network_configuration_category" = "production"
      "nsg_key" = "NSG-APP-KEY"
      "state" = "AVAILABLE"
      "time_created" = "2023-05-26 12:39:49.285 +0000 UTC"
      "timeouts" = null /* object */
      "vcn_id" = "ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaattkvkkiaostwdsz7tbjnklmsm2htaqesvd7ut5udmh2ivltztjka"
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
    }
    "NSG-DB-KEY" = {
      "compartment_id" = "ocid1.compartment.oc1..aaaaaaaawwhpzd5kxd7dcd56kiuuxeaa46icb44cnu7osq3mbclo2pnv3dpq"
      "defined_tags" = tomap({
        "CCA_Basic_Tag.email" = "oracleidentitycloudservice/cosmin.tudor@oracle.com"
      })
      "display_name" = "nsg-db"
      "freeform_tags" = tomap({
        "vision-environment" = "vision"
        "vision-sub-environment" = "prod"
      })
      "id" = "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaajfp5kqct2gs2dwgmmylluqmwbieghcjnqxcspmfeugg4t36otsxa"
      "network_configuration_category" = "production"
      "nsg_key" = "NSG-DB-KEY"
      "state" = "AVAILABLE"
      "time_created" = "2023-05-26 12:39:50.068 +0000 UTC"
      "timeouts" = null /* object */
      "vcn_id" = "ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaattkvkkiaostwdsz7tbjnklmsm2htaqesvd7ut5udmh2ivltztjka"
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
    }
    "NSG-LB-KEY" = {
      "compartment_id" = "ocid1.compartment.oc1..aaaaaaaawwhpzd5kxd7dcd56kiuuxeaa46icb44cnu7osq3mbclo2pnv3dpq"
      "defined_tags" = tomap({
        "CCA_Basic_Tag.email" = "oracleidentitycloudservice/cosmin.tudor@oracle.com"
      })
      "display_name" = "nsg-lb"
      "freeform_tags" = tomap({
        "vision-environment" = "vision"
        "vision-sub-environment" = "prod"
      })
      "id" = "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaavssk2haxavs5x4snsajpnafdbqdn4hqlc46l6aqyq7a33lslankq"
      "network_configuration_category" = "production"
      "nsg_key" = "NSG-LB-KEY"
      "state" = "AVAILABLE"
      "time_created" = "2023-05-26 12:39:50.201 +0000 UTC"
      "timeouts" = null /* object */
      "vcn_id" = "ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaattkvkkiaostwdsz7tbjnklmsm2htaqesvd7ut5udmh2ivltztjka"
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
    }
  }
  "network_security_groups_egress_rules" = {
    "NSG-APP-KEY.anywhere" = {
      "description" = "egress to 0.0.0.0/0 over TCP"
      "destination" = "0.0.0.0/0"
      "destination_type" = "CIDR_BLOCK"
      "direction" = "EGRESS"
      "icmp_options" = tolist([])
      "id" = "9E32FF"
      "is_valid" = true
      "network_configuration_category" = "production"
      "network_security_group_id" = "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaahkexkdbmawopykhfej2bpuiyrfnxxgp6n7dwbkqkpzurgqcj3q3a"
      "network_security_group_key" = "NSG-APP-KEY"
      "network_security_group_name" = "nsg-app"
      "protocol" = "6"
      "source" = tostring(null)
      "source_type" = ""
      "stateless" = false
      "tcp_options" = tolist([
        {
          "destination_port_range" = tolist([])
          "source_port_range" = tolist([])
        },
      ])
      "time_created" = "2023-05-26 12:39:50.78 +0000 UTC"
      "timeouts" = null /* object */
      "udp_options" = tolist([])
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
    }
    "NSG-DB-KEY.anywhere" = {
      "description" = "egress to 0.0.0.0/0 over TCP"
      "destination" = "0.0.0.0/0"
      "destination_type" = "CIDR_BLOCK"
      "direction" = "EGRESS"
      "icmp_options" = tolist([])
      "id" = "2132AF"
      "is_valid" = true
      "network_configuration_category" = "production"
      "network_security_group_id" = "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaajfp5kqct2gs2dwgmmylluqmwbieghcjnqxcspmfeugg4t36otsxa"
      "network_security_group_key" = "NSG-DB-KEY"
      "network_security_group_name" = "nsg-db"
      "protocol" = "6"
      "source" = tostring(null)
      "source_type" = ""
      "stateless" = false
      "tcp_options" = tolist([
        {
          "destination_port_range" = tolist([])
          "source_port_range" = tolist([])
        },
      ])
      "time_created" = "2023-05-26 12:39:50.864 +0000 UTC"
      "timeouts" = null /* object */
      "udp_options" = tolist([])
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
    }
    "NSG-LB-KEY.anywhere" = {
      "description" = "egress to 0.0.0.0/0 over TCP"
      "destination" = "0.0.0.0/0"
      "destination_type" = "CIDR_BLOCK"
      "direction" = "EGRESS"
      "icmp_options" = tolist([])
      "id" = "703C3C"
      "is_valid" = true
      "network_configuration_category" = "production"
      "network_security_group_id" = "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaavssk2haxavs5x4snsajpnafdbqdn4hqlc46l6aqyq7a33lslankq"
      "network_security_group_key" = "NSG-LB-KEY"
      "network_security_group_name" = "nsg-lb"
      "protocol" = "6"
      "source" = tostring(null)
      "source_type" = ""
      "stateless" = false
      "tcp_options" = tolist([
        {
          "destination_port_range" = tolist([])
          "source_port_range" = tolist([])
        },
      ])
      "time_created" = "2023-05-26 12:39:51.449 +0000 UTC"
      "timeouts" = null /* object */
      "udp_options" = tolist([])
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
    }
  }
  "network_security_groups_ingress_rules" = {
    "NSG-APP-KEY.http_8080" = {
      "description" = "ingress from 0.0.0.0/0 over HTTP8080"
      "destination" = tostring(null)
      "destination_type" = ""
      "direction" = "INGRESS"
      "icmp_options" = tolist([])
      "id" = "AF4F7C"
      "is_valid" = true
      "network_configuration_category" = "production"
      "network_security_group_id" = "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaahkexkdbmawopykhfej2bpuiyrfnxxgp6n7dwbkqkpzurgqcj3q3a"
      "network_security_group_key" = "NSG-APP-KEY"
      "network_security_group_name" = "nsg-app"
      "protocol" = "6"
      "source" = "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaavssk2haxavs5x4snsajpnafdbqdn4hqlc46l6aqyq7a33lslankq"
      "source_type" = "NETWORK_SECURITY_GROUP"
      "stateless" = false
      "tcp_options" = tolist([
        {
          "destination_port_range" = tolist([
            {
              "max" = 80
              "min" = 80
            },
          ])
          "source_port_range" = tolist([])
        },
      ])
      "time_created" = "2023-05-26 12:39:51.102 +0000 UTC"
      "timeouts" = null /* object */
      "udp_options" = tolist([])
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
    }
    "NSG-APP-KEY.ssh_22" = {
      "description" = "ingress from 0.0.0.0/0 over TCP22"
      "destination" = tostring(null)
      "destination_type" = ""
      "direction" = "INGRESS"
      "icmp_options" = tolist([])
      "id" = "B84250"
      "is_valid" = true
      "network_configuration_category" = "production"
      "network_security_group_id" = "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaahkexkdbmawopykhfej2bpuiyrfnxxgp6n7dwbkqkpzurgqcj3q3a"
      "network_security_group_key" = "NSG-APP-KEY"
      "network_security_group_name" = "nsg-app"
      "protocol" = "6"
      "source" = "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaavssk2haxavs5x4snsajpnafdbqdn4hqlc46l6aqyq7a33lslankq"
      "source_type" = "NETWORK_SECURITY_GROUP"
      "stateless" = false
      "tcp_options" = tolist([
        {
          "destination_port_range" = tolist([
            {
              "max" = 22
              "min" = 22
            },
          ])
          "source_port_range" = tolist([])
        },
      ])
      "time_created" = "2023-05-26 12:39:50.958 +0000 UTC"
      "timeouts" = null /* object */
      "udp_options" = tolist([])
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
    }
    "NSG-DB-KEY.http_8080" = {
      "description" = "ingress from 0.0.0.0/0 over TCP:1521"
      "destination" = tostring(null)
      "destination_type" = ""
      "direction" = "INGRESS"
      "icmp_options" = tolist([])
      "id" = "7EE933"
      "is_valid" = true
      "network_configuration_category" = "production"
      "network_security_group_id" = "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaajfp5kqct2gs2dwgmmylluqmwbieghcjnqxcspmfeugg4t36otsxa"
      "network_security_group_key" = "NSG-DB-KEY"
      "network_security_group_name" = "nsg-db"
      "protocol" = "6"
      "source" = "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaahkexkdbmawopykhfej2bpuiyrfnxxgp6n7dwbkqkpzurgqcj3q3a"
      "source_type" = "NETWORK_SECURITY_GROUP"
      "stateless" = false
      "tcp_options" = tolist([
        {
          "destination_port_range" = tolist([
            {
              "max" = 1521
              "min" = 1521
            },
          ])
          "source_port_range" = tolist([])
        },
      ])
      "time_created" = "2023-05-26 12:39:51.016 +0000 UTC"
      "timeouts" = null /* object */
      "udp_options" = tolist([])
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
    }
    "NSG-DB-KEY.ssh_22" = {
      "description" = "ingress from 0.0.0.0/0 over TCP22"
      "destination" = tostring(null)
      "destination_type" = ""
      "direction" = "INGRESS"
      "icmp_options" = tolist([])
      "id" = "045843"
      "is_valid" = true
      "network_configuration_category" = "production"
      "network_security_group_id" = "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaajfp5kqct2gs2dwgmmylluqmwbieghcjnqxcspmfeugg4t36otsxa"
      "network_security_group_key" = "NSG-DB-KEY"
      "network_security_group_name" = "nsg-db"
      "protocol" = "6"
      "source" = "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaahkexkdbmawopykhfej2bpuiyrfnxxgp6n7dwbkqkpzurgqcj3q3a"
      "source_type" = "NETWORK_SECURITY_GROUP"
      "stateless" = false
      "tcp_options" = tolist([
        {
          "destination_port_range" = tolist([
            {
              "max" = 22
              "min" = 22
            },
          ])
          "source_port_range" = tolist([])
        },
      ])
      "time_created" = "2023-05-26 12:39:52.562 +0000 UTC"
      "timeouts" = null /* object */
      "udp_options" = tolist([])
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
    }
    "NSG-LB-KEY.http_443" = {
      "description" = "ingress from 0.0.0.0/0 over https:443"
      "destination" = tostring(null)
      "destination_type" = ""
      "direction" = "INGRESS"
      "icmp_options" = tolist([])
      "id" = "F039CD"
      "is_valid" = true
      "network_configuration_category" = "production"
      "network_security_group_id" = "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaavssk2haxavs5x4snsajpnafdbqdn4hqlc46l6aqyq7a33lslankq"
      "network_security_group_key" = "NSG-LB-KEY"
      "network_security_group_name" = "nsg-lb"
      "protocol" = "6"
      "source" = "0.0.0.0/0"
      "source_type" = "CIDR_BLOCK"
      "stateless" = false
      "tcp_options" = tolist([
        {
          "destination_port_range" = tolist([
            {
              "max" = 443
              "min" = 443
            },
          ])
          "source_port_range" = tolist([])
        },
      ])
      "time_created" = "2023-05-26 12:39:51.304 +0000 UTC"
      "timeouts" = null /* object */
      "udp_options" = tolist([])
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
    }
    "NSG-LB-KEY.http_80" = {
      "description" = "ingress from 0.0.0.0/0 over https:80"
      "destination" = tostring(null)
      "destination_type" = ""
      "direction" = "INGRESS"
      "icmp_options" = tolist([])
      "id" = "842AFB"
      "is_valid" = true
      "network_configuration_category" = "production"
      "network_security_group_id" = "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaavssk2haxavs5x4snsajpnafdbqdn4hqlc46l6aqyq7a33lslankq"
      "network_security_group_key" = "NSG-LB-KEY"
      "network_security_group_name" = "nsg-lb"
      "protocol" = "6"
      "source" = "0.0.0.0/0"
      "source_type" = "CIDR_BLOCK"
      "stateless" = false
      "tcp_options" = tolist([
        {
          "destination_port_range" = tolist([
            {
              "max" = 80
              "min" = 80
            },
          ])
          "source_port_range" = tolist([])
        },
      ])
      "time_created" = "2023-05-26 12:39:51.686 +0000 UTC"
      "timeouts" = null /* object */
      "udp_options" = tolist([])
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
    }
    "NSG-LB-KEY.ssh_22" = {
      "description" = "ingress from 0.0.0.0/0 over TCP22"
      "destination" = tostring(null)
      "destination_type" = ""
      "direction" = "INGRESS"
      "icmp_options" = tolist([])
      "id" = "9EDA31"
      "is_valid" = true
      "network_configuration_category" = "production"
      "network_security_group_id" = "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaavssk2haxavs5x4snsajpnafdbqdn4hqlc46l6aqyq7a33lslankq"
      "network_security_group_key" = "NSG-LB-KEY"
      "network_security_group_name" = "nsg-lb"
      "protocol" = "6"
      "source" = "0.0.0.0/0"
      "source_type" = "CIDR_BLOCK"
      "stateless" = false
      "tcp_options" = tolist([
        {
          "destination_port_range" = tolist([
            {
              "max" = 22
              "min" = 22
            },
          ])
          "source_port_range" = tolist([])
        },
      ])
      "time_created" = "2023-05-26 12:39:51.173 +0000 UTC"
      "timeouts" = null /* object */
      "udp_options" = tolist([])
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
    }
  }
  "oci_network_firewall_network_firewall_policies" = {}
  "oci_network_firewall_network_firewalls" = {}
  "public_ips" = {
    "DEV-IP-LB-1-KEY" = {
      "assigned_entity_id" = tostring(null)
      "assigned_entity_type" = ""
      "availability_domain" = tostring(null)
      "compartment_id" = "ocid1.compartment.oc1..aaaaaaaawwhpzd5kxd7dcd56kiuuxeaa46icb44cnu7osq3mbclo2pnv3dpq"
      "defined_tags" = tomap({
        "CCA_Basic_Tag.email" = "oracleidentitycloudservice/cosmin.tudor@oracle.com"
      })
      "display_name" = "dev_ip_lb_1"
      "freeform_tags" = tomap({
        "vision-environment" = "vision"
        "vision-sub-environment" = "dev"
      })
      "id" = "ocid1.publicip.oc1.eu-frankfurt-1.amaaaaaattkvkkiaysu4uk2afvwblhoblw22w22c6seyiki5nsls7mauj23a"
      "ip_address" = "129.159.199.231"
      "lifetime" = "RESERVED"
      "network_configuration_category" = "development"
      "private_ip_id" = tostring(null)
      "pubips_key" = "DEV-IP-LB-1-KEY"
      "public_ip_pool_id" = tostring(null)
      "public_ip_pool_key" = "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
      "scope" = "REGION"
      "state" = "AVAILABLE"
      "time_created" = "2023-05-26 12:39:46.596 +0000 UTC"
    }
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
      "id" = "ocid1.publicip.oc1.eu-frankfurt-1.amaaaaaattkvkkiadpy2vmfy2j2qipzron6t6qhp6qdi54ykkt7gm22x2gfa"
      "ip_address" = "141.147.20.160"
      "lifetime" = "RESERVED"
      "network_configuration_category" = "production"
      "private_ip_id" = tostring(null)
      "pubips_key" = "PROD-IP-LB-1-KEY"
      "public_ip_pool_id" = tostring(null)
      "public_ip_pool_key" = "NOT DETERMINED AS NOT CREATED BY THIS AUTOMATION"
      "scope" = "REGION"
      "state" = "AVAILABLE"
      "time_created" = "2023-05-26 12:39:46.666 +0000 UTC"
    }
  }
  "public_ips_pools" = {}
  "remote_peering_connections" = {}
  "route_tables" = {
    "DEFAULT_ROUTE_TABLE_FOR_VCN-SIMPLE-KEY" = {
      "compartment_id" = "ocid1.compartment.oc1..aaaaaaaawwhpzd5kxd7dcd56kiuuxeaa46icb44cnu7osq3mbclo2pnv3dpq"
      "defined_tags" = tomap({
        "CCA_Basic_Tag.email" = "oracleidentitycloudservice/cosmin.tudor@oracle.com"
      })
      "display_name" = "Default Route Table for vcn-simple"
      "freeform_tags" = tomap({
        "vision-environment" = "vision"
        "vision-sub-environment" = "prod"
      })
      "id" = "ocid1.routetable.oc1.eu-frankfurt-1.aaaaaaaakroqpfui7kgnohajzwszdxzjl6amwdshpwzutzqk6eoprn226xga"
      "network_configuration_category" = "production"
      "route_rules" = tolist([])
      "route_table_key" = "DEFAULT_ROUTE_TABLE_FOR_VCN-SIMPLE-KEY"
      "state" = "AVAILABLE"
      "time_created" = "2023-05-26 12:39:46.718 +0000 UTC"
      "vcn_id" = "ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaattkvkkiaostwdsz7tbjnklmsm2htaqesvd7ut5udmh2ivltztjka"
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
    }
    "RT-01-KEY" = {
      "compartment_id" = "ocid1.compartment.oc1..aaaaaaaawwhpzd5kxd7dcd56kiuuxeaa46icb44cnu7osq3mbclo2pnv3dpq"
      "defined_tags" = tomap({
        "CCA_Basic_Tag.email" = "oracleidentitycloudservice/cosmin.tudor@oracle.com"
      })
      "display_name" = "rt-01"
      "freeform_tags" = tomap({
        "vision-environment" = "vision"
        "vision-sub-environment" = "prod"
      })
      "id" = "ocid1.routetable.oc1.eu-frankfurt-1.aaaaaaaan3m4ysaan6kd3ywcxuu6zlnghybo3dfpbu375qyftndob4m7lgra"
      "network_configuration_category" = "production"
      "route_rules" = toset([
        {
          "cidr_block" = ""
          "description" = "Route for internet access"
          "destination" = "0.0.0.0/0"
          "destination_type" = "CIDR_BLOCK"
          "network_entity_id" = "ocid1.internetgateway.oc1.eu-frankfurt-1.aaaaaaaat4bg6xc46jslhdo6jgcixzdafx7nnke3mlxpdb7rrabiephpddsa"
          "route_type" = ""
        },
      ])
      "route_table_key" = "RT-01-KEY"
      "state" = "AVAILABLE"
      "time_created" = "2023-05-26 12:40:25.947 +0000 UTC"
      "timeouts" = null /* object */
      "vcn_id" = "ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaattkvkkiaostwdsz7tbjnklmsm2htaqesvd7ut5udmh2ivltztjka"
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
    }
    "RT-02-KEY" = {
      "compartment_id" = "ocid1.compartment.oc1..aaaaaaaawwhpzd5kxd7dcd56kiuuxeaa46icb44cnu7osq3mbclo2pnv3dpq"
      "defined_tags" = tomap({
        "CCA_Basic_Tag.email" = "oracleidentitycloudservice/cosmin.tudor@oracle.com"
      })
      "display_name" = "rt-02-prod-vcn-01"
      "freeform_tags" = tomap({
        "vision-environment" = "vision"
        "vision-sub-environment" = "prod"
      })
      "id" = "ocid1.routetable.oc1.eu-frankfurt-1.aaaaaaaaqa6uminiilymosaqfksb55xgzwa7gqzryck7lxvennfcfi77qola"
      "network_configuration_category" = "production"
      "route_rules" = toset([
        {
          "cidr_block" = ""
          "description" = "Route for internet access via NAT GW"
          "destination" = "0.0.0.0/0"
          "destination_type" = "CIDR_BLOCK"
          "network_entity_id" = "ocid1.natgateway.oc1.eu-frankfurt-1.aaaaaaaatzsbreq4fbbzowxi5mwb6xew3mk3t2iukbujyettcyus7m4e2v7q"
          "route_type" = ""
        },
        {
          "cidr_block" = ""
          "description" = "Route for sgw"
          "destination" = "oci-fra-objectstorage"
          "destination_type" = "SERVICE_CIDR_BLOCK"
          "network_entity_id" = "ocid1.servicegateway.oc1.eu-frankfurt-1.aaaaaaaat2uig4tz4af6vwtarrumdasmscrfmosbxddvh5rz4kgvahj2zwdq"
          "route_type" = ""
        },
      ])
      "route_table_key" = "RT-02-KEY"
      "state" = "AVAILABLE"
      "time_created" = "2023-05-26 12:40:26.1 +0000 UTC"
      "timeouts" = null /* object */
      "vcn_id" = "ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaattkvkkiaostwdsz7tbjnklmsm2htaqesvd7ut5udmh2ivltztjka"
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
    }
  }
  "route_tables_attachments" = {
    "PRIVATE-APP-SUBNET-KEY" = {
      "id" = "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaa3ylvsxn7vsblnuz57z2l4ii2yirighelq3feyhv5kplqo7yderma/ocid1.routetable.oc1.eu-frankfurt-1.aaaaaaaaqa6uminiilymosaqfksb55xgzwa7gqzryck7lxvennfcfi77qola"
      "network_configuration_category" = "production"
      "route_table_id" = "ocid1.routetable.oc1.eu-frankfurt-1.aaaaaaaaqa6uminiilymosaqfksb55xgzwa7gqzryck7lxvennfcfi77qola"
      "route_table_key" = "RT-02-KEY"
      "route_table_name" = "rt-02-prod-vcn-01"
      "rta_key" = "PRIVATE-APP-SUBNET-KEY"
      "subnet_id" = "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaa3ylvsxn7vsblnuz57z2l4ii2yirighelq3feyhv5kplqo7yderma"
      "subnet_key" = "PRIVATE-APP-SUBNET-KEY"
      "subnet_name" = "sub-private-app"
      "timeouts" = null /* object */
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
    }
    "PRIVATE-DB-SUBNET-KEY" = {
      "id" = "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaaxo2bcpvreiytwd3an2zimkzxi4qmn2iocucjvcnfne4nzvgru7cq/ocid1.routetable.oc1.eu-frankfurt-1.aaaaaaaaqa6uminiilymosaqfksb55xgzwa7gqzryck7lxvennfcfi77qola"
      "network_configuration_category" = "production"
      "route_table_id" = "ocid1.routetable.oc1.eu-frankfurt-1.aaaaaaaaqa6uminiilymosaqfksb55xgzwa7gqzryck7lxvennfcfi77qola"
      "route_table_key" = "RT-02-KEY"
      "route_table_name" = "rt-02-prod-vcn-01"
      "rta_key" = "PRIVATE-DB-SUBNET-KEY"
      "subnet_id" = "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaaxo2bcpvreiytwd3an2zimkzxi4qmn2iocucjvcnfne4nzvgru7cq"
      "subnet_key" = "PRIVATE-DB-SUBNET-KEY"
      "subnet_name" = "sub-private-db"
      "timeouts" = null /* object */
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
    }
    "PUBLIC-LB-SUBNET-KEY" = {
      "id" = "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaalreuoqee3m6binowztulilhdrirn5y4jnguuqon4zswhv7fxx4wq/ocid1.routetable.oc1.eu-frankfurt-1.aaaaaaaan3m4ysaan6kd3ywcxuu6zlnghybo3dfpbu375qyftndob4m7lgra"
      "network_configuration_category" = "production"
      "route_table_id" = "ocid1.routetable.oc1.eu-frankfurt-1.aaaaaaaan3m4ysaan6kd3ywcxuu6zlnghybo3dfpbu375qyftndob4m7lgra"
      "route_table_key" = "RT-01-KEY"
      "route_table_name" = "rt-01"
      "rta_key" = "PUBLIC-LB-SUBNET-KEY"
      "subnet_id" = "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaalreuoqee3m6binowztulilhdrirn5y4jnguuqon4zswhv7fxx4wq"
      "subnet_key" = "PUBLIC-LB-SUBNET-KEY"
      "subnet_name" = "sub-public-lb"
      "timeouts" = null /* object */
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
    }
  }
  "security_lists" = {
    "SECLIST-APP-KEY" = {
      "compartment_id" = "ocid1.compartment.oc1..aaaaaaaawwhpzd5kxd7dcd56kiuuxeaa46icb44cnu7osq3mbclo2pnv3dpq"
      "defined_tags" = tomap({
        "CCA_Basic_Tag.email" = "oracleidentitycloudservice/cosmin.tudor@oracle.com"
      })
      "display_name" = "sl-app"
      "egress_security_rules" = toset([
        {
          "description" = "egress to 0.0.0.0/0 over TCP"
          "destination" = "0.0.0.0/0"
          "destination_type" = "CIDR_BLOCK"
          "icmp_options" = tolist([])
          "protocol" = "6"
          "stateless" = false
          "tcp_options" = tolist([])
          "udp_options" = tolist([])
        },
      ])
      "freeform_tags" = tomap({
        "vision-environment" = "vision"
        "vision-sub-environment" = "prod"
      })
      "id" = "ocid1.securitylist.oc1.eu-frankfurt-1.aaaaaaaajymzjghs6l774eueukderiqagchwjigzouzehf6ren5b6pfasrfq"
      "ingress_security_rules" = toset([
        {
          "description" = "ingress from 10.0.2.0/24 over HTTP80"
          "icmp_options" = tolist([])
          "protocol" = "6"
          "source" = "10.0.2.0/24"
          "source_type" = "CIDR_BLOCK"
          "stateless" = false
          "tcp_options" = tolist([
            {
              "max" = 80
              "min" = 80
              "source_port_range" = tolist([])
            },
          ])
          "udp_options" = tolist([])
        },
        {
          "description" = "ingress from 10.0.3.0/24 over HTTP80"
          "icmp_options" = tolist([])
          "protocol" = "6"
          "source" = "10.0.3.0/24"
          "source_type" = "CIDR_BLOCK"
          "stateless" = false
          "tcp_options" = tolist([
            {
              "max" = 80
              "min" = 80
              "source_port_range" = tolist([])
            },
          ])
          "udp_options" = tolist([])
        },
        {
          "description" = "ingress from 10.0.3.0/24 over TCP22"
          "icmp_options" = tolist([])
          "protocol" = "6"
          "source" = "10.0.3.0/24"
          "source_type" = "CIDR_BLOCK"
          "stateless" = false
          "tcp_options" = tolist([
            {
              "max" = 22
              "min" = 22
              "source_port_range" = tolist([])
            },
          ])
          "udp_options" = tolist([])
        },
      ])
      "network_configuration_category" = "production"
      "sec_list_key" = "SECLIST-APP-KEY"
      "state" = "AVAILABLE"
      "time_created" = "2023-05-26 12:39:49.183 +0000 UTC"
      "timeouts" = null /* object */
      "vcn_id" = "ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaattkvkkiaostwdsz7tbjnklmsm2htaqesvd7ut5udmh2ivltztjka"
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
    }
    "SECLIST-DB-KEY" = {
      "compartment_id" = "ocid1.compartment.oc1..aaaaaaaawwhpzd5kxd7dcd56kiuuxeaa46icb44cnu7osq3mbclo2pnv3dpq"
      "defined_tags" = tomap({
        "CCA_Basic_Tag.email" = "oracleidentitycloudservice/cosmin.tudor@oracle.com"
      })
      "display_name" = "sl-db"
      "egress_security_rules" = toset([
        {
          "description" = "egress to 0.0.0.0/0 over TCP"
          "destination" = "0.0.0.0/0"
          "destination_type" = "CIDR_BLOCK"
          "icmp_options" = tolist([])
          "protocol" = "6"
          "stateless" = false
          "tcp_options" = tolist([])
          "udp_options" = tolist([])
        },
      ])
      "freeform_tags" = tomap({
        "vision-environment" = "vision"
        "vision-sub-environment" = "prod"
      })
      "id" = "ocid1.securitylist.oc1.eu-frankfurt-1.aaaaaaaasghz5wfectlw7gd5sjwhl2r6dwwfaasg5adtxhzzft2xarrmwriq"
      "ingress_security_rules" = toset([
        {
          "description" = "ingress from 10.0.2.0/24 over TCP22"
          "icmp_options" = tolist([])
          "protocol" = "6"
          "source" = "10.0.2.0/24"
          "source_type" = "CIDR_BLOCK"
          "stateless" = false
          "tcp_options" = tolist([])
          "udp_options" = tolist([])
        },
        {
          "description" = "ingress from 10.0.2.0/24 over TCP:1521"
          "icmp_options" = tolist([])
          "protocol" = "6"
          "source" = "10.0.2.0/24"
          "source_type" = "CIDR_BLOCK"
          "stateless" = false
          "tcp_options" = tolist([
            {
              "max" = 1521
              "min" = 1521
              "source_port_range" = tolist([])
            },
          ])
          "udp_options" = tolist([])
        },
      ])
      "network_configuration_category" = "production"
      "sec_list_key" = "SECLIST-DB-KEY"
      "state" = "AVAILABLE"
      "time_created" = "2023-05-26 12:39:49.215 +0000 UTC"
      "timeouts" = null /* object */
      "vcn_id" = "ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaattkvkkiaostwdsz7tbjnklmsm2htaqesvd7ut5udmh2ivltztjka"
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
    }
    "SECLIST-LB-KEY" = {
      "compartment_id" = "ocid1.compartment.oc1..aaaaaaaawwhpzd5kxd7dcd56kiuuxeaa46icb44cnu7osq3mbclo2pnv3dpq"
      "defined_tags" = tomap({
        "CCA_Basic_Tag.email" = "oracleidentitycloudservice/cosmin.tudor@oracle.com"
      })
      "display_name" = "sl-lb"
      "egress_security_rules" = toset([
        {
          "description" = "egress to 0.0.0.0/0 over ALL protocols"
          "destination" = "0.0.0.0/0"
          "destination_type" = "CIDR_BLOCK"
          "icmp_options" = tolist([])
          "protocol" = "all"
          "stateless" = false
          "tcp_options" = tolist([])
          "udp_options" = tolist([])
        },
      ])
      "freeform_tags" = tomap({
        "vision-environment" = "vision"
        "vision-sub-environment" = "prod"
      })
      "id" = "ocid1.securitylist.oc1.eu-frankfurt-1.aaaaaaaaovcsadzlg4ri2w25ehfhwk7a6zr7ho2ngldxzg6mcxxccpqwlmlq"
      "ingress_security_rules" = toset([
        {
          "description" = "ingress from 0.0.0.0/0 over TCP22"
          "icmp_options" = tolist([])
          "protocol" = "6"
          "source" = "0.0.0.0/0"
          "source_type" = "CIDR_BLOCK"
          "stateless" = false
          "tcp_options" = tolist([
            {
              "max" = 22
              "min" = 22
              "source_port_range" = tolist([])
            },
          ])
          "udp_options" = tolist([])
        },
        {
          "description" = "ingress from 0.0.0.0/0 over TCP443"
          "icmp_options" = tolist([])
          "protocol" = "6"
          "source" = "0.0.0.0/0"
          "source_type" = "CIDR_BLOCK"
          "stateless" = false
          "tcp_options" = tolist([
            {
              "max" = 443
              "min" = 443
              "source_port_range" = tolist([])
            },
          ])
          "udp_options" = tolist([])
        },
        {
          "description" = "ingress from 0.0.0.0/0 over TCP80"
          "icmp_options" = tolist([])
          "protocol" = "6"
          "source" = "0.0.0.0/0"
          "source_type" = "CIDR_BLOCK"
          "stateless" = false
          "tcp_options" = tolist([
            {
              "max" = 80
              "min" = 80
              "source_port_range" = tolist([])
            },
          ])
          "udp_options" = tolist([])
        },
      ])
      "network_configuration_category" = "production"
      "sec_list_key" = "SECLIST-LB-KEY"
      "state" = "AVAILABLE"
      "time_created" = "2023-05-26 12:39:49.183 +0000 UTC"
      "timeouts" = null /* object */
      "vcn_id" = "ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaattkvkkiaostwdsz7tbjnklmsm2htaqesvd7ut5udmh2ivltztjka"
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
    }
  }
  "service_gateways" = {
    "SGW-KEY" = {
      "block_traffic" = false
      "compartment_id" = "ocid1.compartment.oc1..aaaaaaaawwhpzd5kxd7dcd56kiuuxeaa46icb44cnu7osq3mbclo2pnv3dpq"
      "defined_tags" = tomap({
        "CCA_Basic_Tag.email" = "oracleidentitycloudservice/cosmin.tudor@oracle.com"
      })
      "display_name" = "sgw-prod-vcn"
      "freeform_tags" = tomap({
        "vision-environment" = "vision"
        "vision-sub-environment" = "prod"
      })
      "id" = "ocid1.servicegateway.oc1.eu-frankfurt-1.aaaaaaaat2uig4tz4af6vwtarrumdasmscrfmosbxddvh5rz4kgvahj2zwdq"
      "network_configuration_category" = "production"
      "route_table_id" = tostring(null)
      "route_table_key" = tostring(null)
      "route_table_name" = null
      "services" = toset([
        {
          "service_id" = "ocid1.service.oc1.eu-frankfurt-1.aaaaaaaalblrg4eycfxwohulzwwq63btwptzs2hva3muxfan5ro5x7glehtq"
          "service_name" = "OCI FRA Object Storage"
        },
      ])
      "sgw-key" = "SGW-KEY"
      "state" = "AVAILABLE"
      "time_created" = "2023-05-26 12:39:49.967 +0000 UTC"
      "timeouts" = null /* object */
      "vcn_id" = "ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaattkvkkiaostwdsz7tbjnklmsm2htaqesvd7ut5udmh2ivltztjka"
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
    }
  }
  "subnets" = {
    "PRIVATE-APP-SUBNET-KEY" = {
      "availability_domain" = tostring(null)
      "cidr_block" = "10.0.2.0/24"
      "compartment_id" = "ocid1.compartment.oc1..aaaaaaaawwhpzd5kxd7dcd56kiuuxeaa46icb44cnu7osq3mbclo2pnv3dpq"
      "defined_tags" = tomap({
        "CCA_Basic_Tag.email" = "oracleidentitycloudservice/cosmin.tudor@oracle.com"
      })
      "dhcp_options_id" = "ocid1.dhcpoptions.oc1.eu-frankfurt-1.aaaaaaaa7qfivwr32rnr4zf26jynheriwjgcjzonaxhitsmn32pxupzghj3q"
      "dhcp_options_key" = "default_dhcp_options"
      "dhcp_options_name" = "default_dhcp_options"
      "display_name" = "sub-private-app"
      "dns_label" = "privateapp"
      "freeform_tags" = tomap({
        "vision-environment" = "vision"
        "vision-sub-environment" = "prod"
      })
      "id" = "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaa3ylvsxn7vsblnuz57z2l4ii2yirighelq3feyhv5kplqo7yderma"
      "ipv6cidr_block" = tostring(null)
      "ipv6cidr_blocks" = tolist([])
      "ipv6virtual_router_ip" = tostring(null)
      "network_configuration_category" = "production"
      "prohibit_internet_ingress" = true
      "prohibit_public_ip_on_vnic" = true
      "route_table_id" = "ocid1.routetable.oc1.eu-frankfurt-1.aaaaaaaaqa6uminiilymosaqfksb55xgzwa7gqzryck7lxvennfcfi77qola"
      "route_table_key" = "RT-02-KEY"
      "route_table_name" = "rt-02-prod-vcn-01"
      "security_lists" = {
        "ocid1.securitylist.oc1.eu-frankfurt-1.aaaaaaaajymzjghs6l774eueukderiqagchwjigzouzehf6ren5b6pfasrfq" = {
          "display_name" = "sl-app"
          "sec_list_key" = "SECLIST-APP-KEY"
        }
      }
      "state" = "AVAILABLE"
      "subnet_domain_name" = "privateapp.vcnsimple.oraclevcn.com"
      "subnet_key" = "PRIVATE-APP-SUBNET-KEY"
      "time_created" = "2023-05-26 12:39:49.844 +0000 UTC"
      "timeouts" = null /* object */
      "vcn_id" = "ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaattkvkkiaostwdsz7tbjnklmsm2htaqesvd7ut5udmh2ivltztjka"
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
      "virtual_router_ip" = "10.0.2.1"
      "virtual_router_mac" = "00:00:17:A0:12:72"
    }
    "PRIVATE-DB-SUBNET-KEY" = {
      "availability_domain" = tostring(null)
      "cidr_block" = "10.0.1.0/24"
      "compartment_id" = "ocid1.compartment.oc1..aaaaaaaawwhpzd5kxd7dcd56kiuuxeaa46icb44cnu7osq3mbclo2pnv3dpq"
      "defined_tags" = tomap({
        "CCA_Basic_Tag.email" = "oracleidentitycloudservice/cosmin.tudor@oracle.com"
      })
      "dhcp_options_id" = "ocid1.dhcpoptions.oc1.eu-frankfurt-1.aaaaaaaa7qfivwr32rnr4zf26jynheriwjgcjzonaxhitsmn32pxupzghj3q"
      "dhcp_options_key" = "default_dhcp_options"
      "dhcp_options_name" = "default_dhcp_options"
      "display_name" = "sub-private-db"
      "dns_label" = "privatedb"
      "freeform_tags" = tomap({
        "vision-environment" = "vision"
        "vision-sub-environment" = "prod"
      })
      "id" = "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaaxo2bcpvreiytwd3an2zimkzxi4qmn2iocucjvcnfne4nzvgru7cq"
      "ipv6cidr_block" = tostring(null)
      "ipv6cidr_blocks" = tolist([])
      "ipv6virtual_router_ip" = tostring(null)
      "network_configuration_category" = "production"
      "prohibit_internet_ingress" = true
      "prohibit_public_ip_on_vnic" = true
      "route_table_id" = "ocid1.routetable.oc1.eu-frankfurt-1.aaaaaaaaqa6uminiilymosaqfksb55xgzwa7gqzryck7lxvennfcfi77qola"
      "route_table_key" = "RT-02-KEY"
      "route_table_name" = "rt-02-prod-vcn-01"
      "security_lists" = {
        "ocid1.securitylist.oc1.eu-frankfurt-1.aaaaaaaasghz5wfectlw7gd5sjwhl2r6dwwfaasg5adtxhzzft2xarrmwriq" = {
          "display_name" = "sl-db"
          "sec_list_key" = "SECLIST-DB-KEY"
        }
      }
      "state" = "AVAILABLE"
      "subnet_domain_name" = "privatedb.vcnsimple.oraclevcn.com"
      "subnet_key" = "PRIVATE-DB-SUBNET-KEY"
      "time_created" = "2023-05-26 12:39:50.876 +0000 UTC"
      "timeouts" = null /* object */
      "vcn_id" = "ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaattkvkkiaostwdsz7tbjnklmsm2htaqesvd7ut5udmh2ivltztjka"
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
      "virtual_router_ip" = "10.0.1.1"
      "virtual_router_mac" = "00:00:17:A0:12:72"
    }
    "PUBLIC-LB-SUBNET-KEY" = {
      "availability_domain" = tostring(null)
      "cidr_block" = "10.0.3.0/24"
      "compartment_id" = "ocid1.compartment.oc1..aaaaaaaawwhpzd5kxd7dcd56kiuuxeaa46icb44cnu7osq3mbclo2pnv3dpq"
      "defined_tags" = tomap({
        "CCA_Basic_Tag.email" = "oracleidentitycloudservice/cosmin.tudor@oracle.com"
      })
      "dhcp_options_id" = "ocid1.dhcpoptions.oc1.eu-frankfurt-1.aaaaaaaa7qfivwr32rnr4zf26jynheriwjgcjzonaxhitsmn32pxupzghj3q"
      "dhcp_options_key" = "default_dhcp_options"
      "dhcp_options_name" = "default_dhcp_options"
      "display_name" = "sub-public-lb"
      "dns_label" = "publiclb"
      "freeform_tags" = tomap({
        "vision-environment" = "vision"
        "vision-sub-environment" = "prod"
      })
      "id" = "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaalreuoqee3m6binowztulilhdrirn5y4jnguuqon4zswhv7fxx4wq"
      "ipv6cidr_block" = tostring(null)
      "ipv6cidr_blocks" = tolist([])
      "ipv6virtual_router_ip" = tostring(null)
      "network_configuration_category" = "production"
      "prohibit_internet_ingress" = false
      "prohibit_public_ip_on_vnic" = false
      "route_table_id" = "ocid1.routetable.oc1.eu-frankfurt-1.aaaaaaaan3m4ysaan6kd3ywcxuu6zlnghybo3dfpbu375qyftndob4m7lgra"
      "route_table_key" = "RT-01-KEY"
      "route_table_name" = "rt-01"
      "security_lists" = {
        "ocid1.securitylist.oc1.eu-frankfurt-1.aaaaaaaaovcsadzlg4ri2w25ehfhwk7a6zr7ho2ngldxzg6mcxxccpqwlmlq" = {
          "display_name" = "sl-lb"
          "sec_list_key" = "SECLIST-LB-KEY"
        }
      }
      "state" = "AVAILABLE"
      "subnet_domain_name" = "publiclb.vcnsimple.oraclevcn.com"
      "subnet_key" = "PUBLIC-LB-SUBNET-KEY"
      "time_created" = "2023-05-26 12:39:50.433 +0000 UTC"
      "timeouts" = null /* object */
      "vcn_id" = "ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaattkvkkiaostwdsz7tbjnklmsm2htaqesvd7ut5udmh2ivltztjka"
      "vcn_key" = "SIMPLE-VCN-KEY"
      "vcn_name" = "vcn-simple"
      "virtual_router_ip" = "10.0.3.1"
      "virtual_router_mac" = "00:00:17:A0:12:72"
    }
  }
  "vcns" = {
    "SIMPLE-VCN-KEY" = {
      "byoipv6cidr_blocks" = tolist([])
      "byoipv6cidr_details" = tolist(null) /* of object */
      "cidr_block" = "10.0.0.0/18"
      "cidr_blocks" = tolist([
        "10.0.0.0/18",
      ])
      "compartment_id" = "ocid1.compartment.oc1..aaaaaaaawwhpzd5kxd7dcd56kiuuxeaa46icb44cnu7osq3mbclo2pnv3dpq"
      "default_dhcp_options_id" = "ocid1.dhcpoptions.oc1.eu-frankfurt-1.aaaaaaaa7qfivwr32rnr4zf26jynheriwjgcjzonaxhitsmn32pxupzghj3q"
      "default_route_table_id" = "ocid1.routetable.oc1.eu-frankfurt-1.aaaaaaaakroqpfui7kgnohajzwszdxzjl6amwdshpwzutzqk6eoprn226xga"
      "default_security_list_id" = "ocid1.securitylist.oc1.eu-frankfurt-1.aaaaaaaagm6al62k5xmkebezrhwraxsd4hwed5vyc2fhiv2rmmnbskyeneja"
      "defined_tags" = tomap({
        "CCA_Basic_Tag.email" = "oracleidentitycloudservice/cosmin.tudor@oracle.com"
      })
      "display_name" = "vcn-simple"
      "dns_label" = "vcnsimple"
      "freeform_tags" = tomap({
        "vision-environment" = "vision"
        "vision-sub-environment" = "prod"
      })
      "id" = "ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaattkvkkiaostwdsz7tbjnklmsm2htaqesvd7ut5udmh2ivltztjka"
      "ipv6cidr_blocks" = tolist([])
      "ipv6private_cidr_blocks" = tolist([])
      "is_ipv6enabled" = false
      "is_oracle_gua_allocation_enabled" = tobool(null)
      "network_configuration_category" = "production"
      "state" = "AVAILABLE"
      "time_created" = "2023-05-26 12:39:46.718 +0000 UTC"
      "timeouts" = null /* object */
      "vcn_domain_name" = "vcnsimple.oraclevcn.com"
      "vcn_key" = "SIMPLE-VCN-KEY"
    }
  }
}
```