# Private Service Access Example

## Overview

This example provisions a private service access (PSA) connection between your Virtual Cloud Network (VCN) and Oracle Object Storage through the `terraform-oci-landing-zones-networking` core module. The configuration demonstrates how to:

- Define VCN and subnet resources that host the private endpoint.
- Discover the Object Storage PSA service OCID automatically (or override it explicitly).
- Create the `oci_psa_private_service_access` resource via the module, attaching it to the subnet you specify.

Use this example as a starting point for connecting private workloads to Object Storage or other PSA-enabled Oracle services.

## Prerequisites

- Terraform 1.3.0 or newer.
- OCI credentials with permissions to manage networking and private service access resources in the target compartment.
- An RSA private key that matches the fingerprint provided in `terraform.tfvars`.
- The PSA service must be available in the region you target. Object Storage PSA is generally available in commercial OCI regions.

## Files in this Example

| File | Purpose |
| --- | --- |
| `main.tf` | Loads the networking module and injects the Object Storage PSA service ID when available. |
| `variables.tf` | Declares the minimal set of variables required for the example. |
| `terraform.tfvars.template` | Sample values showing how to supply tenancy details, network topology, and PSA settings. Copy this file to `terraform.tfvars` and customize it. |
| `outputs.tf` | Exposes the module outputs for inspection after a successful apply. |

## Configuration Steps

1. Configure the PSA policies at the tenancy level.

    `Allow group <GROUP NAME> to manage private-service-access in tenancy`
    `Allow group <GROUP NAME> to read private-service-access in tenancy`

2. **Copy the template:**
   ```bash
   cp terraform.tfvars.template terraform.tfvars
   ```

3. **Populate tenancy credentials** in `terraform.tfvars`:
   - `tenancy_ocid`
   - `user_ocid`
   - `fingerprint`
   - `private_key_path`
   - `private_key_password` (optional; you can pass it via environment variable instead)
   - `region`

4. **Provide the PSA target service ID.**
   - Locate the Object Storage PSA OCID for your region (for example, `ocid1.psaservice.oc1.iad...`). You can retrieve it from the [OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm) with:
     ```bash
     oci network private-service-access list-available-services --region <region>
     ```
   - For example, the Object Storage service ID is `object-storage`, and the Database service ID is `database-service`.

5. **Customize the networking topology** as needed:
   - Update `cidr_blocks`, subnet definitions, and DNS labels to fit your CIDR plan.
   - If you need additional VCNs or PSA targets, expand the maps following the same pattern.

6. **(Optional) Configure additional networking controls** by extending each PSA entry with the `nsg_ids` or `nsg_keys` attributes. Supplying `nsg_keys` lets the module resolve the IDs of NSGs created within the same configuration.

7. **(Optional) Attach Zero Trust Packet Routing (ZPR) security attributes** by adding a nested `zpr_attributes` block that matches the namespace and attribute names defined in your tenancy. For example:

   ```hcl
   private_service_access = {
     OBJECT-STORAGE = {
       target_service_id = "object-storage"
       subnet_key        = "PSA-SUBNET"
       nsg_keys          = ["PSA-NSG-KEY"]
       zpr_attributes = {
         "oracle-zpr" = {
           sensitivity = {
             value = "test"
             mode  = "enforce"
           }
         }
       }
     }
   }
   ```

   Ensure the namespace (`oracle-zpr` in this example) and attribute (`sensitivity`) exist in **Identity & Security → Zero Trust Packet Routing**; otherwise the OCI API will reject the update with an *Invalid tags* error.

## Running Terraform

```bash
terraform init
terraform plan -out plan.out
terraform apply plan.out
```


## Verifying the Deployment

- Review the output `provisioned_networking_resources.private_service_access` to confirm the PSA resource status and OCIDs.
- In the OCI Console, navigate to **Networking → Private Service Access** to confirm the connection targets Object Storage and is attached to the correct subnet.


## Cleanup

To destroy all resources created by this example:

```bash
terraform destroy
```

## Additional References

- [OCI Private Service Access documentation](https://www.oracle.com/cloud/networking/private-service-access/)
- [terraform-oci-landing-zones-networking module README](../../README.md)
- [OCI provider PSA resource reference](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/psa_private_service_access)
