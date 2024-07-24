<!-- BEGIN_TF_DOCS -->
# OCI DNS Provisioning Example

## Introduction

OCI Domain Name System (DNS) translates human-readable domain names to machine-readable IP addresses. A DNS **nameserver** stores DNS **records** for a **zone** and responds with queries against its database.

OCI DNS service offers the following configurations and features:
* Public DNS: Create zones with publicly available domain names that are reachable on the internet. Had to register wiith a DNS registrar (delegation)
* Private DNS: Provides **hostname** resolution for applications running within and between Virtual Cloud Networks (VCN)
* Secondary DNS: Provides DNS redundancy for primary DNS servers
* Reverse DNS (RDNS): Maps an IP address with a hostname

DNS Service components
* **domain**  
Identify a specific location or a group of locations on the internet as a whole. A common definition of domain is the complet part of the DNS tree that has been delegated to a user's control. 
* **zone**  
A zone is a part of the DNS namespace. A Start of Authority (SOA) record defines a zone. A zone contains all labels underneath itself in a tree (usually)
* **label**  
Labels are prepended to the zone name, sparated by a period, to form the name of a subdomain. www section of www.example.com is labels.   
* **child zone**  
Child zones are independent subdomains with their own Start of Authority and Name Server (NS) records. The parent zone must contains NS records that refer DNS queries to the name servers responsible for the child zone. Each child zone creates another link in the delegation chain.  
* **resource records**   
A record contans specifc domain information for a zone. Eachd record type contains information called record data (RDATA). RDATA of an A or AAAA record contains and IP address for a domain name, while a Mail exchange (MX) records contain information about the mail server for a domain. 
* **delegation**  
The name servers where DNS is hosted and managed.


## Management of DNS Services

* **Public DNS zones** hold trusted DNS records that reside on Oracle Cloud Infrastructure nameservers. Public zonses are created with publicly available domain names. **Private DNS zones** contain domain names that resolve DNS queries for private addresses within a VCN. DNS private zones are used to define a domain name for private address resolution.     
* **Traffic Managment Steering Policies** help guiding traffic to endpoints based on various conditions (like endpoint health or geographic origins of DNS requests).  
* **Service Health**  display the availability status of all DNS zone management systems.
* **Documentation** Documentation for the DNS service  

## Supporting Services 
* **Private Views** Logically group a set of private DNS zones
* **HTTP Redirects** Redirect trafic to another URL
* **TSIG Keys** Ensure that DNS packets originate from authorized sender


## Provided Example

The provided example allows the creation of public and private DNS resources together with other OCI networking resources at the initialization of the services. Additional **dns_resolver** attribute was added to the network configurations variables (both for the newly created and existing VCNs). 

The structure of the attribute is the following: 

```
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
```

This allows the creation in the DNS resolvers associtated with VCNs of the following resources: 

* DNS Private Views
* DNS Zones that can be private or global (public DNS). For the latter, set the attribute **scope** to **GLOBAL**
* DNS RRSets - which allows the creation of DNS Records in a zone. 
* DNS Records - **Deprecated**, replaced by DNS RRSets
* DNS Steering Policies
* DNS Endpoints and Rules
* DNS TSIG Keys 


Following is a representations of the DNS resources that are going to be created by this example.
 
