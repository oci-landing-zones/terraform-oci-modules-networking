locals {
  network_configuration = local.network_configuration_from_input_json_yaml_file != null ? {
    default_compartment_id           = contains(keys(local.network_configuration_from_input_json_yaml_file), "default_compartment_id") ? local.network_configuration_from_input_json_yaml_file.default_compartment_id != null ? local.network_configuration_from_input_json_yaml_file.default_compartment_id : var.default_compartment_ocid != null ? var.default_compartment_ocid : var.tenancy_ocid : var.default_compartment_ocid != null ? var.default_compartment_ocid : var.tenancy_ocid
    default_defined_tags             = contains(keys(local.network_configuration_from_input_json_yaml_file), "default_defined_tags") ? local.network_configuration_from_input_json_yaml_file.default_defined_tags : null
    default_freeform_tags            = contains(keys(local.network_configuration_from_input_json_yaml_file), "default_freeform_tags") ? local.network_configuration_from_input_json_yaml_file.default_freeform_tags : null
    default_enable_cis_checks        = contains(keys(local.network_configuration_from_input_json_yaml_file), "default_enable_cis_checks") ? local.network_configuration_from_input_json_yaml_file.default_enable_cis_checks : null
    default_ssh_ports_to_check       = contains(keys(local.network_configuration_from_input_json_yaml_file), "default_ssh_ports_to_check") ? local.network_configuration_from_input_json_yaml_file.default_ssh_ports_to_check : null
    network_configuration_categories = contains(keys(local.network_configuration_from_input_json_yaml_file), "network_configuration_categories") ? local.network_configuration_from_input_json_yaml_file.network_configuration_categories : null
  } : null
}

module "terraform-oci-cis-landing-zone-networking" {
  source = "../"
  network_configuration = local.network_configuration
}