# Copyright (c) 2024 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

#-- Used to inform module and release number.
locals {
  cislz_module_tag = { "ocilz-terraform-module" : fileexists("${path.module}/../../release.txt") ? "${var.module_name}/${file("${path.module}/../../release.txt")}" : "${var.module_name}" }
}    