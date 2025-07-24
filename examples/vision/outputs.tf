# Copyright (c) 2024 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "vision_network" {
  value = module.vision_network.provisioned_networking_resources
}

# This resource writes a file with select output as JSON content. This file can be used as a network dependency by another network configuration example that depends on VCNs or DRGs managed by this example.
resource "local_file" "network_output" {
  content = module.vision_network.provisioned_networking_resources != null ? jsonencode({
            "vcns" : {for k, v in module.vision_network.provisioned_networking_resources.vcns : k => {"id" : v.id}},
            "dynamic_routing_gateways" : {for k, v in module.vision_network.provisioned_networking_resources.dynamic_routing_gateways : k => {"id" : v.id}},
            "subnets" : {for k, v in module.vision_network.provisioned_networking_resources.subnets : k => {"id" : v.id}}
            "network_security_groups" : {for k, v in module.vision_network.provisioned_networking_resources.network_security_groups : k => {"id" : v.id}}
    }) : null
  filename = "./vision-network.json"
}
