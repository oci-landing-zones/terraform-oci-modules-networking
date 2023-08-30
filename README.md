<!-- BEGIN_TF_DOCS -->
# CIS OCI Landing Zone Networking Module

![Landing Zone logo](./images/landing_zone_300.png)


The ```terraform-oci-cis-landing-zone-networking``` module is a Terraform networking core module that facilitates, in an optional fashion, the provisioning of a CIS compliant network topology for the entire topology or for specific areas of the topology.

It aims to facilitate the provisioning of any OCI networking topology, covering the internal OCI networking, entirely, and the edge networking, partially.

Check [module specification](./SPEC.md) for a full description of module requirements, supported variables, managed resources and outputs.

In future releases, it will also cover associated networking services like DNS, Load Balancers, 3rd-party firewalls, etc.

This module uses Terraform complex types and optional attributes, in order to create a new abstraction layer on top of Terraform. 
This abstraction layer allows the specification of any networking topology containing any number of networking resources like VCNs, subnets, DRGs and others and mapping those on any existing compartments topology.

It allows both creating a complex networking topology from scratch and also injecting resources into any existing networking topology by following the same abstraction layer format. 

The abstraction layer format can be HCL (```*.tfvars``` or ```*.auto.tfvars```) or JSON (```*.tfvars.json``` or ```*.auto.tfvars.json```).

This approach represents an excellent tool for templating. The templating will be made outside of the code, in the configurations files themselves. The ```*.tfvars.*``` can be used as sharable templates that define different and complex topologies.

The main advantage of this approach is that there will be one single code repository for any networking configuration. Creation of a new networking configuration will not have any impact on the Terraform code, it will just impact the configuration files (```*.tfvars.*``` files).

The separation of code and configuration supports DevOps key concepts for operations design, change management, pipelines.

## CIS OCI Foundations Benchmark Modules Collection

This repository is part of a broader collection of repositories containing modules that help customers align their OCI implementations with the CIS OCI Foundations Benchmark recommendations:
<br />

- [Identity & Access Management ](https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam)
- [Networking](https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking) - current repository
- [Governance](https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-governance)
- Security (coming soon)
- [Observability & Monitoring](https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-observability)

The modules in this collection are designed for flexibility, are straightforward to use, and enforce CIS OCI Foundations Benchmark recommendations when possible.
<br />

Using these modules does not require a user extensive knowledge of Terraform or OCI resource types usage. Users declare a JSON object describing the OCI resources according to each module’s specification and minimal Terraform code to invoke the modules. The modules generate outputs that can be consumed by other modules as inputs, allowing for the creation of independently managed operational stacks to automate your entire OCI infrastructure.
<br />

## Requirements

### IAM Permissions

This module requires the following OCI IAM permissions:
```
Allow group <group-name> to manage virtual-network-family in compartment <compartment-name>

Allow group <group-name> to manage drgs in compartment <compartment-name>
```

### Terraform Version < 1.3.x and Optional Object Type Attributes

This module relies on [Terraform Optional Object Type Attributes feature](https://developer.hashicorp.com/terraform/language/expressions/type-constraints#optional-object-type-attributes), which is experimental from Terraform 0.14.x to 1.2.x. It shortens the amount of input values in complex object types, by having Terraform automatically inserting a default value for any missing optional attributes. The feature has been promoted and it is no longer experimental in Terraform 1.3.x.

Upon running *terraform plan* with Terraform versions prior to 1.3.x, Terraform displays the following warning:
```
Warning: Experimental feature "module_variable_optional_attrs" is active
```

Note the warning is harmless. The code has been tested with Terraform 1.3.x and the implementation is fully compatible.

If you really want to use Terraform 1.3.x, in [providers.tf](./providers.tf):
1. Change the terraform version requirement to:

```
required_version = ">= 1.3.0"
```

2. Remove the line:

```
experiments = [module_variable_optional_attrs]
```

## How to Invoke the Module

Terraform modules can be invoked locally or remotely. 

For invoking the module locally, just set the module *source* attribute to the module file path (relative path works). The following example assumes the module is two folders up in the file system.
```
module "terraform-oci-cis-landing-zone-networking" {
  source = "../.."
  network_configuration = var.network_configuration
}
```

For invoking the module remotely, set the module *source* attribute to the networking module repository, as shown:
```
module "terraform-oci-cis-landing-zone-networking" {
  source = "git@github.com:oracle-quickstart/terraform-oci-cis-landing-zone-networking.git"
  network_configuration = var.network_configuration
}
```
For referring to a specific module version, append *ref=\<version\>* to the *source* attribute value, as in:
```
  source = "git@github.com:oracle-quickstart/terraform-oci-cis-landing-zone-networking.git?ref=v0.1.0"
```

## How to use the module

The input parameters for the module can be divided into two categories, for which we recomend to create two different ```*.tfvars.*``` files:
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
      - ```dhcp_options```, 
      - ```subnets```, 
      - ```network_security_groups``` and
      - ```vcn_specific_gateways``` like: 
        - ```internet_gateways```,
        - ```nat_gateways```,
        - ```service_gateways``` and 
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
            - ```dhcp_options```, 
            - ```subnets```, 
            - ```network_security_groups``` and
            - ```vcn_specific_gateways``` like:
              - ```internet_gateways```, 
              - ```nat_gateways```, 
              - ```service_gateways``` or
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

This module can be used directly by copying one of the provided [examples](examples/) and modify to match the use-case.

It can also be integrated with other core modules into an orchestrated solution. It might be needed to apply some customizations to the complex type.

When using this module in stand-alone mode, but leave some options, customizations may be required, too.

<a name="howtoexample"></a>
### Examples

- [Simple Example](examples/simple-example/)
- [Provision a load balancer on top of an existing VCN](examples/simple-no_vcn-oci-native-l7-lbaas-example)
- [Provision a complete VCN and a load balancer](examples/standard-vcn-oci-native-l7-lbaas-example)

## Related Documentation
- [OCI Networking Overview](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/overview.htm)

## Known Issues

- On some corner case situations a ```cycle-graph``` exception might be raised when using route tables attached to GWs. This issue will be addressed in one of the next releases.