```
...
 dns_resolver                                   = {
          + "SIMPLE-VCN-KEY" = {
              + attached_views = {
                  + "DNS_VIEW_1" = {
                      + compartment_id = null
                      + defined_tags   = null
                      + display_name   = "test1_view"
                      + dns_zones      = {
                          + "DNS_ZONE_1" = {
                              + compartment_id        = null
                              + defined_tags          = null
                              + dns_records           = null
                              + dns_rrset             = {
                                  + "RRSET_A" = {
                                      + compartment_id = null
                                      + domain         = "name1.testzone1.com"
                                      + items          = [
                                          + {
                                              + domain = "name1.testzone1.com"
                                              + rdata  = "10.0.2.10"
                                              + rtype  = "A"
                                              + ttl    = "3600"
                                            },
                                        ]
                                      + rtype          = "A"
                                      + scope          = "PRIVATE"
                                    }
                                }
                              + dns_steering_policies = null
                              + external_downstreams  = null
                              + external_masters      = null
                              + freeform_tags         = null
                              + name                  = "testzone1.com"
                              + scope                 = "PRIVATE"
                              + zone_type             = "PRIMARY"
                            }
                          + "DNS_ZONE_2" = {
                              + compartment_id        = null
                              + defined_tags          = null
                              + dns_records           = null
                              + dns_rrset             = null
                              + dns_steering_policies = null
                              + external_downstreams  = null
                              + external_masters      = null
                              + freeform_tags         = null
                              + name                  = "testzone2.com"
                              + scope                 = "PRIVATE"
                              + zone_type             = "PRIMARY"
                            }
                          + "DNS_ZONE_3" = {
                              + compartment_id        = null
                              + defined_tags          = null
                              + dns_records           = null
                              + dns_rrset             = null
                              + dns_steering_policies = null
                              + external_downstreams  = null
                              + external_masters      = null
                              + freeform_tags         = null
                              + name                  = "testzone5.com"
                              + scope                 = "GLOBAL"
                              + zone_type             = "PRIMARY"
                            }
                        }
                      + freeform_tags  = null
                    }
                }
              + defined_tags   = null
              + display_name   = "test1"
              + freeform_tags  = null
              + rules          = [
                  + {
                      + action                    = "FORWARD"
                      + client_address_conditions = null
                      + destination_address       = [
                          + "10.0.2.128",
                        ]
                      + qname_cover_conditions    = null
                      + source_endpoint_name      = "RESOLVER_ENDPOINT_TEST1"
                    },
                  + {
                      + action                    = "FORWARD"
                      + client_address_conditions = [
                          + "192.168.1.0/24",
                        ]
                      + destination_address       = [
                          + "10.0.2.128",
                        ]
                      + qname_cover_conditions    = null
                      + source_endpoint_name      = "RESOLVER_ENDPOINT_TEST1"
                    },
                ]
              + vcn_key        = "SIMPLE-VCN-KEY"
            }
        }
      + dns_rrsets                                     = {
          + "RRSET_A" = {
              + compartment_id = "ocid1.compartment.oc1.."
              + domain         = "name1.testzone1.com"
              + items          = [
                  + {
                      + domain = "name1.testzone1.com"
                      + rdata  = "10.0.2.10"
                      + rtype  = "A"
                      + ttl    = "3600"
                    },
                ]
              + rrset_key      = "RRSET_A"
              + rtype          = "A"
              + scope          = "PRIVATE"
              + view_key       = "DNS_VIEW_1"
              + zone_key       = "DNS_ZONE_1"
            }
        }
      + dns_steering_policies                          = {}
      + dns_tsig_keys                                  = {
          + "TSIG_KEY1" = {
              + algorithm      = "hmac-sha1"
              + compartment_id = "ocid1.compartment.oc1.."
              + defined_tags   = null
              + freeform_tags  = null
              + name           = "test1_tsig_key-name"
              + secret         = "welcome1"
              + tsig_key_key   = "TSIG_KEY1"
              + vcn_key        = "SIMPLE-VCN-KEY"
            }
        }
      + dns_views                                      = {
          + "DNS_VIEW_1" = {
              + compartment_id = "ocid1.compartment.oc1.."
              + defined_tags   = null
              + display_name   = "test1_view"
              + freeform_tags  = null
              + vcn_key        = "SIMPLE-VCN-KEY"
              + view_key       = "DNS_VIEW_1"
            }
        }
      + dns_zones                                      = {
          + "DNS_ZONE_1" = {
              + compartment_id       = "ocid1.compartment.oc1.."
              + defined_tags         = null
              + external_downstreams = []
              + external_masters     = []
              + freeform_tags        = null
              + name                 = "testzone1.com"
              + scope                = "PRIVATE"
              + view_key             = "DNS_VIEW_1"
              + zone_key             = "DNS_ZONE_1"
              + zone_type            = "PRIMARY"
            }
          + "DNS_ZONE_2" = {
              + compartment_id       = "ocid1.compartment.oc1.."
              + defined_tags         = null
              + external_downstreams = []
              + external_masters     = []
              + freeform_tags        = null
              + name                 = "testzone2.com"
              + scope                = "PRIVATE"
              + view_key             = "DNS_VIEW_1"
              + zone_key             = "DNS_ZONE_2"
              + zone_type            = "PRIMARY"
            }
          + "DNS_ZONE_3" = {
              + compartment_id       = "ocid1.compartment.oc1.."
              + defined_tags         = null
              + external_downstreams = []
              + external_masters     = []
              + freeform_tags        = null
              + name                 = "testzone5.com"
              + scope                = "GLOBAL"
              + view_key             = null
              + zone_key             = "DNS_ZONE_3"
              + zone_type            = "PRIMARY"
            }
        }

```