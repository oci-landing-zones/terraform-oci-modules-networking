# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


output "provisioned_l7_load_balancers" {
  description = "Provisioned L7 Application Load Balancers"
  value       = module.l7_load_balancers.provisioned_l7_load_balancers
}