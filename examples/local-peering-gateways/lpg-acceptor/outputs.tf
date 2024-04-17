# Copyright (c) 2024 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "networking_resources" {
  description = "Networking resources"
  value       = module.lpg_acceptor.provisioned_networking_resources
}

# This resource writes a file with select output as JSON content. This file can be used as a network dependency by another network configuration example that depends on RPCs managed by this example.
resource "local_file" "network_output" {
  content = module.lpg_acceptor.provisioned_networking_resources != null ? jsonencode({
            "local_peering_gateways" : {for k, v in module.lpg_acceptor.provisioned_networking_resources.local_peering_gateways : k => {"id" : v.id}}
    }) : null
  filename = "./vision-network.json"
}