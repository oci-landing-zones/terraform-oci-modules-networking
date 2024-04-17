# Remote Peering Connections 

The enclosed pair of examples shows how to create Remote Peering connections (RPCs) across regions using the [OCI Landing Zone Core Networking module](https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking).

It creates two DRGs, one in the region specified in [./rpc_acceptor/input.auto.tfvars.template](./rpc_acceptor/input.auto.tfvars.template) and another in the region specified in [./rpc_requestor/input.auto.tfvars.template](./rpc_requestor/input.auto.tfvars.template). Each DRG is attached an RPC (Remote Peering Connection). The RPCs are then peered.

## How to Run the Examples

### Run the Acceptor
1. Replace the placeholders marked with \<\> with appropriate values in ./rpc_acceptor/input.auto.tfvars.template. Rename the file to ./rpc_acceptor/input.auto.tfvars.
2. Execute terraform init/plan/apply in ./rpc-acceptor folder.

### Run the Requestor
3. Replace the placeholders marked with \<\> with appropriate values in ./rpc_requestor/input.auto.tfvars.template. Rename the file to ./rpc_requestor/input.auto.tfvars.
4. Execute terraform init/plan/apply in ./rpc-requestor folder.