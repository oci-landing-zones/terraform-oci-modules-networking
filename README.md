# OCI Landing Zones Networking Module

![Landing Zone logo](./images/landing_zone_300.png)

Welcome to the [OCI Landing Zones (OLZ) Community](https://github.com/oci-landing-zones)! 

The **OCI Landing Zones Networking** module is a Terraform networking core module that facilitates, in an optional fashion, the provisioning of a CIS compliant network topology for the entire topology or for specific areas of the topology.

It aims to facilitate the provisioning of any OCI networking topology, covering the internal OCI networking, entirely, and the edge networking, partially.

Check [module specification](./SPEC.md) for a full description of module requirements, supported variables, managed resources and outputs.

- [CIS OCI Foundations Benchmark Modules Collection](#cis-collection)
- [Requirements](#requirements)
- [How to Invoke the Module](#invoke)
  - [With Resource Manager](#with-rms)
- [Module Functioning](#functioning)
  - [External Dependencies](#ext-dep)
  - [Available Examples](#howtoexample)
- [Related Documentation](#related)
- [Known Issues](#issues)

This module uses Terraform complex types and optional attributes, in order to create a new abstraction layer on top of Terraform. 
This abstraction layer allows the specification of any networking topology containing any number of networking resources like VCNs, subnets, DRGs and others and mapping those on any existing compartments topology.

It allows both creating a complex networking topology from scratch and also injecting resources into any existing networking topology by following the same abstraction layer format. 

The abstraction layer format can be HCL (```*.tfvars``` or ```*.auto.tfvars```) or JSON (```*.tfvars.json``` or ```*.auto.tfvars.json```).

This approach represents an excellent tool for templating. The templating will be made outside of the code, in the configurations files themselves. The ```*.tfvars.*``` can be used as sharable templates that define different and complex topologies.

The main advantage of this approach is that there will be one single code repository for any networking configuration. Creation of a new networking configuration will not have any impact on the Terraform code, it will just impact the configuration files (```*.tfvars.*``` files).

The separation of code and configuration supports DevOps key concepts for operations design, change management, pipelines.

## <a name="cis-collection">CIS OCI Foundations Benchmark Modules Collection

This repository is part of a broader collection of repositories containing modules that help customers align their OCI implementations with the CIS OCI Foundations Benchmark recommendations:
<br />

- [Identity & Access Management ](https://github.com/oci-landing-zones/terraform-oci-modules-iam)
- [Networking](https://github.com/oci-landing-zones/terraform-oci-modules-networking) - current repository
- [Governance](https://github.com/oci-landing-zones/terraform-oci-modules-governance)
- [Security](https://github.com/github.com/oci-landing-zones/terraform-oci-modules-security)
- [Observability & Monitoring](https://github.com/oci-landing-zones/terraform-oci-modules-observability)
- [Secure Workloads](https://github.com/oci-landing-zones/terraform-oci-modules-workloads)

The modules in this collection are designed for flexibility, are straightforward to use, and enforce CIS OCI Foundations Benchmark recommendations when possible.
<br />

Using these modules does not require a user extensive knowledge of Terraform or OCI resource types usage. Users declare a JSON object describing the OCI resources according to each module’s specification and minimal Terraform code to invoke the modules. The modules generate outputs that can be consumed by other modules as inputs, allowing for the creation of independently managed operational stacks to automate your entire OCI infrastructure.
<br />

## <a name="requirements">Requirements

### Terraform Version >= 1.3.0

This module requires Terraform binary version 1.3.0 or greater, as it relies on Optional Object Type Attributes feature. The feature shortens the amount of input values in complex of having Terraform automatically inserting a default value for any missing optional attributes.


### IAM Permissions

This module requires the following OCI IAM permissions:
```
Allow group <group-name> to manage virtual-network-family in compartment <compartment-name>

Allow group <group-name> to manage drgs in compartment <compartment-name>
```

## <a name="invoke">How to Invoke the Module

Terraform modules can be invoked locally or remotely. 

For invoking the module locally, just set the module *source* attribute to the module file path (relative path works). The following example assumes the module is two folders up in the file system.
```
module "terraform-oci-landing-zones-networking" {
  source = "../.."
  network_configuration = var.network_configuration
}
```

For invoking the module remotely, set the module *source* attribute to the networking module repository, as shown:
```
module "terraform-oci-landing-zone-networking" {
  source = "github.com/oci-landing-zones/terraform-oci-modules-networking"
  network_configuration = var.network_configuration
}
```
For referring to a specific module version, append *ref=\<version\>* to the *source* attribute value, as in:
```
  source = "github.com/oci-landing-zones/terraform-oci-modules-networking?ref=v0.1.0"
```

### <a name="with-orm">Using the Module with Resource Manager

For an ad-hoc use where you can select your resources, follow these guidelines:
1. [![Deploy_To_OCI](images/DeployToOCI.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/oci-landing-zones/terraform-oci-modules-networking/archive/refs/heads/main.zip)
2. Accept terms,  wait for the configuration to load. 
3. Set the working directory to “orm-facade”. 
4. Set the stack name you prefer.
5. Add your JSON/YAML configuration files. Click Next.
6. Un-check run apply. Click Create.

## <a name="functioning">Module Functioning

The input parameters for the module can be divided into two categories, for which we recommend to create two different ```*.tfvars.*``` files:
 1. OCI REST API authentication information (secrets) - ```terraform.tfvars``` (HCL) or ```terraform.tfvars.json``` (JSON):
    - ```tenancy_ocid```
    - ```user_ocid```
    - ```fingerprint```
    - ```private_key_path```
    - ```region```
 2. Network configuration single complex type: ```network_configuration.auto.tfvars``` (HCL) or ```network_configuration.auto.tfvars.json``` (JSON):
    - ```network_configuration``` 

The ```network_configuration``` complex type can accept any new networking topology together or separated with injecting resources into existing networking topologies, and all those can map on any compartments topology.

The ```network_configuration``` complex type fully supports optional attributes as long as they do not break any dependency imposed by OCI.

The ```network_configuration``` is a multidimensional complex object:
- ```default_compartment_id``` holds the compartment id that will be used if no compartment id has been set at the specific resource or category (see ```network_configuration_categories``` for details) level. 
- ```default_defined_tags``` and ```default_freeform_tags```  hold the defined_tags and freeform_tags to be used if no specific defined_tags and freeform_tags have been set at the resource or category* level. Those will be merged with the values provided at their higher levels, including the highest level: ```default_defined_tags``` and ```default_freeform_tags```.
- ```default_enable_cis_checks``` when set to ```true``` the module will validate the entire configuration for CIS compliancy by checking the network security and NSG rules for specific configurations. It can can be overwritten at the category* level. It will default to ```true``` if not set or set to ```null```. Setting this to ```false``` will disable the CIS checks.
- ```default_ssh_ports_to_check``` defines the ports the CIS validation mechanism will check for. If not set or set to ```null``` it will default to ```[22, 3389]```.
- ```network_configuration_categories``` represents a construct that will not be directly reflected into OCI but it will have indirect configurations consequences and it will facilitate the grouping of networking resources based on compartments allocation and CIS enablement. This attribte allows any number of catogeries. For each category these attributes can be specified:
    - ```category_compartment_id``` will override the ```default_compartment_id```.
    - ```category_defined_tags``` and ```category_freeform_tags``` will be merged with ```default_defined_tags``` and, respectively, with ```default_freeform_tags```.
    - ```category_enable_cis_checks``` will override the ```default_enable_cis_checks```.
    - ```category_ssh_ports_to_check``` will override the ```default_ssh_ports_to_check```.
    - ```vcns``` defines any number of VCNs to be created for this category.will enable one to specify any number of vcns he wants to create under one category. Each ```vcn``` can have any number of:
      - ```security_lists```,
      - ```route_tables```, 
        - For route rules we support the following:
          - ```destination``` supported values: 
              - ```a cidr block```
              - ```objectstorage``` or ```all-services``` - only for ```SERVICE_CIDR_BLOCK```
          - ```destination_type``` supported values:
              - ```CIDR_BLOCK```
              - ```SERVICE_CIDR_BLOCK``` - only for SGW
      - ```dhcp_options```, 
      - ```subnets```, 
      - ```network_security_groups```,
      - ```security```
          - ```zpr_attributes``` - Zero-Packet-Routing attributes
              - ```namespace``` - The security attribute namespace
              - ```attr_name``` - Name of the security attribute key
              - ```attr_value```- Security attribute value
              - ```mode``` - Mode of security attribute
            ```
            security = {
                zpr_attributes = [
                  {namespace = "lz-zpr", attr_name = "network", attr_value = "prod"}
                ]
            }
            ```

      - ```vcn_specific_gateways``` like: 
        - ```internet_gateways```,
        - ```nat_gateways```,
        - ```service_gateways``` 
          - SGW services value:
            - ```objectstorage``` - for object storage access
            - ```all-services``` - for all OCI internal network services access
        - ```local_peering_gateways```. 
      - All the resources of a ```vcn``` (including the VCN) are created from scratch. To refer to a resource a key is used to refer to the related resource. Here is an example for specifying a security list, attached to a subnet:
  
        ```
              ...
              security_lists = {
                SECLIST_LB_KEY = {
                  display_name = "sl-lb"
                  ...
                  }
                }

              ...
              subnets = {
                PUBLIC_LB_SUBNET_KEY = {
                  ...
                  security_list_keys = ["SECLIST_LB_KEY"]
                }
              ...
              }
        ```

        __NOTE:__ *It is strongly recommended* not *to change a resource key after the first provisioning. Once a key has been defined and applied the configuration, changing the key will result in  resource re-creation. As the key does not play any role in the configuration that will be pushed to OCI, it will have no impact on the deployment. To distinguish keys from resource names it is recommended to use this convention (using capital characters): ```{RESOURCE_NAME}-KEY```.*

        There will be one exception to the rule above. For the ```local_peering``` it possible to peer to an existing Local Peering Gateway (LPG) created outside this automation. In this case the ```peer_id``` attribute must be set to the OCID of the acceptor LPG. If no OCID is specified, the acceptor LPG created during the automation must be referred by a key specified in ```peer_key```. The value of ```peer_id``` will be checked first, if null the value of ```peer_key``` will be used. If both values are null, the LPG created will be an acceptor LPG.
    - ```inject_into_existing_vcns``` this attribute is used similarly to the ```vcns``` attribute. It will not create any new resources but will inject them in existing VCNs.
        - ```vcn_id``` represents the OCID of a VCN to inject new resources to.
          - Any number these attributes can be specified:
            - ```security_lists```, 
            - ```route_tables```, 
              - For route rules we support the following:
                - ```destination``` supported values: 
                    - ```a cidr block```
                    - ```objectstorage``` or ```all-services``` - only for ```SERVICE_CIDR_BLOCK```
                - ```destination_type``` supported values:
                    - ```CIDR_BLOCK```
                    - ```SERVICE_CIDR_BLOCK``` - only for SGW
            - ```dhcp_options```, 
            - ```subnets```, 
            - ```network_security_groups``` and
            - ```vcn_specific_gateways``` like:
              - ```internet_gateways```, 
              - ```nat_gateways```, 
              - ```service_gateways```
                - SGW services value:
                  - ```objectstorage``` - for object storage access
                  - ```all-services``` - for all OCI internal network services access
              - ```local_peering_gateways```. 
        - To refer a resource within a resource, the following options are available:
            1. To use the referend object key when the refered object was created as part of the same automation.
            2. To use the refered object OCID when the refered object already existed as it was created outside this automation.
   
          See the comments above for ```local_peering_gateways``` and extrapolate to other similar models like adding security lists and route tables to subnets, specifying gateways as next hops in route rules, etc.
    - ```non_vcn_specific_gateways``` allows the configuration of any number of dynamic routing gateways (DRGs), Network Firewalls (NFWs) and inject resources into any number of existing DRGs.
      - The ```dynamic_routing_gateways``` attribute can have any number of DRGs to be created. Each entry can have any number of
        - ```remote_peering_connections```,
        - ```drg_attachments```, 
        - ```drg_route_tables``` and
        - ```drg_route_distributions```.
      - The ```inject_into_existing_drgs``` attribute can inject resources in any number of existing drgs. Any number of the following attributes are supported:
        - ```remote_peering_connections```,
        - ```drg_attachments```,
        - ```drg_route_tables```
        - ```drg_route_distributions```.
      - ```ipsecs``` attribute can define any number(0, 1 or multiple) of ipsec connections, and inside the ipsec connection definition, the corresponding ```ipsec_tunnel_management``` can be defined. Both ```ipsec``` and ```ipsec_tunnels_management``` are exposing all the attributes of their corresponding OCI REST API objects through the OCI Terraform provider resources. For reference, the following documentation can be used:
          - OCI IPSEC:
            - [REST API](https://docs.oracle.com/en-us/iaas/api/#/en/iaas/20160918/IPSecConnection/CreateIPSecConnection)
            - [Terraform Resources](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_ipsec)
          - OCI IPSEC Tunnel Management:
            - [REST API](https://docs.oracle.com/en-us/iaas/api/#/en/iaas/20160918/datatypes/UpdateIPSecConnectionTunnelDetails)
            - [Terraform Resources](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_ipsec_connection_tunnel_management)
      - ```fast_connect_virtual_circuits``` attribute can define any number(0, 1 or multiple) of OCI fast connect virtual circuits. This attribute exposes all the attributes of the corresponding OCI REST API object through the OCI Terraform provider resource. For reference, the following documentation can be used:
            - [REST API](https://docs.oracle.com/en-us/iaas/api/#/en/iaas/20160918/datatypes/CreateVirtualCircuitDetails)
            - [Terraform Resources](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_virtual_circuit)

        Please note the following 2 bool attributes of a fast connect virtual circuit: ```provision_fc_virtual_circuit``` and       ```show_available_fc_virtual_circuit_providers```:
        - ```provision_fc_virtual_circuit```:
            - set it to ```false``` when you want just to define a draft fast connect configuration without applying and provisione it.
            - set it to ```true``` when you want to apply and provision the defined fast connect configuration.
        - ```show_available_fc_virtual_circuit_providers```:
            - set it to ```true``` when you want to see the available fast connect providers for the current configuration;
            - set it to ```false``` when you do not want to see the available fast connect providers for the current configuration;

        The recommendation will be to use the above 2 attributes, in conjunction, in the following 2 use cases:
          1. When you do not know the available fast connect partners for a certain draft configuration, define the configuration, set the ```provision_fc_virtual_circuit = false``` and ```show_available_fc_virtual_circuit_providers = true``` and run ```terraform apply```. This will generate in the terraform ouput, for each and every draft fast connect virtual circuit that you've defined, all the available fast connect providers and their details. Pick the provider of your choice and note down either the provider ocid or the provider key.
          2. Once you have the provider ocid and/or the provider key update the corresponding fast connect virtual cirtcuit with those and set the ```provision_fc_virtual_circuit = true``` and ```show_available_fc_virtual_circuit_providers = false```. This will provision the configured virtual circuit and will not show anymore all the available providers for that draft fast connect virtual circuit configuration.
      - ```cross_connect_groups``` attribute can define any number(0, 1 or multiple) of cross connect groups, and inside a cross connect group definition, any number(0, 1 or multiple) of ```cross_connects``` can be defined. Both ```cross_connect_groups``` and ```cross_connects``` expose all the attributes of their corresponding OCI REST API objects through the OCI Terraform provider resources. For reference, the following documentation can be used:
          - OCI Cross Connect Group:
            - [REST API](https://docs.oracle.com/en-us/iaas/api/#/en/iaas/20160918/CrossConnectGroup/)
            - [Terraform Resources](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_cross_connect_group)
          - OCI Cross Connect:
            - [REST API](https://docs.oracle.com/en-us/iaas/api/#/en/iaas/20160918/CrossConnect/)
            - [Terraform Resources](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_cross_connect)
      - The ```network_firewalls_configuration``` attribute can be used to inject any number of ```network_firewalls``` and/or ```network_firewall_policies```. Existing policies or newly created policies can be specified.
      When updating an attached network firewall policy, a copy of the attached policy will be created, updated with the new values. When done the copy will replace the existing policy.
      - ```l7_load_balancers``` is a multidimensional attribute that:
        - ```compartment_id``` holds the compartment id that will be used 
        - ```display_name``` load balancer displayed name
        - ```shape``` LBaaS shape
        - ```subnet_ids``` and ```subnet_keys``` the ocids of the subnets that will be used by the LBaaS. If the ```subnet_ids``` are empty than the automation will try to search the subnets by the provided ```subnet_keys```.
        - ```defined_tags``` LBaaS defined tags
        - ```freeform_tags``` LBaaS freeform tags
        - All the OCI LBaaS resource attributes are supported by this configuration: ```ip_mode```, ```is_private```, ```network_security_group_ids/network_security_group_keys```, ```reserved_ips_ids/reserved_ips_keys``` and ```shape_details```. Please refer to the OCI LBaaS documentation that is covering all the upper mentioned resource attributes.
        - ```backend_sets``` represents an optional attribute that allows the definition of zero, one or multiple backend sets that will be associated with the current load balancer. All the OCI ```backend_set attributes``` are covered: ```health_checker```, ```name```, ```policy```, ```lb_cookie_session_persistence_configuration```, ```session_persistence_configuration```, ```ssl_configuration``` and ```backends```. Please refer to the OCI LBaaS documentation that is covering all the upper mentioned resource attributes.
        - ```path_route_sets``` represents an optional attribute that allows the definition of zero, one or multiple path route sets that will be associated with the current load balancer. All the OCI ```path_route_sets``` attributes are covered: ```name```, ```path_routes```. Please refer to the OCI LBaaS documentation that is covering all the upper mentioned resource attributes.
        - ```host_names``` represents an optional attribute that allows the definition of zero, one or multiple host names that will be associated with the current load balancer. All the OCI ```host_names``` attributes are covered: ```hostname``` and ```name```. Please refer to the OCI LBaaS documentation that is covering all the upper mentioned resource attributes.
        - ```routing_policies``` represents an optional attribute that allows the definition of zero, one or multiple routing policies that will be associated with the current load balancer. All the OCI ```routing_policies``` attributes are covered: ```condition_language_version```, ```name```,  and ```condition```. Please refer to the OCI LBaaS documentation that is covering all the upper mentioned resource attributes.
        - ```rule_sets``` represents an optional attribute that allows the definition of zero, one or multiple rules sets that will be associated with the current load balancer. All the OCI ```rule_sets``` attributes are covered: ```name``` and ```items```. Please refer to the OCI LBaaS documentation that is covering all the upper mentioned resource attributes.
        - ```certificates``` represents an optional attribute that allows the definition of zero, one or multiple certificates that will be associated with the current load balancer. All the OCI ```certificates``` attributes are covered: ```certificate_name```, ```ca_certificate```, ```passphrase```, ```private_key``` and ```public_certificate```. Please refer to the OCI LBaaS documentation that is covering all the upper mentioned resource attributes.
        - ```listeners``` represents an optional attribute that allows the definition of zero, one or multiple listeners that will be associated with the current load balancer. All the OCI ```listeners``` attributes are covered: ```default_backend_set_key```, ```name```, ```port```, ```protocol```, ```connection_configuration```, ```hostname_keys```, ```path_route_set_key```, ```routing_policy_key```, ```rule_set_keys``` and ```ssl_configuration```. Please refer to the OCI LBaaS documentation that is covering all the upper mentioned resource attributes.

### <a name="ext-dep">External Dependencies</a>
An optional feature, external dependencies are resources managed elsewhere that resources managed by this module depends on. The following dependencies are supported:

#### compartments_dependency (Optional)
A map of objects containing the externally managed compartments this module may depend on. All map objects must have the same type and must contain at least an *id* attribute with the compartment OCID. This mechanism allows for the usage of referring keys (instead of OCIDs) in *default_compartment_id* and *compartment_id* attributes. The module replaces the keys by the OCIDs provided within *compartments_dependency* map. Contents of *compartments_dependency* is typically the output of a [Compartments module](https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam/tree/main/compartments) client.

Example:
```
{
  "NETWORK-CMP": {
    id": "ocid1.compartment.oc1..aaaaaaaa...7xq"
  }
}
```

Attributes that support a compartment referring key:
  - *default_compartment_id*
  - *compartment_id*

#### network_dependency (Optional)
A map of map of objects containing the externally managed network resources this module may depend on. This mechanism allows for the usage of referring keys (instead of OCIDs) in some attributes. The module replaces the keys by the OCIDs provided within *network_dependency* map. Contents of *network_dependency* is typically the output of a client of this module. Within *network_dependency*, VCNs must be indexed with the **vcns** key, DRGs indexed with the **dynamic_routing_gateways** key, DRG attachments indexed with **drg_attachments** key, Local Peering Gateways (LPG) indexed with **local_peering_gateways**, Remote Peering Connections (RPC) indexed with **remote_peering_connections** key, DNS Private Views indexed by **dns_private_views**. Each VCN, DRG, DRG attachment, LPG, RPC and DNS Private View must contain the *id* attribute (to which the actual OCID is assigned). RPCs must also pass the peer region name in the *region_name* attribute.

*network_dependency* example:
```
{
  "vcns" : {
    "XYZ-VCN" : {
      "id" : "ocid1.vcn.oc1.iad.aaaaaaaax...e7a"
    }
  },
  "dynamic_routing_gateways" : {  
    "XYZ-DRG" : {
      "id" : "ocid1.drg.oc1.iad.aaaaaaaa...xlq"
    }
  },
  "drg_attachments" : {  
    "XYZ-DRG-ATTACH" : {
      "id" : "ocid1.drgattachment.oc1.iad.aaaaaaa...xla"
    }
  },
  "local_peering_gateways" : {  
    "XYZ-LPG" : {
      "id" : "ocid1.localpeeringgateway.oc1.us-ashburn-1.aaaaaaaa...3oa"
    }
  },
  "remote_peering_connections" : {  
    "XYZ-RPC" : {
      "id" : "ocid1.remotepeeringconnection.oc1.us-ashburn-1.aaaaaaaa...4rt",
      "region_name" : "us-ashburn-1"
    }
  }  
  "dns_private_views" : {  
    "XYZ-DNS-VIEW" : {
      "id" : "ocid1.dnsview.oc1.phx.aaaaaaaa...nhq",
    }
  }
} 
```
**Note**: **vcns**, **dynamic_routing_gateways**, **drg_attachments**, **local_peering_gateways**, **remote_peering_connections** and **dns_private_views** attributes are all optional. They only become mandatory if the *network_configuration* refers to one of these resources through a referring key. Below are the attributes where a referring key is supported:

*network_dependency* attribute | Attribute names in *network_configuration* where the referring key can be utilized
--------------|-------------
**vcns** | *vcn_id* in *inject_into_existing_vcns*
**dynamic_routing_gateways** | *drg_id* in *inject_into_existing_drgs*, *network_entity_key* in *route_tables'* *route_rules*
**drg_attachments** | *drg_attachment_key*
**local_peering_gateways** | *peer_key* in *local_peering_gateways*
**remote_peering_connections** | *peer_key* in *remote_peering_connections*
**dns_private_views** | *existing_view_id* in *dns_resolver's* *attached_views*.

#### private_ips_dependency (Optional)
A map of map of objects containing the externally managed private IP resources this module may depend on. This mechanism allows for the usage of referring keys (instead of OCIDs) in some attributes. The module replaces the keys by the OCIDs provided within *private_ips_dependency* map. Each private IP must contain the **"id"** attribute (to which the actual OCID is assigned), as in the example below:

Example:
```
{
  "INDOOR-NLB": {
    "id": "ocid1.privateip.oc1.iad.abyhql...nrq"
  }
}
```

Attributes that support a private IP referring key:
  - *network_entity_key* in *route_tables'* *route_rules*


#### Wrapping Example
Note how the *network_configuration* snippet example below refers to keys in *compartments_dependency* (*NETWORK-CMP*) and *network_dependency* (*XYZ-VCN*):
```
network_configuration = {
  default_compartment_id = "NETWORK-CMP" # This key is defined in compartments_dependency
  network_configuration_categories = {
    production = {
      inject_into_existing_vcns = {
        VISION-VCN-INJECTED = {
          vcn_id = "XYZ-VCN" # This key is defined in network_dependency, under the vcns attribute.
          subnets = {
            SUPPLEMENT-SUBNET = {
              display_name = "supplement-subnet"
              cidr_block = "10.0.0.96/27"
            }
          }
        }  
      }
    }
  }
}
```
See [external-dependency example](./examples/external-dependency/) for a functional example.

### <a name="howtoexample">Available Examples</a>

- [Simple Three-Tier VCN - Vision](examples/vision/)
- [External Dependency](examples/external-dependency/) 
- [Simple Example](examples/simple-example/)
- [Provision a load balancer on top of an existing VCN](examples/simple-no_vcn-oci-native-l7-lbaas-example)
- [Provision a complete VCN and a load balancer](examples/standard-vcn-oci-native-l7-lbaas-example)
- [Edge Connectivity](examples/edge-connectivity/)
   - [Fast Connect Examples](examples/edge-connectivity/fast-connect-examples/)
      - [Generic OCI Fast Connect Partner](examples/edge-connectivity/fast-connect-examples/generic-oci-fastconnect-partner/)
   - [IPSec VPN Examples](examples/edge-connectivity/ipsec-examples/)
      - [Generic OCI IPSec BGP VPN](examples/edge-connectivity/ipsec-examples/generic-OCI-ipsec-bgp-vpn/)    
- [Local Peering Gateways](examples/local-peering-gateways/)     
- [Remote Peering Connections](examples/remote-peering-connections/)  

## <a name="related">Related Documentation
- [OCI Networking Overview](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/overview.htm)

## Help

Open an issue in this repository.

## Contributing

This project welcomes contributions from the community. Before submitting a pull request, please [review our contribution guide](./CONTRIBUTING.md).

## Security

Please consult the [security guide](./SECURITY.md) for our responsible security vulnerability disclosure process.

## License

Copyright (c) 2023,2024 Oracle and/or its affiliates.

*Replace this statement if your project is not licensed under the UPL*

Released under the Universal Permissive License v1.0 as shown at
<https://oss.oracle.com/licenses/upl/>.

## <a name="issues">Known Issues

- On some corner case situations, a ```cycle-graph``` exception might be raised when using route tables attached to GWs. This issue will be addressed in one of the next releases.
