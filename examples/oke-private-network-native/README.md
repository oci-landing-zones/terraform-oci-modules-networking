<!-- BEGIN_TF_DOCS -->
# OKE Native networking architecture - topology provisioning 

## Description

This is an example for a VCN NATIVE CNI with Private API Endpoint, Private Worker Nodes and Public Load Balancers instantiation of the ```terraform-oci-cis-landing-zone-networking``` networking core module.

It is designed to use NSGS instead of Security Lists.

For detailed description of the ```terraform-oci-cis-landing-zone-networking``` networking core module please refer to the core module specific [README.md](../../README.md) and [SPEC.md](../../SPEC.md).

This example is leveraging the fully dynamic characteristics of the complex networking module input to describe the following networking topology:

- networking construct provisioned on a single compartment
- single networking category defined
- the category will contain one single VCN (10.0.0.0/16)
- the VCN will contain the following:
    - Five security lists:
        - an api endpoint security list allowing ingress for ICMP (Path Discovery).
        - a workers security list allowing ingress for ICMP (Path Discovery).
        - a pods security list allowing ingress for ICMP (Path Discovery).
        - three operator security list. One ingress for ICMP (Path Discovery) and Two egress for allowing connectivity to the OKE Private api endpoint and managed ssh access to workers in the Node Pool subnet.
        - a services security list allowing ingress for ICMP (Path Discovery).
    - Three gateways:
        - One Internet Gateway
        - One NAT Gateway
        - One Service Gateway
    - Five route tables:
        - ```rt-services``` defines a route to the Internet Gateway
        - ```rt-api``` defines two routes:
            - a route to the NAT GW;
            - a route to the Service GW;
        - ```rt-workers``` defines two routes:
            - a route to the NAT GW;
            - a route to the Service GW;
        - ```rt-pods``` defines two routes:
            - a route to the NAT GW;
            - a route to the Service GW;            
        - ```rt-operator``` defines two routes:
            - a route to the NAT GW;
            - a route to the Service GW;                        
    - Four Network Security Groups (NSGs)
        - ```nsg-api```
        - ```nsg-workers``` 
        - ```nsg-pods``` 
        - ```nsg-services```
    - all NSGs contain the rules to allow a Kubernetes Cluster with Flannel CNI to run correctly.
    - Five subnets:
        - ```sub-api``` (10.0.0.0/30) for the api endpoint. This subnet will be using the ```rt-api``` route table, default VCN DHCP options and the api security list.
        -  ```sub-workers``` (10.0.1.0/24) for the workers. This subnet will be using the ```rt-workers``` route table, default VCN DHCP options and the workers security list.
        -  ```sub-pods``` (10.0.32.0/19) for the pods. This subnet will be using the ```rt-pods``` route table, default VCN DHCP options and the pods security list.
        - ```sub-services``` (10.0.2.0/24) for the load balancers. This subnet will be using the ```rt-services``` route table, default VCN DHCP options and the services security list.
        - ```sub-operator``` (10.0.3.0/28) for allowing Bastion service access to the kubernetes api in the **sub-api** subnet and managed ssh to workers in the **sub-workers** subnet. This subnet will be using the ```rt-operator``` route table, default VCN DHCP options and the operator security list.



__NOTE:__ Please note that the entire configuration is a single complex input parameter and you're able to edit it and change the resources names and any of their configuration (like VCN and subnet CIDR blocks, dns labels...) and, also, you're able to change the input configuration topology/structure like adding more categories, more VCNs inside a category, more subnets inside a VCN or inject new resources into existing VCNs and this will reflect into the topology that terraform will provision.


## Instantiation

For clarity and proper separation and isolation we've separated the input parameters into 2 files by leveraging terraform ```*.auto.tfvars``` feature:

- [terraform.tfvars](./terraform.tfvars.template)


- [network_configuration.auto.tfvars](./network_configuration.auto.tfvars)


