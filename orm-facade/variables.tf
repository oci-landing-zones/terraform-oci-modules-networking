# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {
  type    = string
  default = null
}
variable "user_ocid" {
  type    = string
  default = null
}
variable "fingerprint" {
  type    = string
  default = null
}
variable "private_key_path" {
  type    = string
  default = null
}
variable "private_key_password" {
  type    = string
  default = null
}

variable "region" {
  type    = string
  default = null
}

variable "input_config_file_url" {
  type        = string
  default     = null
  description = "URL that points to the JSON OR YAML configuration file."
}

variable "default_compartment_ocid" {
  type        = string
  default     = null
  description = "The compartment that will be used by default by all the networking resources if no specific network resource or category compartments are defined."
}