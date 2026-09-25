# Network Completion Module Specification

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |

## Providers

| Name | Version |
|------|---------|
| oci | n/a |

## Resources

| Name | Type |
|------|------|
| route-table-partition.oci_core_route_table.custom | resource |
| route-table-partition.oci_core_default_route_table.default | resource |
| oci_core_route_table_attachment.these | resource |

## Interface

Inputs are intentionally separated into five custom route-table partitions, five
customized default-route-table partitions, default route-table IDs, attachment intents,
and target maps for internet gateways, NAT gateways, service gateways, DRGs, LPGs,
managed private IPs, OCI Network Firewalls, and external/NLB private IPs.

Outputs expose each of the ten route-table partitions separately plus the completed
route-table attachment map. The networking root module aliases these outputs back to
its existing compatibility locals. Five static calls to the shared
`route-table-partition` worker preserve the dependency boundaries required to avoid
gateway/route-table graph cycles while keeping the resource implementation in one
place.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_drga_route_tables"></a> [drga\_route\_tables](#module\_drga\_route\_tables) | ./modules/route-table-partition | n/a |
| <a name="module_igw_natgw_route_tables"></a> [igw\_natgw\_route\_tables](#module\_igw\_natgw\_route\_tables) | ./modules/route-table-partition | n/a |
| <a name="module_lpg_route_tables"></a> [lpg\_route\_tables](#module\_lpg\_route\_tables) | ./modules/route-table-partition | n/a |
| <a name="module_remaining_route_tables"></a> [remaining\_route\_tables](#module\_remaining\_route\_tables) | ./modules/route-table-partition | n/a |
| <a name="module_sgw_route_tables"></a> [sgw\_route\_tables](#module\_sgw\_route\_tables) | ./modules/route-table-partition | n/a |

## Resources

| Name | Type |
|------|------|
| [oci_core_route_table_attachment.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_route_table_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartments_dependency"></a> [compartments\_dependency](#input\_compartments\_dependency) | Compartments that route tables may reference by key. | <pre>map(object({<br/>    id = string<br/>  }))</pre> | `{}` | no |
| <a name="input_default_route_table_ids_by_vcn"></a> [default\_route\_table\_ids\_by\_vcn](#input\_default\_route\_table\_ids\_by\_vcn) | Default route table OCIDs keyed by VCN key. | `map(string)` | `{}` | no |
| <a name="input_drga_specific_default_route_tables"></a> [drga\_specific\_default\_route\_tables](#input\_drga\_specific\_default\_route\_tables) | Default route tables that can be attached to DRG attachments. | `any` | `{}` | no |
| <a name="input_drga_specific_route_tables"></a> [drga\_specific\_route\_tables](#input\_drga\_specific\_route\_tables) | Custom route tables that can be attached to DRG attachments. | `any` | `{}` | no |
| <a name="input_dynamic_gateway_targets"></a> [dynamic\_gateway\_targets](#input\_dynamic\_gateway\_targets) | Dynamic routing gateway route-rule targets. | <pre>map(object({<br/>    id = string<br/>  }))</pre> | `{}` | no |
| <a name="input_external_private_ip_targets"></a> [external\_private\_ip\_targets](#input\_external\_private\_ip\_targets) | Externally managed private IP route-rule targets, including VM and NLB firewall targets. | <pre>map(object({<br/>    id = string<br/>  }))</pre> | `{}` | no |
| <a name="input_igw_natgw_specific_default_route_tables"></a> [igw\_natgw\_specific\_default\_route\_tables](#input\_igw\_natgw\_specific\_default\_route\_tables) | Default route tables that can be attached to internet and NAT gateways. | `any` | `{}` | no |
| <a name="input_igw_natgw_specific_route_tables"></a> [igw\_natgw\_specific\_route\_tables](#input\_igw\_natgw\_specific\_route\_tables) | Custom route tables that can be attached to internet and NAT gateways. | `any` | `{}` | no |
| <a name="input_internet_gateway_targets"></a> [internet\_gateway\_targets](#input\_internet\_gateway\_targets) | Internet gateway route-rule targets. | <pre>map(object({<br/>    id = string<br/>  }))</pre> | `{}` | no |
| <a name="input_local_peering_gateway_targets"></a> [local\_peering\_gateway\_targets](#input\_local\_peering\_gateway\_targets) | Local peering gateway route-rule targets. | <pre>map(object({<br/>    id = string<br/>  }))</pre> | `{}` | no |
| <a name="input_lpg_specific_default_route_tables"></a> [lpg\_specific\_default\_route\_tables](#input\_lpg\_specific\_default\_route\_tables) | Default route tables that can be attached to local peering gateways. | `any` | `{}` | no |
| <a name="input_lpg_specific_route_tables"></a> [lpg\_specific\_route\_tables](#input\_lpg\_specific\_route\_tables) | Custom route tables that can be attached to local peering gateways. | `any` | `{}` | no |
| <a name="input_managed_private_ip_targets"></a> [managed\_private\_ip\_targets](#input\_managed\_private\_ip\_targets) | Private IP route-rule targets managed by the networking root module. | <pre>map(object({<br/>    id = string<br/>  }))</pre> | `{}` | no |
| <a name="input_module_tag"></a> [module\_tag](#input\_module\_tag) | Freeform tags added by the networking module. | `map(string)` | `{}` | no |
| <a name="input_nat_gateway_targets"></a> [nat\_gateway\_targets](#input\_nat\_gateway\_targets) | NAT gateway route-rule targets. | <pre>map(object({<br/>    id = string<br/>  }))</pre> | `{}` | no |
| <a name="input_network_firewall_private_ip_targets"></a> [network\_firewall\_private\_ip\_targets](#input\_network\_firewall\_private\_ip\_targets) | OCI Network Firewall private IP route-rule targets managed by the networking root module. | <pre>map(object({<br/>    id = string<br/>  }))</pre> | `{}` | no |
| <a name="input_non_gw_specific_remaining_default_route_tables"></a> [non\_gw\_specific\_remaining\_default\_route\_tables](#input\_non\_gw\_specific\_remaining\_default\_route\_tables) | Default route tables that are attachable only to subnets. | `any` | `{}` | no |
| <a name="input_non_gw_specific_remaining_route_tables"></a> [non\_gw\_specific\_remaining\_route\_tables](#input\_non\_gw\_specific\_remaining\_route\_tables) | Custom route tables that are attachable only to subnets. | `any` | `{}` | no |
| <a name="input_route_table_attachments"></a> [route\_table\_attachments](#input\_route\_table\_attachments) | Final subnet route-table associations, keyed by the stable subnet key. | <pre>map(object({<br/>    default_route_table_id         = string<br/>    network_configuration_category = string<br/>    route_table_id                 = optional(string)<br/>    route_table_key                = optional(string)<br/>    subnet_id                      = string<br/>    subnet_name                    = optional(string)<br/>    vcn_key                        = string<br/>    vcn_name                       = string<br/>  }))</pre> | `{}` | no |
| <a name="input_service_gateway_targets"></a> [service\_gateway\_targets](#input\_service\_gateway\_targets) | Service gateway route-rule targets. | <pre>map(object({<br/>    id = string<br/>  }))</pre> | `{}` | no |
| <a name="input_sgw_specific_default_route_tables"></a> [sgw\_specific\_default\_route\_tables](#input\_sgw\_specific\_default\_route\_tables) | Default route tables that can be attached to service gateways. | `any` | `{}` | no |
| <a name="input_sgw_specific_route_tables"></a> [sgw\_specific\_route\_tables](#input\_sgw\_specific\_route\_tables) | Custom route tables that can be attached to service gateways. | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_provisioned_drga_specific_default_route_tables"></a> [provisioned\_drga\_specific\_default\_route\_tables](#output\_provisioned\_drga\_specific\_default\_route\_tables) | Provisioned default route tables that can be assigned to DRG attachments. |
| <a name="output_provisioned_drga_specific_route_tables"></a> [provisioned\_drga\_specific\_route\_tables](#output\_provisioned\_drga\_specific\_route\_tables) | Provisioned route tables that can be assigned to DRG attachments. |
| <a name="output_provisioned_igw_natgw_specific_default_route_tables"></a> [provisioned\_igw\_natgw\_specific\_default\_route\_tables](#output\_provisioned\_igw\_natgw\_specific\_default\_route\_tables) | Provisioned default route tables that can be assigned to internet and NAT gateways. |
| <a name="output_provisioned_igw_natgw_specific_route_tables"></a> [provisioned\_igw\_natgw\_specific\_route\_tables](#output\_provisioned\_igw\_natgw\_specific\_route\_tables) | Provisioned route tables that can be assigned to internet and NAT gateways. |
| <a name="output_provisioned_lpg_specific_default_route_tables"></a> [provisioned\_lpg\_specific\_default\_route\_tables](#output\_provisioned\_lpg\_specific\_default\_route\_tables) | Provisioned default route tables that can be assigned to local peering gateways. |
| <a name="output_provisioned_lpg_specific_route_tables"></a> [provisioned\_lpg\_specific\_route\_tables](#output\_provisioned\_lpg\_specific\_route\_tables) | Provisioned route tables that can be assigned to local peering gateways. |
| <a name="output_provisioned_non_gw_specific_remaining_default_route_tables"></a> [provisioned\_non\_gw\_specific\_remaining\_default\_route\_tables](#output\_provisioned\_non\_gw\_specific\_remaining\_default\_route\_tables) | Provisioned default route tables that can be assigned only to subnets. |
| <a name="output_provisioned_non_gw_specific_remaining_route_tables"></a> [provisioned\_non\_gw\_specific\_remaining\_route\_tables](#output\_provisioned\_non\_gw\_specific\_remaining\_route\_tables) | Provisioned route tables that can be assigned only to subnets. |
| <a name="output_provisioned_route_tables_attachments"></a> [provisioned\_route\_tables\_attachments](#output\_provisioned\_route\_tables\_attachments) | Provisioned subnet route-table attachments. |
| <a name="output_provisioned_sgw_specific_default_route_tables"></a> [provisioned\_sgw\_specific\_default\_route\_tables](#output\_provisioned\_sgw\_specific\_default\_route\_tables) | Provisioned default route tables that can be assigned to service gateways. |
| <a name="output_provisioned_sgw_specific_route_tables"></a> [provisioned\_sgw\_specific\_route\_tables](#output\_provisioned\_sgw\_specific\_route\_tables) | Provisioned route tables that can be assigned to service gateways. |
<!-- END_TF_DOCS -->
