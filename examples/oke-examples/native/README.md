<!-- BEGIN_TF_DOCS -->
# Native-based OKE Private Networking

## Introduction

This is an example of a network topology to host an OKE cluster that utilizes Native CNI, private API endpoint, private worker nodes and public load balancers. It is deployed via the [terraform-oci-cis-landing-zone-networking module](https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking). 

The network configuration assumes cluster access occurs from an OKE client that is either external to the tenancy (as a user laptop) or a Compute instance in the VCN *access* subnet. In both cases, access to OKE API endpoint and worker nodes is enabled by the OCI Bastion service. 

Examples of OKE configurations that deploy in this network configuration:
- [Native Basic No Access Automation](https://github.com/oracle-quickstart/terraform-oci-secure-workloads/tree/main/cis-oke/examples/native/basic): a Native-based OKE cluster with no cluster access automation.
- [Native Basic with Access Automation via OCI Bastion Service - Access from localhost](https://github.com/oracle-quickstart/terraform-oci-secure-workloads/tree/main/cis-oke/examples/native/basic-access-via-bastion-from-localhost): a Native-based OKE cluster with full access automation via the OCI Bastion service. The OKE client is external to the tenancy (as a user laptop).
- [Native Basic with Access Automation via OCI Bastion Service - Access from operator host](https://github.com/oracle-quickstart/terraform-oci-secure-workloads/tree/main/cis-oke/examples/native/basic-access-via-bastion-from-operator-host): a Native-based OKE cluster with full access automation via the OCI Bastion service. The OKE client is a Compute instance in the VCN *access* subnet.

### Resources Deployed by this Example

The following resources are deployed by this example:

- Single VCN in the compartment referred by *default_compartment_id* attribute, containing the following:
    - Five subnets:
        - **api-subnet** (10.0.0.0/30) for the OKE API endpoint. This subnet utilizes the *api-routetable* route table, default VCN DHCP options and the *api-seclist* security list.
        - **workers-subnet** (10.0.1.0/24) for the application tier. This subnet utilizes the *workers-routetable* route table, default VCN DHCP options and the *workers-seclist* security list.
        - **sub-pods** (10.0.32.0/19) for the pods. This subnet utilizes *pods-routetable* route table, default VCN DHCP options and the *pods-seclist* security list.
        - **services-subnet** (10.0.2.0/24) for the load balancers. This subnet utilizes the *services-routetable* route table, default VCN DHCP options and the *services-seclist* security list.
        - **access-subnet** (10.0.3.0/28) for OCI Bastion service endpoint and/or operator host. This subnet utilizes the *access-routetable* route table, default VCN DHCP options and the *access-seclist* security list. This subnet is utilized as an access path from OKE clients to OKE API private endpoint and private worker nodes for management purposes.
    Five route tables:
        - **services-routetable**: defines a route to Internet Gateway.
        - **api-routetable**: defines two routes:
            - a route to NAT Gateway.
            - a route to Service Gateway.
        - **workers-routetable**: defines two routes:
            - a route to NAT Gateway.
            - a route to Service Gateway.   
        - **pods-routetable**: defines two routes:
            - a route to NAT Gateway.
            - a route to Service Gateway.  
        - **access-routetable**: defines two routes:
            - a route to NAT Gateway.
            - a route to Service Gateway.  
    - Five security lists:
        - **api-seclist**: for the API endpoint subnet, allowing ingress for ICMP (Path Discovery).
        - **workers-seclist**: for the workers subnet, allowing ingress for ICMP (Path Discovery).
        - **pods-seclist**: for the pods subnet, allowing ingress for ICMP (Path Discovery).
        - **services-seclist**: for the services subnet, allowing ingress for ICMP (Path Discovery).
        - **access-seclist**: for the access subnet, allowing egress to API subnet, egress to access subnet itself (For Bastion service endpoint to operator host communication), egress to workers subnet, ingress for ICMP (Path Discovery) and ingress to access subnet itself (For Bastion service endpoint to operator host communication).
    - Five Network Security Groups (NSGs): **api-nsg**, **workers-nsg**, **pods-nsg**, **services-nsg** and **access-nsg**, containing security rules to allow a Native-based OKE Cluster to run correctly.    
    - Three gateways:
        - One Internet Gateway.
        - One NAT Gateway.
        - One Service Gateway.

See [input.auto.tfvars.template](./input.auto.tfvars.template) for the variables configuration.

## Using this example
1. Rename *input.auto.tfvars.template* to *\<project-name\>.auto.tfvars*, where *\<project-name\>* is any name of your choice.

2. Within *\<project-name\>.auto.tfvars*, provide tenancy connectivity information and adjust the input variables, by making the appropriate substitutions:
   - Replace \<REPLACE-BY-\*\> placeholder with appropriate value. 
   
Refer to [Networking module README.md](https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking/blob/main/README.md) for overall attributes usage.

3. In this folder, run the typical Terraform workflow:
```
terraform init
terraform plan -out plan.out
terraform apply plan.out
```


