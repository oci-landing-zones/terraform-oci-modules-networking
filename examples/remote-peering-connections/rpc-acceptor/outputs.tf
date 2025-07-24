# Copyright (c) 2024 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "networking_resources" {
  description = "Networking resources"
  value       = module.rpc_acceptor.provisioned_networking_resources
}

# This resource writes a file with select output as JSON content. This file can be used as a network dependency by another network configuration example that depends on RPCs managed by this example.
resource "local_file" "network_output" {
  content = module.rpc_acceptor.provisioned_networking_resources != null ? jsonencode({
            "remote_peering_connections" : {for k, v in module.rpc_acceptor.provisioned_networking_resources.remote_peering_connections : k => {"id" : v.id, "region_name" : var.region}}
    }) : null
  filename = "./vision-network.json"
}