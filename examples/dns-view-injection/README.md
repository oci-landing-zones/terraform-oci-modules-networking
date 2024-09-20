# OCI Private DNS View Injection Example

## Description

This example shows how to inject na existing private DNS view to a DNS resolver managed by the [terraform-oci-landing-zones-networking](../..) module.

It directly injects the existing private DNS view OCID into the *attached_view*'s *existing_view_id* attribute. 

Optionally, it could also inject a key within *dns_private_views* attribute of *network_dependency* variable. 

## Using this example
1. Rename *terraform.tfvars.template* to *terraform.tfvars*.

2. Within *terraform.tfvars*, provide tenancy connectivity information and adjust the input variables, by making the appropriate substitutions:
    - Replace \<REPLACE-BY-\*\> placeholder with appropriate value.

Refer to [Networking module README.md](../../README.md) for overall attributes usage.

3. In this folder, run the typical Terraform workflow:
```
terraform init
terraform plan -out plan.out
terraform apply plan.out
```