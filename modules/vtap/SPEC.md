## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_core_capture_filter.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_capture_filter) | resource |
| [oci_core_vtap.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_vtap) | resource |
| [oci_network_load_balancer_backend_set.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/network_load_balancer_backend_set) | resource |
| [oci_network_load_balancer_listener.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/network_load_balancer_listener) | resource |
| [oci_network_load_balancer_network_load_balancer.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/network_load_balancer_network_load_balancer) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartments_dependency"></a> [compartments\_dependency](#input\_compartments\_dependency) | A map of objects containing the externally managed compartments this module may depend on. All map objects must have the same type and must contain an 'id' attribute of string type set with the compartment OCID. | <pre>map(object({<br>    id = string # the compartment OCID<br>  }))</pre> | `null` | no |
| <a name="input_network_dependency"></a> [network\_dependency](#input\_network\_dependency) | An object containing the externally managed network resources this module may depend on. Supported resource is 'subnets' , represented as map of objects. Each object, when defined, must have an 'id' attribute of string type set with the subnet OCID. | <pre>object({<br>    subnets = optional(map(object({<br>      id = string # the subnet OCID<br>    })))<br>  })</pre> | `null` | no |
| <a name="input_vtaps_configuration"></a> [vtaps\_configuration](#input\_vtaps\_configuration) | n/a | <pre>object({<br>    default_compartment_id = optional(string)<br>    capture_filters = optional(map(object({<br>      compartment_id            = optional(string)<br>      filter_type               = string<br>      display_name              = optional(string)<br>      vtap_capture_filter_rules = optional(map(object({<br>        traffic_direction = optional(string)<br>        rule_action       = optional(string)<br>        source_cidr       = optional(string)<br>        destination_cidr  = optional(string)<br>        protocol          = optional(string)<br>        icmp_options      = optional(map(object({<br>          type = optional(string)<br>          code = optional(string)<br>        })))<br>        tcp_options       = optional(map(object({<br>          destination_port_range_max = optional(number)<br>          destination_port_range_min = optional(number)<br>          source_port_range_max      = optional(number)<br>          source_port_range_min      = optional(number)<br>        })))<br>        udp_options       = optional(map(object({<br>          destination_port_range_max = optional(number)<br>          destination_port_range_min = optional(number)<br>          source_port_range_max      = optional(number)<br>          source_port_range_min      = optional(number)<br>        })))<br>      })))<br>    })))<br><br>    network_load_balancers = optional(map(object({<br>      compartment_id = optional(string)<br>      display_name   = string<br>      subnet_id      = string<br>    })))<br><br>    vtaps = optional(map(object({<br>      compartment_id    = optional(string)<br>      source_type       = optional(string)<br>      source_id         = string<br>      vcn_id            = string<br>      display_name      = optional(string)<br>      is_vtap_enabled   = optional(bool)<br>      target_type       = optional(string)<br>      target_id         = optional(string)<br>      capture_filter_id = string<br>    })))<br><br>    network_load_balancer_listeners = optional(map(object({<br>      default_backend_set_name = string<br>      listener_name            = string<br>      network_load_balancer_id = string<br>      port                     = number<br>      protocol                 = string<br>    })))<br><br>    network_load_balancer_backend_sets = optional(map(object({<br>      name                     = string<br>      network_load_balancer_id = string<br>      policy                   = string<br>      protocol                 = string<br>    })))<br>  })</pre> | n/a | yes |

## Outputs

No outputs.
