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
| [oci_waf_web_app_firewall.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/waf_web_app_firewall) | resource |
| [oci_waf_web_app_firewall_policy.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/waf_web_app_firewall_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartments_dependency"></a> [compartments\_dependency](#input\_compartments\_dependency) | A map of objects containing the externally managed compartments this module may depend on. All map objects must have the same type and must contain an 'id' attribute of string type set with the compartment OCID. See External Dependencies section in README.md (https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking#ext-dep) for details. | <pre>map(object({<br>    id = string<br>  }))</pre> | `null` | no |
| <a name="input_waf_configuration"></a> [waf\_configuration](#input\_waf\_configuration) | Web Application Firewall (WAF) configuration settings for the WAF and related WAF policies. | <pre>object({<br>    default_compartment_id     = optional(string),<br>    default_defined_tags       = optional(map(string)),<br>    default_freeform_tags      = optional(map(string)),<br><br>    waf = map(object({<br>      display_name            = optional(string)<br>      defined_tags            = optional(map(string))<br>      defined_tags            = optional(map(string))<br>      freeform_tags           = optional(map(string))<br>      backend_type            = string<br>      compartment_id          = optional(string)<br>      load_balancer_id        = string<br>      waf_policy_display_name = optional(string)<br>      actions = optional(map(object({<br>        name = string<br>        type = string<br>        body = optional(object({<br>          text = string<br>          type = string<br>        }))<br>        code = optional(string)<br>        headers = optional(object({<br>          name  = string<br>          value = string<br>        }))<br>      })))<br>    }))<br>  })</pre> | n/a | yes |

## Outputs

No outputs.
