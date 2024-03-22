# Networking Vision Example 

## Introduction

This example shows how to deploy core VCN resources in OCI using the [OCI Landing Zone Networking module](https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking). 

It deploys one basic three-tier VCN with the following resources:

- three subnets: public LBR, private app, and private database;
- three route tables, one to each subnet;
- four network security groups, including a Bastion network security group to allow SSH connections to private subnets;
- one Internet Gateway;
- one NAT Gateway;
- one Service Gateway. 

The example outputs a file named *vision-network.json*, with select resources (VCNs) that can be further used as a dependency in another network configuration example that requires resources managed by this configuration example.  
See [external-dependency](../external-dependency/) example.

See [input.auto.tfvars.template](./input.auto.tfvars.template) for the network configuration.

See [module's README.md](https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking/blob/main/README.md) for overall attributes usage.

## Using this example
1. Rename *input.auto.tfvars.template* to *\<project-name\>.auto.tfvars*, where *\<project-name\>* is any name of your choice.

2. Within *\<project-name\>.auto.tfvars*, provide tenancy connectivity information and adjust the input variables, by making the appropriate substitutions:
   - Replace *\<REPLACE-WITH-NETWORK-COMPARTMENT-OCID\>* placeholder with the network compartment OCID where the VCN is created.
   - Replace *\<REPLACE-WITH-ALLOWED-CIDR-RANGE\>* placeholder with the CIDR range allowed to SSH into the Bastion Network Security Group. 
   
3. In this folder, run the typical Terraform workflow:
```
terraform init
terraform plan -out plan.out
terraform apply plan.out
```