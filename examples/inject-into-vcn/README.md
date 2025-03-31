# Networking Vision Example 

## Introduction

This example shows how to deploy core VCN resources in OCI using the [OCI Landing Zone Networking module](https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking). 

Specifically, it shows how to inject a route table and VCN gateways into a VCN that is provisioned in the same configuration. This is useful in advanced scenarios where you need, *in a single Terraform configuration*, to add resources to a VCN that depend on other resources provisioned in the VCN itself. Picture the case where you need to create a VCN route table rule that points to a Compute instance. In this case, the VCN is typically created first, the Compute next. But we need to update the VCN route tables by adding a route table that points to the Compute instance. 

See [input.auto.tfvars.template](./input.auto.tfvars.template) for the network configuration.

See [module's README.md](https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking/blob/main/README.md) for overall attributes usage.

## Using this example
1. Rename *input.auto.tfvars.template* to *\<project-name\>.auto.tfvars*, where *\<project-name\>* is any name of your choice.

2. Within *\<project-name\>.auto.tfvars*, provide tenancy connectivity information and adjust the input variables, by making the appropriate substitutions:
   - Replace *\<REPLACE-WITH-NETWORK-COMPARTMENT-OCID\>* placeholder with the network compartment OCID where the VCN is created.
   
3. In this folder, run the typical Terraform workflow:
```
terraform init
terraform plan -out plan.out
terraform apply plan.out
```