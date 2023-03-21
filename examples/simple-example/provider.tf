# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_version = "< 1.3.0"
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
  experiments = [module_variable_optional_attrs]
}

provider "oci" {
  version          = ">= 4.109.0"
  tenancy_ocid     = var.tenancy_id
  user_ocid        = var.user_id
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}