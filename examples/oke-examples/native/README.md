<!-- BEGIN_TF_DOCS -->
# NPN (Native Pod Networking) OKE

## Introduction

This is an example of a network topology to host an OKE cluster that utilizes Native CNI, private API endpoint, private worker nodes and public load balancers. It is deployed via the [terraform-oci-cis-landing-zone-networking module](https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking). 

This topology is discussed in the [OCI documentation](https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengnetworkconfigexample.htm#example-oci-cni-privatek8sapi_privateworkers_publiclb).

The network configuration assumes cluster access occurs from an OKE client that is either external to the tenancy (as a user laptop) or a Compute instance in the VCN *mgmt-subnet*. In both cases, access to OKE API endpoint and worker nodes is enabled by the OCI Bastion service. 

Examples of OKE configurations that deploy in this network configuration:
- [NPN Basic OKE Cluster](https://github.com/oracle-quickstart/terraform-oci-secure-workloads/tree/main/cis-oke/examples/native/basic): a NPN OKE cluster with no cluster access automation.
- [NPN Basic OKE Cluster with Access from localhost](https://github.com/oracle-quickstart/terraform-oci-secure-workloads/tree/main/cis-oke/examples/native/basic-access-from-localhost): a NPN OKE cluster with access automation via the OCI Bastion service. The OKE client is external to the tenancy (as a user laptop).
- [NPN Basic OKE Cluster with Access from Operator host](https://github.com/oracle-quickstart/terraform-oci-secure-workloads/tree/main/cis-oke/examples/native/basic-access-from-operator-host): a NPN OKE cluster with access automation via the OCI Bastion service. The OKE client is a Compute instance deployed in the VCN *mgmt-subnet*.

### Resources Deployed by this Example

The following resources are deployed by this example:

- Single VCN in the compartment referred by *default_compartment_id* attribute, containing the following:
    - Five subnets:
        - **api-subnet** (10.0.0.0/30) for the OKE API endpoint. This subnet utilizes the *api-routetable* route table, default VCN DHCP options and the *api-seclist* security list.
        - **workers-subnet** (10.0.1.0/24) for the application tier. This subnet utilizes the *workers-routetable* route table, default VCN DHCP options and the *workers-seclist* security list.
        - **sub-pods** (10.0.32.0/19) for the pods. This subnet utilizes *pods-routetable* route table, default VCN DHCP options and the *pods-seclist* security list.
        - **services-subnet** (10.0.2.0/24) for the load balancers. This subnet utilizes the *services-routetable* route table, default VCN DHCP options and the *services-seclist* security list.
        - **mgmt-subnet** (10.0.3.0/28) for OCI Bastion service endpoint and/or operator host. This subnet utilizes the *mgmt-routetable* route table, default VCN DHCP options and the *mgmt-seclist* security list. This subnet is utilized as an access path from OKE clients to OKE API private endpoint and private worker nodes for management purposes.
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
        - **mgmt-routetable**: defines two routes:
            - a route to NAT Gateway.
            - a route to Service Gateway.  
    - Five security lists:
        - **api-seclist**: for the *api-subnet*, allowing ingress for ICMP (Path Discovery).
        - **workers-seclist**: for the *workers-subnet*, allowing ingress for ICMP (Path Discovery).
        - **pods-seclist**: for the *pods-subnet*, allowing ingress for ICMP (Path Discovery).
        - **services-seclist**: for the *services-subnet*, allowing ingress for ICMP (Path Discovery).
        - **mgmt-seclist**: for the *mgmt-subnet*, with the following rules:
            - *ingress* rule for ICMP (Path Discovery);
            - *ingress* rule from *mgmt-subnet* itself (for Bastion service endpoint to Operator host communication);
            - *egress* rule to *api-subnet* (for Bastion service endpoint to *api-subnet*) 
            - *egress* rule to *mgmt-subnet* itself (For Bastion service endpoint to Operator host communication);
            - *egress* rule to *workers-subnet* (for Bastion service endpoint to *workers-subnet*);
    - Five Network Security Groups (NSGs): **api-nsg**, **workers-nsg**, **pods-nsg**, **services-nsg** and **mgmt-nsg**, containing security rules to allow a NPN OKE cluster to run correctly.    
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


