# ###################################################################################################### #
# Copyright (c) 2024 Oracle and/or its affiliates, All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl. #
# ###################################################################################################### #

variable "waf_configuration" {
  description = "Web Application Firewall (WAF) configuration settings for the WAF and related WAF policies."
  type = object({
    default_compartment_id     = optional(string),
    default_defined_tags       = optional(map(string)),
    default_freeform_tags      = optional(map(string)),

    waf = map(object({
      display_name            = optional(string)
      defined_tags            = optional(map(string))
      freeform_tags           = optional(map(string))
      backend_type            = string
      compartment_id          = optional(string)
      load_balancer_id        = string
      waf_policy_display_name = optional(string)
      actions = optional(map(object({
        name = string
        type = string
        body = optional(object({
          text = string
          type = string
        }))
        code = optional(string)
        headers = optional(object({
          name  = string
          value = string
        }))
      })))
    }))
  })
}

variable "compartments_dependency" {
  description = "A map of objects containing the externally managed compartments this module may depend on. All map objects must have the same type and must contain an 'id' attribute of string type set with the compartment OCID. See External Dependencies section in README.md (https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking#ext-dep) for details."
  type = map(object({
    id = string
  }))
  default = null
}
