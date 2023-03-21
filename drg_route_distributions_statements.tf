locals {
  one_dimension_processed_drg_route_distributions_statements = local.one_dimension_processed_drg_route_distributions != null ? length(local.one_dimension_processed_drg_route_distributions) > 0 ? {
    for flat_drgrdssts in flatten([
      for drgrd_key, drgrd_value in local.one_dimension_processed_drg_route_distributions :
      drgrd_value.statements != null ? length(drgrd_value.statements) > 0 ? [
        for drgrdsts_key, drgrdsts_value in drgrd_value.statements : {
          drg_route_distribution_id      = oci_core_drg_route_distribution.these[drgrd_key].id
          drg_id                         = drgrd_value.drg_id
          drg_name                       = drgrd_value.drg_name
          drg_key                        = drgrd_value.drg_key
          drg_route_distribution_key     = drgrd_key
          drg_route_distribution_name    = oci_core_drg_route_distribution.these[drgrd_key].display_name
          drg_route_distribution_id      = oci_core_drg_route_distribution.these[drgrd_key].id
          network_configuration_category = drgrd_value.network_configuration_category
          action                         = drgrdsts_value.action
          priority                       = drgrdsts_value.priority
          match_criteria                 = drgrdsts_value.match_criteria
          drgrdsts_key                   = drgrdsts_key
        }
      ] : [] : []
    ]) : flat_drgrdssts.drgrdsts_key => flat_drgrdssts
  } : null : null

  provisioned_drg_route_distributions_statements = {
    for drgrdsts_key, drgrdsts_value in oci_core_drg_route_distribution_statement.these : drgrdsts_key => {
      id                             = drgrdsts_value.id
      drgrdsts_key                   = drgrdsts_key
      drg_route_distribution_id      = local.one_dimension_processed_drg_route_distributions_statements[drgrdsts_key].drg_route_distribution_id
      drg_route_distribution_key     = local.one_dimension_processed_drg_route_distributions_statements[drgrdsts_key].drg_route_distribution_key
      drg_route_distribution_name    = local.one_dimension_processed_drg_route_distributions_statements[drgrdsts_key].drg_route_distribution_name
      action                         = drgrdsts_value.action
      match_criteria                 = drgrdsts_value.match_criteria
      priority                       = drgrdsts_value.priority
      drg_id                         = local.one_dimension_processed_drg_route_distributions_statements[drgrdsts_key].drg_id
      drg_name                       = local.one_dimension_processed_drg_route_distributions_statements[drgrdsts_key].drg_name
      drg_key                        = local.one_dimension_processed_drg_route_distributions_statements[drgrdsts_key].drg_key
      network_configuration_category = local.one_dimension_processed_drg_route_distributions_statements[drgrdsts_key].network_configuration_category
    }
  }
}

resource "oci_core_drg_route_distribution_statement" "these" {
  for_each = local.one_dimension_processed_drg_route_distributions_statements != null ? local.one_dimension_processed_drg_route_distributions_statements : {}
  #Required
  drg_route_distribution_id = each.value.drg_route_distribution_id
  action                    = each.value.action
  #Optional 
  priority = each.value.priority
  #Optional
  dynamic "match_criteria" {
    iterator = criteria
    for_each = each.value.match_criteria != null ? length(each.value.match_criteria) > 0 ? [
      for v, x in each.value.match_criteria : {
        match_type = x.match_type
        #Optional
        attachment_type   = x.attachment_type
        drg_attachment_id = x.drg_attachment_id
    }] : [] : []

    content {
      #Required
      match_type = criteria.value.match_type
      #Optional
      attachment_type   = criteria.value.attachment_type
      drg_attachment_id = criteria.value.drg_attachment_id
    }
  }
}