# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_core_vcn" "existing_vcns" {
  for_each = local.aux_one_dimension_processed_existing_vcns
  #Required
  vcn_id = each.value.vcn_id
}