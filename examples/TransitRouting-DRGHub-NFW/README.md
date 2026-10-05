# Transit routing with a DRG hub and OCI Network Firewall

This example connects three spoke VCNs and an on-premises network through a DRG.
Traffic entering the hub VCN is routed through OCI Network Firewall.

![Transit routing topology](diagrams/network_transit_detailed_layout_2021.png)

The example calls the networking module directly:

```hcl
module "terraform_oci_networking" {
  source                = "../../"
  network_configuration = var.network_configuration
}
```

[network_configuration.auto.tfvars.template](network_configuration.auto.tfvars.template)
contains the complete topology. Firewall routes use `network_entity_id = "HUB-NFW-KEY"`
to reference the firewall defined in the same configuration. The module resolves its
private-IP OCID automatically, so the full topology can be deployed in one apply.

## Deploy with Terraform

1. Copy the input templates:

   ```shell
   cp terraform.tfvars.template terraform.tfvars
   cp network_configuration.auto.tfvars.template network_configuration.auto.tfvars
   ```

2. Set your OCI authentication values in `terraform.tfvars`. In
   `network_configuration.auto.tfvars`, set `default_compartment_id` and adjust the
   FastConnect provider, BGP peering addresses, CIDRs, and firewall policy for your
   environment.

3. Run Terraform from this directory:

   ```shell
   terraform init
   terraform plan -out=plan.out
   terraform apply plan.out
   ```

## YAML input

[network_configuration.yaml](input-configs-standards-options/network_configuration.yaml)
provides the same complete configuration in YAML. Edit its compartment, FastConnect,
and policy settings for your environment.

For OCI Resource Manager, use `orm-facade` as the stack's working directory and set
`input_config_file_url` to the URL of your edited YAML file. Run one plan/apply cycle.

See the module [README](../../README.md) and [specification](../../SPEC.md) for the
available configuration attributes.
