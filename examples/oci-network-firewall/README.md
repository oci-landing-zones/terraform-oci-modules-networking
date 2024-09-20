# OCI Network Firewall Example

## Description

This example implements the network firewall policy in the use case described in https://www.ateam-oracle.com/post/oci-network-firewall---concepts-and-deployment. The complete routing scenario is not implemented.

Note that the IP addresses for the Internet hosts are fictitious, so please update them appropriately.

For detailed description of the ```terraform-oci-landing-zones-networking``` networking core module please refer to the core module specific [README.md](../../README.md) and [SPEC.md](../../SPEC.md).

## Using this example
1. Rename *terraform.tfvars.template* to *terraform.tfvars*.

2. Within *terraform.tfvars*, provide tenancy connectivity information and adjust the input variables, by making the appropriate substitutions:
    - Replace \<REPLACE-BY-\*\> placeholder with appropriate value.

Refer to [Networking module README.md](https://github.com/oci-landing-zones/terraform-oci-modules-networking/blob/main/README.md) for overall attributes usage.

3. In this folder, run the typical Terraform workflow:
```
terraform init
terraform plan -out plan.out
terraform apply plan.out
```
