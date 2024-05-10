<!-- BEGIN_TF_DOCS -->
# Flannel-based OKE Networking with External Access

## Introduction

This is an example of a network topology to host an OKE cluster that utilizes Flannel CNI, private API endpoint, private worker nodes and public load balancers. It is deployed via the [terraform-oci-cis-landing-zone-networking module](https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking). The network setup assumes cluster access occurs from an OKE client that is **external** to the tenancy (such as a user laptop) through the OCI Bastion service. 

Examples of OKE configurations that deploy in this network topology:
- [Flannel Basic](https://github.com/oracle-quickstart/terraform-oci-secure-workloads/tree/main/cis-oke/examples/flannel/basic): a Flannel-based OKE cluster with no cluster access automation.
- [Flannel Basic Access from localhost](https://github.com/oracle-quickstart/terraform-oci-secure-workloads/tree/main/cis-oke/examples/flannel/basic-access-via-bastion-from-localhost): a Flannel-based OKE cluster with access via the OCI Bastion service. The OKE client is external to the tenancy (such as in a user laptop).

### Resources Deployed by this Example

The following resources are deployed by this example:

- Single VCN in the compartment referred by *default_compartment_id* attribute, containing the following:
    - Four subnets:
        - **sub-api** (10.0.0.0/30) for the API endpoint. This subnet utilizes the **rt-api** route table, default VCN DHCP options and the **sl-api** security list.
        - **sub-workers** (10.0.1.0/24) for the worker nodes. This subnet utilizes the **rt-workers** route table, default VCN DHCP options and the **sl-workers** security list.
        - **sub-services** (10.0.2.0/24) for the load balancers. This subnet utilizes the **rt-services** route table, default VCN DHCP options and the **sl-services** security list.
        - **sub-bastion** (10.0.3.0/28) for OCI Bastion service endpoint. This subnet utilizes the **rt-bastion** route table, default VCN DHCP options and the **sl-bastion** security list.
    - - Three gateways:
        - One Internet Gateway.
        - One NAT Gateway.
        - One Service Gateway.    
    - Four route tables:
        - **rt-services**: defines a route to the Internet Gateway.
        - **rt-api**: defines two routes:
            - a route to the NAT GW.
            - a route to the Service GW.
        - **rt-workers**: defines two routes:
            - a route to the NAT GW.
            - a route to the Service GW.   
        - **rt-bastion**: defines one route:
            - a route to the Service GW.   
    - Four security lists:
        - **sl-api**: for the API endpoint subnet, allowing ingress for ICMP (Path Discovery).
        - **sl-workers**: for the workers subnet, allowing ingress for ICMP (Path Discovery).
        - **sl-services**: for the services subnet, allowing ingress for ICMP (Path Discovery).
        - **sl-bastion**: for the bastion subnet, allowing egress to API subnet, egress to Workers subnet and ingress for ICMP (Path Discovery).
    - Three Network Security Groups (NSGs): **nsg-api**, **nsg-workers** and **nsg-services**, containing security rules to allow a Kubernetes cluster with Flannel CNI to run correctly.    

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


