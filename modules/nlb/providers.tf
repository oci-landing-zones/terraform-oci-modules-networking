# Copyright (c) 2023 Oracle and/or its affiliates.
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