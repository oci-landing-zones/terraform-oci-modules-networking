# Copyright (c) 2024 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "rpc_requestor" {
  source = "../../../"
  network_configuration = var.network_configuration
  network_dependency    = jsondecode(file("../rpc-acceptor/vision-network.json"))
}

