# Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "nlb_configuration" {
  type = object({
    default_compartment_id  = optional(string)
    default_subnet_id       = optional(string)
    default_defined_tags    = optional(map(string))
    default_freeform_tags   = optional(map(string))
    nlbs = optional(map(object({
      compartment_id = optional(string)
      display_name   = string
      is_private     = bool # Whether the NLB has a virtual cloud network-local (private) IP address.
      subnet_id      = optional(string)
      network_security_group_ids = optional(list(string))
      reserved_ips = optional(list(object({ # List of objects representing a reserved IP address to be attached or that is already attached to a network load balancer. 
        id = optional(string) # OCID of the reserved public IP address created with the VCN.
      })))
      skip_source_dest_check = optional(bool)
      listeners = map(object({
        name         = optional(string)
        port         = number
        protocol     = string
        ip_version   = optional(string)
        backend_set  = object({
          name       = string
          policy     = optional(string)
          health_checker = object({
            protocol = string # The protocol the health check must use. Valid values: "HTTP", "HTTPS", "UDP", "TCP".
            interval_in_millis = optional(number) # The interval between health checks, in milliseconds. The default value is 10000 (10 seconds)
            port = optional(number) # The backend server port against which to run the health check. If the port is not specified, then the network load balancer uses the port information from the Backend object.
            request_data = optional(string) # Base64 encoded pattern to be sent as UDP or TCP health check probe.
            response_body_regex = optional(string) # A regular expression for parsing the response body from the backend server. Example: ^((?!false).|\s)*$
            response_data = optional(string) # Base64 encoded pattern to be validated as UDP or TCP health check probe response.
            retries = optional(number) # The number of retries to attempt before a backend server is considered "unhealthy". This number also applies when recovering a server to the "healthy" state. The default value is 3.
            return_code = optional(number) # The status code a healthy backend server should return. If you configure the health check policy to use the HTTP protocol, then you can use common HTTP status codes such as "200".
            timeout_in_millis = optional(number) # The maximum time, in milliseconds, to wait for a reply to a health check. A health check is successful only if a reply returns within this timeout period. The default value is 3000 (3 seconds)
            url_path = optional(string) # The path against which to run the health check. Default is "/" Example: "/healthcheck"
          })
          ip_version = optional(string)
          backends = map(object({
            name       = string
            port       = number
            weight     = optional(number)
            ip_address = optional(string)
            is_backup  = optional(bool)
            is_drain   = optional(bool)
            is_offline = optional(bool)
            target_id  = optional(string) # The IP OCID/Instance OCID associated with the backend server
          }))
        })
      }))
      defined_tags = optional(map(string))
      freeform_tags = optional(map(string))
    })))
  })
}

variable "enable_output" {
  description = "Whether Terraform should enable the module output."
  type        = bool
  default     = true
}

variable "module_name" {
  description = "The module name."
  type        = string
  default     = "network-load-balancer"
}

variable compartments_dependency {
  description = "A map of objects containing the externally managed compartments this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute (representing the compartment OCID) of string type." 
  type = map(object({
    id = string # the compartment OCID
  }))
  default = null
}

variable network_dependency {
  description = "An object containing the externally managed network resources this module may depend on. Supported resources are 'subnets' and 'network_security_groups', represented as map of objects. Each object, when defined, must have an 'id' attribute of string type set with the subnet OCID or network security group OCID."
  type = object({
    subnets = optional(map(object({
      id = string # the subnet OCID
    })))
    network_security_groups = optional(map(object({
      id = string # the network security group OCID
    })))
  })
  default = null
}

variable instances_dependency {
  description = "A map of objects containing the externally managed Compute instances this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute (representing the instance OCID) of string type." 
  type = map(object({
    id = string # the instance OCID
    private_ip = optional(string) # the instance or VNIC private IP address
  }))
  default = null
}