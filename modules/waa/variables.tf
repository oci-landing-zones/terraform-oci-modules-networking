# ###################################################################################################### #
# Copyright (c) 2024 Oracle and/or its affiliates, All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl. #
# ###################################################################################################### #

variable "waa_configuration" {
  description = "Web application acceleration (WAA) configuration settings for the WAA and the WAA policies."
  type = object({
    default_compartment_id     = optional(string),
    default_defined_tags       = optional(map(string)),
    default_freeform_tags      = optional(map(string)),

    web_app_accelerations = map(object({
      compartment_id                           = optional(string)
      display_name                             = optional(string)
      defined_tags                             = optional(map(string))
      freeform_tags                            = optional(map(string))
      load_balancer_id                         = string
      backend_type                             = string
      is_response_header_based_caching_enabled = optional(bool)
      gzip_compression_is_enabled              = optional(bool)
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
