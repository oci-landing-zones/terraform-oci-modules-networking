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
| [oci_network_load_balancer_backend.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/network_load_balancer_backend) | resource |
| [oci_network_load_balancer_backend_set.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/network_load_balancer_backend_set) | resource |
| [oci_network_load_balancer_listener.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/network_load_balancer_listener) | resource |
| [oci_network_load_balancer_network_load_balancer.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/network_load_balancer_network_load_balancer) | resource |
| [oci_core_private_ips.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/core_private_ips) | data source |
| [oci_core_public_ip.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/core_public_ip) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartments_dependency"></a> [compartments\_dependency](#input\_compartments\_dependency) | A map of objects containing the externally managed compartments this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute (representing the compartment OCID) of string type. | <pre>map(object({<br>    id = string # the compartment OCID<br>  }))</pre> | `null` | no |
| <a name="input_enable_output"></a> [enable\_output](#input\_enable\_output) | Whether Terraform should enable the module output. | `bool` | `true` | no |
| <a name="input_instances_dependency"></a> [instances\_dependency](#input\_instances\_dependency) | A map of objects containing the externally managed Compute instances this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute (representing the instance OCID) of string type. | <pre>map(object({<br>    id = string # the instance OCID<br>    private_ip = optional(string) # the instance or VNIC private IP address<br>  }))</pre> | `null` | no |
| <a name="input_module_name"></a> [module\_name](#input\_module\_name) | The module name. | `string` | `"network-load-balancer"` | no |
| <a name="input_network_dependency"></a> [network\_dependency](#input\_network\_dependency) | An object containing the externally managed network resources this module may depend on. Supported resources are 'subnets' and 'network\_security\_groups', represented as map of objects. Each object, when defined, must have an 'id' attribute of string type set with the subnet OCID or network security group OCID. | <pre>object({<br>    subnets = optional(map(object({<br>      id = string # the subnet OCID<br>    })))<br>    network_security_groups = optional(map(object({<br>      id = string # the network security group OCID<br>    })))<br>  })</pre> | `null` | no |
| <a name="input_nlb_configuration"></a> [nlb\_configuration](#input\_nlb\_configuration) | n/a | <pre>object({<br>    default_compartment_id  = optional(string)<br>    default_subnet_id       = optional(string)<br>    default_defined_tags    = optional(map(string))<br>    default_freeform_tags   = optional(map(string))<br>    nlbs = optional(map(object({<br>      compartment_id = optional(string)<br>      display_name   = string<br>      is_private     = bool # Whether the NLB has a virtual cloud network-local (private) IP address.<br>      subnet_id      = optional(string)<br>      network_security_group_ids = optional(list(string))<br>      reserved_ips = optional(list(object({ # List of objects representing a reserved IP address to be attached or that is already attached to a network load balancer. <br>        id = optional(string) # OCID of the reserved public IP address created with the VCN.<br>      })))<br>      skip_source_dest_check = optional(bool)<br>      listeners = map(object({<br>        name         = optional(string)<br>        port         = number<br>        protocol     = string<br>        ip_version   = optional(string)<br>        backend_set  = object({<br>          name       = string<br>          policy     = optional(string)<br>          health_checker = object({<br>            protocol = string # The protocol the health check must use. Valid values: "HTTP", "HTTPS", "UDP", "TCP".<br>            interval_in_millis = optional(number) # The interval between health checks, in milliseconds. The default value is 10000 (10 seconds)<br>            port = optional(number) # The backend server port against which to run the health check. If the port is not specified, then the network load balancer uses the port information from the Backend object.<br>            request_data = optional(string) # Base64 encoded pattern to be sent as UDP or TCP health check probe.<br>            response_body_regex = optional(string) # A regular expression for parsing the response body from the backend server. Example: ^((?!false).|\s)*$<br>            response_data = optional(string) # Base64 encoded pattern to be validated as UDP or TCP health check probe response.<br>            retries = optional(number) # The number of retries to attempt before a backend server is considered "unhealthy". This number also applies when recovering a server to the "healthy" state. The default value is 3.<br>            return_code = optional(number) # The status code a healthy backend server should return. If you configure the health check policy to use the HTTP protocol, then you can use common HTTP status codes such as "200".<br>            timeout_in_millis = optional(number) # The maximum time, in milliseconds, to wait for a reply to a health check. A health check is successful only if a reply returns within this timeout period. The default value is 3000 (3 seconds)<br>            url_path = optional(string) # The path against which to run the health check. Default is "/" Example: "/healthcheck"<br>          })<br>          ip_version = optional(string)<br>          backends = map(object({<br>            name       = string<br>            port       = number<br>            weight     = optional(number)<br>            ip_address = optional(string)<br>            is_backup  = optional(bool)<br>            is_drain   = optional(bool)<br>            is_offline = optional(bool)<br>            target_id  = optional(string) # The IP OCID/Instance OCID associated with the backend server<br>          }))<br>        })<br>      }))<br>      defined_tags = optional(map(string))<br>      freeform_tags = optional(map(string))<br>    })))<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nlb_backend_sets"></a> [nlb\_backend\_sets](#output\_nlb\_backend\_sets) | The NLB backend sets. |
| <a name="output_nlb_backends"></a> [nlb\_backends](#output\_nlb\_backends) | The NLB backends. |
| <a name="output_nlb_listeners"></a> [nlb\_listeners](#output\_nlb\_listeners) | The NLB listeners. |
| <a name="output_nlbs"></a> [nlbs](#output\_nlbs) | The Network Load Balancers (NLBs). |
| <a name="output_nlbs_primary_private_ips"></a> [nlbs\_primary\_private\_ips](#output\_nlbs\_primary\_private\_ips) | The NLBs primary private IP addresses. |
| <a name="output_nlbs_public_ips"></a> [nlbs\_public\_ips](#output\_nlbs\_public\_ips) | The NLBs public IP addresses. |
