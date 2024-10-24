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

  ### data source list of security attributes in tenancy
  secattr_list = length(data.oci_security_attribute_security_attributes.these) > 0 ? flatten([
    for k, v in data.oci_security_attribute_security_attributes.these : [
      for i in v.security_attributes : {
        namespace = i.security_attribute_namespace_name
        attr_name = i.name
      }
    ]
  ]) : []
  secattr_list_by_name = [ for i in local.secattr_list : "${i.namespace}.${i.attr_name}" ]

  vcn_secattr_name_list = local.vcn_security_attrs != null ? {
    for vcn_secattr in flatten([
      for k, v in local.vcn_security_attrs : [
        {
          names = v.zpr_attributes != null ? [
            for a in v.zpr_attributes :
              "${a.namespace}.${a.attr_name}"
          ] : []
          secattr_list_key = k
        }
      ]
    ]) : vcn_secattr.secattr_list_key => vcn_secattr
  } : null

  ### used to generate list of missing security attribute names
  missing_secattrs = local.vcn_secattr_name_list != null ? {
    for missing in flatten([
      for k, v in local.vcn_secattr_name_list : [
      {
        missing_ns_attr_names = v.names != null ? [
            join(", ", [for a in setsubtract(toset(v.names), (toset(local.secattr_list_by_name))) : format("\"%s\"", a)])
        ] : []
        secattrs_key = k
        }
      ]
    ]) : missing.secattrs_key => missing
  } : null
}