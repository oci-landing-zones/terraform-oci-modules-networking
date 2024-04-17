# Local Peering Gateways 

The enclosed pair of examples shows how to create and peer Local Peering Gateways (LPGs) within a region using the [OCI Landing Zone Core Networking module](https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking).

It creates two VCNs. Within each VCN a Local Peering Gateway (LPG) is created. The LPGs are then peered.

## How to Run the Examples

### Run the Acceptor
1. Replace the placeholders marked with \<\> with appropriate values in ./lpg_acceptor/input.auto.tfvars.template. Rename the file to ./lpg_acceptor/input.auto.tfvars.
2. Execute terraform init/plan/apply in ./lpg-acceptor folder.

### Run the Requestor
3. Replace the placeholders marked with \<\> with appropriate values in ./lpg_requestor/input.auto.tfvars.template. Rename the file to ./lpg_requestor/input.auto.tfvars.
4. Execute terraform init/plan/apply in ./lpg-requestor folder.