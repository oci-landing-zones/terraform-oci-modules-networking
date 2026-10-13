variable "compartments_dependency" {
  description = "Compartments that route tables may reference by key."
  type = map(object({
    id = string
  }))
  default = {}
}

variable "custom_route_tables" {
  description = "Custom route tables assigned to this dependency partition."
  type        = any
  default     = {}
}

variable "default_route_tables" {
  description = "Customized VCN default route tables assigned to this dependency partition."
  type        = any
  default     = {}
}

variable "default_route_table_ids_by_vcn" {
  description = "Default route table OCIDs keyed by VCN key."
  type        = map(string)
  default     = {}
}

variable "merge_module_tag" {
  description = "Whether to merge the networking module tag into this partition's resources."
  type        = bool
  default     = false
}

variable "module_tag" {
  description = "Freeform tags added by the networking module when merge_module_tag is true."
  type        = map(string)
  default     = {}
}

variable "route_rule_targets" {
  description = "Route-rule targets allowed for this dependency partition."
  type = map(object({
    id = string
  }))
  default = {}
}
