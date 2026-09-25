variable "compartments_dependency" {
  description = "Compartments that route tables may reference by key."
  type = map(object({
    id = string
  }))
  default = {}
}

variable "module_tag" {
  description = "Freeform tags added by the networking module."
  type        = map(string)
  default     = {}
}

variable "igw_natgw_specific_route_tables" {
  description = "Custom route tables that can be attached to internet and NAT gateways."
  type        = any
  default     = {}
}

variable "sgw_specific_route_tables" {
  description = "Custom route tables that can be attached to service gateways."
  type        = any
  default     = {}
}

variable "lpg_specific_route_tables" {
  description = "Custom route tables that can be attached to local peering gateways."
  type        = any
  default     = {}
}

variable "drga_specific_route_tables" {
  description = "Custom route tables that can be attached to DRG attachments."
  type        = any
  default     = {}
}

variable "non_gw_specific_remaining_route_tables" {
  description = "Custom route tables that are attachable only to subnets."
  type        = any
  default     = {}
}

variable "igw_natgw_specific_default_route_tables" {
  description = "Default route tables that can be attached to internet and NAT gateways."
  type        = any
  default     = {}
}

variable "sgw_specific_default_route_tables" {
  description = "Default route tables that can be attached to service gateways."
  type        = any
  default     = {}
}

variable "lpg_specific_default_route_tables" {
  description = "Default route tables that can be attached to local peering gateways."
  type        = any
  default     = {}
}

variable "drga_specific_default_route_tables" {
  description = "Default route tables that can be attached to DRG attachments."
  type        = any
  default     = {}
}

variable "non_gw_specific_remaining_default_route_tables" {
  description = "Default route tables that are attachable only to subnets."
  type        = any
  default     = {}
}

variable "default_route_table_ids_by_vcn" {
  description = "Default route table OCIDs keyed by VCN key."
  type        = map(string)
  default     = {}
}

variable "external_private_ip_targets" {
  description = "Externally managed private IP route-rule targets, including VM and NLB firewall targets."
  type = map(object({
    id = string
  }))
  default = {}
}

variable "managed_private_ip_targets" {
  description = "Private IP route-rule targets managed by the networking root module."
  type = map(object({
    id = string
  }))
  default = {}
}

variable "network_firewall_private_ip_targets" {
  description = "OCI Network Firewall private IP route-rule targets managed by the networking root module."
  type = map(object({
    id = string
  }))
  default = {}
}

variable "internet_gateway_targets" {
  description = "Internet gateway route-rule targets."
  type = map(object({
    id = string
  }))
  default = {}
}

variable "nat_gateway_targets" {
  description = "NAT gateway route-rule targets."
  type = map(object({
    id = string
  }))
  default = {}
}

variable "service_gateway_targets" {
  description = "Service gateway route-rule targets."
  type = map(object({
    id = string
  }))
  default = {}
}

variable "dynamic_gateway_targets" {
  description = "Dynamic routing gateway route-rule targets."
  type = map(object({
    id = string
  }))
  default = {}
}

variable "local_peering_gateway_targets" {
  description = "Local peering gateway route-rule targets."
  type = map(object({
    id = string
  }))
  default = {}
}

variable "route_table_attachments" {
  description = "Final subnet route-table associations, keyed by the stable subnet key."
  type = map(object({
    default_route_table_id         = string
    network_configuration_category = string
    route_table_id                 = optional(string)
    route_table_key                = optional(string)
    subnet_id                      = string
    subnet_name                    = optional(string)
    vcn_key                        = string
    vcn_name                       = string
  }))
  default = {}
}
