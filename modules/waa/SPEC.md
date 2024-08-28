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
| [oci_waa_web_app_acceleration.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/waa_web_app_acceleration) | resource |
| [oci_waa_web_app_acceleration_policy.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/waa_web_app_acceleration_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartments_dependency"></a> [compartments\_dependency](#input\_compartments\_dependency) | A map of objects containing the externally managed compartments this module may depend on. All map objects must have the same type and must contain an 'id' attribute of string type set with the compartment OCID. See External Dependencies section in README.md (https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking#ext-dep) for details. | <pre>map(object({<br>    id = string<br>  }))</pre> | `null` | no |
| <a name="input_waa_configuration"></a> [waa\_configuration](#input\_waa\_configuration) | Web application acceleration (WAA) configuration settings for the WAA and the WAA policies. | <pre>object({<br>    default_compartment_id     = optional(string),<br>    default_defined_tags       = optional(map(string)),<br>    default_freeform_tags      = optional(map(string)),<br><br>    web_app_accelerations = map(object({<br>      compartment_id                           = optional(string)<br>      display_name                             = optional(string)<br>      defined_tags                             = optional(map(string))<br>      freeform_tags                            = optional(map(string))<br>      load_balancer_id                         = string<br>      backend_type                             = string<br>      is_response_header_based_caching_enabled = optional(bool)<br>      gzip_compression_is_enabled              = optional(bool)<br>    }))<br>  })</pre> | n/a | yes |

## Outputs

No outputs.
