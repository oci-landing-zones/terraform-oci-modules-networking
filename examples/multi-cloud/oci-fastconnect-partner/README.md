<!-- BEGIN_TF_DOCS -->
# Multicloud connectivity - FastConnect Partner

## Description

This is an example for a private Multicloud connection using OCI FastConnect and a FastConnect Partner.
This scenario will use simple/basic instantiation of the ```terraform-oci-cis-landing-zone-networking``` networking core module.

For detailed description of the ```terraform-oci-cis-landing-zone-networking``` networking core module please refer to the core module specific [README.md](../../README.md) and [SPEC.md](../../SPEC.md).

This example is leveraging the fully dynamic characteristics of the complex networking module input to describe the following networking topology:

- networking construct provisioned on a single compartment
- single networking category defined
- the CIDR range proposed for the secondary Cloud is 172.16.0.0/16
- the category will contain one single VCN (10.0.0.0/18)
- the VCN will contain the following a 3 tier topology (load balancer, application and database) as follows:
    - Three security lists:
        - a load balancer security list allowing ingress from anywhere for https:443 and ssh:22
        - an application security list allowing ingress from the lb subnet and from secondary Cloud over http:80, ssh:22 and ICMP.
        - a database security list allowing ingress from the db subnet CIDR over TCP(jdbc):1521 and ssh:22
    - All three security lists contain an egress rule to allow egress traffic over any port to anywhere.
    - Three gateways:
        - One Internet Gateway
        - One NAT Gateway
        - One Service Gateway
    - Two route tables:
        - ```rt-01``` defines a route to the Internet Gateway
        - ```rt-02``` defines the following routes:
            - a route to the NAT GW;
            - a route to the Service GW;
            - a route to the DRG for reaching the Secondary Cloud
    - Three subnets:
        - ```lb-subnet``` (10.0.3.0/24) for the load balancer tier. This subnet will be using the ```rt-01``` route table, default VCN DHCP options and the lb security list.
        -  ```app-subnet``` (10.0.2.0/24) for the application tier. This subnet will be using the ```rt-02``` route table, default VCN DHCP options and the app security list.
        - ```db-subnet``` (10.0.1.0/24) for the database tier. This subnet will be using the ```rt-02``` route table, default VCN DHCP options and the db security list.

__NOTE 1:__ Please note that the specific partner configuration will not be mantained in this repo. The specific partner tf file will provide the public path to the code.

__NOTE 2:__ Please note the redudancy in defining both security lists and NSGs. We've intentionally chosed to define both, for example purposes, but you'll just need to define one or the other, depending on your usecase.

__NOTE 3:__ Please note that the entire configuration is a single complex input parameter and you're able to edit it and change the resources names and any of their configuration (like VCN and subnet CIDR blocks, dns labels...) and, also, you're able to change the input configuration topology/structure like adding more categories, more VCNs inside a category, more subnets inside a VCN or inject new resources into existing VCNs and this will reflect into the topology that terraform will provision.

## Diagram of a Multicloud connectivity - FastConnect Partner scenario

![](diagrams/oci-aws-equinix.png)

## Instantiation

For clarity and proper separation and isolation we've separated the input parameters into 2 files by leveraging terraform ```*.auto.tfvars``` feature:

- [terraform.tfvars](./terraform.tfvars.template)

- [oci_network_configuration.auto.tfvars](./oci_network_configuration.auto.tfvars)


## Output Example:

```
provisioned_fc_vc_id = "ocid1.virtualcircuit.oc1.eu-frankfurt-1.........."
```

This is the ocid of the virtual circuit that must be provided to the connectivity partner
