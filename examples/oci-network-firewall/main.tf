# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "terraform_oci_networking" {
  source = "../../"
  network_configuration = var.network_configuration
}

