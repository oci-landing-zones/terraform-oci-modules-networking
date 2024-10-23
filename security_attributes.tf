data "oci_security_attribute_security_attribute_namespaces" "these" {
  compartment_id            = var.tenancy_ocid
  compartment_id_in_subtree = true

  filter {
    name   = "state"
    values = ["ACTIVE"]
  }
}

data "oci_security_attribute_security_attributes" "these" {
  for_each = length(data.oci_security_attribute_security_attribute_namespaces.these) > 0 ? {
  for i in data.oci_security_attribute_security_attribute_namespaces.these.security_attribute_namespaces : i.id => i.name } : {}
  security_attribute_namespace_id = each.key
  filter {
    name   = "state"
    values = ["ACTIVE"]
  }
}

locals {
  vcn_security_attrs = local.one_dimension_processed_vcns != null ? {
    for flat_security in flatten([
      for vcn_key, vcn_value in local.one_dimension_processed_vcns : [
        {
          zpr_attributes = vcn_value.security != null ? vcn_value.security.zpr_attributes != null ? [
            for zattr in vcn_value.security.zpr_attributes : {
              namespace  = zattr.namespace
              attr_name  = zattr.attr_name
              attr_value = zattr.attr_value
              mode       = zattr.mode
          }] : [] : []
          security_attr_key = vcn_key
        }
      ]
    ]) : flat_security.security_attr_key => flat_security
  } : null

  secattr_list = length(data.oci_security_attribute_security_attributes.these) > 0 ? flatten([
    for k, v in data.oci_security_attribute_security_attributes.these : [
      for i in v.security_attributes : {
        key       = i.security_attribute_namespace_name
        namespace = i.security_attribute_namespace_name
        attr_name = i.name
      }
    ]
  ]) : []
  secattr_list_by_name = { for i in local.secattr_list : "${i.key}.${i.attr_name}" => { namepace = i.namespace, attr_name = i.attr_name } }
}