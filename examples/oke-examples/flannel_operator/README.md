<!-- BEGIN_TF_DOCS -->
# Flannel-based OKE Networking with Access from Operator Instance

## Introduction

This is an example of a network topology to host an OKE cluster that utilizes Flannel CNI, private API endpoint, private worker nodes and public load balancers. It is deployed via the [terraform-oci-cis-landing-zone-networking module](https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking). The network setup assumes cluster access occurs from an OKE client that is **internal** to the tenancy (an Operator instance) through the OCI Bastion service.

Examples of OKE configurations that deploy in this network topology:
- [Flannel Basic](https://github.com/oracle-quickstart/terraform-oci-secure-workloads/tree/main/cis-oke/examples/flannel/basic): a Flannel-based OKE cluster with no cluster access automation.
- [Flannel Basic Access from Operator instance](https://github.com/oracle-quickstart/terraform-oci-secure-workloads/tree/main/cis-oke/examples/flannel/basic-access-via-bastion-from-operator-host): a Flannel-based OKE cluster with access via the OCI Bastion service. The OKE client is internal to the tenancy (an operator instance).

### Resources Deployed by this Example

The following resources are deployed by this example:
- Single VCN in the compartment referred by *default_compartment_id* attribute, containing the following:
    - Four subnets:
        - **sub-api** (10.0.0.0/30) for the API endpoint. This subnet utilizes the **rt-api** route table, default VCN DHCP options and the **sl-api** security list.
        - **sub-workers** (10.0.1.0/24) for the worker nodes. This subnet utilizes the **rt-workers** route table, default VCN DHCP options and the **sl-workers** security list.
        - **sub-services** (10.0.2.0/24) for the load balancers. This subnet utilizes the **rt-services** route table, default VCN DHCP options and the **sl-services** security list.
        - **sub-operator** (10.0.3.0/28) for allowing access to the Kubernetes API in the **sub-api** subnet and SSH access to worker nodes in the **sub-workers** subnet through the operator instance. This subnet utilizes the **rt-operator** route table, default VCN DHCP options and the **sl-operator** security list.
    - Three gateways:
        - One Internet Gateway.
        - One NAT Gateway.
        - One Service Gateway.    
    - Four route tables:
        - **rt-services** defines a route to the Internet Gateway
        - **rt-api** defines two routes:
            - a route to the NAT GW.
            - a route to the Service GW.
        - **rt-workers** defines two routes:
            - a route to the NAT GW.
            - a route to the Service GW.
        - **rt-operator** defines two routes:
            - a route to the NAT GW.
            - a route to the Service GW.    
    - Four security lists:
        - **sl-api**: for the **sub-api** subnet, allowing ingress for ICMP (Path Discovery).
        - **sl-workers**: for the **sub-workers**, allowing ingress for ICMP (Path Discovery).
        - **sl-services**: for the **sub-services** subnet, allowing ingress for ICMP (Path Discovery).
        - **sl-operator**: for the **sub-operator** subnet, with the following rules:
            - one egress rule allowing Bastion service to SSH into the operator instance.
            - one ingress rule allowing Bastion service to SSH into the operator instance.
            - one ingress rule for ICMP (Path Discovery). 
    - Four Network Security Groups (NSGs): **nsg-api**, **nsg-workers**, **nsg-services**, and **nsg-operator**, containing security rules to allow a Kubernetes cluster with Flannel CNI to run correctly.
    
See [input.auto.tfvars.template](./input.auto.tfvars.template) for the variables configuration.

## Using this example
1. Rename *input.auto.tfvars.template* to *\<project-name\>.auto.tfvars*, where *\<project-name\>* is any name of your choice.

2. Within *\<project-name\>.auto.tfvars*, provide tenancy connectivity information and adjust the input variables, by making the appropriate substitutions:
   - Replace \<REPLACE-BY-\*\> placeholder with appropriate value. 
   
Refer to [Networking module README.md](.https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking/blob/main/README.md) for overall attributes usage.

3. In this folder, run the typical Terraform workflow:
```
terraform init
terraform plan -out plan.out
terraform apply plan.out
```


